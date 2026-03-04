# Dashboards

Padrões para visualização eficaz de métricas e saúde de sistemas distribuídos.

---

## 1) Princípios de Design

### Menos é Mais

❌ **Ruim:** Dashboard com 50 gráficos, ninguém sabe onde olhar
✅ **Bom:** Dashboard focado com 5-10 gráficos críticos

**Regra:** Se você não olha para um gráfico há 30 dias, remova-o.

### Hierarquia de Informação

```
Overview (Empresa)
    ↓
Service-Level (Serviço específico)
    ↓
Resource-Level (Recurso: DB, Cache, Queue)
```

**Drill-down:** Começar com visão geral, depois detalhar.

### Contexto é Essencial

Todo gráfico deve responder:
- 📊 **O quê?** — Qual métrica está sendo mostrada
- 🎯 **Por quê?** — Por que essa métrica importa
- ✅ **Bom/Ruim?** — Qual é o valor esperado (threshold, SLO)

---

## 2) Metodologias

### RED Method (Request-Driven)

Para serviços que recebem requisições (APIs, gRPC):

| Métrica | Descrição | Query Exemplo |
|---------|-----------|---------------|
| **R**ate | Requisições por segundo | `rate(http_requests_total[5m])` |
| **E**rrors | Taxa de erro | `rate(http_requests_total{status=~"5.."}[5m])` |
| **D**uration | Latência (p50, p95, p99) | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` |

### USE Method (Resource-Driven)

Para recursos (CPU, memória, disco, rede):

| Métrica | Descrição | Query Exemplo |
|---------|-----------|---------------|
| **U**tilization | % de uso | `1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))` |
| **S**aturation | Fila/espera | `node_load1 / count(node_cpu_seconds_total{mode="idle"})` |
| **E**rrors | Taxa de erro | `rate(node_disk_io_errors_total[5m])` |

### Four Golden Signals (Google SRE)

1. **Latency** — Tempo de resposta
2. **Traffic** — Volume de requisições
3. **Errors** — Taxa de falhas
4. **Saturation** — Uso de recursos

---

## 3) Estrutura de Dashboards

### Nível 1: Overview (Empresa)

**Propósito:** Visão geral de todos os serviços.

**Audiência:** Executivos, gerentes, on-call.

**Painéis:**
- Status de todos os serviços (UP/DOWN)
- SLO compliance por serviço
- Alertas ativos (critical, high)
- Error budget restante
- Tráfego total (RPS)

**Exemplo de layout:**
```
+----------------------------------+----------------------------------+
|  Services Status                 |  Active Alerts                   |
|  ✅ order-service    99.95%      |  🔴 payment-service: HighLatency |
|  ✅ payment-service  99.90%      |  🟡 cart-service: CPUHigh        |
|  ✅ user-service     99.99%      |                                  |
+----------------------------------+----------------------------------+
|  Total Traffic (RPS)                                                |
|  📈 [Gráfico de linha: últimas 24h]                                 |
+---------------------------------------------------------------------+
|  Error Rate (%)                  |  SLO Compliance                  |
|  📊 [Gráfico de área]            |  📊 [Gauge charts]               |
+----------------------------------+----------------------------------+
```

### Nível 2: Service-Level

**Propósito:** Detalhar um serviço específico.

**Audiência:** Engenheiros, SREs, DevOps.

**Painéis (RED):**
1. Request Rate (RPS)
2. Error Rate (%)
3. Latency (p50, p95, p99)
4. Apdex Score
5. Request Duration Histogram
6. Top Endpoints (por latência/erro)

**Exemplo de layout:**
```
+---------------------------------------------------------------------+
|  Service: order-service                          Status: ✅ Healthy |
+----------------------------------+----------------------------------+
|  Request Rate (RPS)              |  Error Rate (%)                  |
|  📈 [linha: 5m, 1h, 24h]         |  📊 [área: threshold em 1%]      |
+----------------------------------+----------------------------------+
|  Latency Percentiles (ms)                                           |
|  📈 [linhas: p50, p95, p99 com thresholds]                          |
+---------------------------------------------------------------------+
|  Request Duration Distribution   |  Top Slow Endpoints              |
|  📊 [heatmap]                    |  📋 [tabela]                     |
+----------------------------------+----------------------------------+
|  Dependencies Health                                                |
|  📊 [status: DB ✅, Cache ✅, Payment API ⚠️]                       |
+---------------------------------------------------------------------+
```

### Nível 3: Resource-Level

**Propósito:** Detalhar um recurso específico (DB, cache, queue).

**Audiência:** DBAs, engenheiros de infra.

**Painéis (USE):**
1. Utilization (CPU, memória, disco)
2. Saturation (load, queue depth)
3. Errors (falhas de I/O, timeouts)
4. Throughput (queries/s, ops/s)
5. Connection pool usage

---

## 4) Dashboards Obrigatórios

### 4.1) HTTP API Dashboard (RED)

**Painéis:**

#### 1. Request Rate
```promql
# Total RPS
sum(rate(http_requests_total{service="order-service"}[5m]))

# RPS por endpoint
sum(rate(http_requests_total{service="order-service"}[5m])) by (endpoint)

# RPS por status code
sum(rate(http_requests_total{service="order-service"}[5m])) by (status)
```

#### 2. Error Rate
```promql
# Error rate %
(
  sum(rate(http_requests_total{service="order-service",status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total{service="order-service"}[5m]))
) * 100

# Threshold: linha vermelha em 1%
```

#### 3. Latency
```promql
# p50
histogram_quantile(0.50, rate(http_request_duration_seconds_bucket{service="order-service"}[5m]))

# p95
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{service="order-service"}[5m]))

# p99
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{service="order-service"}[5m]))
```

#### 4. Apdex Score
```promql
# Apdex: % de requisições "satisfatórias"
# T = 0.5s (threshold)
(
  sum(rate(http_request_duration_seconds_bucket{service="order-service",le="0.5"}[5m]))
  +
  sum(rate(http_request_duration_seconds_bucket{service="order-service",le="2"}[5m])) * 0.5
)
/
sum(rate(http_request_duration_seconds_count{service="order-service"}[5m]))
```

#### 5. Top Endpoints (por latência)
```promql
# Query: Table format
topk(10, 
  histogram_quantile(0.95, 
    rate(http_request_duration_seconds_bucket{service="order-service"}[5m])
  ) by (endpoint)
)
```

---

### 4.2) gRPC Dashboard

Similar ao HTTP, mas com métricas específicas:

```promql
# Request Rate
sum(rate(grpc_server_handled_total{service="order-service"}[5m]))

# Error Rate (status != OK)
sum(rate(grpc_server_handled_total{service="order-service",grpc_code!="OK"}[5m]))
/
sum(rate(grpc_server_handled_total{service="order-service"}[5m]))

# Latency
histogram_quantile(0.95, 
  rate(grpc_server_handling_seconds_bucket{service="order-service"}[5m])
)
```

---

### 4.3) Background Jobs Dashboard

**Painéis:**

#### 1. Job Throughput
```promql
# Jobs processados por segundo
sum(rate(jobs_processed_total{service="worker-service"}[5m])) by (job_type)
```

#### 2. Job Success Rate
```promql
# Success rate %
(
  sum(rate(jobs_processed_total{service="worker-service",status="success"}[5m]))
  /
  sum(rate(jobs_processed_total{service="worker-service"}[5m]))
) * 100
```

#### 3. Job Duration
```promql
# p95 duration por tipo
histogram_quantile(0.95, 
  rate(job_duration_seconds_bucket{service="worker-service"}[5m])
) by (job_type)
```

#### 4. Queue Depth
```promql
# Tamanho da fila
job_queue_depth{service="worker-service"}
```

#### 5. DLQ (Dead Letter Queue)
```promql
# Taxa de jobs na DLQ
rate(jobs_dlq_total{service="worker-service"}[5m])
```

---

### 4.4) Database Dashboard (USE)

**Painéis:**

#### 1. Query Throughput
```promql
# Queries por segundo
sum(rate(db_queries_total{db="postgres"}[5m])) by (operation)
```

#### 2. Query Latency
```promql
# p95 latency
histogram_quantile(0.95, 
  rate(db_query_duration_seconds_bucket{db="postgres"}[5m])
) by (operation)
```

#### 3. Connection Pool
```promql
# Conexões ativas
db_connections_active{db="postgres"}

# Conexões idle
db_connections_idle{db="postgres"}

# Max connections
db_connections_max{db="postgres"}
```

#### 4. Slow Queries
```promql
# Queries > 1s
sum(rate(db_query_duration_seconds_count{db="postgres",le="+Inf"}[5m]))
-
sum(rate(db_query_duration_seconds_bucket{db="postgres",le="1"}[5m]))
```

#### 5. Lock Waits
```promql
# Tempo esperando locks
rate(db_lock_wait_seconds_total{db="postgres"}[5m])
```

---

### 4.5) Infrastructure Dashboard (USE)

**Painéis:**

#### 1. CPU Utilization
```promql
# CPU usage %
(1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)) * 100
```

#### 2. Memory Utilization
```promql
# Memory usage %
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

#### 3. Disk I/O
```promql
# Read throughput (MB/s)
rate(node_disk_read_bytes_total[5m]) / 1024 / 1024

# Write throughput (MB/s)
rate(node_disk_written_bytes_total[5m]) / 1024 / 1024
```

#### 4. Network I/O
```promql
# Received (Mbps)
rate(node_network_receive_bytes_total[5m]) * 8 / 1000000

# Transmitted (Mbps)
rate(node_network_transmit_bytes_total[5m]) * 8 / 1000000
```

#### 5. Load Average
```promql
# Load 1min
node_load1

# Normalized load (load / CPU cores)
node_load1 / count(node_cpu_seconds_total{mode="idle"}) by (instance)
```

---

### 4.6) SLO Dashboard

**Painéis:**

#### 1. SLO Compliance (Gauge)
```promql
# Availability SLO: 99.9%
(
  sum(rate(http_requests_total{status=~"2..|3.."}[30d]))
  /
  sum(rate(http_requests_total[30d]))
) * 100

# Visualização: Gauge com zonas:
# - Verde: > 99.9%
# - Amarelo: 99.5% - 99.9%
# - Vermelho: < 99.5%
```

#### 2. Error Budget Remaining
```promql
# Error budget restante (minutos)
(
  (
    sum(rate(http_requests_total{status=~"2..|3.."}[30d]))
    /
    sum(rate(http_requests_total[30d]))
  )
  - 0.999  # SLO
)
/
(1 - 0.999)
* (30 * 24 * 60)  # Total minutes in 30 days
```

#### 3. Error Budget Burn Rate
```promql
# Burn rate (quanto mais rápido está queimando)
(
  (1 - (sum(rate(http_requests_total{status=~"2..|3.."}[1h])) 
        / sum(rate(http_requests_total[1h]))))
  / (1 - 0.999)
)

# Linha de referência em 1.0 (velocidade normal)
```

#### 4. SLO Trend (30 dias)
```promql
# Availability nos últimos 30 dias (rolling window)
(
  sum(rate(http_requests_total{status=~"2..|3.."}[30d]))
  /
  sum(rate(http_requests_total[30d]))
) * 100
```

---

## 5) Elementos Visuais

### Gráficos por Tipo de Dado

| Tipo de Dado | Gráfico Recomendado | Exemplo |
|--------------|---------------------|---------|
| Tendência temporal | Linha | Latência ao longo do tempo |
| Distribuição | Histograma | Duração de requisições |
| Comparação | Barra | RPS por endpoint |
| Proporção | Pizza (evitar!) | Status codes (use barra) |
| Status atual | Gauge/Stat | CPU atual, error rate |
| Matriz de valores | Heatmap | Latência por hora/dia |
| Lista ordenada | Tabela | Top 10 endpoints lentos |

### Cores

**Semântica de cores:**
- 🟢 **Verde:** Tudo OK (< threshold)
- 🟡 **Amarelo:** Atenção (próximo do threshold)
- 🔴 **Vermelho:** Problema (> threshold)
- 🔵 **Azul:** Informacional (não há threshold)

**Evite:**
- Muitas cores diferentes
- Cores sem significado
- Vermelho para dados não-problemáticos

### Thresholds e Anotações

**Sempre adicione:**
- Linha horizontal do SLO/threshold
- Zona de alerta (amarelo)
- Zona crítica (vermelho)
- Anotações de deploys/incidentes

**Exemplo:**
```yaml
# Painel de latência com thresholds
panel:
  title: "Latency p95"
  thresholds:
    - value: 0.5   # SLO
      color: yellow
      label: "SLO (500ms)"
    - value: 1.0   # Crítico
      color: red
      label: "Critical (1s)"
```

---

## 6) Boas Práticas

### ✅ Faça

1. **Use templates:** Dashboards similares para serviços similares
2. **Variáveis de template:** Filtrar por `service`, `environment`, `region`
3. **Links entre dashboards:** De overview para detail
4. **Descrições claras:** Tooltip explicando cada métrica
5. **Time range selector:** 5m, 1h, 6h, 24h, 7d
6. **Auto-refresh:** 30s ou 1min
7. **Annotations:** Marcar deploys, incidentes, mudanças

### ❌ Evite

1. **Dashboard poluído:** Máximo 10-12 painéis
2. **Gráficos sem contexto:** Sempre adicione thresholds
3. **Pizza charts:** Difícil de comparar proporções
4. **Cores aleatórias:** Use semântica consistente
5. **Métricas vanity:** "Parece legal" mas não ajuda
6. **Dashboards esquecidos:** Remova o que não usa

### Checklist de Qualidade

Antes de publicar um dashboard:

- [ ] Título claro e descritivo
- [ ] Cada painel tem descrição
- [ ] Thresholds/SLOs marcados
- [ ] Cores semânticas consistentes
- [ ] Variáveis de template para filtrar
- [ ] Links para dashboards relacionados
- [ ] Time range selector configurado
- [ ] Auto-refresh habilitado
- [ ] Testado em diferentes resoluções
- [ ] Revisado por outro engenheiro

---

## 7) Dashboard as Code

### Vantagens

- ✅ Versionamento (Git)
- ✅ Review de mudanças (PR)
- ✅ Backup automático
- ✅ Replicação entre ambientes
- ✅ Padronização via templates

### Formato Grafana

Dashboards Grafana são JSON:

```json
{
  "dashboard": {
    "title": "Order Service - RED Metrics",
    "uid": "order-service-red",
    "timezone": "utc",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate (RPS)",
        "type": "graph",
        "targets": [{
          "expr": "sum(rate(http_requests_total{service=\"order-service\"}[5m]))",
          "refId": "A"
        }],
        "gridPos": {"x": 0, "y": 0, "w": 12, "h": 8}
      }
    ],
    "time": {"from": "now-6h", "to": "now"},
    "refresh": "30s"
  }
}
```

**Ferramentas de geração:**
- **Grafonnet** (Jsonnet DSL)
- **Terraform Grafana Provider**
- **Scripts Python/C#** (ver `tooling/observability/`)

---

## 8) Provisioning (IaC)

### Terraform

```hcl
# grafana_dashboards.tf
resource "grafana_dashboard" "order_service_red" {
  config_json = file("${path.module}/dashboards/order-service-red.json")
  folder      = grafana_folder.services.id
}

resource "grafana_folder" "services" {
  title = "Services"
}
```

### Grafana Provisioning

```yaml
# provisioning/dashboards/dashboards.yml
apiVersion: 1

providers:
  - name: 'services'
    orgId: 1
    folder: 'Services'
    type: file
    options:
      path: /etc/grafana/dashboards/services
```

---

## 9) Exemplos de Dashboards

### Dashboard Mínimo (Starter)

**Para um novo serviço, comece com:**

1. **Request Rate** — Tráfego
2. **Error Rate** — Saúde
3. **Latency p95** — Performance

**3 gráficos, 5 minutos para criar.**

### Dashboard Completo (Production-Ready)

**Para serviço maduro:**

1. **Overview:**
   - Status (UP/DOWN)
   - SLO compliance
   - Error budget

2. **Traffic:**
   - RPS total
   - RPS por endpoint
   - RPS por status code

3. **Errors:**
   - Error rate %
   - Top errors (por tipo)
   - Error trend (7 dias)

4. **Latency:**
   - p50, p95, p99
   - Heatmap de distribuição
   - Top slow endpoints

5. **Dependencies:**
   - Database latency
   - Cache hit rate
   - External API response time

6. **Resources:**
   - CPU usage
   - Memory usage
   - Connection pools

---

## 10) Checklist

Antes de ir para produção:

- [ ] Dashboard de overview criado
- [ ] Dashboard por serviço (RED/USE)
- [ ] Dashboard de infraestrutura
- [ ] Dashboard de SLOs
- [ ] Thresholds/SLOs marcados em todos os gráficos
- [ ] Variáveis de template configuradas
- [ ] Links entre dashboards funcionando
- [ ] Descrições/tooltips em todos os painéis
- [ ] Testado em diferentes time ranges
- [ ] Dashboard versionado (Git)
- [ ] Permissões configuradas (quem pode editar)

---

## 11) Ferramentas Recomendadas

### Visualização
- **Grafana** — Padrão de mercado, open-source
- **Kibana** — Para logs (Elasticsearch)
- **Datadog** — SaaS completo
- **New Relic** — APM com dashboards

### Dashboard as Code
- **Grafonnet** — DSL Jsonnet para Grafana
- **Terraform Grafana Provider** — Provisioning via IaC
- **Grafana Provisioning** — YAML-based auto-load

**Exemplos de código:** Ver `tooling/observability/grafana/`

---

## Referências

- [Grafana Best Practices](https://grafana.com/docs/grafana/latest/best-practices/)
- [RED Method (Tom Wilkie)](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
- [USE Method (Brendan Gregg)](https://www.brendangregg.com/usemethod.html)
- [Google SRE - Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
- [Grafana Dashboard Examples](https://grafana.com/grafana/dashboards/)