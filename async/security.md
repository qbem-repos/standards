# Segurança em Mensageria

Objetivo: proteger **dados em trânsito**, garantir **acesso controlado** e evitar abusos.

---

## 1) Criptografia
- **TLS obrigatório** na comunicação com broker (Kafka, RabbitMQ, Pub/Sub, SQS).
- Mensagens sensíveis: avaliar criptografia **de payload** (ex.: AES-GCM).

---

## 2) Autenticação
- **Kafka**: SASL/SCRAM, OAuth ou mTLS.
- **RabbitMQ**: usuário/senha + TLS.
- **AWS/GCP**: IAM roles/service accounts.
- Credenciais sempre gerenciadas por **Vault/Secret Manager**.

---

## 3) Autorização (ACLs)
- Controle granular por **ação + tópico/fila**:
  - `produce` → só produtores autorizados.
  - `consume` → só consumidores autorizados.
- Padrão:
  - `orders-service` pode **produzir** em `orders-*`.
  - `billing-service` pode **consumir** `orders-order-created-v1`.

---

## 4) Integridade & Autenticidade
- Para ambientes multi-tenant ou fora da rede confiável:
  - Header `signature` (HMAC-SHA256 com chave secreta).
  - Header `timestamp` (ISO 8601).
  - Consumidor valida:
    1. Assinatura em tempo constante.
    2. `now - timestamp <= 5m`.
    3. Deduplicação por `idempotency_key`.

---

## 5) Privacidade & PII
- Publicar **apenas dados necessários**.
- Evitar PII sensível em payload (CPF, endereço, telefone) → se necessário, aplicar:
  - **Mascaramento** ou **hash**.
  - **Tokenização**.
- Seguir LGPD/GDPR → base legal clara para cada evento.

---

## 6) Auditoria
- Registrar:
  - `producer` (serviço emissor).
  - `consumer` (serviço consumidor).
  - `event_id`, `event_type`, `trace_id`.
  - `delivered_at` + `ack_at`.
- Logs imutáveis e acessíveis só a roles autorizados.

---

## 7) Rate Limiting & Abuse
- Proteger consumidores críticos com **quota por tenant**.
- Alertar em:
  - Picos anormais de mensagens.
  - Volume acima de baseline (ex.: 5x média).

---

## 8) Checklist
- [ ] TLS obrigatório.
- [ ] Credenciais seguras (Vault/Secret Manager).
- [ ] ACLs aplicadas por tópico/fila.
- [ ] Assinatura HMAC quando fora de rede confiável.
- [ ] PII minimizada/mascarada.
- [ ] Auditoria ativada (logs + métricas).
