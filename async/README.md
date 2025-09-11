# Padrões para Mensageria Assíncrona

Este diretório reúne os **padrões, convenções e recomendações** para eventos, filas e streaming em integrações assíncronas. O objetivo é garantir **consistência**, **confiabilidade**, **segurança** e **observabilidade** em sistemas distribuídos.

## Índice dos Documentos

- [`conventions.md`](conventions.md)
  Convenções de nomes, envelopes, headers, ordenação, idempotência, evolução de schema, segurança e observabilidade.
- [`headers.md`](headers.md)
  Padrão de headers/atributos para correlação, idempotência, segurança e mapeamento por broker.
- [`schema-evolution.md`](schema-evolution.md)
  Regras para evolução compatível de schemas, versionamento, matriz de compatibilidade e validação em CI.
- [`reliability.md`](reliability.md)
  Estratégias para entrega confiável, retries, DLQ, idempotência, timeouts, circuit breaker e monitoramento.
- [`security.md`](security.md)
  Práticas de segurança: criptografia, autenticação, autorização, integridade, privacidade, auditoria e rate limiting.

  - **Exemplos**
  - [`examples/order-paid.proto`](examples/order-paid.proto): Exemplo de contrato Protobuf.
  - [`examples/payment-failed.json`](examples/payment-failed.json): Exemplo de evento JSON.
  - [`examples/user-created.asyncapi.yaml`](examples/user-created.asyncapi.yaml): Exemplo de contrato AsyncAPI.

## Como usar

1. **Consulte os documentos abaixo** para modelar, publicar e consumir eventos de forma padronizada.
2. **Siga as convenções** de nomes, envelopes, headers e contratos descritas.
3. **Implemente os checklists** para garantir conformidade e robustez.
4. **Valide contratos** (AsyncAPI/Protobuf) e schemas no CI antes de publicar.
5. **Adapte exemplos** conforme seu domínio e broker (Kafka, SQS, Pub/Sub, RabbitMQ).

## Recomendações

- Sempre inclua `event_id`, `event_type`, `occurred_at`, `source` e `metadata` nos envelopes.
- Use headers padrão para rastreabilidade e deduplicação.
- Versione contratos e tópicos conforme regras de compatibilidade.
- Implemente DLQ e métricas para monitoramento.
- Proteja dados sensíveis e aplique ACLs por tópico/fila.

Para dúvidas ou sugestões, consulte os documentos ou entre em contato com o time de arquitetura.
