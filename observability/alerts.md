# Alertas e SLOs

Sistema de alertas baseado em SLIs, SLOs e Error Budgets para garantir confiabilidade.

---

## 1) Conceitos Fundamentais

### SLI, SLO, SLA

| Conceito | Definição | Exemplo |
|----------|-----------|---------|
| **SLI** (Service Level Indicator) | Métrica que mede a saúde do serviço | Latência p95, taxa de sucesso |
| **SLO** (Service Level Objective) | Meta interna de confiabilidade | 99.9% de disponibilidade |
| **SLA** (Service Level Agreement) | Contrato externo com consequências | 99.5% uptime ou reembolso |

**Hierarquia:**
```
SLA ≤ SLO ≤ Performance Real

Exemplo:
99.5% (SLA) < 99.9% (SLO) < 99.95% (real)
```

**Regra de ouro:** SLO deve ser mais restritivo que SLA para ter buffer de segurança.

---

## 2) Error Budget

### O que é Error Budget?

**Error Budget** = Quantidade de erro permitida sem violar o SLO.

```
Error Budget = 100% - SLO
```

**Exemplo:**
- SLO: 99.9% (uptime mensal)
- Error Budget: 0.1% = 43 minutos por mês
- Se gastar 43 minutos de downtime, **esgotou o budget**

### Calculando Error Budget

**Fórmula:**
```
Error Budget (segundos) = (1 - SLO) × Período (segundos)

Exemplo (SLO 99.9% em 30 dias):
(1 - 0.999) × (30 × 24 × 60 × 60) = 2.592 segundos = 43,2 minutos
```

### Consumo de Error Budget

**Monitorar com PromQL:**
```promql
# % do error budget consumido
(1 - (sum(rate(http_requests_total{status=~"2..|3.."}[30d])) / sum(rate(http_requests_total[30d])))) / (1 - 0.999) * 100
```

**Ações baseadas no budget:**

| Budget Restante | Ação |
|-----------------|------|
| > 50% | Deploy normal, experimentos permitidos |
| 25-50% | Cautela, reduzir deploys arriscados |
| 10-25% | Congelar features, foco em confiabilidade |
| < 10% | **CODE FREEZE**, apenas hotfixes críticos |

---

## 3) Definindo SLIs

### SLIs Comuns

#### Disponibilidade (Availability)

```
Availability = (Requisições bem-sucedidas) / (Total de requisições)
```

**PromQL:**
```promql
sum(rate(http_requests_total{status=~"2..|3.."}[5m])) 
/ 
sum(rate(http_requests_total[5m]))
```

**Bom SLI:**
- ✅ Baseado em requisições (não em uptime de servidor)
- ✅ Do ponto de vista do usuário
- ✅ Exclui erros do cliente (4xx) se apropriado

#### Latência

```
Latência p95 < 500ms
```

**PromQL:**
```promql
histogram_quantile(0.95, 
  rate(http_request_duration_seconds_bucket[5m])
) < 0.5
```

**Por que p95 e não média?**
- Média esconde outliers
- p95 garante que 95% dos usuários têm boa experiência

#### Taxa de Erro

```
Error Rate = (Requisições com erro) / (Total de requisições)
```

**PromQL:**
```promql
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m]))
```

#### Throughput (Capacidade)

```
Requests per Second (RPS) > mínimo esperado
```

**PromQL:**
```promql
sum(rate(http_requests_total[5m]))
```

### Tabela de SLIs Recomendados

| Tipo de Serviço | SLI Primário | SLI Secundário | SLO Típico |
|-----------------|--------------|----------------|------------|
| API REST | Disponibilidade | Latência p95 | 99.9% / 500ms |
| API gRPC | Taxa de sucesso | Latência p99 | 99.95% / 200ms |
| Background Job | Taxa de sucesso | Duração p95 | 99% / 5min |
| Sistema de Fila | Latência de processamento | Taxa de DLQ | p95 < 30s / < 0.1% |
| Banco de Dados | Latência de query | Disponibilidade | p99 < 50ms / 99.99% |

---

## 4) Definindo SLOs

### Formato Padrão

```yaml
slo:
  name: "API Orders - Availability"
  service: "order-service"
  sli:
    metric: "availability"
    query: |
      sum(rate(http_requests_total{service="order-service",status=~"2..|3.."}[5m])) 
      / 
      sum(rate(http_requests_total{service="order-service"}[5m]))
  objective:
    target: 0.999  # 99.9%
    window: 30d
  error_budget:
    remaining: 43.2  # minutos
    burn_rate_alert: 2  # Alertar se queimar 2x mais rápido
```

### Propriedades de um SLO

**SMART:**
- **S**pecific — Claro e específico
- **M**easurable — Mensurável objetivamente
- **A**chievable — Atingível com esforço razoável
- **R**elevant — Relevante para o usuário
- **T**ime-bound — Com janela de tempo definida

---

## 5) Tipos de Alertas

### Sintoma vs Causa

| Tipo | Descrição | Exemplo | Quem aciona |
|------|-----------|---------|-------------|
| **Sintoma** | Problema percebido pelo usuário | Alta latência, erros 5xx | SLO, user-facing metrics |
| **Causa** | Problema na infraestrutura | CPU alto, disco cheio | Resource metrics, logs |

**Regra:** Alerte em **sintomas**, investigue **causas**.

❌ **Ruim:** "CPU > 80%" (causa, pode não impactar usuário)
✅ **Bom:** "Latência p95 > 1s" (sintoma, usuário sente)

### Severidade

| Severidade | Descrição | Exemplo | Ação |
|------------|-----------|---------|------|
| **CRITICAL** | Impacto severo no usuário | API down, error rate > 10% | Page on-call imediatamente |
| **HIGH** | Impacto moderado | Latência 2x pior, error rate > 1% | Notificar on-call, responder em 15min |
| **MEDIUM** | Potencial problema futuro | Error budget < 25% | Notificar equipe, planejar ação |
| **LOW** | Informacional | Deploy completo, config alterada | Log, sem ação imediata |

---

## 6) Alertas Obrigatórios

### 1. Disponibilidade (Availability)

**Alert:** API não está disponível ou taxa de erro alta.

**PromQL:**
```promql
# Regra de alerta
- alert: HighErrorRate
  expr: |
    (
      sum(rate(http_requests_total{status=~"5.."}[5m])) 
      / 
      sum(rate(http_requests_total[5m]))
    ) > 0.05  # > 5% de erro
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High error rate on {{ $labels.service }}"
    description: "Error rate is {{ $value | humanizePercentage }} (threshold: 5%)"
    runbook_url: "https://wiki.qbem.net.br/runbooks/high-error-rate"
```

### 2. Latência (Latency)

**Alert:** Latência acima do SLO.

**PromQL:**
```promql
- alert: HighLatency
  expr: |
    histogram_quantile(0.95, 
      rate(http_request_duration_seconds_bucket[5m])
    ) > 1.0  # p95 > 1 segundo
  for: 5m
  labels:
    severity: high
  annotations:
    summary: "High latency on {{ $labels.service }}"
    description: "p95 latency is {{ $value }}s (threshold: 1s)"
    runbook_url: "https://wiki.qbem.net.br/runbooks/high-latency"
```

### 3. Error Budget Burn Rate

**Alert:** Error budget sendo consumido muito rápido.

**Conceito:** Se queimar error budget 10x mais rápido, ficará sem budget em 3 dias.

**PromQL (Multiwindow Burn Rate):**
```promql
- alert: ErrorBudgetBurnRateFast
  expr: |
    (
      (1 - (sum(rate(http_requests_total{status=~"2..|3.."}[1h])) 
            / sum(rate(http_requests_total[1h]))))
      / (1 - 0.999)  # SLO 99.9%
    ) > 10  # Queimando 10x mais rápido
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Fast error budget burn on {{ $labels.service }}"
    description: "Error budget burn rate is {{ $value }}x (at this rate, budget will be exhausted in 3 days)"
```

### 4. Saturação (Saturation)

**Alert:** Recursos próximos do limite.

**PromQL (CPU):**
```promql
- alert: HighCPUUsage
  expr: |
    (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))) > 0.8
  for: 15m
  labels:
    severity: high
  annotations:
    summary: "High CPU usage on {{ $labels.instance }}"
    description: "CPU usage is {{ $value | humanizePercentage }}"
```

**PromQL (Memória):**
```promql
- alert: HighMemoryUsage
  expr: |
    (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.9
  for: 10m
  labels:
    severity: high
  annotations:
    summary: "High memory usage on {{ $labels.instance }}"
    description: "Memory usage is {{ $value | humanizePercentage }}"
```

### 5. Healthcheck Failing

**Alert:** Endpoint de health não responde.

**PromQL (Blackbox Exporter):**
```promql
- alert: ServiceDown
  expr: |
    probe_success{job="blackbox"} == 0
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Service {{ $labels.instance }} is down"
    description: "Healthcheck failing for 2 minutes"
    runbook_url: "https://wiki.qbem.net.br/runbooks/service-down"
```

---

## 7) Runbooks

**Runbook** = Documentação de como responder a um alerta.

### Estrutura de Runbook

```markdown
# Runbook: High Error Rate

## Descrição
Taxa de erro acima de 5% por mais de 5 minutos.

## Severidade
**CRITICAL** - Impacto direto nos usuários.

## Causa Provável
1. Deploy recente com bug
2. Dependência externa falhando
3. Problema de infraestrutura (DB, cache)

## Diagnóstico

### 1. Verificar logs recentes
```bash
kubectl logs -l app=order-service --tail=100 --since=10m | grep ERROR
```

### 2. Verificar traces com erro
- Acessar Jaeger: https://jaeger.qbem.net.br
- Filtrar por: `service=order-service` e `error=true`
- Analisar span com maior latência ou erro

### 3. Verificar métricas de dependências
```promql
rate(http_requests_total{service="payment-service",status=~"5.."}[5m])
```

## Ações de Mitigação

### Ação 1: Rollback de Deploy
Se houve deploy recente (< 30min):
```bash
kubectl rollout undo deployment/order-service
```

### Ação 2: Escalar Serviço
Se alta carga:
```bash
kubectl scale deployment/order-service --replicas=10
```

### Ação 3: Ativar Circuit Breaker
Se dependência falhando:
```bash
# Ativar feature flag para circuit breaker
curl -X POST https://config.qbem.net.br/flags/payment-circuit-breaker/enable
```

## Escalação
- **< 15min:** Engenheiro on-call tenta mitigar
- **15-30min:** Escalar para tech lead
- **> 30min:** Escalar para gerência + comunicar clientes

## Postmortem
Após resolver, criar postmortem:
https://wiki.qbem.net.br/postmortems/new

## Links Úteis
- Dashboard: https://grafana.qbem.net.br/d/order-service
- Logs: https://loki.qbem.net.br
- Traces: https://jaeger.qbem.net.br
```

---

## 8) On-Call e Escalação

### Rotação de On-Call

**Recomendações:**
- Rotação semanal (não diária)
- Máximo 2 semanas consecutivas
- Backup on-call sempre disponível
- Compensação por plantão (folga ou pagamento)

### Níveis de Escalação

```
Level 1 (L1) - Engenheiro On-Call
  ↓ (após 15min sem resolução)
Level 2 (L2) - Tech Lead / Senior
  ↓ (após 30min sem resolução)
Level 3 (L3) - Gerente de Engenharia
  ↓ (após 1h sem resolução)
Level 4 (L4) - CTO + Comunicação Externa
```

### Configuração Alertmanager

```yaml
# alertmanager.yml
route:
  receiver: 'team-pager'
  group_by: ['alertname', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  
  routes:
    # Alertas críticos - page imediato
    - match:
        severity: critical
      receiver: 'team-pager'
      continue: true
    
    # Alertas high - notificar Slack
    - match:
        severity: high
      receiver: 'team-slack'
      continue: true
    
    # Alertas low/medium - apenas log
    - match_re:
        severity: (low|medium)
      receiver: 'team-email'

receivers:
  - name: 'team-pager'
    pagerduty_configs:
      - service_key: '<pagerduty-service-key>'
        description: '{{ .CommonAnnotations.summary }}'
  
  - name: 'team-slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/XXX'
        channel: '#alerts-production'
        title: '{{ .CommonAnnotations.summary }}'
  
  - name: 'team-email'
    email_configs:
      - to: 'team@qbem.net.br'
        from: 'alerts@qbem.net.br'
```

---

## 9) Silenciamento (Silencing)

### Quando Silenciar

**Casos válidos:**
- Manutenção programada
- Deploy conhecido que causa alertas temporários
- Falso positivo conhecido (enquanto corrige regra)

**❌ Nunca silenciar:**
- Alertas porque "sempre disparam"
- Problema real que você está ignorando

### Como Silenciar

**Via Alertmanager UI:**
1. Acessar Alertmanager UI
2. Selecionar alerta
3. Clicar em "Silence"
4. Definir duração e motivo
5. Confirmar

**Via API (automação):**
```bash
# Criar silenciamento
curl -X POST http://alertmanager:9093/api/v2/silences \
  -H 'Content-Type: application/json' \
  -d '{
    "matchers": [
      {"name": "alertname", "value": "HighErrorRate", "isRegex": false}
    ],
    "startsAt": "2025-01-10T14:00:00Z",
    "endsAt": "2025-01-10T16:00:00Z",
    "createdBy": "oncall@qbem.net.br",
    "comment": "Deploy de nova versão - silenciar temporariamente"
  }'
```

---

## 10) Postmortem

Após incidente resolvido, **sempre** fazer postmortem:

### Template de Postmortem

```markdown
# Postmortem: [TÍTULO DO INCIDENTE]

**Data:** 2025-01-10
**Duração:** 45 minutos (14:30 - 15:15 UTC)
**Severidade:** CRITICAL
**Autor:** João Silva

---

## Resumo Executivo

Em 10/01/2025 às 14:30, o serviço de Orders ficou indisponível por 45 minutos, 
resultando em 100% de erro nas requisições. Aproximadamente 10.000 usuários 
foram impactados. O problema foi causado por um bug introduzido no deploy 
da versão 2.3.1.

---

## Impacto

- **Usuários afetados:** ~10.000
- **Receita perdida:** R$ 50.000 (estimado)
- **Error budget consumido:** 18 minutos (42% do budget mensal)
- **SLO status:** ⚠️ Em risco (75% do budget restante)

---

## Timeline

| Hora | Evento |
|------|--------|
| 14:30 | Deploy da versão 2.3.1 iniciado |
| 14:32 | Alerta "HighErrorRate" disparado |
| 14:35 | Engenheiro on-call notificado |
| 14:40 | Identificado problema no novo código |
| 14:45 | Rollback iniciado |
| 14:50 | Rollback completo |
| 15:15 | Serviço estabilizado, error rate < 0.1% |

---

## Causa Raiz

Bug no código de validação de orders introduzido no PR #1234.

**Por que passou despercebido:**
- Testes unitários não cobriam caso edge
- Staging não tinha dados de teste representativos
- Code review não identificou o problema

---

## Ações de Mitigação (o que fizemos)

1. ✅ Rollback para versão 2.3.0 (14:45)
2. ✅ Comunicação com clientes via status page (14:50)
3. ✅ Validação de rollback bem-sucedido (15:00)

---

## Ações Preventivas (o que faremos)

| Ação | Responsável | Prazo | Status |
|------|-------------|-------|--------|
| Adicionar testes para edge cases | João Silva | 12/01 | ✅ Concluído |
| Atualizar dataset de staging | Maria Santos | 15/01 | 🔄 Em progresso |
| Implementar canary deployment | Pedro Costa | 20/01 | 📅 Planejado |
| Criar runbook para rollback rápido | Ana Lima | 13/01 | ✅ Concluído |

---

## Lições Aprendidas

### O que funcionou bem ✅
- Alertas dispararam rapidamente (2min após deploy)
- Rollback foi executado em < 15min
- Comunicação com clientes foi clara

### O que pode melhorar ⚠️
- Testes de edge cases insuficientes
- Staging não reflete produção
- Sem canary deployment (100% de tráfego de uma vez)

---

## Referências

- Alerta Disparado: [HighErrorRate](https://alertmanager.qbem.net.br/alert/123)
- Dashboard: [Order Service](https://grafana.qbem.net.br/d/orders)
- PR com bug: [#1234](https://github.com/qbem/orders/pull/1234)
- PR com fix: [#1240](https://github.com/qbem/orders/pull/1240)
```

---

## 11) Boas Práticas

### ✅ Faça

1. **Alerte em sintomas, não causas**
   - Foco no impacto do usuário

2. **Tenha runbooks para todos alertas críticos**
   - Documentação clara de resposta

3. **Configure severidade apropriada**
   - CRITICAL apenas para impacto severo

4. **Use error budget para decisões**
   - Congelar features quando budget baixo

5. **Faça postmortem sem culpa**
   - Foco em melhorar o sistema

6. **Teste alertas regularmente**
   - Verifique se notificações funcionam

### ❌ Evite

1. **Alert fatigue**
   - Muitos alertas = ninguém responde

2. **Alertas sem ação clara**
   - Todo alerta deve ter runbook

3. **Silenciar problemas reais**
   - Corrigir a causa, não o alerta

4. **SLOs muito ambiciosos**
   - 99.999% é muito caro

5. **Ignorar error budget**
   - É um contrato com o usuário

---

## 12) Checklist

Antes de ir para produção:

- [ ] SLOs definidos (availability, latency, error rate)
- [ ] Error budget calculado e monitorado
- [ ] Alertas críticos configurados (error rate, latency, saturation)
- [ ] Runbooks escritos para cada alerta crítico
- [ ] Alertmanager configurado com routing correto
- [ ] On-call rotation definida e testada
- [ ] Silencing policy documentada
- [ ] Postmortem template pronto
- [ ] Dashboard de SLOs criado
- [ ] Teste de ponta-a-ponta (disparar alerta e verificar notificação)

---

## 13) Ferramentas Recomendadas

### Alerting
- **Prometheus Alertmanager** — Gerenciamento de alertas open-source
- **PagerDuty** — On-call management e escalation
- **Opsgenie** — Alternativa ao PagerDuty
- **VictorOps** — Incident management

### SLO Tracking
- **Sloth** — Gerador de SLOs para Prometheus
- **Pyrra** — UI para visualizar SLOs
- **Google SLO Generator** — Ferramenta do Google para SLO automation

### Incident Management
- **Incident.io** — Incident management moderno
- **Jira Service Management** — Ticketing + incident
- **StatusPage** — Comunicação com clientes

---

## Referências

- [Google SRE Book - SLIs, SLOs, SLAs](https://sre.google/sre-book/service-level-objectives/)
- [Google SRE Workbook - Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
- [Prometheus Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
- [The Art of SLOs (Alex Hidalgo)](https://www.oreilly.com/library/view/the-art-of/9781492076414/)