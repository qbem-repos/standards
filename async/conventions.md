# Convenções para Eventos, Filas e Streaming

Objetivo: garantir **consistência**, **confiabilidade** e **observabilidade**
em integrações assíncronas.

---

## 1) Nomes (tópicos/filas, eventos e schemas)

* **Domínio.recurso.ação** em `kebab-case`:

  * Evento: `billing.invoice.paid`
  * Tópico/fila: `billing-invoice-paid-v1`
* **Versão no nome do tópico** (`-v1`, `-v2`…) quando houver *breaking*.
* **Chaves de particionamento** previsíveis:

  * `partition_key = <aggregate_id>` (ex.: `user_id`, `order_id`).

✅ Exemplos:

```plain
topic: orders-order-created-v1
event.type: "orders.order.created"
partition_key: "ord_123"
```

---

## 2) Estrutura do evento (payload)

* **Envelope** mínimo (JSON ou Protobuf):

  * `event_id` (UUID v4)
  * `event_type` (ex.: `orders.order.created`)
  * `occurred_at` (ISO 8601, UTC)
  * `source` (serviço produtor)
  * `data` (objeto do domínio)
  * `metadata` (opcional: versão, schema, etc.)

```json
{
  "event_id": "f0b8f8d3-66b9-4a38-bd79-8f1d8c6a5f69",
  "event_type": "orders.order.created",
  "occurred_at": "2025-09-11T12:00:00Z",
  "source": "orders-service",
  "data": {
    "order_id": "ord_123",
    "user_id": "u_9",
    "total": { "currency": "BRL", "amount": 12990 }
  },
  "metadata": {
    "schema_version": "1.2.0"
  }
}
```

---

## 3) Headers padrão (mensageria)

Inclua via headers/attributes conforme o broker (Kafka, SQS/SNS, Pub/Sub, RabbitMQ):

* `trace_id` — correlação com logs/traces.
* `correlation_id` — encadeia uma saga/fluxo.
* `idempotency_key` — deduplicação no consumidor.
* `producer` — nome do serviço produtor.
* `schema_version` — versão do contrato do `data`.
* `tenant_id` — multitenant (quando aplicável).

Exemplo (Kafka headers):

```plain
trace_id=ab12cd34
correlation_id=saga-ord_123
schema_version=1.2.0
producer=orders-service
tenant_id=tn_1
```

> Detalhes em `headers.md`.

---

## 4) Entrega, ordenação e idempotência

* **Entrega**: *at-least-once* por padrão (assuma duplicatas).
* **Deduplicação** por `event_id` ou `idempotency_key` no consumidor.
* **Ordenação**: só garantida **por partição**. Use `partition_key`
correto (ex.: `order_id`).
* **Retries** com **backoff exponencial** e **DLQ** (Dead Letter Queue).
* **Time-out** de processamento definido (ex.: 30s).

Pseudocódigo de consumidor:

```pseudo
onMessage(msg):
  if cache.contains(msg.event_id): ack(); return
  try:
    process(msg.data)
    cache.put(msg.event_id, ttl=24h)
    ack()
  catch retriable:
    retryWithBackoff()
  catch fatal:
    sendToDLQ(msg)
```

---

## 5) Evolução de schema (compatibilidade)

* **Regra**: mudanças devem ser **compatíveis** (adicionar campos opcionais).
* *Breaking* → **novo tópico com versão** (`-v2`) e **novo `event_type` major**
(ex.: `orders.order.created.v2` opcional).
* Documente compat no `schema-evolution.md` e valide no CI (schema diff).

Compatível ✔️:

```json
"data": {
  "order_id": "ord_123",
  "coupon": { "code": "WELCOME10" }  // novo campo opcional
}
```

Breaking ❌ (exige `-v2`):

```json
// campo obrigatório novo OU mudança de tipo
"data": {
  "order_id": 123   // antes era string
}
```

---

## 6) Segurança

* **Criptografia em trânsito** (TLS) do broker/cliente.
* **Controle de acesso** por tópico (produzir/consumir).
* **Sanitização**: não publicar segredos/PII desnecessária.
* Assinatura/Verificação (quando sair da rede confiável):

  * Header `signature` (HMAC-SHA256) + `timestamp` para anti-replay.
* **TTL**/retenção de tópicos conforme necessidade de auditoria.

> Detalhes em `security.md`.

---

## 7) Observabilidade

* **Trace**: propagar `trace_id`/`span_id` (W3C traceparent se suportado).
* **Métricas** mínimas por consumidor/produtor:

  * `events_published_total`, `events_consumed_total`
  * `event_processing_latency_ms`
  * `event_processing_errors_total`
  * `retries_total`, `dlq_total`
* **Logs estruturados** com `event_id`, `event_type`, `trace_id`, `partition`, `offset`.

Exemplo de log:

```json
{
  "timestamp": "2025-09-11T12:00:01Z",
  "level": "INFO",
  "message": "order created processed",
  "event_type": "orders.order.created",
  "event_id": "f0b8f8d3-66b9-4a38-bd79-8f1d8c6a5f69",
  "trace_id": "ab12cd34",
  "partition": 7,
  "offset": 98231
}
```

---

## 8) Contratos (AsyncAPI/Protobuf)

* **AsyncAPI** recomendado para tópicos/eventos JSON.
* **Protobuf** recomendado para alto throughput/baixa latência.
* **CI obrigatório**:

  * Lint do contrato.
  * *Breaking check* (ex.: `buf breaking` para Protobuf).
  * Publicação do contrato (repositório de contratos).

Exemplo AsyncAPI (trecho):

```yaml
asyncapi: '3.0.0'
info:
  title: Orders Events
  version: '1.2.0'
channels:
  orders-order-created-v1:
    address: orders-order-created-v1
    messages:
      orderCreated:
        $ref: '#/components/messages/OrderCreated'
components:
  messages:
    OrderCreated:
      name: OrderCreated
      payload:
        type: object
        required: [order_id, occurred_at]
        properties:
          order_id: { type: string }
          occurred_at: { type: string, format: date-time }
          total:
            type: object
            properties:
              currency: { type: string }
              amount: { type: integer }
```

---

## 9) SLA de reprocessamento e DLQ

* **DLQ obrigatória** para consumidores críticos.
* Processo de **replay** documentado (janela de retenção, filtros por `event_type`).
* **Alerta** quando `dlq_total` > 0 ou `retries_total` acima de limiar.

---

## 10) Checklist para novos eventos

* [ ] Nome do **tópico** e `event_type` definidos (com versão se necessário).
* [ ] **Partition key** coerente (garante ordenação por agregado).
* [ ] Envelope com `event_id`, `occurred_at`, `source`.
* [ ] Headers: `trace_id`, `correlation_id`, `schema_version`, `tenant_id` (se aplicável).
* [ ] Contrato em **AsyncAPI/Protobuf** versionado e validado no CI.
* [ ] Consumidor idempotente + DLQ + retries com backoff.
* [ ] Métricas e logs estruturados implementados.
* [ ] Segurança: ACLs, TLS, sanitização de PII.
