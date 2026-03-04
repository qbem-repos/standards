![globe](https://api.iconify.design/lucide:globe.svg?color=%234a9eff&width=32) 

# Guia de Padrões para APIs HTTP

> Convenções e boas práticas para desenvolvimento de APIs RESTful consistentes, previsíveis e interoperáveis.

[![OpenAPI 3.1](https://img.shields.io/badge/OpenAPI-3.1-green.svg)](https://spec.openapis.org/oas/v3.1.0)
[![RFC 7807](https://img.shields.io/badge/RFC-7807-blue.svg)](https://tools.ietf.org/html/rfc7807)
[![Status](https://img.shields.io/badge/status-completo-success.svg)]()

**[⬅️ Voltar](../) · [🏠 Home](../README.md)**

---

## 📖 Visão Geral

Este guia reúne as principais convenções para desenvolvimento de APIs HTTP na organização. O objetivo é garantir **consistência**, **previsibilidade** e **interoperabilidade** entre serviços, facilitando a manutenção, evolução e integração dos sistemas.

### 🎯 O que você encontrará aqui

- ✅ Nomenclatura de recursos e métodos HTTP
- ✅ Modelo padronizado de erros (RFC 7807)
- ✅ Estratégias de versionamento
- ✅ Guia de estilo para contratos OpenAPI
- ✅ Exemplos práticos e testados

---

## 📚 Documentação

### ![file-text](https://api.iconify.design/lucide:file-text.svg?width=20) [1. Convenções para APIs HTTP](conventions.md)

Padrões fundamentais para design de APIs.

**Conteúdo:**
- ![box](https://api.iconify.design/lucide:box.svg?width=14) Recursos e URLs (nomenclatura, hierarquia)
- ![arrow-right](https://api.iconify.design/lucide:arrow-right.svg?width=14) Métodos HTTP (GET, POST, PATCH, DELETE)
- ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=14) Versionamento na URL (`/v1`, `/v2`)
- ![list](https://api.iconify.design/lucide:list.svg?width=14) Paginação (cursor-based e offset-based)
- ![repeat](https://api.iconify.design/lucide:repeat.svg?width=14) Idempotência (Idempotency-Key)
- ![shield](https://api.iconify.design/lucide:shield.svg?width=14) Segurança (autenticação, rate limiting)
- ![activity](https://api.iconify.design/lucide:activity.svg?width=14) Observabilidade (health checks, logs, traces)
- ![database](https://api.iconify.design/lucide:database.svg?width=14) Cache e concorrência (ETag, If-None-Match)
- ![globe-2](https://api.iconify.design/lucide:globe-2.svg?width=14) Internacionalização (datas, moedas, idiomas)
- ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) Descoberta (endpoint `/openapi.json`)

**[📖 Ler documento completo →](conventions.md)**

---

### ![alert-circle](https://api.iconify.design/lucide:alert-circle.svg?width=20) [2. Modelo de Erros (RFC 7807)](error-model.md)

Tratamento padronizado de erros usando `application/problem+json`.

**Conteúdo:**
- ![package](https://api.iconify.design/lucide:package.svg?width=14) Estrutura base (`type`, `title`, `status`, `trace_id`)
- ![tag](https://api.iconify.design/lucide:tag.svg?width=14) Padrões de `type` (namespace e kebab-case)
- ![alert-triangle](https://api.iconify.design/lucide:alert-triangle.svg?width=14) Erros de validação (422 com array de `errors`)
- ![lock](https://api.iconify.design/lucide:lock.svg?width=14) Autenticação e autorização (401, 403)
- ![git-merge](https://api.iconify.design/lucide:git-merge.svg?width=14) Conflitos e idempotência (409)
- ![clock](https://api.iconify.design/lucide:clock.svg?width=14) Rate limiting (429 com headers)
- ![search-x](https://api.iconify.design/lucide:search-x.svg?width=14) Recursos não encontrados (404)
- ![alert-octagon](https://api.iconify.design/lucide:alert-octagon.svg?width=14) Erros internos (500)
- ![shield-alert](https://api.iconify.design/lucide:shield-alert.svg?width=14) Segurança de informação
- ![eye](https://api.iconify.design/lucide:eye.svg?width=14) Telemetria e observabilidade

**[📖 Ler documento completo →](error-model.md)**

---

### ![file-code](https://api.iconify.design/lucide:file-code.svg?width=20) [3. Guia de Estilo OpenAPI](openapi-style-guide.md)

Como escrever e manter contratos OpenAPI 3.1 de forma padronizada.

**Conteúdo:**
- ![file-json](https://api.iconify.design/lucide:file-json.svg?width=14) Versão e estrutura (OpenAPI 3.1 + JSON Schema Draft 2020-12)
- ![tags](https://api.iconify.design/lucide:tags.svg?width=14) Tags (agrupamento por domínio funcional)
- ![database](https://api.iconify.design/lucide:database.svg?width=14) Schemas (snake_case, exemplos, nullable)
- ![arrow-right-left](https://api.iconify.design/lucide:arrow-right-left.svg?width=14) Endpoints (summary, description, operationId)
- ![header](https://api.iconify.design/lucide:header.svg?width=14) Headers e padrões (RateLimit, ETag, Retry-After)
- ![key](https://api.iconify.design/lucide:key.svg?width=14) Segurança (Bearer JWT, securitySchemes)
- ![alert-circle](https://api.iconify.design/lucide:alert-circle.svg?width=14) Erros (modelo RFC 7807)
- ![sparkles](https://api.iconify.design/lucide:sparkles.svg?width=14) Boas práticas (oneOf, discriminator, links)
- ![check-circle](https://api.iconify.design/lucide:check-circle.svg?width=14) Lint & CI (Spectral, oasdiff)

**[📖 Ler documento completo →](openapi-style-guide.md)**

---

### ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=20) [4. Versionamento de APIs](versioning.md)

Estratégias para evolução previsível sem quebrar consumidores.

**Conteúdo:**
- ![target](https://api.iconify.design/lucide:target.svg?width=14) Estratégia (SemVer + versionamento na URL)
- ![x-circle](https://api.iconify.design/lucide:x-circle.svg?width=14) O que é breaking change
- ![check-circle](https://api.iconify.design/lucide:check-circle.svg?width=14) O que é mudança compatível
- ![calendar-x](https://api.iconify.design/lucide:calendar-x.svg?width=14) Depreciação (headers Deprecation, Sunset, Link)
- ![clock](https://api.iconify.design/lucide:clock.svg?width=14) Ciclo de vida (aviso, suporte paralelo, remoção)
- ![workflow](https://api.iconify.design/lucide:workflow.svg?width=14) Compatibilidade no CI (oasdiff, breaking detection)
- ![file-text](https://api.iconify.design/lucide:file-text.svg?width=14) Exemplo no OpenAPI (deprecated: true)
- ![clipboard-check](https://api.iconify.design/lucide:clipboard-check.svg?width=14) Checklist para versionar

**[📖 Ler documento completo →](versioning.md)**

---

### ![lightbulb](https://api.iconify.design/lucide:lightbulb.svg?width=20) [5. Exemplos de Implementação](examples/)

Contratos e coleções de referência prontos para uso.

**Arquivos disponíveis:**

- ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) [`openapi-min.yaml`](examples/openapi-min.yaml) — Contrato OpenAPI mínimo completo
- ![send](https://api.iconify.design/lucide:send.svg?width=14) [`qbem-api.postman_collection.json`](examples/qbem-api.postman_collection.json) — Coleção Postman com exemplos
- ![file-json](https://api.iconify.design/lucide:file-json.svg?width=14) [`request-create-user.json`](examples/request-create-user.json) — Exemplo de request
- ![user](https://api.iconify.design/lucide:user.svg?width=14) [`response-user.json`](examples/response-user.json) — Exemplo de response de sucesso
- ![alert-circle](https://api.iconify.design/lucide:alert-circle.svg?width=14) [`response-error.json`](examples/response-error.json) — Exemplo de erro RFC 7807

**[📁 Ver todos os exemplos →](examples/)**

---

## 🚀 Como Usar

### ![code](https://api.iconify.design/lucide:code.svg?width=16) Para Implementar uma Nova API

1. ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) Leia [conventions.md](conventions.md) para entender os padrões básicos
2. ![file-code](https://api.iconify.design/lucide:file-code.svg?width=14) Crie seu contrato OpenAPI seguindo [openapi-style-guide.md](openapi-style-guide.md)
3. ![alert-circle](https://api.iconify.design/lucide:alert-circle.svg?width=14) Implemente erros conforme [error-model.md](error-model.md)
4. ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=14) Planeje versionamento usando [versioning.md](versioning.md)
5. ![copy](https://api.iconify.design/lucide:copy.svg?width=14) Reutilize [examples/](examples/) como base

### ![wrench](https://api.iconify.design/lucide:wrench.svg?width=16) Para Validar seu Contrato

```bash
# Validar com Spectral
spectral lint openapi.yaml --ruleset ../tooling/spectral/ruleset.yml

# Detectar breaking changes
oasdiff breaking openapi-v1.yaml openapi-v2.yaml
```

### ![eye](https://api.iconify.design/lucide:eye.svg?width=16) Para Revisar uma API Existente

Use os documentos como checklist:
- ✅ Nomenclatura de recursos segue [conventions.md](conventions.md)?
- ✅ Erros usam RFC 7807 [error-model.md](error-model.md)?
- ✅ Contrato OpenAPI está conforme [openapi-style-guide.md](openapi-style-guide.md)?
- ✅ Versionamento está correto [versioning.md](versioning.md)?

---

## 📐 Princípios Fundamentais

### ![box](https://api.iconify.design/lucide:box.svg?width=16) Recursos, não Ações

URLs devem representar **recursos** (substantivos), não ações (verbos).

✅ **Correto:**
```
GET    /v1/users
POST   /v1/users
GET    /v1/users/{id}
PATCH  /v1/users/{id}
DELETE /v1/users/{id}
```

❌ **Incorreto:**
```
GET /v1/getUsers
POST /v1/createUser
GET /v1/getUserById
```

### ![shield](https://api.iconify.design/lucide:shield.svg?width=16) Segurança desde o Início

- 🔐 Autenticação obrigatória (Bearer JWT)
- 🚦 Rate limiting configurado
- 🔒 HTTPS/TLS obrigatório
- 🛡️ Validação de entrada rigorosa
- 🕵️ Auditoria e logs de acesso

### ![activity](https://api.iconify.design/lucide:activity.svg?width=16) Observabilidade Nativa

Toda API deve expor:
- `/health` — Status da aplicação
- `/ready` — Capacidade de receber tráfego
- `/openapi.json` — Contrato autodocumentado
- Logs estruturados com `trace_id`
- Métricas de latência e taxa de erro

### ![file-text](https://api.iconify.design/lucide:file-text.svg?width=16) Documentação como Código

- OpenAPI 3.1 é **obrigatório**
- Contratos são versionados no Git
- Validação automatizada no CI
- Exemplos testáveis e realistas

---

## 🔗 Links Úteis

### Especificações Externas
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [RFC 7807 - Problem Details](https://tools.ietf.org/html/rfc7807)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [Conventional Commits](https://conventionalcommits.org)
- ![link](https://api.iconify.design/lucide:link.svg?width=14) [Semantic Versioning](https://semver.org)

### Ferramentas
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [Spectral](https://stoplight.io/open-source/spectral) — Linter para OpenAPI
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [oasdiff](https://github.com/tufin/oasdiff) — Detectar breaking changes
- ![wrench](https://api.iconify.design/lucide:wrench.svg?width=14) [Postman](https://www.postman.com) — Testar APIs

### Documentos Relacionados
- ![arrow-right](https://api.iconify.design/lucide:arrow-right.svg?width=14) [Mensageria Assíncrona](../async/) — Padrões para eventos
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
| Modelo de Erros | ✅ Completo | Atualizado |
| Guia OpenAPI | ✅ Completo | Atualizado |
| Versionamento | ✅ Completo | Atualizado |
| Exemplos | ✅ Completo | Atualizado |

---

**[⬆ Voltar ao topo](#guia-de-padrões-para-apis-http)**

**[🏠 Voltar para Standards](../README.md)**

---

*Mantido com ❤️ pela equipe de arquitetura QBEM*