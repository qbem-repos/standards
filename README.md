![QBEM Logo](https://images.squarespace-cdn.com/content/v1/6298b052e407667e7e44c2ed/4051d667-ae53-469a-8465-b3598180b2f5/Logo-QBem---Ecossistema-Quiver.png)

# QBEM Standards

> Padronizações Oficiais para Desenvolvimento de Serviços

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**Autonomia aos times · Consistência organizacional · Qualidade e segurança**

📖 [Documentação](#-documentação-por-domínio) · 🚀 [Como Usar](#-como-usar) · 🤝 [Contribuir](CONTRIBUTING.md) · 📝 [ADRs](adr/)

---

## 📖 Sobre

Este repositório concentra as **padronizações oficiais** da QBEM para desenvolvimento de serviços, APIs, eventos assíncronos, webhooks, observabilidade e segurança.

### 🎯 Objetivos

- ✅ **Autonomia** — Times têm liberdade para escolher tecnologias
- ✅ **Consistência** — Padrões garantem interoperabilidade entre serviços
- ✅ **Qualidade** — Documentação e validação automatizada
- ✅ **Segurança** — Práticas de segurança desde o início

---

## 📚 Documentação por Domínio

### ![globe](https://api.iconify.design/lucide:globe.svg?color=%234a9eff&width=20) [APIs HTTP](apis/)

Convenções completas para desenvolvimento de APIs RESTful.

- ![file-text](https://api.iconify.design/lucide:file-text.svg?width=16) [Convenções Gerais](apis/conventions.md) — Recursos, métodos, paginação, cache
- ![alert-circle](https://api.iconify.design/lucide:alert-circle.svg?width=16) [Modelo de Erros RFC 7807](apis/error-model.md) — Tratamento padronizado de erros
- ![file-code](https://api.iconify.design/lucide:file-code.svg?width=16) [Guia de Estilo OpenAPI](apis/openapi-style-guide.md) — Como escrever contratos OpenAPI 3.1
- ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=16) [Versionamento](apis/versioning.md) — Estratégias de versionamento e breaking changes
- ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=16) [Exemplos](apis/examples/) — Contratos e coleções Postman de referência

**Status:** ✅ Completo

---

### ![zap](https://api.iconify.design/lucide:zap.svg?color=%23ffd700&width=20) [Mensageria Assíncrona](async/)

Padrões para eventos, filas e streaming.

- ![file-text](https://api.iconify.design/lucide:file-text.svg?width=16) [Convenções](async/conventions.md) — Nomes, envelopes, headers, idempotência
- ![tag](https://api.iconify.design/lucide:tag.svg?width=16) [Headers Padrão](async/headers.md) — Correlação, trace, schema version por broker
- ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=16) [Evolução de Schemas](async/schema-evolution.md) — Compatibilidade e versionamento
- ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=16) [Confiabilidade](async/reliability.md) — Retries, DLQ, timeouts, circuit breaker
- ![lock](https://api.iconify.design/lucide:lock.svg?width=16) [Segurança](async/security.md) — Criptografia, autenticação, ACLs, HMAC
- ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=16) [Exemplos](async/examples/) — AsyncAPI, Protobuf e JSON de referência

**Status:** ✅ Completo

---

### ![webhook](https://api.iconify.design/lucide:webhook.svg?color=%23ff6b6b&width=20) [Webhooks](webhooks/)

Guias para design e implementação de webhooks.

- ![package](https://api.iconify.design/lucide:package.svg?width=16) Design de payloads
- ![shield](https://api.iconify.design/lucide:shield.svg?width=16) Segurança com HMAC
- ![repeat](https://api.iconify.design/lucide:repeat.svg?width=16) Estratégias de retry
- ![code](https://api.iconify.design/lucide:code.svg?width=16) Exemplos de implementação

**Status:** 🚧 Em desenvolvimento

---

### ![bar-chart](https://api.iconify.design/lucide:bar-chart.svg?color=%2351cf66&width=20) [Observabilidade](observability/)

Padrões de logs, métricas e tracing.

- ![file-json](https://api.iconify.design/lucide:file-json.svg?width=16) Logs estruturados (JSON)
- ![activity](https://api.iconify.design/lucide:activity.svg?width=16) Métricas com OpenTelemetry
- ![network](https://api.iconify.design/lucide:network.svg?width=16) Distributed tracing
- ![gauge](https://api.iconify.design/lucide:gauge.svg?width=16) Dashboards e alertas

**Status:** 🚧 Em desenvolvimento

---

### ![shield](https://api.iconify.design/lucide:shield.svg?color=%23ff6b6b&width=20) [Segurança](security/)

Práticas de segurança para toda a stack.

- ![key](https://api.iconify.design/lucide:key.svg?width=16) Gestão de segredos
- ![package-check](https://api.iconify.design/lucide:package-check.svg?width=16) Auditoria de dependências
- ![search](https://api.iconify.design/lucide:search.svg?width=16) Threat modeling
- ![file-check](https://api.iconify.design/lucide:file-check.svg?width=16) Compliance e LGPD

**Status:** 🚧 Em desenvolvimento

---

### ![wrench](https://api.iconify.design/lucide:wrench.svg?color=%23868e96&width=20) [Ferramentas](tooling/)

Linters, validadores e automações.

- ![check-circle](https://api.iconify.design/lucide:check-circle.svg?width=16) [Spectral para OpenAPI](tooling/spectral/) — Validação de contratos
- ![git-commit](https://api.iconify.design/lucide:git-commit.svg?width=16) Pre-commit hooks
- ![workflow](https://api.iconify.design/lucide:workflow.svg?width=16) CI/CD pipelines
- ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=16) Checklists automatizados

**Status:** 🚧 Em desenvolvimento

---

### ![clipboard-list](https://api.iconify.design/lucide:clipboard-list.svg?color=%234a9eff&width=20) [Checklists](checklists/)

Checklists para diferentes cenários.

- ![plus-circle](https://api.iconify.design/lucide:plus-circle.svg?width=16) Novo serviço
- ![globe](https://api.iconify.design/lucide:globe.svg?width=16) Nova API
- ![zap](https://api.iconify.design/lucide:zap.svg?width=16) Novo evento
- ![eye](https://api.iconify.design/lucide:eye.svg?width=16) Code review

**Status:** 🚧 Em desenvolvimento

---

### ![monitor](https://api.iconify.design/lucide:monitor.svg?color=%23845ef7&width=20) [Frontend](frontend/)

Padrões para aplicações frontend.

- ![code-2](https://api.iconify.design/lucide:code-2.svg?width=16) Convenções de código
- ![folder-tree](https://api.iconify.design/lucide:folder-tree.svg?width=16) Estrutura de projetos
- ![gauge](https://api.iconify.design/lucide:gauge.svg?width=16) Performance e acessibilidade

**Status:** 🚧 Em desenvolvimento

---

### ![book-open](https://api.iconify.design/lucide:book-open.svg?color=%23ff922b&width=20) [ADRs - Architecture Decision Records](adr/)

Histórico de decisões arquiteturais importantes.

- ![file-text](https://api.iconify.design/lucide:file-text.svg?width=16) [Template de ADR](adr/0000-template.md)
- ![list](https://api.iconify.design/lucide:list.svg?width=16) [Lista de ADRs](adr/README.md)

Toda decisão significativa é documentada em um ADR imutável que explica contexto, alternativas e consequências.

---

## 🚀 Como Usar

### ![user](https://api.iconify.design/lucide:user.svg?width=18) Para Desenvolvedores

1. ![search](https://api.iconify.design/lucide:search.svg?width=14) **Consulte a documentação relevante** → Navegue até a pasta do domínio (APIs, eventos, etc.)
2. ![copy](https://api.iconify.design/lucide:copy.svg?width=14) **Reutilize exemplos** → Todos os exemplos são testados e validados
3. ![check-square](https://api.iconify.design/lucide:check-square.svg?width=14) **Valide seus contratos** → Use as ferramentas em `/tooling` para validar OpenAPI/AsyncAPI
4. ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=14) **Siga os checklists** → Garanta que nada foi esquecido

### ![users](https://api.iconify.design/lucide:users.svg?width=18) Para Tech Leads

1. ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=14) **Garanta conformidade** → Revise se novos serviços seguem os padrões
2. ![message-circle](https://api.iconify.design/lucide:message-circle.svg?width=14) **Contribua com feedback** → Padrões evoluem com aprendizados dos times
3. ![file-edit](https://api.iconify.design/lucide:file-edit.svg?width=14) **Documente exceções** → Quando necessário desviar, documente o motivo

### ![compass](https://api.iconify.design/lucide:compass.svg?width=18) Para Arquitetos

1. ![trending-up](https://api.iconify.design/lucide:trending-up.svg?width=14) **Evolua os padrões** → Proponha melhorias via RFC
2. ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) **Crie ADRs** → Documente decisões importantes
3. ![layers](https://api.iconify.design/lucide:layers.svg?width=14) **Mantenha consistência** → Revise PRs e garanta alinhamento

---

## 📐 Convenções Gerais

Todos os serviços devem seguir:

### ![git-commit](https://api.iconify.design/lucide:git-commit.svg?width=18) Commits e Versionamento

- ✅ **[Conventional Commits](https://conventionalcommits.org)** — `feat:`, `fix:`, `docs:`, etc.
- ✅ **[Semantic Versioning](https://semver.org)** — MAJOR.MINOR.PATCH

### ![book](https://api.iconify.design/lucide:book.svg?width=18) Documentação

- ✅ **OpenAPI 3.1** para APIs HTTP
- ✅ **AsyncAPI 3.0** ou **Protobuf** para eventos
- ✅ Português para docs internas, inglês para código

### ![eye](https://api.iconify.design/lucide:eye.svg?width=18) Observabilidade

- ✅ Logs estruturados em JSON
- ✅ Métricas expostas e padronizadas
- ✅ Tracing distribuído com correlation IDs

### ![lock](https://api.iconify.design/lucide:lock.svg?width=18) Segurança

- ✅ HMAC para webhooks
- ✅ Secrets via Vault/Secret Manager
- ✅ Dependências auditadas regularmente
- ✅ TLS obrigatório

---

## 🔄 Evolução dos Padrões

Os padrões são **vivos** e evoluem continuamente:

1. ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=14) **Proposta** → Abra issue ou PR com RFC curta
2. ![message-square](https://api.iconify.design/lucide:message-square.svg?width=14) **Discussão** → Feedback da comunidade (até 5 dias úteis)
3. ![check-circle](https://api.iconify.design/lucide:check-circle.svg?width=14) **Decisão** → Aprovação pelos CODEOWNERS
4. ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) **ADR** → Decisão documentada em `/adr`
5. ![code](https://api.iconify.design/lucide:code.svg?width=14) **Implementação** → Atualização dos padrões e ferramentas

Veja [GOVERNANCE.md](GOVERNANCE.md) para detalhes do processo.

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Este repositório é colaborativo.

### ![git-pull-request](https://api.iconify.design/lucide:git-pull-request.svg?width=18) Como Contribuir

1. ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) Leia [CONTRIBUTING.md](CONTRIBUTING.md)
2. ![git-fork](https://api.iconify.design/lucide:git-fork.svg?width=14) Faça um fork e crie um branch
3. ![edit](https://api.iconify.design/lucide:edit.svg?width=14) Faça suas mudanças com commits convencionais
4. ![check-square](https://api.iconify.design/lucide:check-square.svg?width=14) Valide com as ferramentas disponíveis
5. ![send](https://api.iconify.design/lucide:send.svg?width=14) Abra um Pull Request explicando o contexto

### ![heart](https://api.iconify.design/lucide:heart.svg?width=18) Código de Conduta

Todos devem seguir nosso [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
Respeito e colaboração são fundamentais.

---

## 📞 Suporte

- ![message-circle](https://api.iconify.design/lucide:message-circle.svg?width=16) **Issues** — Para dúvidas e sugestões
- ![shield-alert](https://api.iconify.design/lucide:shield-alert.svg?width=16) **Segurança** — Veja [SECURITY.md](SECURITY.md) para reportar vulnerabilidades
- ![mail](https://api.iconify.design/lucide:mail.svg?width=16) **Contato** — Entre em contato com o time de arquitetura

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

**[⬆ Voltar ao topo](#qbem-standards)**

Feito com ❤️ pela equipe QBEM