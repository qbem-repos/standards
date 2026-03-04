# Contexto do Projeto: Standards QBEM

## Visão Geral

Este repositório contém as **padronizações oficiais** da organização QBEM para desenvolvimento de serviços, APIs, eventos assíncronos, webhooks, observabilidade e segurança. O objetivo principal é proporcionar **autonomia aos times** mantendo **consistência, qualidade e segurança** em toda a stack tecnológica.

## Estrutura do Repositório

```
standards/
├── .ai/                    # Contexto para assistentes de IA
├── .github/                # Configurações GitHub (CODEOWNERS)
├── adr/                    # Architecture Decision Records
├── apis/                   # ✅ Padrões para APIs HTTP
│   ├── conventions.md
│   ├── error-model.md
│   ├── openapi-style-guide.md
│   ├── versioning.md
│   └── examples/
├── async/                  # ✅ Padrões para mensageria assíncrona
│   ├── conventions.md
│   ├── headers.md
│   ├── reliability.md
│   ├── schema-evolution.md
│   ├── security.md
│   └── examples/
├── webhooks/               # 🚧 Em desenvolvimento
├── observability/          # 🚧 Em desenvolvimento
├── security/               # 🚧 Em desenvolvimento
├── tooling/                # Ferramentas de validação
│   └── spectral/
├── frontend/               # 🚧 Em desenvolvimento
├── checklists/             # 🚧 Em desenvolvimento
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── GOVERNANCE.md
├── LICENSE
├── README.md
└── SECURITY.md
```

## Áreas Principais

### 1. APIs HTTP (`/apis`)
Convenções completas para desenvolvimento de APIs RESTful:
- **Nomenclatura de recursos** e métodos HTTP
- **Modelo de erros** baseado em RFC 7807
- **Versionamento** de APIs
- **Guia de estilo OpenAPI**
- Exemplos práticos de implementação

### 2. Mensageria Assíncrona (`/async`)
Padrões para eventos, filas e streaming:
- **Convenções** de nomes, envelopes e headers
- **Schema evolution** e versionamento
- **Confiabilidade**: retries, DLQ, idempotência
- **Segurança**: criptografia, autenticação, autorização
- Suporte para AsyncAPI e Protobuf

### 3. Webhooks (`/webhooks`)
Guias para design de webhooks (em desenvolvimento):
- Segurança com HMAC
- Estratégias de retry
- Exemplos de implementação

### 4. Observabilidade (`/observability`)
Padrões de observabilidade (em desenvolvimento):
- Logs estruturados (JSON)
- Métricas
- Tracing com OpenTelemetry

### 5. Segurança (`/security`)
Práticas de segurança (em desenvolvimento):
- Gestão de segredos
- Auditoria de dependências
- Threat modeling

### 6. Ferramentas (`/tooling`)
Linters, validadores e pre-commit hooks:
- Spectral para OpenAPI
- Validação de AsyncAPI
- Checklists automatizados

### 7. ADRs (`/adr`)
Architecture Decision Records:
- Registro histórico de decisões arquiteturais
- Template padrão para novos ADRs
- Decisões já tomadas (ex: Casdoor)

## Convenções Gerais

### Commits
- **Conventional Commits** obrigatório
- Formato: `tipo(escopo): descrição`
- Tipos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

### Versionamento
- **Semantic Versioning (SemVer)**
- MAJOR.MINOR.PATCH
- Documentação de breaking changes

### Documentação
- APIs: OpenAPI 3.x obrigatório
- Eventos: AsyncAPI ou Protobuf
- Português para documentação interna
- Inglês para código e especificações técnicas

### Observabilidade Padrão
- Logs estruturados em JSON
- Métricas expostas
- Tracing distribuído
- Correlation IDs em todas as requisições

### Segurança
- HMAC para webhooks
- Secrets gerenciados via vault/env vars
- Dependências auditadas regularmente
- Autenticação e autorização desde o início

## Fluxo de Trabalho

### Para Consultar Standards
1. Navegue até a pasta relevante (`apis/`, `async/`, etc.)
2. Leia o `README.md` da seção
3. Consulte os documentos específicos
4. Utilize exemplos como base

### Para Propor Mudanças
1. Abra uma **issue** descrevendo a proposta
2. Use template de **RFC curta** para mudanças em padrões
3. Crie um **fork** e branch descritivo
4. Faça **commits** seguindo Conventional Commits
5. Abra **Pull Request** com contexto detalhado
6. Aguarde revisão de CODEOWNERS

### Para Decisões Arquiteturais
1. Proposta deve ser discutida via RFC
2. Após aprovação, criar **ADR** em `/adr`
3. ADR documenta contexto, decisão e consequências
4. ADRs são imutáveis (apenas novos ADRs superseding)

## Princípios

### Autonomia com Governança
- Times têm liberdade para escolher tecnologias
- Padrões garantem interoperabilidade
- Exceções são permitidas com justificativa

### Evolução Contínua
- Standards são **vivos** e evoluem
- Feedback dos times é essencial
- Aprendizados geram melhorias

### Documentação é Código
- OpenAPI/AsyncAPI são fonte da verdade
- Validação automatizada no CI
- Exemplos devem ser testáveis

### Segurança by Design
- Segurança desde o início, não depois
- Defense in depth
- Auditoria e compliance

## Ferramentas e Validação

### CI/CD
- Markdownlint para documentação
- Link-check para URLs
- Spectral para OpenAPI
- AsyncAPI validator

### Pre-commit
- Validação local antes do push
- Formatação automática
- Lint de commits

### Exemplos Testáveis
- Exemplos em `/examples` devem ser válidos
- Validação automatizada
- Manter sincronizado com padrões

## Público-Alvo

- **Desenvolvedores**: implementam APIs e eventos seguindo os padrões
- **Arquitetos**: definem e evoluem os standards
- **Tech Leads**: garantem conformidade nos times
- **Platform Engineers**: constroem ferramentas baseadas nos padrões

## Objetivos de Qualidade

### Consistência
- Mesma estrutura de erro em todas APIs
- Mesmos headers em todos os eventos
- Nomenclatura previsível

### Manutenibilidade
- Documentação atualizada
- Exemplos claros
- Decisões documentadas em ADRs

### Interoperabilidade
- Contratos bem definidos
- Versionamento compatível
- Schema evolution controlada

### Observabilidade
- Logs estruturados
- Métricas padronizadas
- Tracing end-to-end

## Como Este Repositório Ajuda

### Para Novos Serviços
1. Consulte checklists em `/checklists`
2. Reutilize exemplos de `/examples`
3. Valide com ferramentas de `/tooling`
4. Documente conforme templates

### Para Serviços Existentes
1. Identifique gaps com os padrões
2. Planeje migração gradual
3. Documente exceções se necessário
4. Contribua com aprendizados

### Para Decisões Técnicas
1. Verifique se há ADR existente
2. Consulte padrões relevantes
3. Proponha RFC se necessário
4. Documente decisão final

## Recursos Importantes

- **README principal**: Visão geral e estrutura
- **CONTRIBUTING**: Como propor mudanças
- **CODE_OF_CONDUCT**: Regras de convivência
- **GOVERNANCE**: Processo de decisão
- **SECURITY**: Como reportar vulnerabilidades

## Manutenção do Contexto

Este arquivo deve ser atualizado quando:
- Novos padrões forem adicionados
- Estrutura do repositório mudar
- Novos ADRs importantes forem criados
- Ferramentas ou processos mudarem

---

## Para Assistentes de IA

Ao trabalhar com este repositório:

1. **Respeite os padrões existentes**: não invente convenções, siga os documentos
2. **Consulte exemplos**: use os arquivos em `/examples` como referência
3. **Mantenha consistência**: aplique as mesmas regras em todos os artefatos
4. **Proponha melhorias**: se identificar gaps ou inconsistências, sugira correções
5. **Documente decisões**: mudanças significativas devem gerar ADRs
6. **Valide contra schemas**: garanta que exemplos sejam válidos
7. **Preserve o português**: documentação interna em português, specs em inglês
8. **Formato GitHub-friendly**: use Markdown corretamente para renderização no GitHub Pages

### Tarefas Comuns

**Criar nova API**:
- Siga `/apis/conventions.md`
- Use modelo de erros de `/apis/error-model.md`
- Documente em OpenAPI conforme `/apis/openapi-style-guide.md`
- Versionamento segundo `/apis/versioning.md`

**Criar novo evento**:
- Siga `/async/conventions.md`
- Use headers de `/async/headers.md`
- Planeje evolução com `/async/schema-evolution.md`
- Implemente confiabilidade de `/async/reliability.md`
- Aplique segurança de `/async/security.md`

**Propor mudança de padrão**:
- Abra issue com RFC
- Explique problema, solução e alternativas
- Inclua exemplos práticos
- Após aprovação, crie ADR em `/adr`

**Melhorar documentação**:
- Mantenha formato Markdown
- Adicione exemplos quando possível
- Use linguagem clara e objetiva
- Valide links e formatação