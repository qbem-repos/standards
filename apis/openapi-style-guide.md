# Guia de Estilo — OpenAPI (3.1)

Este guia define como escrever e manter contratos **OpenAPI 3.1** de forma padronizada.

---

## Versão e Estrutura

- **Obrigatório:** OpenAPI 3.1 + JSON Schema Draft 2020-12.
- Arquivo raiz: `openapi.yaml` (pode referenciar outros via `$ref`).
- Um spec por serviço.
- Reuso de schemas em `components/schemas`.

Exemplo início de arquivo:

```yaml
openapi: 3.1.0
info:
  title: Orders API
  version: "1.0.0"
  description: API para gestão de pedidos
servers:
  - url: https://api.sua-org.dev/v1

````

---

## Tags

*Agrupe endpoints por domínio funcional.
*Nome em **minúsculo** e singular/plural coerente.

Exemplo:

```yaml
tags:
  - name: users
    description: Operações relacionadas a usuários
  - name: orders
    description: Gestão de pedidos
```

---

## Schemas

*Campos em **snake\_case**.
*Inclua **exemplos reais** (`example:`).
*Documente `nullable: true` explicitamente.

Exemplo:

```yaml
components:
  schemas:
    User:
      type: object
      required: [id, email, created_at]
      properties:
        id:
          type: string
          example: u_123
        email:
          type: string
          format: email
          example: ana@example.com
        name:
          type: string
          nullable: true
          example: Ana
        created_at:
          type: string
          format: date-time
          example: 2025-09-11T12:00:00Z
```

---

## Endpoints

*Sempre inclua `summary`, `description` (quando relevante) e `operationId` **único**.
*Use parâmetros de forma consistente (`in: path`, `in: query`).
*Documente **status de erro** (`4xx`, `5xx`).

Exemplo:

```yaml
paths:
  /users/{id}:
    get:
      summary: Detalhar usuário
      description: Retorna dados completos do usuário
      operationId: getUser
      tags: [users]
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        "200":
          description: OK
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/User"
        "404":
          description: Não encontrado
          content:
            application/problem+json:
              schema:
                $ref: "#/components/schemas/Error"
```

---

## Headers e Padrões

*Defina headers padrão em `components/headers`.
*Inclua `RateLimit-*`, `ETag`, `Retry-After` se aplicável.

Exemplo:

```yaml
components:
  headers:
    X-RateLimit-Limit:
      description: Número máximo de requests permitidos
      schema:
        type: integer
    X-RateLimit-Remaining:
      description: Requests restantes na janela atual
      schema:
        type: integer
```

---

## Segurança

*Defina `securitySchemes` em `components`.
*Autenticação padrão: Bearer JWT.

Exemplo:

```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

---

## Erros

*Sempre usar modelo RFC 7807 (ver `error-model.md`).
*Inclua `trace_id` em todos os erros.

Exemplo:

```yaml
components:
  schemas:
    Error:
      type: object
      required: [type, title, status, trace_id]
      properties:
        type: { type: string, format: uri }
        title: { type: string }
        status: { type: integer }
        detail: { type: string }
        instance: { type: string }
        trace_id: { type: string }
```

---

## Boas práticas extras

*`oneOf`/`anyOf` com `discriminator` quando necessário.
*Sempre fornecer **exemplo válido** em cada endpoint.
*Usar **links** para relacionar recursos (`Link: rel="next"` em paginação).
*Sempre documentar códigos de erro esperados.

---

## Lint & CI

***Spectral** com `tooling/spectral/ruleset.yaml` obrigatório.
***oasdiff** no CI para detectar breaking changes.
*Bloquear merge se contrato estiver desatualizado.
