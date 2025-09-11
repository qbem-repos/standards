# Standards

Este repositório concentra as **padronizações oficiais** usadas nos serviços da organização: APIs, webhooks, eventos assíncronos, observabilidade e segurança.
O objetivo é dar **autonomia aos times**, garantindo ao mesmo tempo **consistência, qualidade e segurança**.

---

## Estrutura

* **/apis** → convenções para APIs HTTP (OpenAPI, versionamento, erros, exemplos).
* **/webhooks** → guia para design, segurança (HMAC), retries e exemplos.
* **/async** → padrões para eventos/filas (AsyncAPI/Protobuf, schema evolution).
* **/observability** → logs estruturados, métricas e tracing (OpenTelemetry).
* **/security** → práticas de segurança (segredos, dependências, threat modeling).
* **/tooling** → linters, pre-commit, checklists e regras de validação.
* **/adr** → *Architecture Decision Records* (histórico de decisões).

---

## Como usar

1. Consulte a pasta do domínio relevante (ex.: `apis/`, `webhooks/`).
2. Reaproveite exemplos e checklists disponíveis.
3. Sempre que criar algo novo, valide com as regras e ferramentas daqui.
4. Em caso de dúvidas, abra uma issue ou PR neste repositório.

---

## Evolução dos padrões

* Toda mudança deve passar por **RFC curta** (issue ou PR).
* Decisões aprovadas viram um **ADR** em `/adr`.
* As regras aqui são **vivas**: evoluem com feedback dos times e aprendizados.

---

## Convenções gerais

* **Conventional Commits** + **SemVer**.
* Documentação obrigatória (OpenAPI/AsyncAPI).
* Observabilidade padrão (logs JSON, métricas, tracing).
* Segurança desde o início (HMAC, secrets, dependências auditadas).

---

## Contribuindo

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para entender como propor mudanças.
Pull Requests são bem-vindos — este repositório é a **fonte da verdade** para todos os times.
