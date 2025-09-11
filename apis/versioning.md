# Versionamento de APIs

O objetivo é garantir **evolução previsível** sem quebrar consumidores inesperadamente.
Adotamos **SemVer** para contratos e **versionamento na URL**.

---

## Estratégia

* Versão **major na URL**: `/v1`, `/v2`.
* Contratos seguem **SemVer**:

  * **Major**: mudanças *breaking* → nova versão (`v2`).
  * **Minor**: mudanças compatíveis → incrementa `info.version` (`1.1.0`).
  * **Patch**: correções sem impacto → incrementa (`1.0.1`).

Exemplo:

```plain
/v1/users        → versão estável
/v2/users        → quando houver breaking
```

---

## O que é *breaking*

* Remover endpoint, campo ou parâmetro.
* Alterar nome ou tipo de campo.
* Tornar campo opcional em obrigatório.
* Mudar semântica da resposta.
* Alterar status code esperado (`200 → 201`).

Exemplo breaking ❌:

```yaml
# Antes
properties:
  age: { type: integer }

# Depois (incompatível)
properties:
  age: { type: string }
```

---

## O que **não** é breaking

* Adicionar novos endpoints.
* Adicionar campos opcionais.
* Adicionar novos valores permitidos em enum (quando cliente faz fallback).
* Melhorar descrições, docs ou exemplos.

Exemplo compatível ✔️:

```yaml
# Antes
properties:
  email: { type: string }

# Depois (ainda compatível)
properties:
  email: { type: string }
  phone: { type: string, nullable: true }
```

---

## Depreciação

* Marque recursos antigos com `deprecated: true` no OpenAPI.
* Inclua cabeçalhos HTTP:

```plain
Deprecation: version="v1"; date="2025-12-01"
Sunset: Wed, 01 Jun 2026 00:00:00 GMT
Link: <https://docs.sua-org.dev/migration/v2>; rel="deprecation"
```

---

## Ciclo de vida sugerido

1. **Aviso de depreciação**: publicado pelo menos **90 dias antes** da remoção.
2. **Suporte paralelo**: mantenha `v1` e `v2` por período de transição.
3. **Remoção**: comunicar claramente no changelog e docs.

---

## Compatibilidade no CI

Automatize verificação de breaking changes:

```bash
# Exemplo usando oasdiff
npx oasdiff breaking v1/openapi.yaml v2/openapi.yaml
```

Integre no pipeline para bloquear merges que introduzam breaking sem major novo.

---

## Exemplo no OpenAPI

```yaml
openapi: 3.1.0
info:
  title: Orders API
  version: "1.2.0"   # minor compatível
servers:
  - url: https://api.sua-org.dev/v1
paths:
  /orders:
    get:
      summary: Lista pedidos
      deprecated: true
      description: |
        Este endpoint será removido em 2026-06-01.
        Use GET /v2/orders em seu lugar.
```

---

## Checklist para versionar

* [ ] Nova versão major → caminho `/v{n}` atualizado.
* [ ] Recursos antigos marcados como `deprecated: true`.
* [ ] Documentação de migração publicada.
* [ ] Cabeçalhos HTTP de depreciação adicionados.
* [ ] CI validando breaking changes (oasdiff).
