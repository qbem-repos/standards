# Métricas

Padrões para métricas de monitoramento de serviços e infraestrutura.

---

## 1) Metodologias

### RED Method (Requisições)

Para serviços que atendem requisições (APIs, gRPC):

- **Rate** — Requisições por segundo
- **Errors** — Taxa de erro (%)
- **Duration** — Latência (percentis p50, p95, p99)

### USE Method (Recursos)

Para recursos de infraestrutura (CPU, memória, disco):

- **Utilization** — % de uso do recurso
- **Saturation** — Fila de trabalho aguardando
- **Errors** — Contagem de erros

---

## 2) Tipos de Métricas

### Counter

Valor que **só aumenta** (resets em restart).

**Uso:** Contadores de requisições, erros, eventos.

```prometheus
# Total de requisições HTTP
http_requests_total{method="GET", status="200"} 1234
http_requests_total{method="POST", status="201"} 567
```

**Convenção:** Sufixo `_total`.

### Gauge

Valor que pode **subir e descer**.

**Uso:** Valores instantâneos (memória, conexões ativas, temperatura).

```prometheus
# Conexões ativas no pool
db_connections_active{database="postgres"} 42
```

### Histogram

Distribui observações em **buckets** predefinidos.

**Uso:** Latência, tamanho de payload.

```prometheus
# Latência de requisições HTTP
http_request_duration_seconds_bucket{le="0.1"} 100
http_request_duration_seconds_bucket{le="0.5"} 250
http_request_duration_seconds_bucket{le="1.0"} 300
http_request_duration_seconds_bucket{le="+Inf"} 320
http_request_duration_seconds_sum 150.5
http_request_duration_seconds_count 320
```

**Benefício:** Permite calcular percentis no Prometheus.

### Summary

Similar ao histogram, mas calcula **percentis no cliente**.

**Uso:** Quando não pode definir buckets antecipadamente.

```prometheus
http_request_duration_seconds{quantile="0.5"} 0.12
http_request_duration_seconds{quantile="0.95"} 0.45
http_request_duration_seconds{quantile="0.99"} 0.78
http_request_duration_seconds_sum 150.5
http_request_duration_seconds_count 320
```

**⚠️ Trade-off:** Não pode agregar percentis entre instâncias.

---

## 3) Convenções de Nomenclatura

### Formato Padrão

```
<namespace>_<subsystem>_<name>_<unit>_<suffix>
```

**Exemplos:**
```
http_requests_total
http_request_duration_seconds
db_connections_active
cache_hits_total
job_processing_duration_seconds
```

### Regras

1. **snake_case** (não camelCase)
2. **Unidades no nome:** `_seconds`, `_bytes`, `_ratio`
3. **Sufixos padronizados:**
   - `_total` — Counters
   - `_count` — Contagem (histogram)
   - `_sum` — Soma (histogram)
   - `_bucket` — Bucket (histogram)

### Namespaces Recomendados

| Namespace | Uso | Exemplos |
|-----------|-----|----------|
| `http_` | Requisições HTTP | `http_requests_total` |
| `grpc_` | Chamadas gRPC | `grpc_server_handled_total` |
| `db_` | Database | `db_query_duration_seconds` |
| `cache_` | Cache | `cache_hits_total`, `cache_misses_total` |
| `job_` | Background jobs | `job_processing_duration_seconds` |
| `queue_` | Filas | `queue_depth`, `queue_messages_total` |

---

## 4) Labels/Tags

### Labels Obrigatórios

```prometheus
# Sempre incluir
service="order-service"
environment="production"
version="1.2.3"
```

### Labels Comuns

#### HTTP APIs

```prometheus
http_requests_total{
  service="order-service",
  environment="production",
  method="POST",
  path="/v1/orders",
  status_code="201"
}
```

#### gRPC

```prometheus
grpc_server_handled_total{
  service="order-service",
  grpc_service="OrderService",
  grpc_method="CreateOrder",
  grpc_code="OK"
}
```

#### Background Jobs

```prometheus
job_processing_duration_seconds{
  service="worker-service",
  job_type="send-email",
  status="success"
}
```

#### Database

```prometheus
db_query_duration_seconds{
  service="order-service",
  database="postgres",
  operation="SELECT"
}
```

### ⚠️ Cardinalidade

**Problema:** Muitos valores únicos explodem o número de time series.

❌ **Evite labels com alta cardinalidade:**
```prometheus
# Ruim - user_id tem milhões de valores
http_requests_total{user_id="u_123456"}

# Ruim - timestamp é único
http_requests_total{timestamp="2025-01-10T14:30:00Z"}
```

✅ **Use labels com baixa cardinalidade:**
```prometheus
# Bom - poucos valores possíveis
http_requests_total{method="POST", status_code="200"}
```

**Regra:** Máximo 10-20 valores únicos por label.

---

## 5) Métricas Obrigatórias

### HTTP APIs

#### RED Metrics

```prometheus
# Rate (requisições por segundo)
http_requests_total{method, path, status_code}

# Errors (taxa de erro)
http_requests_total{status_code=~"5.."}

# Duration (latência)
http_request_duration_seconds{method, path}
```

#### Exemplo Completo

```prometheus
# Counter - Total de requisições
http_requests_total{
  service="order-service",
  environment="production",
  method="POST",
  path="/v1/orders",
  status_code="201"
} 1234

# Histogram - Duração de requisições
http_request_duration_seconds_bucket{
  service="order-service",
  method="POST",
  path="/v1/orders",
  le="0.1"
} 950

# Gauge - Requisições em andamento
http_requests_in_progress{
  service="order-service",
  method="POST",
  path="/v1/orders"
} 5
```

### gRPC

```prometheus
# Total de chamadas
grpc_server_handled_total{
  service,
  grpc_service,
  grpc_method,
  grpc_code
}

# Duração
grpc_server_handling_seconds{
  service,
  grpc_service,
  grpc_method
}

# Mensagens enviadas/recebidas
grpc_server_msg_received_total{service, grpc_service, grpc_method}
grpc_server_msg_sent_total{service, grpc_service, grpc_method}
```

### Background Jobs

```prometheus
# Jobs processados
job_processed_total{service, job_type, status}

# Duração de processamento
job_processing_duration_seconds{service, job_type}

# Tamanho da fila
job_queue_depth{service, queue_name}

# Dead Letter Queue
job_dlq_total{service, queue_name}
```

### Database

```prometheus
# Queries executadas
db_queries_total{service, database, operation}

# Duração de queries
db_query_duration_seconds{service, database, operation}

# Conexões no pool
db_connections_active{service, database}
db_connections_idle{service, database}
db_connections_max{service, database}

# Erros
db_errors_total{service, database, error_type}
```

### Cache

```prometheus
# Hits e misses
cache_hits_total{service, cache_name}
cache_misses_total{service, cache_name}

# Hit ratio
cache_hit_ratio = cache_hits_total / (cache_hits_total + cache_misses_total)

# Itens no cache
cache_items{service, cache_name}

# Tamanho em bytes
cache_size_bytes{service, cache_name}

# Latência
cache_operation_duration_seconds{service, cache_name, operation}
```

### Mensageria (Kafka, SQS, etc)

```prometheus
# Mensagens produzidas
messages_produced_total{service, topic}

# Mensagens consumidas
messages_consumed_total{service, topic, consumer_group}

# Lag de consumo
consumer_lag{service, topic, partition, consumer_group}

# Erros
message_processing_errors_total{service, topic}
```

---

## 6) Latência e Percentis

### Buckets Recomendados

Para latência de APIs (segundos):

```prometheus
buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]
```

**Justificativa:**
- `0.005` (5ms) — Muito rápido
- `0.1` (100ms) — Rápido
- `0.5` (500ms) — SLO típico
- `1` (1s) — Lento
- `10` (10s) — Muito lento

### Cálculo de Percentis

**PromQL:**

```promql
# p50 (mediana)
histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))

# p95
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# p99
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
```

### Por que Percentis?

❌ **Média esconde problemas:**
```
Requisições: 100ms, 100ms, 100ms, 5000ms
Média: 1325ms (parece ruim)
p95: 5000ms (mostra o problema real)
```

✅ **Percentis revelam outliers:**
- **p50:** 50% dos usuários têm esta latência ou menos
- **p95:** 95% dos usuários têm esta latência ou menos (alvo típico de SLO)
- **p99:** 99% dos usuários (para serviços críticos)

---

## 7) Cardinalidade e Performance

### Problema da Explosão de Cardinalidade

**Cada combinação única de labels = 1 time series**

```prometheus
# 3 methods × 50 paths × 10 status codes = 1.500 time series
http_requests_total{method, path, status_code}

# 3 methods × 10.000 user_ids × 10 status = 300.000 time series ⚠️
http_requests_total{method, user_id, status_code}
```

**Impacto:**
- Alto uso de memória no Prometheus
- Queries lentas
- Custo elevado em SaaS

### Soluções

1. **Agrupe labels de alta cardinalidade**
   ```prometheus
   # Ruim: path="/users/123"
   # Bom: path="/users/:id"
   ```

2. **Use recording rules**
   ```yaml
   # Pré-calcular métricas agregadas
   - record: job:http_requests:rate5m
     expr: sum(rate(http_requests_total[5m])) by (job)
   ```

3. **Limite valores de labels**
   ```
   # Agrupe status codes
   status="2xx", "4xx", "5xx" (não 200, 201, 204...)
   ```

4. **Use sampling para labels específicos**
   ```
   # Logar user_id apenas para 1% das requisições
   ```

---

## 8) Exposição de Métricas

### Endpoint `/metrics`

**Padrão:** Expor métricas em `/metrics` no formato Prometheus.

```http
GET /metrics HTTP/1.1
Host: api.qbem.net.br

# Resposta
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",path="/v1/orders",status_code="200"} 1234
http_requests_total{method="POST",path="/v1/orders",status_code="201"} 567

# HELP http_request_duration_seconds HTTP request duration
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{method="GET",path="/v1/orders",le="0.1"} 950
http_request_duration_seconds_bucket{method="GET",path="/v1/orders",le="0.5"} 1180
http_request_duration_seconds_bucket{method="GET",path="/v1/orders",le="+Inf"} 1234
http_request_duration_seconds_sum{method="GET",path="/v1/orders"} 98.5
http_request_duration_seconds_count{method="GET",path="/v1/orders"} 1234
```

### Segurança

**⚠️ Métricas podem expor informações sensíveis!**

❌ **Evite:**
- Credenciais em labels
- PII (user_id, email)
- Dados de negócio sensíveis

✅ **Proteja o endpoint:**
```yaml
# Kubernetes - annotation para scraping interno apenas
apiVersion: v1
kind: Service
metadata:
  name: my-service-metrics
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
spec:
  type: ClusterIP  # Não exposto externamente
  ports:
    - port: 9090
      name: metrics
```

---

## 9) Queries Úteis (PromQL)

### Taxa de Requisições (QPS)

```promql
# QPS total
sum(rate(http_requests_total[5m]))

# QPS por serviço
sum(rate(http_requests_total[5m])) by (service)

# QPS por endpoint
sum(rate(http_requests_total[5m])) by (service, path)
```

### Taxa de Erro

```promql
# Error rate (%)
(
  sum(rate(http_requests_total{status_code=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
) * 100

# Error rate por serviço
sum(rate(http_requests_total{status_code=~"5.."}[5m])) by (service)
/
sum(rate(http_requests_total[5m])) by (service)
```

### Latência (Percentis)

```promql
# p95 latency
histogram_quantile(0.95, 
  rate(http_request_duration_seconds_bucket[5m])
)

# p95 por serviço
histogram_quantile(0.95, 
  sum(rate(http_request_duration_seconds_bucket[5m])) by (service, le)
)
```

### Uso de CPU/Memória

```promql
# CPU usage (%)
(1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)) * 100

# Memory usage (%)
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

---

## 10) Bibliotecas Recomendadas

### Python
- **prometheus-client** — Cliente oficial Prometheus
- **opentelemetry-api** — OpenTelemetry (padrão moderno)

### C# (.NET)
- **prometheus-net** — Cliente Prometheus para .NET
- **OpenTelemetry.Instrumentation.AspNetCore** — OpenTelemetry para ASP.NET Core

### Node.js
- **prom-client** — Cliente Prometheus
- **@opentelemetry/api** — OpenTelemetry

### Java
- **micrometer** — Abstração de métricas (suporta Prometheus)
- **OpenTelemetry Java** — SDK completo

**Configurações detalhadas:** Ver `tooling/observability/`

---

## 11) Checklist

Antes de ir para produção:

- [ ] Métricas RED implementadas (rate, errors, duration)
- [ ] Labels obrigatórios presentes (service, environment, version)
- [ ] Cardinalidade controlada (< 10k time series por serviço)
- [ ] Endpoint `/metrics` exposto e protegido
- [ ] Buckets de histogram apropriados
- [ ] Nomenclatura seguindo convenções (snake_case, unidades)
- [ ] Métricas de negócio identificadas e instrumentadas
- [ ] Recording rules para queries pesadas
- [ ] Teste de scraping (Prometheus consegue coletar)
- [ ] Alertas configurados em métricas críticas

---

## 12) Ferramentas Recomendadas

### Collection & Storage
- **Prometheus** — Padrão de mercado, open-source
- **VictoriaMetrics** — Alternativa mais performática
- **Thanos** — Prometheus de longa duração
- **Cortex** — Prometheus multi-tenant

### Visualização
- **Grafana** — Dashboards e alertas
- **Prometheus UI** — Query explorer básico

### SaaS
- **Datadog** — Full-stack observability
- **New Relic** — APM com métricas
- **Grafana Cloud** — Hosted Prometheus + Grafana

---

## Referências

- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Prometheus Naming Conventions](https://prometheus.io/docs/practices/naming/)
- [RED Method](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
- [USE Method](https://www.brendangregg.com/usemethod.html)
- [Google SRE - Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
- [OpenTelemetry Metrics](https://opentelemetry.io/docs/specs/otel/metrics/)