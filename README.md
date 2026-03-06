# QBEM Standards

> Documentação oficial de padrões técnicos para desenvolvimento de software na QBEM

---

## 💡 Sobre os Padrões

Este é o **catálogo oficial de padrões técnicos** da QBEM. Aqui você encontra convenções, boas práticas e diretrizes para desenvolvimento de:

- APIs HTTP RESTful
- Comunicação assíncrona (eventos e mensageria)
- Segurança de aplicações
- Observabilidade e monitoramento
- Arquitetura de software

**Objetivo**: Garantir consistência, qualidade e interoperabilidade entre todos os serviços da organização.

---

## Índice de Padrões

### [APIs HTTP](apis/)

Padrões para desenvolvimento de APIs RESTful.

- [Convenções Gerais](apis/conventions.md) — Recursos, verbos HTTP, paginação, filtros
- [Modelo de Erros RFC 7807](apis/error-model.md) — Padronização de respostas de erro
- [Guia de Estilo OpenAPI](apis/openapi-style-guide.md) — Como documentar APIs com OpenAPI 3.1
- [Versionamento](apis/versioning.md) — Estratégias de versionamento e breaking changes

> **Status**: Completo

---

### ⚡ [Mensageria Assíncrona](async/)

Padrões para eventos, filas e streaming.

- [Convenções](async/conventions.md) — Nomenclatura, formato de eventos, idempotência
- [Headers Padrão](async/headers.md) — Metadados obrigatórios (correlação, trace, versão)
- [Evolução de Schemas](async/schema-evolution.md) — Compatibilidade e versionamento
- [Confiabilidade](async/reliability.md) — Retries, DLQ, timeouts, circuit breaker
- [Segurança](async/security.md) — TLS, ACLs, autenticação, HMAC

> **Status**: Completo

---

### 🔒 [Segurança](security/)

Práticas de segurança para toda a stack.

- [Gestão de Segredos](security/secrets-management.md) — Vault, rotação, detecção de vazamento
- [Autenticação & Autorização](security/auth.md) — OAuth 2.0, JWT, RBAC, mTLS
- [Segurança de APIs](security/api-security.md) — Rate limiting, validação, OWASP API Top 10
- [Proteção de Dados & LGPD](security/data-protection.md) — Criptografia, privacidade, compliance

> **Status**: Completo (base)

---

### 🪝 [Webhooks](webhooks/)

Design e implementação de webhooks seguros.

> **Status**: Em desenvolvimento

---

### 📊 [Observabilidade](observability/)

Logs, métricas e distributed tracing.

> **Status**: Em desenvolvimento

---

### 🔧 [Ferramentas](tooling/)

Linters, validadores e automação.

- [Spectral para OpenAPI](tooling/spectral/) — Validação de contratos

> **Status**: Em desenvolvimento

---

### [Checklists](checklists/)

Checklists de qualidade para diferentes cenários.

> **Status**: Em desenvolvimento

---

### 💻 [Frontend](frontend/)

Padrões para aplicações frontend.

> **Status**: Em desenvolvimento

---

### [ADRs](adr/)

Architecture Decision Records — histórico de decisões técnicas.

- [Template](adr/0000-template.md)
- [Lista de ADRs](adr/README.md)

---

## Convenções Gerais

> Todos os serviços desenvolvidos na QBEM **devem** seguir estas convenções:

### Commits e Versionamento

- **[Conventional Commits](https://conventionalcommits.org)** — `feat:`, `fix:`, `docs:`, etc.
- **[Semantic Versioning](https://semver.org)** — MAJOR.MINOR.PATCH

### Documentação Técnica

- **OpenAPI 3.1** para APIs HTTP
- **AsyncAPI 3.0** ou **Protobuf** para eventos
- Documentação em português, código em inglês

### Observabilidade

- Logs estruturados (JSON)
- Métricas expostas e padronizadas
- Distributed tracing com correlation IDs

### Segurança

- TLS 1.2+ obrigatório
- Secrets via Vault/Secret Manager
- Dependências auditadas (sem vulnerabilidades CRITICAL)
- Autenticação e autorização em todos os endpoints sensíveis

---

## Como Usar

###  Para Desenvolvedores

1. Consulte o padrão relevante ao seu domínio (API, eventos, etc.)
2. Siga as convenções documentadas
3. Use os exemplos como referência
4. Valide com as ferramentas disponíveis

### Para Tech Leads

1. Revise se novos serviços seguem os padrões
2. Contribua com feedback e melhorias
3. Documente exceções quando necessário

### Para Arquitetos

1. Evolua os padrões via RFC
2. Crie ADRs para decisões importantes
3. Mantenha consistência através de code reviews

---

## Processo de Evolução

Os padrões evoluem através de:

1. **Proposta** — Issue ou PR com RFC
2. **Discussão** — Feedback da comunidade (5 dias úteis)
3. **Decisão** — Aprovação pelos CODEOWNERS
4. **ADR** — Decisão documentada
5. **Implementação** — Atualização dos padrões

Detalhes em [GOVERNANCE.md](GOVERNANCE.md)

---

## Contribuindo

Para contribuir com a documentação:

1. Edite os arquivos Markdown relevantes
2. Faça commit seguindo Conventional Commits
3. Abra Pull Request

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para mais detalhes.

---

## Licença

[MIT License](LICENSE)

---

## Informações

- **Versão**: Atualizada automaticamente via GitHub Pages
- **Última atualização**: Veja [histórico de commits](https://github.com/qbem-repos/standards/commits/main)
- **Mantenedores**: Veja [CODEOWNERS](.github/CODEOWNERS)
- **Issues**: [Reportar problemas ou sugestões](https://github.com/qbem-repos/standards/issues)
