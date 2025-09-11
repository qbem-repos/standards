# Confiabilidade em Mensageria (Reliability)

Objetivo: garantir **processamento robusto**, mesmo sob falhas, picos de carga ou duplicações.

---

## 1) Entrega e Semântica
- Padrão: **at-least-once** (pode haver duplicatas → consumidores devem ser idempotentes).
- Se necessário **at-most-once** (permissivo a perda) → documentar no contrato.
- **Exactly-once** só quando broker + storage suportarem nativamente (ex.: Kafka + transactional writes).

---

## 2) Retries
- Sempre usar **retries com backoff exponencial** (ex.: 1s, 2s, 4s, máx 1min).
- Limite de tentativas (ex.: 5).
- Após limite, mensagem vai para **DLQ** (Dead Letter Queue).

---

## 3) Dead Letter Queue (DLQ)
- DLQ obrigatória para consumidores críticos.
- Nome padrão: `<topic>-dlq`.
- Mensagem na DLQ deve conter:
  - `event_id`
  - `event_type`
  - `failed_at` (timestamp)
  - `retries`
  - `last_error`
- Processar DLQ com ferramenta dedicada (replay manual ou automático).

---

## 4) Idempotência
- Consumidores **devem** descartar duplicatas usando:
  - `event_id` ou `idempotency_key`.
  - TTL (ex.: 24h).
- Estratégias:
  - Cache in-memory + persistência em banco rápido (Redis).
  - Dedup table (`event_id`, `processed_at`).

---

## 5) Timeouts e Circuit Breaker
- Defina **timeout de processamento** por mensagem (ex.: 30s).
- Se serviço downstream falhar:
  - **Retry** com backoff.
  - **Circuit breaker** para evitar avalanche.

---

## 6) Ordenação
- Garantida apenas por **partition_key** → escolha consistente (ex.: `order_id`).
- Eventos independentes não devem depender de ordem global.

---

## 7) Monitoramento & Alertas
- Métricas obrigatórias:
  - `events_published_total`
  - `events_consumed_total`
  - `event_processing_latency_ms`
  - `event_processing_errors_total`
  - `retries_total`
  - `dlq_total`
- Alertas:
  - `dlq_total > 0`
  - `retry rate > X%`
  - Latência acima de SLA.

---

## 8) Checklist
- [ ] Consumidor idempotente.
- [ ] Retries com backoff + DLQ.
- [ ] Métricas e logs implementados.
- [ ] Monitoramento de retries e DLQ.
- [ ] Timeout + circuit breaker configurados.
