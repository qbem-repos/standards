![bar-chart](https://api.iconify.design/lucide:bar-chart.svg?color=%2351cf66&width=32)

# Padrões para Observabilidade

> Logs estruturados, métricas, tracing e alertas para sistemas distribuídos observáveis.

[![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-1.0-blueviolet.svg)](https://opentelemetry.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-compatible-orange.svg)](https://prometheus.io/)
[![Status](https://img.shields.io/badge/status-completo-success.svg)]()

**[⬅️ Voltar](../) · [🏠 Home](../README.md)**

---

## 📖 Visão Geral

Este guia reúne os padrões de observabilidade da QBEM, garantindo **visibilidade**, **rastreabilidade** e **diagnóstico eficiente** de problemas em sistemas distribuídos.

### 🎯 O que você encontrará aqui

- ✅ Logs estruturados em JSON
- ✅ Métricas padronizadas (RED/USE)
- ✅ Distributed tracing com OpenTelemetry
- ✅ Alertas e SLOs
- ✅ Dashboards e visualização

### 🏛️ Os Três Pilares da Observabilidade

1. **Logs** — O que aconteceu e quando (eventos discretos)
2. **Métricas** — Quanto e com que frequência (agregações numéricas)
3. **Traces** — Como e por onde (fluxo de requisições)

---

## 📚 Documentação

### ![file-json](https://api.iconify.design/lucide:file-json.svg?width=20) [1. Logs Estruturados](logs.md)

Padrões para logs estruturados e contextuais.

**Conteúdo:**
- ![package](https://api.iconify.design/lucide:package.svg?width=14) Formato padrão (JSON, campos obrigatórios)
- ![layers](https://api.iconify.design/lucide:layers.svg?width=14) Níveis de log (TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
- ![key](https://api.iconify.design/lucide:key.svg?width=14) Campos obrigatórios (timestamp, level, message, trace_id, service)
- ![tag](https://api.iconify.design/lucide:tag.svg?width=14) Contexto adicional (user_id, request_id, environment)
- ![alert-triangle](https://api.iconify.design/lucide:alert-triangle.svg?width=14) Tratamento de erros (stack traces, error codes)
- ![shield](https://api.iconify.design/lucide:shield.svg?width=14) Segurança (sanitização de PII, mascaramento)
- ![search](https://api.iconify.design/lucide:search.svg?width=14) Boas práticas de busca e retenção
- ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=14) Exemplos por linguagem

**[📖 Ler documento completo →](logs.md)**

---

### ![activity](https://api.iconify.design/lucide:activity.svg?width=20) [2. Métricas](metrics.md)

Métricas padronizadas para monitoramento de serviços.

**Conteúdo:**
- ![target](https://api.iconify.design/lucide:target.svg?width=14) Metodologias (RED: Rate, Errors, Duration / USE: Utilization, Saturation, Errors)
- ![gauge](https://api.iconify.design/lucide:gauge.svg?width=14) Tipos de métricas (Counter, Gauge, Histogram, Summary)
- ![tag](https://api.iconify.design/lucide:tag.svg?width=14) Convenções de nomenclatura (snake_case, namespaces)
- ![tags](https://api.iconify.design/lucide:tags.svg?width=14) Labels/tags (service, environment, version, endpoint)
- ![box](https://api.iconify.design/lucide:box.svg?width=14) Métricas obrigatórias (HTTP, gRPC, background jobs, database)
- ![clock](https://api.iconify.design/lucide:clock.svg?width=14) Latência e percentis (p50, p95, p99)
- ![database](https://api.iconify.design/lucide:database.svg?width=14) Cardinalidade (evitar explosão de labels)
- ![code](https://api.iconify.design/lucide:code.svg?width=14) Instrumentação (Prometheus, OpenTelemetry)

**[📖 Ler documento completo →](metrics.md)**

---

### ![network](https://api.iconify.design/lucide:network.svg?width=20) [3. Distributed Tracing](tracing.md)

Rastreamento de requisições em sistemas distribuídos.

**Conteúdo:**
- ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=14) Conceitos (Trace, Span, Context Propagation)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) W3C Trace Context (traceparent, tracestate)
- ![package](https://api.iconify.design/lucide:package.svg?width=14) OpenTelemetry (instrumentação automática e manual)
- ![tags](https://api.iconify.design/lucide:tags.svg?width=14) Atributos de span (obrigatórios e opcionais)
- ![shuffle](https://api.iconify.design/lucide:shuffle.svg?width=14) Propagação de contexto (HTTP headers, mensageria)
- ![percent](https://api.iconify.design/lucide:percent.svg?width=14) Sampling (estratégias, trade-offs)
- ![eye](https://api.iconify.design/lucide:eye.svg?width=14) Visualização e análise
- ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=14) Exemplos de instrumentação

**[📖 Ler documento completo →](tracing.md)**

---

### ![bell](https://api.iconify.design/lucide:bell.svg?width=20) [4. Alertas e SLOs](alerts.md)

Sistema de alertas baseado em SLOs e SLIs.

**Conteúdo:**
- ![target](https://api.iconify.design/lucide:target.svg?width=14) SLI/SLO/SLA (definições e diferenças)
- ![trending-up](https://api.iconify.design/lucide:trending-up.svg?width=14) Error Budget (cálculo e gestão)
- ![alert-triangle](https://api.iconify.design/lucide:alert-triangle.svg?width=14) Tipos de alertas (sintoma vs causa, severidade)
- ![zap](https://api.iconify.design/lucide:zap.svg?width=14) Alertas obrigatórios (latência, taxa de erro, disponibilidade)
- ![book](https://api.iconify.design/lucide:book.svg?width=14) Runbooks (documentação de resposta)
- ![users](https://api.iconify.design/lucide:users.svg?width=14) On-call e escalation
- ![mute](https://api.iconify.design/lucide:mute.svg?width=14) Silencing e manutenção programada
- ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=14) Checklist de configuração

**[📖 Ler documento completo →](alerts.md)**

---

### ![layout-dashboard](https://api.iconify.design/lucide:layout-dashboard.svg?width=20) [5. Dashboards](dashboards.md)

Visualização eficaz de métricas e saúde do sistema.

**Conteúdo:**
- ![layers](https://api.iconify.design/lucide:layers.svg?width=14) Hierarquia (Overview, Service, Resource)
- ![layout](https://api.iconify.design/lucide:layout.svg?width=14) Estrutura de dashboards (RED/USE, Golden Signals)
- ![bar-chart-2](https://api.iconify.design/lucide:bar-chart-2.svg?width=14) Painéis obrigatórios (HTTP, gRPC, jobs, infra)
- ![sparkles](https://api.iconify.design/lucide:sparkles.svg?width=14) Boas práticas (menos é mais, contexto claro)
- ![palette](https://api.iconify.design/lucide:palette.svg?width=14) Design e usabilidade
- ![code](https://api.iconify.design/lucide:code.svg?width=14) Dashboard as Code (Grafana, Terraform)
- ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=14) Exemplos e templates

**[📖 Ler documento completo →](dashboards.md)**

---

### ![wrench](https://api.iconify.design/lucide:wrench.svg?width=20) [6. Ferramentas](tools.md)

Stack de ferramentas para observabilidade.

**Conteúdo:**
- ![package](https://api.iconify.design/lucide:package.svg?width=14) Stack padrão QBEM
- ![file-json](https://api.iconify.design/lucide:file-json.svg?width=14) Logs (Loki, Elasticsearch)
- ![activity](https://api.iconify.design/lucide:activity.svg?width=14) Métricas (Prometheus, Grafana)
- ![network](https://api.iconify.design/lucide:network.svg?width=14) Tracing (Jaeger, Tempo)
- ![code](https://api.iconify.design/lucide:code.svg?width=14) SDKs (OpenTelemetry por linguagem)
- ![box](https://api.iconify.design/lucide:box.svg?width=14) Collectors (OTEL Collector)
- ![cloud](https://api.iconify.design/lucide:cloud.svg?width=14) SaaS vs Self-hosted
- ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) Guias de instalação

**[📖 Ler documento completo →](tools.md)**

---

### ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=20) [7. Exemplos](examples/)

Exemplos práticos de instrumentação.

**Estrutura:**
- ![folder](https://api.iconify.design/lucide:folder.svg?width=14) `python/` — Exemplos Python (structlog, prometheus-client, OpenTelemetry)
- ![folder](https://api.iconify.design/lucide:folder.svg?width=14) `dotnet/` — Exemplos C# (.NET Core) (Serilog, prometheus-net, OpenTelemetry)
- ![folder](https://api.iconify.design/lucide:folder.svg?width=14) `prometheus/` — Regras de alerta e recording rules
- ![folder](https://api.iconify.design/lucide:folder.svg?width=14) `grafana/` — Dashboards (RED, USE, SLO)

**Arquivos de referência:**
- ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) `log-format.json` — Formato padrão de log estruturado
- ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) `trace-span.json` — Formato padrão de span OpenTelemetry
- ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) `metrics-http.prom` — Métricas HTTP em formato Prometheus

**[📁 Ver todos os exemplos →](examples/)**

---

## 🚀 Como Usar

### ![code](https://api.iconify.design/lucide:code.svg?width=16) Para Implementar Observabilidade em um Serviço

1. ![file-json](https://api.iconify.design/lucide:file-json.svg?width=14) Configure **logs estruturados** seguindo [logs.md](logs.md)
2. ![activity](https://api.iconify.design/lucide:activity.svg?width=14) Exponha **métricas** conforme [metrics.md](metrics.md)
3. ![network](https://api.iconify.design/lucide:network.svg?width=14) Instrumente **tracing** usando [tracing.md](tracing.md)
4. ![bell](https://api.iconify.design/lucide:bell.svg?width=14) Defina **alertas** baseados em [alerts.md](alerts.md)
5. ![layout-dashboard](https://api.iconify.design/lucide:layout-dashboard.svg?width=14) Crie **dashboards** conforme [dashboards.md](dashboards.md)
6. ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) Configure stack usando [tools.md](tools.md)

### ![eye](https://api.iconify.design/lucide:eye.svg?width=16) Para Diagnosticar Problemas

```bash
# 1. Identificar o problema (métricas/alertas)
# Dashboard mostra latência p99 elevada

# 2. Buscar logs relacionados
# Filtrar por trace_id, time range, error level

# 3. Analisar trace distribuído
# Identificar span lento na cadeia

# 4. Correlacionar contexto
# Logs + métricas + trace do mesmo trace_id
```

### ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=16) Checklist de Observabilidade

Use esta checklist antes de colocar um serviço em produção:

- [ ] ![file-json](https://api.iconify.design/lucide:file-json.svg?width=14) Logs estruturados em JSON com campos obrigatórios
- [ ] ![activity](https://api.iconify.design/lucide:activity.svg?width=14) Métricas RED/USE expostas em `/metrics`
- [ ] ![network](https://api.iconify.design/lucide:network.svg?width=14) Tracing instrumentado com propagação de contexto
- [ ] ![heart-pulse](https://api.iconify.design/lucide:heart-pulse.svg?width=14) Health checks (`/health`, `/ready`) implementados
- [ ] ![bell](https://api.iconify.design/lucide:bell.svg?width=14) Alertas críticos configurados com runbooks
- [ ] ![layout-dashboard](https://api.iconify.design/lucide:layout-dashboard.svg?width=14) Dashboard básico (RED) criado
- [ ] ![key](https://api.iconify.design/lucide:key.svg?width=14) Correlation IDs em todas as requisições
- [ ] ![shield](https://api.iconify.design/lucide:shield.svg?width=14) PII sanitizada em logs
- [ ] ![percent](https://api.iconify.design/lucide:percent.svg?width=14) Sampling de traces configurado (evitar custo excessivo)
- [ ] ![database](https://api.iconify.design/lucide:database.svg?width=14) Retenção de logs definida (ex: 30 dias)

---

## 📐 Princípios Fundamentais

### ![layers](https://api.iconify.design/lucide:layers.svg?width=16) Observabilidade, não Monitoramento

**Monitoramento tradicional:**
- Você sabe o que procurar (métricas predefinidas)
- "Known unknowns"

**Observabilidade moderna:**
- Você explora o desconhecido (alta cardinalidade, contexto rico)
- "Unknown unknowns"

### ![key](https://api.iconify.design/lucide:key.svg?width=16) Correlação é Essencial

Tudo deve ser correlacionável:
```json
{
  "timestamp": "2025-01-10T14:30:00Z",
  "level": "ERROR",
  "message": "Payment processing failed",
  "trace_id": "abc123",
  "span_id": "def456",
  "user_id": "u_789",
  "order_id": "ord_999"
}
```

### ![zap](https://api.iconify.design/lucide:zap.svg?width=16) Instrumentação Automática Primeiro

Priorize instrumentação automática (OpenTelemetry Auto-Instrumentation) antes de manual:
- ✅ Menos código para manter
- ✅ Cobertura padrão garantida
- ✅ Upgrades mais fáceis

### ![gauge](https://api.iconify.design/lucide:gauge.svg?width=16) Golden Signals

Todo serviço deve expor:
1. **Latency** — Tempo de resposta
2. **Traffic** — Requisições por segundo
3. **Errors** — Taxa de erro
4. **Saturation** — Uso de recursos

### ![shield](https://api.iconify.design/lucide:shield.svg?width=16) Segurança em Observabilidade

- 🔒 Não logue senhas, tokens, PII não mascarada
- 🔐 Controle de acesso a logs/métricas/traces
- 🕵️ Auditoria de quem acessa dados sensíveis
- ⏱️ Retenção adequada (compliance vs custo)

---

## 🔗 Links Úteis

### Especificações
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [OpenTelemetry](https://opentelemetry.io/)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [W3C Trace Context](https://www.w3.org/TR/trace-context/)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [Prometheus Exposition Format](https://prometheus.io/docs/instrumenting/exposition_formats/)

### Metodologias
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [RED Method](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [USE Method](https://www.brendangregg.com/usemethod.html)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [Google SRE Book - Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)

### Ferramentas
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [Prometheus](https://prometheus.io/)
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [Grafana](https://grafana.com/)
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [Jaeger](https://www.jaegertracing.io/)
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [Loki](https://grafana.com/oss/loki/)
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [Tempo](https://grafana.com/oss/tempo/)

### Documentos Relacionados
- ![arrow-right](https://api.iconify.design/lucide:arrow-right.svg?width=14) [APIs HTTP](../apis/) — Padrões para APIs RESTful
- ![arrow-right](https://api.iconify.design/lucide:arrow-right.svg?width=14) [Mensageria Assíncrona](../async/) — Padrões para eventos
- ![arrow-right](https://api.iconify.design/lucide:arrow-right.svg?width=14) [ADRs](../adr/) — Decisões arquiteturais

---

## 🤝 Como Contribuir

Encontrou algo que pode ser melhorado? Contribuições são bem-vindas!

1. ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) Leia [CONTRIBUTING.md](../CONTRIBUTING.md)
2. ![message-circle](https://api.iconify.design/lucide:message-circle.svg?width=14) Abra uma issue para discutir sua proposta
3. ![git-pull-request](https://api.iconify.design/lucide:git-pull-request.svg?width=14) Envie um Pull Request com sua melhoria
4. ![users](https://api.iconify.design/lucide:users.svg?width=14) Aguarde revisão dos CODEOWNERS

**Dúvidas ou sugestões?** Abra uma issue neste repositório!

---

## 📊 Status da Documentação

| Documento | Status | Última Atualização |
|-----------|--------|-------------------|
| Logs Estruturados | ✅ Completo | 2025-01-10 |
| Métricas | ✅ Completo | 2025-01-10 |
| Distributed Tracing | ✅ Completo | 2025-01-10 |
| Alertas e SLOs | ✅ Completo | 2025-01-10 |
| Dashboards | ✅ Completo | 2025-01-10 |
| Ferramentas | ✅ Completo | 2025-01-10 |
| Exemplos | ✅ Completo | 2025-01-10 |

---

**[⬆ Voltar ao topo](#padrões-para-observabilidade)**

**[🏠 Voltar para Standards](../README.md)**

---

*Mantido com ❤️ pela equipe de arquitetura QBEM*