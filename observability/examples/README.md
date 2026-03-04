# Exemplos de Configuração de Observabilidade

Esta pasta contém exemplos práticos de implementação dos padrões de observabilidade da QBEM.

---

## 📂 Estrutura

```
examples/
├── python/              # Exemplos Python
│   ├── logging_config.py
│   ├── metrics_config.py
│   └── tracing_config.py
├── dotnet/              # Exemplos C# (.NET Core)
│   ├── LoggingConfiguration.cs
│   ├── MetricsConfiguration.cs
│   └── TracingConfiguration.cs
├── prometheus/          # Configurações Prometheus
│   └── alerts.yml
└── grafana/             # Dashboards Grafana
    └── dashboard-red.json
```

---

## 🐍 Python

### Logs Estruturados (`logging_config.py`)

Configuração completa de logs estruturados usando **structlog** e **python-json-logger**.

**Instalação:**
```bash
pip install structlog python-json-logger
```

**Uso:**
```python
from logging_config import setup_logging, get_logger

setup_logging(service_name="my-service")
logger = get_logger(__name__)

logger.info("user_logged_in", user_id="u_123", ip="192.168.1.1")
```

**Features:**
- ✅ Logs em JSON
- ✅ Campos obrigatórios (timestamp, service, environment, version)
- ✅ Sanitização de PII
- ✅ Middleware para FastAPI e Flask
- ✅ Correlação com trace_id

---

### Métricas (`metrics_config.py`)

Configuração de métricas usando **prometheus-client**.

**Instalação:**
```bash
pip install prometheus-client
```

**Uso:**
```python
from metrics_config import setup_metrics, get_metrics

setup_metrics(service_name="my-service")
metrics = get_metrics()

metrics.http_requests_total.labels(
    service="my-service",
    method="GET",
    path="/users/:id",
    status_code=200
).inc()
```

**Features:**
- ✅ Métricas RED (Rate, Errors, Duration)
- ✅ Métricas de negócio
- ✅ Métricas de database, cache, jobs
- ✅ Middleware para FastAPI e Flask
- ✅ Endpoint `/metrics` automático

---

### Tracing (`tracing_config.py`)

Configuração de distributed tracing usando **OpenTelemetry**.

**Instalação:**
```bash
pip install opentelemetry-api opentelemetry-sdk
pip install opentelemetry-instrumentation-fastapi
pip install opentelemetry-instrumentation-requests
pip install opentelemetry-exporter-otlp
```

**Uso:**
```python
from tracing_config import setup_tracing, get_tracer

setup_tracing(service_name="my-service", sampling_rate=0.1)
tracer = get_tracer(__name__)

with tracer.start_as_current_span("process_order") as span:
    span.set_attribute("order_id", "ord_123")
    # Processar pedido
```

**Features:**
- ✅ OpenTelemetry SDK configurado
- ✅ Auto-instrumentation (FastAPI, requests, SQLAlchemy)
- ✅ Propagação de contexto (W3C Trace Context)
- ✅ Sampling configurável
- ✅ Decorator para instrumentação simples

---

## 🔷 C# (.NET Core)

### Logs Estruturados (`LoggingConfiguration.cs`)

Configuração completa de logs estruturados usando **Serilog**.

**Instalação:**
```bash
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Formatting.Compact
```

**Uso:**
```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);
builder.Host.ConfigureStructuredLogging();

var app = builder.Build();
app.UseRequestLogging();
```

**Features:**
- ✅ Logs em JSON (Compact format)
- ✅ Campos obrigatórios
- ✅ Sanitização de PII
- ✅ Middleware de correlação
- ✅ Enrichers customizados

---

### Métricas (`MetricsConfiguration.cs`)

Configuração de métricas usando **prometheus-net**.

**Instalação:**
```bash
dotnet add package prometheus-net
dotnet add package prometheus-net.AspNetCore
```

**Uso:**
```csharp
// Program.cs
builder.Services.AddMetrics();

var app = builder.Build();
app.UseHttpMetrics();
app.MapMetrics();
```

**Features:**
- ✅ Métricas RED
- ✅ Métricas de negócio
- ✅ Middleware automático
- ✅ DI integration
- ✅ Endpoint `/metrics`

---

### Tracing (`TracingConfiguration.cs`)

Configuração de distributed tracing usando **OpenTelemetry**.

**Instalação:**
```bash
dotnet add package OpenTelemetry
dotnet add package OpenTelemetry.Extensions.Hosting
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
dotnet add package OpenTelemetry.Instrumentation.Http
dotnet add package OpenTelemetry.Instrumentation.SqlClient
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol
```

**Uso:**
```csharp
// Program.cs
builder.Services.AddDistributedTracing();
```

**Features:**
- ✅ OpenTelemetry SDK configurado
- ✅ Auto-instrumentation (ASP.NET Core, HttpClient, SQL)
- ✅ Propagação de contexto
- ✅ Sampling configurável
- ✅ ActivitySource para spans manuais

---

## 📊 Prometheus

### Regras de Alerta (`alerts.yml`)

Exemplos de regras de alerta baseadas nos padrões QBEM.

**Uso:**
```yaml
# prometheus.yml
rule_files:
  - "/etc/prometheus/rules/*.yml"
```

**Inclui:**
- ✅ Alertas de disponibilidade (HighErrorRate, ServiceDown)
- ✅ Alertas de latência (HighLatencyP95, HighLatencyP99)
- ✅ Alertas de error budget (burn rate)
- ✅ Alertas de saturação (CPU, memória, disco)
- ✅ Alertas de database, cache, jobs
- ✅ Recording rules para métricas agregadas

**Cada alerta inclui:**
- Severidade apropriada
- Thresholds baseados em SLOs
- Link para runbook
- Descrição clara

---

## 📈 Grafana

### Dashboard RED (`dashboard-red.json`)

Dashboard completo implementando a metodologia RED.

**Import:**
1. Grafana → Dashboards → Import
2. Copiar conteúdo de `dashboard-red.json`
3. Selecionar datasource Prometheus
4. Ajustar variáveis `$service` e `$environment`

**Painéis inclusos:**
- ✅ Request Rate (RPS)
- ✅ Error Rate (%)
- ✅ Latency Percentiles (p50, p95, p99)
- ✅ Top Slow Endpoints
- ✅ Requests by Status Code
- ✅ SLO Compliance (gauge)
- ✅ Error Budget Remaining
- ✅ Requests In Progress

**Features:**
- Template variables (`$service`, `$environment`)
- Thresholds configurados (SLO 99.9%)
- Alertas configurados
- Anotações (restarts, deploys)
- Auto-refresh (30s)

---

## 🚀 Quick Start

### 1. Python (FastAPI)

```bash
# Instalar dependências
pip install structlog python-json-logger prometheus-client
pip install opentelemetry-api opentelemetry-sdk
pip install opentelemetry-instrumentation-fastapi
pip install opentelemetry-exporter-otlp

# Criar main.py
```

```python
from fastapi import FastAPI
from logging_config import setup_logging, create_fastapi_logging_middleware
from metrics_config import setup_metrics, create_fastapi_metrics_middleware, create_fastapi_metrics_endpoint
from tracing_config import setup_tracing, setup_fastapi_tracing

# Setup
setup_logging(service_name="my-service")
setup_metrics(service_name="my-service")
setup_tracing(service_name="my-service")

# App
app = FastAPI()

# Middlewares
app.middleware("http")(create_fastapi_logging_middleware())
app.middleware("http")(create_fastapi_metrics_middleware())
setup_fastapi_tracing(app)

# Endpoints
app.get("/metrics")(create_fastapi_metrics_endpoint())

@app.get("/")
def read_root():
    return {"message": "Hello World"}
```

**Pronto! Você tem:**
- ✅ Logs estruturados em JSON
- ✅ Métricas em `/metrics`
- ✅ Tracing automático

---

### 2. C# (.NET Core)

```bash
# Instalar dependências
dotnet add package Serilog.AspNetCore
dotnet add package prometheus-net.AspNetCore
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
```

```csharp
// Program.cs
using Qbem.Observability.Logging;
using Qbem.Observability.Metrics;
using Qbem.Observability.Tracing;

var builder = WebApplication.CreateBuilder(args);

// Configurar observabilidade
builder.Host.ConfigureStructuredLogging();
builder.Services.AddMetrics();
builder.Services.AddDistributedTracing();

var app = builder.Build();

// Middlewares
app.UseRequestLogging();
app.UseHttpMetrics();

// Endpoints
app.MapMetrics();
app.MapGet("/", () => "Hello World");

app.Run();
```

**Pronto! Você tem:**
- ✅ Logs estruturados em JSON
- ✅ Métricas em `/metrics`
- ✅ Tracing automático

---

## 📚 Documentação Completa

Para entender os padrões por trás destes exemplos, consulte:

- [📖 Logs Estruturados](../logs.md)
- [📖 Métricas](../metrics.md)
- [📖 Distributed Tracing](../tracing.md)
- [📖 Alertas e SLOs](../alerts.md)
- [📖 Dashboards](../dashboards.md)
- [📖 Ferramentas](../tools.md)

---

## 🤝 Contribuindo

Encontrou um bug ou quer adicionar um exemplo para outra linguagem?

1. Abra uma issue descrevendo sua proposta
2. Envie um PR com o exemplo
3. Garanta que segue os padrões do documento correspondente

---

## 📋 Checklist de Implementação

Ao implementar observabilidade em um serviço, use este checklist:

### Logs
- [ ] Configuração copiada e adaptada
- [ ] Logs em JSON estruturado
- [ ] Campos obrigatórios presentes
- [ ] PII sanitizada
- [ ] Middleware configurado

### Métricas
- [ ] Configuração copiada e adaptada
- [ ] Endpoint `/metrics` exposto
- [ ] Métricas RED implementadas
- [ ] Middleware configurado
- [ ] Labels sem alta cardinalidade

### Tracing
- [ ] Configuração copiada e adaptada
- [ ] OpenTelemetry SDK configurado
- [ ] Auto-instrumentation habilitada
- [ ] Contexto propagado
- [ ] Sampling configurado

### Alertas
- [ ] Regras de alerta adaptadas
- [ ] Prometheus carregando `alerts.yml`
- [ ] Thresholds ajustados para seu SLO
- [ ] Runbooks escritos

### Dashboards
- [ ] Dashboard RED importado
- [ ] Variáveis ajustadas (`$service`)
- [ ] Thresholds ajustados
- [ ] Anotações configuradas

---

## ⚠️ Notas Importantes

### Variáveis de Ambiente

Todos os exemplos usam variáveis de ambiente para configuração:

```bash
export SERVICE_NAME="my-service"
export ENVIRONMENT="production"
export APP_VERSION="1.0.0"
export LOG_LEVEL="INFO"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://otel-collector:4317"
export OTEL_SAMPLING_RATE="0.1"  # 10%
```

### Segurança

- ⚠️ Endpoint `/metrics` deve ser protegido (não expor publicamente)
- ⚠️ Nunca logar PII sem mascarar
- ⚠️ Use HTTPS/TLS em produção

### Performance

- Sampling de traces: 1-10% em produção (não 100%)
- Logs: Use nível INFO em produção (não DEBUG)
- Métricas: Evite labels de alta cardinalidade

---

**Dúvidas?** Consulte a documentação completa ou abra uma issue!