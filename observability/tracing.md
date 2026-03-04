# Distributed Tracing

Padrões para rastreamento de requisições em sistemas distribuídos usando OpenTelemetry.

---

## 1) Conceitos Fundamentais

### O que é Distributed Tracing?

**Distributed Tracing** permite rastrear uma requisição através de múltiplos serviços, fornecendo visibilidade completa do fluxo de execução.

```
Client Request
    │
    ├─► Service A (span_a)
    │       ├─► Database (span_db)
    │       └─► Cache (span_cache)
    │
    └─► Service B (span_b)
            ├─► Service C (span_c)
            │       └─► External API (span_ext)
            └─► Queue (span_queue)
```

### Terminologia

| Termo | Descrição | Exemplo |
|-------|-----------|---------|
| **Trace** | Jornada completa de uma requisição | Todo o fluxo de criação de um pedido |
| **Span** | Unidade de trabalho dentro de um trace | Chamada HTTP, query DB, processamento |
| **Trace ID** | Identificador único do trace | `abc123def456` |
| **Span ID** | Identificador único do span | `span789xyz` |
| **Parent Span ID** | ID do span pai | `parent456` |
| **Context** | Informações propagadas entre serviços | Headers HTTP, metadata de mensagens |

---

## 2) W3C Trace Context

**Obrigatório:** Use o padrão [W3C Trace Context](https://www.w3.org/TR/trace-context/) para propagação.

### Header `traceparent`

**Formato:**
```
traceparent: 00-<trace-id>-<parent-id>-<trace-flags>
```

**Exemplo:**
```
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
```

**Componentes:**
- `00` — Versão do protocolo
- `0af7651916cd43dd8448eb211c80319c` — Trace ID (32 hex chars)
- `b7ad6b7169203331` — Parent Span ID (16 hex chars)
- `01` — Trace flags (sampled=1, not-sampled=0)

### Header `tracestate`

Usado para informações vendor-specific:
```
tracestate: vendor1=value1,vendor2=value2
```

**Regra:** Sempre propague `traceparent` e `tracestate` em chamadas downstream.

---

## 3) Estrutura de Span

### Campos Obrigatórios

```json
{
  "trace_id": "0af7651916cd43dd8448eb211c80319c",
  "span_id": "b7ad6b7169203331",
  "parent_span_id": "00f067aa0ba902b7",
  "name": "POST /v1/orders",
  "kind": "SERVER",
  "start_time": "2025-01-10T14:30:00.000Z",
  "end_time": "2025-01-10T14:30:00.123Z",
  "status": {
    "code": "OK",
    "message": ""
  },
  "attributes": {
    "http.method": "POST",
    "http.url": "/v1/orders",
    "http.status_code": 201,
    "service.name": "order-service",
    "service.version": "1.2.3"
  }
}
```

### Tipos de Span (Span Kind)

| Kind | Uso | Exemplo |
|------|-----|---------|
| **SERVER** | Recebe requisição | HTTP server, gRPC server |
| **CLIENT** | Faz requisição externa | HTTP client, gRPC client |
| **PRODUCER** | Produz mensagem | Kafka producer, SQS send |
| **CONSUMER** | Consome mensagem | Kafka consumer, SQS receive |
| **INTERNAL** | Operação interna | Função, método, processamento |

### Status do Span

```typescript
{
  "status": {
    "code": "OK" | "ERROR" | "UNSET",
    "message": "Optional error message"
  }
}
```

**Regras:**
- `OK` — Operação bem-sucedida
- `ERROR` — Operação falhou (sempre adicione `message`)
- `UNSET` — Status desconhecido (default)

---

## 4) Atributos Semânticos

Use [Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/) do OpenTelemetry.

### HTTP (Server)

```json
{
  "attributes": {
    "http.method": "POST",
    "http.url": "https://api.qbem.net.br/v1/orders",
    "http.target": "/v1/orders",
    "http.host": "api.qbem.net.br",
    "http.scheme": "https",
    "http.status_code": 201,
    "http.user_agent": "axios/1.4.0",
    "http.request_content_length": 1024,
    "http.response_content_length": 256
  }
}
```

### HTTP (Client)

```json
{
  "attributes": {
    "http.method": "GET",
    "http.url": "https://payment-gateway.com/api/charge",
    "http.status_code": 200,
    "net.peer.name": "payment-gateway.com",
    "net.peer.port": 443
  }
}
```

### Database

```json
{
  "attributes": {
    "db.system": "postgresql",
    "db.name": "orders_db",
    "db.statement": "SELECT * FROM orders WHERE user_id = $1",
    "db.operation": "SELECT",
    "db.user": "app_user",
    "net.peer.name": "db.qbem.net.br",
    "net.peer.port": 5432
  }
}
```

### Mensageria (Kafka)

```json
{
  "attributes": {
    "messaging.system": "kafka",
    "messaging.destination": "orders-order-created-v1",
    "messaging.destination_kind": "topic",
    "messaging.operation": "publish",
    "messaging.message_id": "evt_123",
    "messaging.kafka.partition": 3,
    "messaging.kafka.offset": 98765
  }
}
```

### gRPC

```json
{
  "attributes": {
    "rpc.system": "grpc",
    "rpc.service": "OrderService",
    "rpc.method": "CreateOrder",
    "rpc.grpc.status_code": 0,
    "net.peer.name": "order-service.qbem.net.br",
    "net.peer.port": 50051
  }
}
```

---

## 5) Propagação de Contexto

### HTTP Headers

**Requisição:**
```http
POST /v1/orders HTTP/1.1
Host: api.qbem.net.br
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
tracestate: vendor=value
Content-Type: application/json
```

**Resposta:**
```http
HTTP/1.1 201 Created
traceparent: 00-0af7651916cd43dd8448eb211c80319c-c9ad8b8179304442-01
```

### Mensageria (Kafka)

**Headers de Mensagem:**
```json
{
  "headers": {
    "traceparent": "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01",
    "tracestate": "vendor=value"
  },
  "key": "order_123",
  "value": {
    "event_type": "orders.order.created",
    "order_id": "ord_999"
  }
}
```

### gRPC Metadata

```
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
tracestate: vendor=value
```

**Regra:** Sempre injete contexto ao fazer chamadas downstream.

---

## 6) Sampling

**Por que fazer sampling?**
- Reduz custo de armazenamento
- Diminui overhead de performance
- Mantém representatividade estatística

### Estratégias de Sampling

| Estratégia | Descrição | Uso |
|------------|-----------|-----|
| **Always On** | 100% de traces | Development, staging |
| **Always Off** | 0% de traces | Desabilitar temporariamente |
| **Probabilistic** | % fixo (ex: 10%) | Produção com tráfego moderado |
| **Rate Limiting** | N traces/segundo | Produção com tráfego alto |
| **Parent-based** | Respeita decisão do pai | Microserviços (padrão) |
| **Tail-based** | Decide após trace completo | Samplear apenas erros |

### Recomendações

| Ambiente | Sampling | Motivo |
|----------|----------|--------|
| Development | 100% | Debug completo |
| Staging | 100% | Validação de integração |
| Production (low traffic) | 10-50% | Balance custo/visibilidade |
| Production (high traffic) | 1-5% | Reduzir custo |
| Production (errors) | 100% | Tail-based sampling |

### Exemplo de Configuração

```yaml
# Head-based sampling (decisão no início)
sampler:
  type: probabilistic
  param: 0.1  # 10%

# Tail-based sampling (decisão no fim)
processors:
  tail_sampling:
    policies:
      - name: error-traces
        type: status_code
        status_code:
          status_codes: [ERROR]
      - name: slow-traces
        type: latency
        latency:
          threshold_ms: 1000
      - name: random-sample
        type: probabilistic
        probabilistic:
          sampling_percentage: 1
```

---

## 7) Span Events e Links

### Span Events

Eventos marcam momentos específicos dentro de um span:

```json
{
  "span_id": "abc123",
  "events": [
    {
      "name": "cache_miss",
      "timestamp": "2025-01-10T14:30:00.050Z",
      "attributes": {
        "cache.key": "user:123",
        "cache.ttl": 300
      }
    },
    {
      "name": "retry_attempt",
      "timestamp": "2025-01-10T14:30:00.100Z",
      "attributes": {
        "retry.attempt": 2,
        "retry.max_attempts": 3
      }
    }
  ]
}
```

**Quando usar:**
- Marcos importantes (cache miss, retry, circuit breaker)
- Não crie span separado para operações instantâneas

### Span Links

Links conectam spans de diferentes traces:

```json
{
  "span_id": "def456",
  "links": [
    {
      "trace_id": "xyz789",
      "span_id": "parent123",
      "attributes": {
        "link.type": "follows_from"
      }
    }
  ]
}
```

**Casos de uso:**
- Batch processing (um job processa múltiplas requisições)
- Fan-out/fan-in (uma requisição gera múltiplas sub-tarefas)

---

## 8) Integração com Logs

**Sempre correlacione logs com traces!**

### Formato de Log com Trace

```json
{
  "timestamp": "2025-01-10T14:30:00.123Z",
  "level": "INFO",
  "message": "Order created successfully",
  "service": "order-service",
  "trace_id": "0af7651916cd43dd8448eb211c80319c",
  "span_id": "b7ad6b7169203331",
  "context": {
    "order_id": "ord_999",
    "user_id": "u_789"
  }
}
```

**Benefício:** Clicar em um log leva ao trace completo no Jaeger/Tempo.

---

## 9) Boas Práticas

### ✅ Faça

1. **Use instrumentação automática quando possível**
   - Menos código para manter
   - Cobertura padrão garantida

2. **Propague contexto em TODAS chamadas**
   - HTTP, gRPC, mensageria, DB (via comentários SQL)

3. **Adicione atributos relevantes**
   - `user_id`, `tenant_id`, `order_id` (contexto de negócio)

4. **Use span events para marcos importantes**
   - Cache miss, retry, circuit breaker

5. **Configure sampling apropriado**
   - Produção: 1-10%
   - Sempre samplear traces com erro

6. **Correlacione logs com traces**
   - Adicione `trace_id` e `span_id` em todos os logs

7. **Use semantic conventions**
   - Padrões do OpenTelemetry

### ❌ Evite

1. **Criar spans demais**
   - Overhead de performance
   - Poluição visual

2. **Logar PII em atributos**
   - Senhas, tokens, dados sensíveis

3. **Esquecer de propagar contexto**
   - Quebra a cadeia de traces

4. **100% sampling em produção alto tráfego**
   - Custo proibitivo

5. **Ignorar exceptions**
   - Sempre marque span com erro e adicione details

6. **Atributos com alta cardinalidade**
   - `timestamp`, `trace_id` como atributo (redundante)

### Span Naming

❌ **Ruim:**
```
"function_1"
"process"
"handle_request_1641825600"  # Timestamp no nome
```

✅ **Bom:**
```
"POST /v1/orders"
"process_payment"
"db.query.orders.select"
"kafka.publish.orders-events"
```

**Regra:** Nome deve ser genérico e reutilizável (baixa cardinalidade).

---

## 10) Visualização

### Jaeger UI

**Trace completo:**
```
Trace: 0af7651916cd43dd8448eb211c80319c
Duration: 245ms
Services: 3

├─ POST /v1/orders [order-service] [123ms]
│  ├─ process_payment [payment-service] [45ms]
│  │  └─ http.client.charge [payment-gateway] [40ms]
│  ├─ db.query.insert [order-service] [12ms]
│  └─ kafka.publish [order-service] [8ms]
```

**Filtros úteis:**
- Service: `order-service`
- Operation: `POST /v1/orders`
- Tags: `http.status_code=500`
- Min Duration: `> 1s`
- Max Duration: `< 100ms`

### Grafana Tempo

**Integração com Loki (logs):**

```
[Log] ERROR: Payment failed for order_123
      trace_id: 0af7651916cd43dd8448eb211c80319c
      
      [Click to view trace] → Abre Tempo
      
[Trace] 0af7651916cd43dd8448eb211c80319c
        └─ payment_service: Gateway timeout
```

---

## 11) Troubleshooting

### Trace não aparece no backend

**Checklist:**
- [ ] Sampling está habilitado? (não é AlwaysOff)
- [ ] Exporter configurado corretamente?
- [ ] OTEL Collector/Backend acessível? (network, firewall)
- [ ] Span sendo exportado? (verificar logs do SDK)

### Contexto não está propagando

**Checklist:**
- [ ] Header `traceparent` presente na requisição?
- [ ] Propagator configurado? (W3C Trace Context)
- [ ] Middleware de propagação habilitado?
- [ ] Biblioteca suporta auto-instrumentation?

### Performance degradada

**Soluções:**
- Reduzir sampling (de 100% para 10%)
- Usar BatchSpanProcessor (não SimpleSpanProcessor)
- Reduzir número de atributos customizados
- Desabilitar stack traces em spans

---

## 12) Bibliotecas Recomendadas

### Python
- **opentelemetry-api** — API do OpenTelemetry
- **opentelemetry-sdk** — SDK de instrumentação
- **opentelemetry-instrumentation-fastapi** — Auto-instrumentation FastAPI
- **opentelemetry-instrumentation-requests** — Auto-instrumentation requests

### C# (.NET)
- **OpenTelemetry** — SDK principal
- **OpenTelemetry.Instrumentation.AspNetCore** — Auto-instrumentation ASP.NET Core
- **OpenTelemetry.Instrumentation.Http** — Auto-instrumentation HttpClient
- **OpenTelemetry.Instrumentation.SqlClient** — Auto-instrumentation SQL

### Node.js
- **@opentelemetry/api** — API core
- **@opentelemetry/sdk-node** — SDK Node.js
- **@opentelemetry/auto-instrumentations-node** — Auto-instrumentation bundle

### Java
- **opentelemetry-api** — API Java
- **opentelemetry-sdk** — SDK Java
- **opentelemetry-javaagent** — Auto-instrumentation via agent

**Configurações detalhadas:** Ver `tooling/observability/`

---

## 13) Checklist

Antes de ir para produção:

- [ ] Instrumentação automática configurada (HTTP, DB, mensageria)
- [ ] Propagação de contexto implementada (W3C Trace Context)
- [ ] Sampling configurado (1-10% em produção)
- [ ] Atributos semânticos seguindo OpenTelemetry conventions
- [ ] Logs correlacionados com traces (trace_id, span_id)
- [ ] Exceptions sendo capturadas em spans (record_exception)
- [ ] Backend configurado (Jaeger, Tempo, ou SaaS)
- [ ] Dashboards criados para análise de traces
- [ ] PII não está sendo logada em atributos
- [ ] Teste de ponta-a-ponta (trace completo visível)

---

## 14) Ferramentas Recomendadas

### Backends Open Source
- **Jaeger** — UI excelente, suporta OpenTelemetry
- **Grafana Tempo** — Integração com Loki/Prometheus, cost-effective
- **Zipkin** — Alternativa mais simples ao Jaeger

### SaaS
- **Honeycomb** — Análise avançada, high-cardinality queries
- **Datadog APM** — Full-stack observability
- **New Relic** — APM tradicional com tracing
- **Lightstep** — Foco em distributed tracing

### Collectors
- **OTEL Collector** — Pipeline padrão para processar/exportar traces
- **Jaeger Agent** — Collector específico do Jaeger

---

## Referências

- [OpenTelemetry Tracing Specification](https://opentelemetry.io/docs/specs/otel/trace/)
- [W3C Trace Context](https://www.w3.org/TR/trace-context/)
- [OpenTelemetry Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/)
- [OpenTelemetry Python Docs](https://opentelemetry-python.readthedocs.io/)
- [OpenTelemetry .NET Docs](https://opentelemetry.io/docs/languages/net/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Grafana Tempo](https://grafana.com/docs/tempo/)