# Git Repository Naming Standard
## 1. Objetivo

Este documento define o **padrão obrigatório de nomenclatura de repositórios Git** da organização.

O objetivo é garantir:
- consistência entre projetos
- identificação clara do tipo de sistema
- organização previsível da arquitetura
- facilidade de busca e manutenção

Este padrão **deve ser seguido obrigatoriamente** na criação de novos repositórios.

# 2. Convenção de escrita

Todos os repositórios **devem utilizar kebab-case**.

Formato:
```
nome-do-repositorio
```

Exemplo:
```
payments-api
billing-worker
customer-platform
auth-service
```

Não é permitido utilizar:
```
camelCase
snake_case
PascalCase
```

Exemplos proibidos:
```
PaymentAPI
payment_api
Payment-Service
```

# 3. Estrutura obrigatória do nome

Todos os repositórios devem seguir o formato:
```
<dominio>-<tipo>
```

Onde:
- **dominio** = domínio de negócio ou funcionalidade
- **tipo** = tipo do sistema

Exemplo:
```
billing-api
auth-service
notification-worker
customer-platform
```

# 4. Tipos de repositório permitidos
A organização utiliza exclusivamente os seguintes tipos:

|Tipo|Uso|
|---|---|
|monolith|aplicação monolítica|
|platform|monorepo contendo UI + BFF|
|api|API HTTP|
|service|microserviço interno|
|worker|processamento assíncrono|
|ui|frontend isolado|
|poc|prova de conceito|
|infra|infraestrutura como código|

Nenhum outro tipo deve ser utilizado.

# 5. Monólitos
Aplicações monolíticas **devem utilizar**:

```
<dominio>-monolith
```

Exemplos:

```
erp-monolith
backoffice-monolith
legacy-core-monolith
```

# 6. Monorepo (UI + BFF)

Repositórios contendo **frontend e BFF no mesmo projeto** devem utilizar:
```
<dominio>-platform
```

Exemplos:
```
customer-platform
admin-platform
billing-platform
```

Estrutura obrigatória dentro do repositório:
```
<dominio>-platform
 ├─ ui
 ├─ bff
 ├─ shared
 └─ docs
```

# 7. Frontend isolado

Quando o frontend estiver **em um repositório separado**, deve ser utilizado:
```
<dominio>-ui
```

Exemplos:
```
customer-ui
admin-ui
billing-ui
backoffice-ui
```
# 8. APIs
APIs HTTP **devem utilizar**:
```
<dominio>-api
```

Exemplos:

```
payments-api
billing-api
auth-api
notification-api
```
# 9. Services

Microserviços internos **devem utilizar**:

```
<dominio>-service
```

Exemplos:
```
auth-service
billing-service
customer-service
```

Regras:

- services são usados para comunicação interna
- não devem expor APIs públicas diretamente

# 10. Workers

Processamentos assíncronos **devem utilizar**:
```
<dominio>-worker
```

Exemplos:
```
billing-worker
email-worker
notification-worker
invoice-worker
```

Workers são utilizados para:
- processamento de filas
- jobs agendados
- processamento de eventos

# 11. Provas de conceito

Provas de conceito **devem utilizar**:

```
poc-<tema>
```

Exemplos:

```
poc-nfc-pos
poc-ai-agent
poc-payment-integration
```

Regras:
- POCs não devem evoluir para produção
- se a POC virar produto, deve ser criado um novo repositório

# 12. Infraestrutura (Infrastructure as Code)

Repositórios de infraestrutura **devem utilizar**:

```
infra-<projeto>
```

Exemplos:

```
infra-conciliacao
infra-eb
infra-qhealth
```

# 13. Regras obrigatórias

Todos os repositórios devem:

1. utilizar **kebab-case**
2. seguir o formato **-**
3. utilizar apenas os tipos definidos neste documento
4. possuir nome descritivo do domínio

# 14. Padrões proibidos

Não é permitido criar repositórios com:

- nomes genéricos
- abreviações obscuras
- versão no nome
- nomes inconsistentes com o padrão

Exemplos proibidos:

```
backend
api-v2
service-final
project
repo
usr-svc
```

# 15. Versionamento

Versões **não devem ser incluídas no nome do repositório**.

Exemplos proibidos:

```
billing-api-v2
auth-service-v3
```

Versionamento deve ser feito utilizando:

- tags
- releases
- branches


# 16. Processo obrigatório para criação de repositórios

Antes de criar um novo repositório deve-se:

1. identificar o domínio do sistema
2. identificar o tipo do sistema
3. aplicar o padrão de nomenclatura

Regra de composição:
```
dominio + tipo = nome do repositorio
```

Exemplo:
```
billing + api = billing-api
notification + worker = notification-worker
customer + platform = customer-platform
customer + ui = customer-ui
```
# 17. Estrutura padrão da organização

Exemplo de estrutura válida:

```
auth-api
auth-service
auth-worker

billing-api
billing-worker

notification-service
notification-worker

customer-platform
admin-ui
backoffice-ui

erp-monolith

infra-terraform
infra-kubernetes
infra-observability

poc-nfc-pos
poc-ai-agent
```

Essa estrutura permite identificar imediatamente:
- domínio do sistema
- responsabilidade do projeto
- tipo de componente arquitetural
# 18. Conformidade

Todos os novos repositórios devem seguir este padrão.

Repositórios existentes devem ser adequados gradualmente quando houver manutenção significativa.****