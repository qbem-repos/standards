# Ferramentas de Observabilidade

Stack de ferramentas e comparações para implementar observabilidade completa.

---

## 1) Stack Padrão QBEM

### Arquitetura Recomendada

```
┌─────────────────────────────────────────────────────────────┐
│                      Aplicações                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Service A│  │ Service B│  │ Service C│  │ Service D│   │
│  │ (Python) │  │ (C#)     │  │ (Python) │  │ (C#)     │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │ OpenTelemetry │             │ OpenTelemetry │       │
└───────┼────────────┼───────────────┼────────────┼──────────┘
        │            │               │            │
        ├────────────┴───────────────┴────────────┤
        │                                          │
        ▼                                          ▼
┌─────────────────────────────────────────────────────────────┐
│              OTEL Collector (Opcional)                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Recebe, processa e roteia telemetria                   │ │
│  │ - Sampling                                             │ │
│  │ - Filtering                                            │ │
│  │ - Batching                                             │ │
│  └────────────────────────────────────────────────────────┘ │
└───────┬──────────────────┬──────────────────┬───────────────┘
        │                  │                  │
        │ Logs             │ Metrics          │ Traces
        ▼                  ▼                  ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│    Loki     │   │ Prometheus  │   │   Tempo     │
│  (Grafana)  │   │             │   │  (Grafana)  │
└──────┬──────┘   └──────┬──────┘   └──────┬──────┘
       │                 │                  │
       └─────────────────┴──────────────────┘
                         │
                         ▼
                  ┌─────────────┐
                  │   Grafana   │
                  │ (Dashboards)│
                  └─────────────┘
```

---

## 2) Logs

### Opções

| Ferramenta | Tipo | Prós | Contras | Quando Usar |
|------------|------|------|---------|-------------|
| **Loki** | OSS | - Query similar ao Prometheus<br>- Baixo custo storage<br>- Integração nativa Grafana | - Menos features que ELK<br>- Full-text search limitado | ✅ **Recomendado** para maioria dos casos |
| **Elasticsearch** | OSS | - Full-text search potente<br>- Análises complexas<br>- Ecossistema maduro | - Alto custo storage<br>- Complexo de operar | Use para análises avançadas |
| **CloudWatch Logs** | SaaS (AWS) | - Integração nativa AWS<br>- Zero manutenção | - Custo alto em volume<br>- Vendor lock-in | Use se 100% AWS |
| **Cloud Logging** | SaaS (GCP) | - Integração nativa GCP<br>- Zero manutenção | - Custo alto em volume<br>- Vendor lock-in | Use se 100% GCP |
| **Datadog Logs** | SaaS | - Full-stack observability<br>- UI excelente | - Custo muito alto | Use se budget não for problema |

### Escolha Recomendada

**🎯 Stack Primário: Loki + Grafana**

**Razões:**
- ✅ Cost-effective
- ✅ Integração perfeita com Prometheus e Tempo
- ✅ Query language familiar (LogQL similar ao PromQL)
- ✅ Fácil de operar

**Casos especiais:**
- **Elasticsearch:** Se precisa de full-text search avançado ou já tem expertise
- **Cloud Provider:** Se toda infraestrutura está em um provider (AWS/GCP/Azure)

---

## 3) Métricas

### Opções

| Ferramenta | Tipo | Prós | Contras | Quando Usar |
|------------|------|------|---------|-------------|
| **Prometheus** | OSS | - Padrão de mercado<br>- PromQL poderoso<br>- Pull model (service discovery) | - Storage local apenas<br>- Não multi-tenant | ✅ **Recomendado** como base |
| **VictoriaMetrics** | OSS | - Drop-in replacement Prometheus<br>- Melhor performance<br>- Long-term storage | - Comunidade menor | Use para scale (milhões de series) |
| **Thanos** | OSS | - Long-term storage Prometheus<br>- Multi-cluster | - Complexo de operar | Use com múltiplos clusters Prometheus |
| **Cortex** | OSS | - Multi-tenant Prometheus<br>- Horizontally scalable | - Muito complexo | Use para SaaS multi-tenant |
| **Datadog** | SaaS | - Full-stack observability<br>- UI excelente | - Custo muito alto | Use se budget não for problema |

### Escolha Recomendada

**🎯 Stack Primário: Prometheus + Grafana**

**Razões:**
- ✅ Padrão da indústria
- ✅ Integração com tudo (OpenTelemetry, Kubernetes, etc)
- ✅ PromQL é a linguagem padrão de queries
- ✅ Ecosystem rico (exporters, libraries)

**Upgrade path:**
1. **Start:** Prometheus standalone
2. **Scale:** VictoriaMetrics (drop-in replacement)
3. **Multi-region:** Thanos (federated queries + long-term storage)

---

## 4) Tracing

### Opções

| Ferramenta | Tipo | Prós | Contras | Quando Usar |
|------------|------|------|---------|-------------|
| **Tempo** | OSS | - Integração nativa Grafana<br>- Cost-effective<br>- Object storage (S3, GCS) | - Features limitadas vs Jaeger<br>- UI básica | ✅ **Recomendado** para começar |
| **Jaeger** | OSS | - UI excelente<br>- Features maduras<br>- Sampling avançado | - Requer mais recursos<br>- Storage (Cassandra/ES) | Use se precisa UI avançada |
| **Zipkin** | OSS | - Simples de operar<br>- Leve | - Menos features<br>- UI datada | Use para casos simples |
| **Datadog APM** | SaaS | - Full-stack observability<br>- Análises avançadas | - Custo muito alto | Use se budget não for problema |
| **Honeycomb** | SaaS | - High-cardinality queries<br>- Excelente para debug | - Custo alto<br>- Learning curve | Use para debugging complexo |

### Escolha Recomendada

**🎯 Stack Primário: Tempo + Grafana**

**Razões:**
- ✅ Integração perfeita com Loki e Prometheus
- ✅ Usa object storage (S3/GCS) - barato
- ✅ Zero manutenção de database
- ✅ Query traces direto de logs

**Alternativa:**
- **Jaeger:** Se precisa de UI mais rica e análises avançadas
- **SaaS:** Se não quer gerenciar infraestrutura

---

## 5) Visualização e Dashboards

### Opções

| Ferramenta | Tipo | Prós | Contras | Quando Usar |
|------------|------|------|---------|-------------|
| **Grafana** | OSS | - Multi-datasource<br>- Plugins ricos<br>- Alerting integrado | - Performance com muitos dashboards | ✅ **Recomendado** única opção |
| **Kibana** | OSS | - Integrado com Elasticsearch<br>- Análises avançadas | - Só funciona com ELK | Use se usar Elasticsearch |
| **Datadog** | SaaS | - UI excelente<br>- Zero config | - Custo muito alto | Use se usar Datadog para tudo |

### Escolha Recomendada

**🎯 Única Escolha: Grafana**

**Razões:**
- ✅ Suporta todos datasources (Prometheus, Loki, Tempo, etc)
- ✅ Ecosystem gigante
- ✅ Dashboard as Code (JSON/Terraform)
- ✅ Alerting integrado

---

## 6) OpenTelemetry Collector

### O que é?

**OTEL Collector** é um proxy que:
- Recebe telemetria (logs, métricas, traces)
- Processa (sampling, filtering, batching)
- Exporta para backends (Loki, Prometheus, Tempo, etc)

### Quando Usar?

| Cenário | Usar OTEL Collector? | Razão |
|---------|----------------------|-------|
| Aplicação → Prometheus direto | ❌ Não | Prometheus faz pull (scrape), não precisa |
| Aplicação → Loki direto | ✅ Opcional | Pode fazer batching e filtering |
| Aplicação → Tempo | ✅ Sim | Melhor performance com batching |
| Múltiplos backends | ✅ Sim | Enviar para vários destinos sem mudar código |
| Sampling avançado | ✅ Sim | Tail-based sampling no collector |
| Multi-tenant | ✅ Sim | Routing por tenant |

### Deployment

```yaml
# Deployment modes
1. Agent (Sidecar)
   - Um por pod/container
   - Baixa latência
   - Uso: traces, logs

2. Gateway (Cluster-wide)
   - Centralizado
   - Processamento pesado
   - Uso: aggregation, sampling
```

---

## 7) Comparação: Self-Hosted vs SaaS

### Self-Hosted (OSS)

**Stack:** Prometheus + Loki + Tempo + Grafana

| Aspecto | Avaliação | Nota |
|---------|-----------|------|
| **Custo** | ⭐⭐⭐⭐⭐ | Apenas infra (compute + storage) |
| **Controle** | ⭐⭐⭐⭐⭐ | Controle total |
| **Manutenção** | ⭐⭐ | Você gerencia tudo |
| **Features** | ⭐⭐⭐⭐ | Rico mas requer config |
| **Time-to-value** | ⭐⭐⭐ | Setup inicial necessário |

**Quando usar:**
- ✅ Controle de custos importante
- ✅ Data sovereignty (LGPD, compliance)
- ✅ Tem equipe para operar

**Custo estimado (produção média):**
- Infrastructure: $500-2000/mês
- Eng time: 20-40h/mês

---

### SaaS (Datadog, New Relic, etc)

| Aspecto | Avaliação | Nota |
|---------|-----------|------|
| **Custo** | ⭐⭐ | $$$$ por host/métrica |
| **Controle** | ⭐⭐⭐ | Limitado à plataforma |
| **Manutenção** | ⭐⭐⭐⭐⭐ | Zero, gerenciado |
| **Features** | ⭐⭐⭐⭐⭐ | Tudo out-of-the-box |
| **Time-to-value** | ⭐⭐⭐⭐⭐ | Minutos |

**Quando usar:**
- ✅ Precisa de quick start
- ✅ Não tem equipe para operar
- ✅ Budget não é problema

**Custo estimado (produção média):**
- Datadog: $3000-10000/mês
- New Relic: $2000-8000/mês

---

## 8) Matriz de Decisão

### Por Tamanho de Empresa

| Tamanho | Stack Recomendado | Justificativa |
|---------|-------------------|---------------|
| **Startup** (< 10 devs) | Grafana Cloud ou Datadog | Time-to-value, zero ops |
| **Scale-up** (10-50 devs) | Prometheus + Loki + Tempo (self-hosted) | Balance custo/controle |
| **Enterprise** (50+ devs) | Self-hosted + OTEL Collector | Controle total, custo otimizado |

### Por Fase do Produto

| Fase | Stack | Razão |
|------|-------|-------|
| **MVP** | SaaS (Datadog/Grafana Cloud) | Foco no produto, não em ops |
| **Product-Market Fit** | Hybrid (OSS + SaaS backup) | Começar a controlar custos |
| **Scale** | Full OSS (self-hosted) | Custos de SaaS explodem |

### Por Budget

| Budget Mensal | Stack | Nota |
|---------------|-------|------|
| **< $500** | Grafana Cloud Free Tier | Limitado mas funcional |
| **$500-2000** | Self-hosted (Prometheus + Loki + Tempo) | Melhor custo-benefício |
| **$2000-5000** | Hybrid (self-hosted + SaaS para traces) | Balance |
| **> $5000** | SaaS Full (Datadog/New Relic) se não tem ops | Ou self-hosted se tem equipe |

---

## 9) Bibliotecas por Linguagem

### Python

**Logs:**
- `structlog` + `python-json-logger` ✅ Recomendado
- `logging` (stdlib) - Para casos simples

**Métricas:**
- `prometheus-client` ✅ Recomendado
- `opentelemetry-api` - Alternativa moderna

**Tracing:**
- `opentelemetry-api` + `opentelemetry-sdk` ✅ Recomendado
- `opentelemetry-instrumentation-*` - Auto-instrumentation

### C# (.NET)

**Logs:**
- `Serilog` ✅ Recomendado
- `NLog` - Alternativa
- `Microsoft.Extensions.Logging` - Stdlib (básico)

**Métricas:**
- `prometheus-net` ✅ Recomendado
- `OpenTelemetry.Instrumentation.AspNetCore` - Alternativa

**Tracing:**
- `OpenTelemetry` + `OpenTelemetry.Instrumentation.*` ✅ Recomendado
- `System.Diagnostics.Activity` - Stdlib integration

### Node.js

**Logs:**
- `pino` ✅ Recomendado (mais rápido)
- `winston` - Alternativa (mais features)

**Métricas:**
- `prom-client` ✅ Recomendado

**Tracing:**
- `@opentelemetry/api` + `@opentelemetry/sdk-node` ✅ Recomendado

### Java

**Logs:**
- `Logback` ✅ Recomendado
- `Log4j2` - Alternativa

**Métricas:**
- `Micrometer` ✅ Recomendado (abstração)
- `Prometheus Java Client` - Direto

**Tracing:**
- `OpenTelemetry Java` ✅ Recomendado
- `opentelemetry-javaagent` - Auto-instrumentation

---

## 10) Configurações e Exemplos

Todos os exemplos de código e configurações estão em:

📁 **`observability/examples/`**

```
examples/
├── python/
│   ├── logging_config.py      # Logs estruturados (structlog)
│   ├── metrics_config.py      # Métricas (prometheus-client)
│   └── tracing_config.py      # Tracing (OpenTelemetry)
├── dotnet/
│   ├── LoggingConfiguration.cs   # Logs (Serilog)
│   ├── MetricsConfiguration.cs   # Métricas (prometheus-net)
│   └── TracingConfiguration.cs   # Tracing (OpenTelemetry)
├── prometheus/
│   └── alerts.yml             # Regras de alerta
└── grafana/
    └── dashboard-red.json     # Dashboard RED metrics
```

---

## 11) Roadmap de Implementação

### Fase 1: Básico (Semana 1-2)

1. **Logs estruturados** em JSON
   - Implementar em 1-2 serviços piloto
   - Configurar Loki + Grafana
2. **Métricas básicas** (RED)
   - Prometheus + Grafana
   - Dashboard RED por serviço

**Entregável:** Logs e métricas básicas funcionando

### Fase 2: Tracing (Semana 3-4)

1. **OpenTelemetry SDK** instalado
2. **Auto-instrumentation** para HTTP
3. **Tempo** + Grafana configurado
4. **Correlação** logs ↔ traces

**Entregável:** Traces end-to-end visíveis

### Fase 3: Alertas e SLOs (Semana 5-6)

1. **Alertas críticos** configurados
2. **SLOs definidos** (99.9% availability)
3. **Error budget** monitorado
4. **Runbooks** escritos

**Entregável:** On-call pode responder a incidentes

### Fase 4: Otimização (Mês 2+)

1. **OTEL Collector** para sampling avançado
2. **Dashboards customizados** por squad
3. **Long-term storage** (Thanos/VictoriaMetrics)
4. **Cost optimization** (retention, sampling)

**Entregável:** Sistema de observabilidade maduro

---

## 12) Checklist de Implementação

Antes de considerar observabilidade "completa":

### Logs
- [ ] JSON estruturado em todos serviços
- [ ] PII sanitizada
- [ ] Trace ID em todos logs
- [ ] Loki + Grafana operacional
- [ ] Retenção configurada (30 dias)

### Métricas
- [ ] Prometheus scraping todos serviços
- [ ] Métricas RED expostas
- [ ] Dashboards básicos criados
- [ ] Alertas críticos configurados
- [ ] Recording rules para queries pesadas

### Tracing
- [ ] OpenTelemetry SDK em todos serviços
- [ ] Contexto propagado em todas chamadas
- [ ] Tempo operacional
- [ ] Sampling configurado (1-10%)
- [ ] Integração logs ↔ traces

### Alertas
- [ ] Alertas críticos configurados
- [ ] Runbooks escritos
- [ ] On-call rotation definida
- [ ] Alertmanager configurado
- [ ] Postmortem template pronto

---

## Referências

- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Loki](https://grafana.com/oss/loki/)
- [Tempo](https://grafana.com/oss/tempo/)
- [Jaeger](https://www.jaegertracing.io/)
- [OpenTelemetry](https://opentelemetry.io/)
- [OTEL Collector](https://opentelemetry.io/docs/collector/)