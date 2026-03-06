# QBEM Standards

> Playbook oficial de padrões técnicos e boas práticas para desenvolvimento de software na QBEM

---

## Sobre Este Playbook

Este é o **catálogo oficial de padrões técnicos** da QBEM. Aqui você encontra:

- Padrões de arquitetura e integração
- Convenções de desenvolvimento
- Boas práticas de código
- Diretrizes de segurança
- Guias de observabilidade

**Objetivo**: Garantir consistência, qualidade e interoperabilidade entre todos os serviços e times da organização.

**Para quem**: Desenvolvedores, Tech Leads, Arquitetos e qualquer pessoa envolvida no desenvolvimento de software na QBEM.

---

## Índice de Documentos

### [APIs HTTP](apis/)

Padrões para desenvolvimento de APIs RESTful.

- [Convenções Gerais](apis/conventions.md)
- [Modelo de Erros RFC 7807](apis/error-model.md)
- [Guia de Estilo OpenAPI](apis/openapi-style-guide.md)
- [Versionamento](apis/versioning.md)

**Status**: Completo

---

### [Mensageria Assíncrona](async/)

Padrões para eventos, filas e streaming.

- [Convenções](async/conventions.md)
- [Headers Padrão](async/headers.md)
- [Evolução de Schemas](async/schema-evolution.md)
- [Confiabilidade](async/reliability.md)
- [Segurança](async/security.md)

**Status**: Completo

---

### [Segurança](security/)

Práticas de segurança para toda a stack.

- [Gestão de Segredos](security/secrets-management.md)
- [Autenticação & Autorização](security/auth.md)
- [Segurança de APIs](security/api-security.md)
- [Proteção de Dados & LGPD](security/data-protection.md)

**Status**: Completo

---

### [Boas Práticas](best-practices/)

Diretrizes e políticas para desenvolvimento de software.

- [Política de Uso de IA](best-practices/ai-coding.md)

**Status**: Ativo

---

### [Webhooks](webhooks/)

Design e implementação de webhooks seguros.

**Status**: Em desenvolvimento

---

### [Observabilidade](observability/)

Logs, métricas e distributed tracing.

**Status**: Em desenvolvimento

---

### [Ferramentas](tooling/)

Linters, validadores e automação.

- [Spectral para OpenAPI](tooling/spectral/)

**Status**: Em desenvolvimento

---

### [Checklists](checklists/)

Checklists de qualidade para diferentes cenários.

**Status**: Em desenvolvimento

---

### [Frontend](frontend/)

Padrões para aplicações frontend.

**Status**: Em desenvolvimento

---

## Convenções Gerais

Todos os serviços desenvolvidos na QBEM devem seguir estas convenções:

### Commits e Versionamento

- [Conventional Commits](https://conventionalcommits.org) - `feat:`, `fix:`, `docs:`, etc.
- [Semantic Versioning](https://semver.org) - MAJOR.MINOR.PATCH

### Documentação Técnica

- OpenAPI 3.1 para APIs HTTP
- AsyncAPI 3.0 ou Protobuf para eventos
- Documentação em português, código em inglês

### Observabilidade

- Logs estruturados em JSON
- Métricas expostas e padronizadas
- Distributed tracing com correlation IDs

### Segurança

- TLS 1.2+ obrigatório
- Secrets via Vault ou Secret Manager
- Dependências auditadas regularmente
- Autenticação e autorização em todos os endpoints sensíveis

---

## Como Usar Este Playbook

### Para Desenvolvedores

1. Consulte o padrão relevante ao seu domínio (APIs, eventos, boas práticas, etc.)
2. Siga as convenções documentadas
3. Use os exemplos como referência
4. Valide com as ferramentas disponíveis

### Para Tech Leads

1. Revise se novos serviços seguem os padrões
2. Contribua com feedback e melhorias
3. Documente exceções quando necessário
4. Garanta que o time conhece e aplica os padrões

### Para Arquitetos

1. Evolua os padrões via RFC
2. Documente decisões importantes
3. Mantenha consistência através de code reviews
4. Atualize o playbook com aprendizados

---

## Processo de Evolução dos Padrões

Os padrões evoluem através de:

1. **Proposta** - Issue ou Pull Request com RFC
2. **Discussão** - Feedback da comunidade (prazo de 5 dias úteis)
3. **Decisão** - Aprovação pelos CODEOWNERS
4. **Documentação** - Atualização dos documentos
5. **Implementação** - Aplicação nos projetos

Detalhes completos em [GOVERNANCE.md](GOVERNANCE.md)

---

## Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Edite os arquivos Markdown relevantes
2. Faça commit seguindo Conventional Commits
3. Abra Pull Request
4. Aguarde revisão dos CODEOWNERS

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para mais detalhes.

---

## Licença

[MIT License](LICENSE)

---

## Informações

- **Versão**: Atualizada automaticamente
- **Última atualização**: Veja [histórico de commits](https://github.com/qbem-repos/standards/commits/main)
- **Mantenedores**: Veja [CODEOWNERS](.github/CODEOWNERS)
- **Issues**: [Reportar problemas ou sugestões](https://github.com/qbem-repos/standards/issues)