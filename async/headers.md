# Headers Padrão (Eventos, Filas, Streaming)

Headers/atributos obrigatórios para **correlação, idempotência,
segurança e observabilidade**.
Quando o broker não suportar headers nativos, use campos no
**envelope** (ex.: `metadata`).

---

## 📌 Campos padrão

| Campo             | Tipo    | Obrigatório | Uso                          |
| ----------------- | ------- | ----------- | ---------------------------- |
| `trace_id`        | string  | ✅           | Correlaciona logs/traces  |
| `correlation_id`  | string  | ✅           | Encadeia uma saga/fluxo de negócio|
| `idempotency_key` | string  | ✅           | Deduplicação no consumidor   |
| `schema_version`  | semver  | ✅           | Versão do **payload/data**        |
| `producer`        | string  | ✅           | Serviço emissor (ex.: `orders-service`)|
| `tenant_id`       | string  | ⚠️          | Multi-tenant (se aplicável) |
| `signature`       | base64  | ⚠️          | HMAC-SHA256 para mensagens fora da rede confiável|
| `timestamp`       | ISO8601 | ⚠️          | Anti-replay com `signature`       |

> ⚠️ = obrigatório quando aplicável ao domínio/ambiente.

**Tamanho**: mantenha headers curtos (≤ 8 KB somados). Para blobs, use storage
externo + link.

---

## 🔗 W3C Trace Context

* Preferir header **`traceparent`** (e `tracestate`) quando suportado.
* Se não suportar, espelhar `trace_id` simples.

Exemplo `traceparent`:

```
traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
```

---

## 🧭 Mapeamento por Broker

### 1) Kafka

* **Headers nativos** (`record.headers()`).

Campos recomendados:

```
traceparent / trace_id
correlation_id
idempotency_key
schema_version
producer
tenant_id
signature (opcional)
timestamp (opcional)
```

**Producer (pseudocódigo):**

```pseudo
producer.send(
  topic="orders-order-created-v1",
  key=order_id,                 # garante ordenação por agregado
  value=json(payload),
  headers={
    "traceparent": traceparent,
    "correlation_id": saga_id,
    "idempotency_key": event_id,
    "schema_version": "1.2.0",
    "producer": "orders-service",
    "tenant_id": tenant_id
  }
)
```

**Consumer (pseudocódigo):**

```pseudo
onMessage(record):
  hdr = headers(record)
  trace = hdr.get("traceparent") or hdr.get("trace_id")
  with trace_scope(trace):
    if dedupe.exists(hdr["idempotency_key"]): commit(); return
    process(record.value)
    dedupe.put(hdr["idempotency_key"], ttl=24h)
    commit()
```

---

### 2) AWS SQS / SNS

* **SQS**: `MessageAttributes`
* **SNS**: `MessageAttributes` (propaga para SQS assinante)

**Envio (SNS/SQS):**

```json
"MessageAttributes": {
  "trace_id":        { "DataType": "String", "StringValue": "ab12cd34" },
  "correlation_id":  { "DataType": "String", "StringValue": "saga-ord_123" },
  "idempotency_key": { "DataType": "String", "StringValue": "f0b8f8..." },
  "schema_version":  { "DataType": "String", "StringValue": "1.2.0" },
  "producer":        { "DataType": "String", "StringValue": "orders-service" },
  "tenant_id":       { "DataType": "String", "StringValue": "tn_1" }
}
```

**Observações:**

* Limite por atributo: \~256 KB (mas mantenha pequeno).
* Para **FIFO/SQS**: usar `MessageGroupId = <aggregate_id>` para ordenação por
grupo; `MessageDeduplicationId = idempotency_key`.

---

### 3) Google Pub/Sub

* **Attributes** (string key/value).

**Publish:**

```python
future = publisher.publish(
  topic_path,
  data=json_bytes,
  trace_id="ab12cd34",
  correlation_id="saga-ord_123",
  idempotency_key="f0b8f8...",
  schema_version="1.2.0",
  producer="orders-service",
  tenant_id="tn_1"
)
```

**Notas:**

* Atributos são strings; serialize valores complexos no payload.
* Ordering keys: `ordering_key = <aggregate_id>` para habilitar ordenação por chave.

---

### 4) RabbitMQ

* **Headers** dentro de `BasicProperties.headers`.
* Use **`message_id`** para `idempotency_key` quando fizer sentido.
* **Exchange** + `routing_key` → defina consistente com `event_type`.

**Publish (pseudocódigo):**

```pseudo
channel.basic_publish(
  exchange="orders",
  routing_key="order.created.v1",
  body=json(payload),
  properties={
    message_id: event_id,
    headers: {
      "trace_id": trace_id,
      "correlation_id": saga_id,
      "schema_version": "1.2.0",
      "producer": "orders-service",
      "tenant_id": tenant_id
    }
  }
)
```

---

## Assinatura (opcional, fora de rede confiável)

* Header `signature` = `base64(HMAC_SHA256(secret, timestamp + body))`
* Header `timestamp` = ISO 8601 (UTC).
* **Validação**:

  1. Rejeite se `now - timestamp > 5m` (anti-replay).
  2. Compare assinatura em **tempo constante**.
  3. Dedup com `idempotency_key`.

---

## ♻️ Idempotência (consumidor)

* Use `idempotency_key` ou `event_id` (se for parte do envelope).
* **TTL recomendado**: 24h (ajuste por domínio).
* Armazene hash de **chave + tipo** (`idempotency_key:event_type`) para evitar colisão.

---

## Testes mínimos

* Mensagem publicada contém **todos** headers obrigatórios.
* Consumidor ignora duplicatas (simule reentrega).
* `trace_id`/`traceparent` aparece em logs e traces da cadeia inteira.
* `schema_version` está em métricas para observabilidade (ex.: contagem por versão).

---

## Checklist por broker

**Kafka**

* [ ] `key` = aggregate\_id (ordenação por partição)
* [ ] Headers padrão incluídos
* [ ] Retenção/compaction conforme caso de uso

**SQS/SNS**

* [ ] `MessageGroupId` (FIFO) e `MessageDeduplicationId` configurados
* [ ] `MessageAttributes` com campos padrão

**Pub/Sub**

* [ ] `ordering_key` quando ordenação for necessária
* [ ] Atributos com campos padrão

**RabbitMQ**

* [ ] `exchange`/`routing_key` consistentes com `event_type`
* [ ] `message_id` usado para idempotência (ou header dedicado)

---

Se quiser, eu preparo também o **`schema-evolution.md`** agora
(regras de evolução compatível, matriz de compat forward/backward e
como versionar `-v2`).
