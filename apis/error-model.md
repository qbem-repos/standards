# Modelo de Erros — RFC 7807 (*application/problem+json*)

Todos os serviços devem retornar erros no formato **RFC 7807** com JSON e incluir
`trace_id` para correlação.

* **Content-Type**: `application/problem+json; charset=utf-8`
* **Obrigatórios**: `type`, `title`, `status`, `trace_id`
* **Recomendados**: `detail`, `instance`, `errors` (validação)

---

## Estrutura Base

```json
{
  "type": "https://docs.qbem.dev/errors/not-found",
  "title": "Recurso não encontrado",
  "status": 404,
  "detail": "User 'u_123' não existe",
  "instance": "/v1/users/u_123",
  "trace_id": "b6d1e8c2f5f24a0e"
}
```

#### Campos

* `type` — URI estável e versionada para documentação do erro.
* `title` — resumo curto (humano).
* `status` — HTTP.
* `detail` — explicação contextual (não vaze segredos/impl).
* `instance` — caminho/URL da requisição.
* `trace_id` — ID do trace/log (correlação).
* `errors` — (opcional) lista de erros de validação por campo.

---

## Padrões de `type`

* Namespace: `https://docs.qbem.dev/errors/<slug>`
* Use *kebab-case*: `validation`, `conflict`, `rate-limit`, `unauthorized`, `forbidden`,
`not-found`, `internal`.

Ex.:
`https://docs.qbem.dev/errors/validation`
`https://docs.qbem.dev/errors/rate-limit`

---

## Erros de Validação (`422 Unprocessable Entity`)

Quando houver vários problemas de campo, use `errors`.

```json
{
  "type": "https://docs.qbem.dev/errors/validation",
  "title": "Erro de validação",
  "status": 422,
  "detail": "Requisição possui campos inválidos",
  "trace_id": "b6d1e8c2f5f24a0e",
  "errors": [
    { "field": "email", "message": "formato inválido" },
    { "field": "age", "message": "deve ser >= 18" },
    { "field": "address.zip", "message": "CEP inválido" }
  ]
}
```

#### Boas práticas

* `field` com *dot notation* para aninhados.
* Mensagens curtas, úteis e neutras.

---

## Autenticação & Autorização

### 401 Unauthorized

```json
{
  "type": "https://docs.qbem.dev/errors/unauthorized",
  "title": "Não autenticado",
  "status": 401,
  "detail": "Token ausente ou inválido",
  "trace_id": "c57e8a9f"
}
```

### 403 Forbidden

```json
{
  "type": "https://docs.qbem.dev/errors/forbidden",
  "title": "Acesso negado",
  "status": 403,
  "detail": "Escopo insuficiente: 'orders:write' é necessário",
  "trace_id": "c57e8a9f"
}
```

---

## Idempotência & Conflitos (`409 Conflict`)

```json
{
  "type": "https://docs.qbem.dev/errors/conflict",
  "title": "Conflito",
  "status": 409,
  "detail": "Recurso já existe para esta Idempotency-Key",
  "trace_id": "1f2d3a"
}
```

---

## Rate Limit (`429 Too Many Requests`)

Cabeçalhos sugeridos:

```plain
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1731020400
Retry-After: 30
```

Payload:

```json
{
  "type": "https://docs.qbem.dev/errors/rate-limit",
  "title": "Limite de requisições excedido",
  "status": 429,
  "detail": "Tente novamente após 30 segundos",
  "trace_id": "9a7b6c"
}
```

---

## Recurso não encontrado (`404 Not Found`)

```json
{
  "type": "https://docs.qbem.dev/errors/not-found",
  "title": "Recurso não encontrado",
  "status": 404,
  "detail": "Order 'ord_123' não foi localizada",
  "instance": "/v1/orders/ord_123",
  "trace_id": "f0e1d2c3"
}
```

---

## Concurrency / Pré-condição (`412 Precondition Failed`)

Use com `If-Match` / `ETag` para controle otimista.

```json
{
  "type": "https://docs.qbem.dev/errors/precondition-failed",
  "title": "Pré-condição falhou",
  "status": 412,
  "detail": "ETag não corresponde. Recarregue o recurso e tente novamente.",
  "trace_id": "ab12cd34"
}
```

---

## Erro interno (`500 Internal Server Error`)

```json
{
  "type": "https://docs.qbem.dev/errors/internal",
  "title": "Erro interno",
  "status": 500,
  "detail": "Ocorreu um erro inesperado. Tente novamente.",
  "trace_id": "ee77ff00"
}
```

> Nunca exponha stack traces ou detalhes de infraestrutura no `detail`.

---

## Mapeamento sugerido HTTP → `type`

| HTTP | `type`                    |
| ---: | ------------------------- |
|  400 | `/bad-request`            |
|  401 | `/unauthorized`           |
|  403 | `/forbidden`              |
|  404 | `/not-found`              |
|  409 | `/conflict`               |
|  412 | `/precondition-failed`    |
|  415 | `/unsupported-media-type` |
|  422 | `/validation`             |
|  429 | `/rate-limit`             |
|  500 | `/internal`               |
|  503 | `/unavailable`            |

*(Prefixo comum omitido: `https://docs.qbem.dev/errors`)*

---

## Localização (opcional)

* Padrão: mensagens em **pt-BR**.
* Para i18n, aceitar `Accept-Language` e retornar `title/detail` no idioma.
* Não traduza `type`.

---

## Telemetria & Observabilidade

* Propague `traceparent` (W3C).
* Inclua `trace_id` do span atual no payload e nos logs.
* Regra: **todo erro 4xx/5xx deve ter `trace_id`**.

---

## Erros de Webhook (emissor)

```json
{
  "type": "https://docs.qbem.dev/errors/webhook-delivery",
  "title": "Falha ao entregar webhook",
  "status": 502,
  "detail": "Timeout ao chamar o endpoint do cliente",
  "trace_id": "zx81aa",
  "errors": [
    { "field": "endpoint", "message": "resposta > 5s" }
  ]
}
```

> Recomendado: retries com backoff, DLQ e deduplicação por `event_id`.

---

## Extensões permitidas

Campos extras específicos do domínio podem ser incluídos sob `extensions`:

```json
{
  "type": "https://docs.qbem.dev/errors/validation",
  "title": "Erro de validação",
  "status": 422,
  "detail": "Campos inválidos",
  "trace_id": "t1",
  "extensions": {
    "policy": "KYC_MINIMUM_AGE",
    "docs": "https://docs.qbem.dev/policies/kyc"
  }
}
```

---

## Segurança de informação

* Não inclua IDs sensíveis, tokens, segredos ou SQL nos `detail`.
* Evite enumerar recursos em mensagens (ex.: “email já cadastrado” → use `409 conflict`
com mensagem neutra).

---

## Contrato OpenAPI (schema padrão)

Inclua um schema **comum** `Error` no OpenAPI:

```yaml
components:
  schemas:
    Error:
      type: object
      required: [type, title, status, trace_id]
      properties:
        type:     { type: string, format: uri }
        title:    { type: string }
        status:   { type: integer }
        detail:   { type: string, nullable: true }
        instance: { type: string, nullable: true }
        trace_id: { type: string }
        errors:
          type: array
          items:
            type: object
            properties:
              field:   { type: string }
              message: { type: string }
```

---

## Testes mínimos

* Validar que **todas as respostas 4xx/5xx** retornam `application/problem+json`.
* Garantir presença de `trace_id`.
* Testar exemplos de `422`, `404`, `409`, `429`, `500`.
