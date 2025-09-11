# Evolução de Schemas (Eventos/Filas/Streaming)

Objetivo: permitir **evolução contínua** sem quebrar consumidores.

---

## Princípios

1. **Compatível por padrão**: só mudanças **aditivas e opcionais** sem alterar significado.
2. **Versão no contrato** (`schema_version` semver) e **no tópico** quando *breaking* (`-v2`).
3. **Consumidores tolerantes**: ignorem campos desconhecidos e tratem defaults.
4. **Feature flags/dual-write** para migrações de payloads.
5. **Tudo testado no CI** (diff de schema + contratos publicados).

---

## Mapeamento de SemVer

* **MAJOR** (X.y.z): mudança *breaking* → **novo tópico** `*-v{X+1}`.
* **MINOR** (x.Y.z): campos novos **opcionais** e semântica extendida → mesmo tópico.
* **PATCH** (x.y.Z): correções de docs, exemplos, descrições → mesmo tópico.

`metadata.schema_version` reflete **schema do payload**. Tópico usa sufixo `-vN` apenas em *breaking*.

---

## Compatível vs ❌ Breaking

| Mudança                                                | Compatível? | Ação                                                   |
| ------------------------------------------------------ | ----------- | ------------------------------------------------------ |
| Adicionar **campo opcional**                           | ✅           | Incrementar **MINOR**                                  |
| Adicionar **enum value** (cliente ignora desconhecido) | ✅           | MINOR                                                  |
| Adicionar **object opcional**                          | ✅           | MINOR                                                  |
| Tornar **campo obrigatório**                           | ❌           | **Novo tópico `-v{+1}`**                               |
| Remover campo                                          | ❌           | Novo tópico                                            |
| Renomear campo                                         | ❌           | Novo tópico (ou manter ambos por período de transição) |
| Mudar **tipo** (string → number, etc.)                 | ❌           | Novo tópico                                            |
| Alterar semântica do campo (ex.: unidade, timezone)    | ❌           | Novo tópico                                            |
| Mudar formato/escala de números (centavos → decimal)   | ❌           | Novo tópico (ou `new_*` + transição)                   |
| Reordenar campos                                       | ✅           | Sem impacto                                            |
| Adicionar **valor default** só no produtor             | ⚠️          | MINOR (clientes devem suportar ausência e default)     |
| Reduzir precisão de datas/números                      | ❌           | Novo tópico                                            |

---

## Padrões de Modelagem

* **Datas/tempos:** sempre **ISO 8601 UTC** (`2025-09-11T12:00:00Z`).
* **Valores monetários:** `{ currency: "BRL", amount: 12990 }` (inteiro em centavos).
* **Enums:** documente “tratamento de desconhecido” (fallback `unknown`).
* **IDs:** strings estáveis (evite inferências do formato).
* **Arrays:** adicionar item é compatível; mudar tipo interno é *breaking*.
* **oneOf/discriminator:** se usar, **não** mude `discriminator.property` (breaking).

---

## Exemplo de Mudança Compatível

Antes:

```json
"data": {
  "order_id": "ord_123",
  "total": { "currency": "BRL", "amount": 12990 }
}
```

Depois (MINOR):

```json
"data": {
  "order_id": "ord_123",
  "total": { "currency": "BRL", "amount": 12990 },
  "coupon": { "code": "WELCOME10" }  // novo campo opcional
},
"metadata": { "schema_version": "1.1.0" }
```

---

## ❌ Exemplo de *Breaking* (requer `-v2`)

Mudança de tipo:

```diff
- "order_id": "ord_123"   // string
+ "order_id": 123         // number  → BREAKING
```

Ação: publicar em `orders-order-created-**v2**` e manter `v1` durante transição.

---

## 🔀 Estratégia de Migração (sem downtime)

1. **Planejar**
   * Defina *target schema*, riscos e plano de rollback.

2. **Preparar consumidores** (compat-forward)
   * Garanta que **ignoram campos desconhecidos** e têm defaults.

3. **Dual-write** *(se payload muda significativamente sem quebrar)*
   * Produtor publica **campo novo opcional** junto ao antigo.

4. **Shadow read** *(opcional)*
   * Consumidor lê o novo evento/tópico em paralelo, sem efeitos colaterais, só para medir.

5. **Cutover**
   * Troque consumidores para usar o novo campo/tópico.

6. **Desligar legado**
   * Announce depreciação + prazo; remover após período (ex.: 90 dias).

---

## Versionar no Tópico vs Só no Schema

* **Só `schema_version`** (sem novo tópico) quando for **compatível**.
* **Novo tópico `-v{n+1}`** quando:

  * Campo obrigatório novo.
  * Mudança de tipo ou semântica.
  * Novo particionamento/ordering ou chave muda.
  * Política de retenção/compaction exige separação.

**Ex.:**
`orders-order-created-v1` → compatíveis com `schema_version: 1.y.z`.
`orders-order-created-v2` → quando *breaking*.

---

## Validação em CI

### AsyncAPI (JSON/YAML)

* Lint: `asyncapi validate` (ou CLI equivalente).
* Diff: compare `components/messages.*.payload` (schema) entre versões.

### Protobuf

* Use **buf**:

```bash
buf lint
buf breaking --against '.git#branch=main'
```

* Configure **allow rules** para mudanças compatíveis.

### Portas de verificação

* **Bloquear PR** com *breaking* sem alterar sufixo `-vN`.
* Exigir **atualização de `schema_version`** quando payload mudar.

---

## Contrato: Campos de Controle

No **envelope**:

```json
{
  "event_id": "uuid",
  "event_type": "orders.order.created",
  "occurred_at": "2025-09-11T12:00:00Z",
  "source": "orders-service",
  "metadata": {
    "schema_version": "1.3.0"
  }
}
```

Headers (ver `headers.md`):
`schema_version`, `trace_id`, `correlation_id`, `idempotency_key`, `producer`, `tenant_id`.

---

## Estratégias para *Breaking* sem dor

* **Novo campo com prefixo** `new_` → preencha **ambos** por período de transição, depois remova o antigo.
* **Conversores no consumidor**: camada que normaliza `v1` → `v2`.
* **Publicação dupla**: `v1` e `v2` em paralelo até consumo ≥ 95% em `v2`.
* **Backfill** (opcional): reprocessar históricos para popular dados novos (cuidado com side effects).

---

## Matriz de Compatibilidade (rápida)

| Ação                                    | Produtor               | Consumidor                |
| --------------------------------------- | ---------------------- | ------------------------- |
| Adicionar campo opcional                | Atualiza               | Sem ação                  |
| Remover campo                           | Novo tópico            | Atualiza para novo tópico |
| Tornar campo obrigatório                | Novo tópico            | Atualiza para novo tópico |
| Mudar tipo                              | Novo tópico            | Atualiza para novo tópico |
| Adicionar enum value                    | Atualiza               | Ignora/desconhecido       |
| Aumentar precisão (ex.: cents → micros) | Campo novo + transição | Tolerante a ambos         |
| Mudar particionamento                   | Novo tópico            | Reconfiguração necessária |

---

## Ferramentas sugeridas

* **Schema Registry** (Kafka/Confluent ou equivalente) com **compatibility=BACKWARD**.
* **buf** (Protobuf), **asyncapi** CLI, **schemathesis** (contratos em testes).
* **Linters** e **pre-commit hooks** para bloquear PR sem contrato atualizado.

---

## Checklist antes de publicar

* [ ] Mudança é compatível? Se **não**, criar **novo tópico `-v{n+1}`**.
* [ ] `metadata.schema_version` incrementado (SemVer).
* [ ] CI: lint + breaking check verde.
* [ ] Consumidores toleram campos extras e valores desconhecidos?
* [ ] Plano de rollback e depreciação definido.
* [ ] Observabilidade atualizada (métricas por `schema_version`).
