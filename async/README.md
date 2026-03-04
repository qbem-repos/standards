![zap](https://api.iconify.design/lucide:zap.svg?color=%23ffd700&width=32)

# Padrões para Mensageria Assíncrona

> Padrões, convenções e recomendações para eventos, filas e streaming em integrações assíncronas.

[![AsyncAPI 3.0](https://img.shields.io/badge/AsyncAPI-3.0-purple.svg)](https://www.asyncapi.com/)
[![Protobuf](https://img.shields.io/badge/Protobuf-3-blue.svg)](https://protobuf.dev/)
[![Status](https://img.shields.io/badge/status-completo-success.svg)]()

**[⬅️ Voltar](../) · [🏠 Home](../README.md)**

---

## 📖 Visão Geral

Este guia reúne os padrões para mensageria assíncrona, garantindo **consistência**, **confiabilidade**, **segurança** e **observabilidade** em sistemas distribuídos.

### 🎯 O que você encontrará aqui

- ✅ Convenções de nomes, envelopes e headers
- ✅ Estratégias de confiabilidade (retries, DLQ, idempotência)
- ✅ Evolução de schemas compatível
- ✅ Práticas de segurança (criptografia, ACLs, HMAC)
- ✅ Exemplos práticos (AsyncAPI, Protobuf, JSON)

---

## 📚 Documentação

### ![file-text](https://api.iconify.design/lucide:file-text.svg?width=20) [1. Convenções](conventions.md)

Padrões fundamentais para eventos, filas e streaming.

**Conteúdo:**
- ![tag](https://api.iconify.design/lucide:tag.svg?width=14) Nomes de tópicos/filas e eventos (kebab-case, domínio.recurso.ação)
- ![package](https://api.iconify.design/lucide:package.svg?width=14) Estrutura do evento (envelope padrão com event_id, event_type, occurred_at)
- ![header](https://api.iconify.design/lucide:header.svg?width=14) Headers padrão (trace_id, correlation_id, idempotency_key)
- ![repeat](https://api.iconify.design/lucide:repeat.svg?width=14) Entrega, ordenação e idempotência (at-least-once, partition_key)
- ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=14) Evolução de schema (compatibilidade, versioning)
- ![shield](https://api.iconify.design/lucide:shield.svg?width=14) Segurança (TLS, ACLs, sanitização)
- ![activity](https://api.iconify.design/lucide:activity.svg?width=14) Observabilidade (traces, métricas, logs estruturados)
- ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) Contratos (AsyncAPI/Protobuf)
- ![database](https://api.iconify.design/lucide:database.svg?width=14) SLA de reprocessamento e DLQ
- ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=14) Checklist para novos eventos

**[📖 Ler documento completo →](conventions.md)**

---

### ![tag](https://api.iconify.design/lucide:tag.svg?width=20) [2. Headers Padrão](headers.md)

Headers/atributos obrigatórios para correlação, idempotência, segurança e observabilidade.

**Conteúdo:**
- ![list](https://api.iconify.design/lucide:list.svg?width=14) Campos padrão (trace_id, correlation_id, idempotency_key, schema_version)
- ![network](https://api.iconify.design/lucide:network.svg?width=14) W3C Trace Context (traceparent, tracestate)
- ![boxes](https://api.iconify.design/lucide:boxes.svg?width=14) Mapeamento por broker:
  - Apache Kafka (headers nativos)
  - AWS SQS/SNS (MessageAttributes)
  - Google Pub/Sub (attributes)
  - RabbitMQ (BasicProperties.headers)
- ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=14) Assinatura HMAC (opcional, para mensagens fora da rede confiável)
- ![refresh-cw](https://api.iconify.design/lucide:refresh-cw.svg?width=14) Idempotência no consumidor (cache com TTL)
- ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=14) Checklist por broker

**[📖 Ler documento completo →](headers.md)**

---

### ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=20) [3. Evolução de Schemas](schema-evolution.md)

Regras para evolução compatível de schemas, versionamento e validação.

**Conteúdo:**
- ![target](https://api.iconify.design/lucide:target.svg?width=14) Princípios (compatível por padrão, versão no contrato e tópico)
- ![hash](https://api.iconify.design/lucide:hash.svg?width=14) Mapeamento de SemVer (MAJOR, MINOR, PATCH)
- ![check-circle](https://api.iconify.design/lucide:check-circle.svg?width=14) O que é compatível (adicionar campos opcionais, enum values)
- ![x-circle](https://api.iconify.design/lucide:x-circle.svg?width=14) O que é breaking (campo obrigatório, mudança de tipo, remoção)
- ![box](https://api.iconify.design/lucide:box.svg?width=14) Padrões de modelagem (datas ISO 8601, valores monetários, enums)
- ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=14) Exemplos de mudanças (compatível vs breaking)
- ![workflow](https://api.iconify.design/lucide:workflow.svg?width=14) Estratégia de migração (dual-write, shadow read, cutover)
- ![git-merge](https://api.iconify.design/lucide:git-merge.svg?width=14) Versionar no tópico vs só no schema
- ![check-square](https://api.iconify.design/lucide:check-square.svg?width=14) Validação em CI (buf breaking, asyncapi validate)
- ![table](https://api.iconify.design/lucide:table.svg?width=14) Matriz de compatibilidade

**[📖 Ler documento completo →](schema-evolution.md)**

---

### ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=20) [4. Confiabilidade](reliability.md)

Estratégias para processamento robusto, retries, DLQ e monitoramento.

**Conteúdo:**
- ![package-check](https://api.iconify.design/lucide:package-check.svg?width=14) Entrega e semântica (at-least-once, exactly-once)
- ![repeat](https://api.iconify.design/lucide:repeat.svg?width=14) Retries com backoff exponencial
- ![inbox](https://api.iconify.design/lucide:inbox.svg?width=14) Dead Letter Queue (DLQ obrigatória, estrutura, replay)
- ![refresh-cw](https://api.iconify.design/lucide:refresh-cw.svg?width=14) Idempotência (deduplicação por event_id, TTL)
- ![clock](https://api.iconify.design/lucide:clock.svg?width=14) Timeouts e circuit breaker
- ![arrow-down-up](https://api.iconify.design/lucide:arrow-down-up.svg?width=14) Ordenação (garantida por partition_key)
- ![activity](https://api.iconify.design/lucide:activity.svg?width=14) Monitoramento e alertas (métricas obrigatórias)
- ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=14) Checklist de confiabilidade

**[📖 Ler documento completo →](reliability.md)**

---

### ![lock](https://api.iconify.design/lucide:lock.svg?width=20) [5. Segurança](security.md)

Práticas de segurança: criptografia, autenticação, autorização e privacidade.

**Conteúdo:**
- ![shield](https://api.iconify.design/lucide:shield.svg?width=14) Criptografia (TLS obrigatório, criptografia de payload)
- ![key](https://api.iconify.design/lucide:key.svg?width=14) Autenticação (SASL/SCRAM, OAuth, mTLS, IAM)
- ![lock-keyhole](https://api.iconify.design/lucide:lock-keyhole.svg?width=14) Autorização/ACLs (controle granular por tópico/fila)
- ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=14) Integridade e autenticidade (HMAC-SHA256, timestamp)
- ![user-x](https://api.iconify.design/lucide:user-x.svg?width=14) Privacidade e PII (mascaramento, tokenização, LGPD/GDPR)
- ![file-search](https://api.iconify.design/lucide:file-search.svg?width=14) Auditoria (logs imutáveis, rastreabilidade)
- ![gauge](https://api.iconify.design/lucide:gauge.svg?width=14) Rate limiting e abuse prevention
- ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=14) Checklist de segurança

**[📖 Ler documento completo →](security.md)**

---

### ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=20) [6. Exemplos](examples/)

Contratos e payloads de referência prontos para uso.

**Arquivos disponíveis:**

- ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) [`user-created.asyncapi.yaml`](examples/user-created.asyncapi.yaml) — Contrato AsyncAPI 3.0 completo
- ![file-type](https://api.iconify.design/lucide:file-type.svg?width=14) [`order-paid.proto`](examples/order-paid.proto) — Exemplo de contrato Protobuf
- ![file-json](https://api.iconify.design/lucide:file-json.svg?width=14) [`payment-failed.json`](examples/payment-failed.json) — Exemplo de evento JSON

**[📁 Ver todos os exemplos →](examples/)**

---

## 🚀 Como Usar

### ![code](https://api.iconify.design/lucide:code.svg?width=16) Para Implementar um Novo Evento

1. ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) Leia [conventions.md](conventions.md) para entender os padrões básicos
2. ![tag](https://api.iconify.design/lucide:tag.svg?width=14) Defina nome do tópico e `event_type` com versão se necessário
3. ![package](https://api.iconify.design/lucide:package.svg?width=14) Use envelope padrão com `event_id`, `occurred_at`, `source`
4. ![header](https://api.iconify.design/lucide:header.svg?width=14) Implemente headers conforme [headers.md](headers.md)
5. ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) Crie contrato AsyncAPI ou Protobuf
6. ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=14) Configure retries, DLQ e idempotência [reliability.md](reliability.md)
7. ![lock](https://api.iconify.design/lucide:lock.svg?width=14) Aplique segurança [security.md](security.md)
8. ![copy](https://api.iconify.design/lucide:copy.svg?width=14) Reutilize [examples/](examples/) como base

### ![wrench](https://api.iconify.design/lucide:wrench.svg?width=16) Para Validar Contratos

**AsyncAPI:**
```bash
# Validar contrato
asyncapi validate user-created.asyncapi.yaml

# Gerar documentação
asyncapi generate html user-created.asyncapi.yaml
```

**Protobuf:**
```bash
# Validar e detectar breaking changes
buf lint
buf breaking --against '.git#branch=main'

# Gerar código
buf generate
```

### ![eye](https://api.iconify.design/lucide:eye.svg?width=16) Para Revisar Eventos Existentes

Use os documentos como checklist:
- ✅ Nome do tópico segue [conventions.md](conventions.md)?
- ✅ Headers padrão implementados [headers.md](headers.md)?
- ✅ Schema evolution está compatível [schema-evolution.md](schema-evolution.md)?
- ✅ Consumidor é idempotente e tem DLQ [reliability.md](reliability.md)?
- ✅ Segurança aplicada (TLS, ACLs) [security.md](security.md)?

---

## 📐 Princípios Fundamentais

### ![package](https://api.iconify.design/lucide:package.svg?width=16) Envelope Padrão

Todo evento deve ter estrutura consistente:

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

### ![repeat](https://api.iconify.design/lucide:repeat.svg?width=16) Idempotência Obrigatória

Consumidores **devem** ser idempotentes:
- Deduplique por `event_id` ou `idempotency_key`
- Use cache com TTL (ex: 24h)
- Implemente retries com backoff exponencial
- Configure DLQ para erros fatais

### ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=16) Evolução Compatível

Mudanças devem ser **compatíveis** por padrão:
- ✅ Adicionar campos **opcionais**
- ✅ Adicionar enum values (com fallback)
- ❌ Remover campos → breaking (novo tópico `-v2`)
- ❌ Tornar campo obrigatório → breaking
- ❌ Mudar tipo de campo → breaking

### ![shield](https://api.iconify.design/lucide:shield.svg?width=16) Segurança desde o Início

- 🔐 TLS obrigatório na comunicação
- 🚦 ACLs configuradas por tópico
- 🔒 Credenciais via Vault/Secret Manager
- 🛡️ PII minimizada e mascarada
- 🕵️ Auditoria e logs de acesso

### ![activity](https://api.iconify.design/lucide:activity.svg?width=16) Observabilidade Nativa

Todo produtor/consumidor deve expor:
- Trace propagation (`trace_id`, `correlation_id`)
- Métricas: `events_published_total`, `events_consumed_total`, `event_processing_latency_ms`
- Logs estruturados com `event_id`, `event_type`, `trace_id`
- Alertas para DLQ e retries acima do limiar

---

## 🔗 Links Úteis

### Especificações Externas
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [AsyncAPI 3.0 Specification](https://www.asyncapi.com/docs/reference/specification/v3.0.0)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [Protocol Buffers](https://protobuf.dev/)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [CloudEvents Specification](https://cloudevents.io/)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [W3C Trace Context](https://www.w3.org/TR/trace-context/)

### Brokers
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [Apache Kafka](https://kafka.apache.org/)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [AWS SQS](https://aws.amazon.com/sqs/) / [SNS](https://aws.amazon.com/sns/)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [Google Pub/Sub](https://cloud.google.com/pubsub)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [RabbitMQ](https://www.rabbitmq.com/)

### Ferramentas
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [AsyncAPI CLI](https://github.com/asyncapi/cli) — Validar e gerar docs
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [buf](https://buf.build/) — Lint e breaking detection para Protobuf
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [OpenTelemetry](https://opentelemetry.io/) — Observabilidade distribuída

### Documentos Relacionados
- ![arrow-right](https://api.iconify.design/lucide:arrow-right.svg?width=14) [APIs HTTP](../apis/) — Padrões para APIs RESTful
- ![arrow-right](https://api.iconify.design/lucide:arrow-right.svg?width=14) [Ferramentas](../tooling/) — Linters e validadores
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
| Convenções | ✅ Completo | Atualizado |
| Headers Padrão | ✅ Completo | Atualizado |
| Evolução de Schemas | ✅ Completo | Atualizado |
| Confiabilidade | ✅ Completo | Atualizado |
| Segurança | ✅ Completo | Atualizado |
| Exemplos | ✅ Completo | Atualizado |

---

## 📋 Checklist Rápido para Novos Eventos

Use este checklist antes de publicar um novo evento:

- [ ] ![tag](https://api.iconify.design/lucide:tag.svg?width=14) Nome do tópico e `event_type` definidos (com versão se necessário)
- [ ] ![key](https://api.iconify.design/lucide:key.svg?width=14) Partition key coerente (garante ordenação por agregado)
- [ ] ![package](https://api.iconify.design/lucide:package.svg?width=14) Envelope com `event_id`, `occurred_at`, `source`
- [ ] ![header](https://api.iconify.design/lucide:header.svg?width=14) Headers: `trace_id`, `correlation_id`, `schema_version`, `tenant_id` (se aplicável)
- [ ] ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) Contrato em AsyncAPI/Protobuf versionado e validado no CI
- [ ] ![repeat](https://api.iconify.design/lucide:repeat.svg?width=14) Consumidor idempotente + DLQ + retries com backoff
- [ ] ![activity](https://api.iconify.design/lucide:activity.svg?width=14) Métricas e logs estruturados implementados
- [ ] ![lock](https://api.iconify.design/lucide:lock.svg?width=14) Segurança: ACLs, TLS, sanitização de PII

---

**[⬆ Voltar ao topo](#padrões-para-mensageria-assíncrona)**

**[🏠 Voltar para Standards](../README.md)**

---

*Mantido com ❤️ pela equipe de arquitetura QBEM*