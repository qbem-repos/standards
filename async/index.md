# Mensageria Assíncrona

Esta seção contém toda a documentação sobre padrões para eventos, filas e streaming na QBEM.

## 📚 Documentos

- **[Convenções](conventions.md)** — Nomes, envelopes, headers, idempotência
- **[Headers Padrão](headers.md)** — Correlação, trace, schema version por broker
- **[Evolução de Schemas](schema-evolution.md)** — Compatibilidade e versionamento
- **[Confiabilidade](reliability.md)** — Retries, DLQ, timeouts, circuit breaker
- **[Segurança](security.md)** — Criptografia, autenticação, ACLs, HMAC
- **[Exemplos](examples/)** — AsyncAPI, Protobuf e JSON de referência

## 🎯 Objetivo

Garantir **consistência**, **confiabilidade** e **observabilidade** na comunicação assíncrona entre serviços.

## 🔑 Princípios

- ✅ **At-least-once delivery** — Idempotência obrigatória
- ✅ **Schema Registry** — Evolução controlada de contratos
- ✅ **Observabilidade** — Trace IDs e correlação em todos os eventos
- ✅ **Segurança** — TLS + ACLs + auditoria

## ✅ Status

**Completo** — Esta documentação está finalizada e pronta para uso.

---

**[⬆ Voltar ao início](../index.md)**