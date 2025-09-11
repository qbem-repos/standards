# Convenções para APIs HTTP

Objetivo: garantir **consistência** e **previsibilidade** entre serviços.

---

## 1) Recursos & URLs
✅ Correto:
```
/v1/users
/v1/users/{id}/orders
/v1/orders/{id}/items
```

❌ Errado:
```
/v1/getUserById
/v1/UserProfile
/v1/users/get-orders
````

---

## 2) Métodos HTTP
- `GET /v1/users` → lista usuários
- `POST /v1/users` → cria usuário
- `GET /v1/users/{id}` → busca usuário
- `PATCH /v1/users/{id}` → atualiza parcialmente
- `DELETE /v1/users/{id}` → remove usuário

---

## 3) Versionamento
### Correto
- ✅ `/v1/users`
- ✅ `/v2/users`
### Errado
- ❌ `/users?version=1`
- ❌ `/api/v1.0/users`

---

## 4) Padrão de resposta

### Paginação por cursor
```json
{
  "items": [
    { "id": "u_1", "email": "ana@example.com" },
    { "id": "u_2", "email": "joao@example.com" }
  ],
  "next_cursor": "abc",
  "prev_cursor": null
}
````

### Paginação por página (quando necessário)

```
GET /v1/users?page=2&limit=50
```

---

## 5) Erros

Formato: [RFC 7807](error-model.md).

Exemplo:

```json
{
  "type": "https://docs.qbem.dev/errors/not-found",
  "title": "Recurso não encontrado",
  "status": 404,
  "detail": "User 123 não existe",
  "trace_id": "c57e8a9f"
}
```

---

## 6) Idempotência

Requisições de criação aceitam cabeçalho `Idempotency-Key`.

Exemplo:

```HTTP
POST /v1/payments
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

---

## 7) Segurança

* Autenticação: `Authorization: Bearer <token>`
* Rate limit:

```plain
HTTP/1.1 429 Too Many Requests
Retry-After: 30
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1631030400
```

---

## 8) Observabilidade

* Health checks:
  * `/health` → retorna `200` se app está vivo
  * `/ready` → retorna `200` se app pode receber tráfego

* Logs devem conter:

```json
{
  "timestamp": "2025-09-11T12:00:00Z",
  "level": "INFO",
  "trace_id": "b6d1e8c2f5f24a0e",
  "message": "User created",
  "user_id": "u_123"
}
```

---

## 9) Cache & Concurrency
Exemplo de ETag:

```HTTP
GET /v1/users/123
If-None-Match: "abc123"
```

Resposta:

```plain
HTTP/1.1 304 Not Modified
```

---

## 10) Internacionalização & Tempo

- ✅ `"created_at": "2025-09-11T14:48:00Z"`
- ❌ `"created_at": "11/09/2025 14:48"`

Valores monetários:

```json
{
  "currency": "BRL",
  "amount": 12990
}
```

*(129,90 reais em centavos)*

---

## 11) Descoberta & Docs

* OpenAPI disponível em: `/openapi.json`
* Exemplo:

```HTTP
GET https://api.qbem.dev/v1/openapi.json
```
