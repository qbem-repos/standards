# Logs Estruturados

Padrões para logs estruturados, contextuais e eficientes para diagnóstico.

---

## 1) Formato Padrão

**Obrigatório:** JSON estruturado com campos padronizados.

```json
{
  "timestamp": "2025-01-10T14:30:00.123Z",
  "level": "INFO",
  "message": "User logged in successfully",
  "service": "auth-service",
  "trace_id": "abc123def456",
  "span_id": "789xyz",
  "environment": "production",
  "version": "1.2.3",
  "context": {
    "user_id": "u_789",
    "session_id": "sess_456",
    "ip": "192.168.1.1"
  }
}
```

---

## 2) Níveis de Log

Use níveis apropriados para facilitar filtragem:

| Nível | Uso | Quando usar |
|-------|-----|-------------|
| **TRACE** | Debugging detalhado | Desenvolvimento local apenas |
| **DEBUG** | Informações de debug | Troubleshooting em staging |
| **INFO** | Eventos normais | Operações bem-sucedidas |
| **WARN** | Situações anormais mas recuperáveis | Retries, degradação |
| **ERROR** | Erros que precisam atenção | Falhas de operação |
| **FATAL** | Sistema não pode continuar | Crash iminente |

**Regra:** Produção deve ter nível **INFO** ou superior.

---

## 3) Campos Obrigatórios

Todo log **deve** conter:

### Campos Base

```typescript
{
  "timestamp": string,      // ISO 8601 com milissegundos (UTC)
  "level": string,          // TRACE|DEBUG|INFO|WARN|ERROR|FATAL
  "message": string,        // Mensagem legível
  "service": string,        // Nome do serviço
  "environment": string,    // production|staging|development
  "version": string         // Versão do serviço (SemVer)
}
```

### Campos de Correlação

```typescript
{
  "trace_id": string,       // W3C Trace Context ou UUID
  "span_id": string,        // Span ID do trace (opcional em logs simples)
  "correlation_id": string, // ID de saga/fluxo de negócio (opcional)
  "request_id": string      // ID único da requisição
}
```

---

## 4) Contexto Adicional

Adicione contexto relevante no campo `context`:

### Para APIs HTTP

```json
{
  "context": {
    "http": {
      "method": "POST",
      "path": "/v1/orders",
      "status_code": 201,
      "user_agent": "axios/1.4.0",
      "duration_ms": 123
    },
    "user_id": "u_789",
    "tenant_id": "tn_1"
  }
}
```

### Para Eventos Assíncronos

```json
{
  "context": {
    "event": {
      "type": "orders.order.created",
      "event_id": "evt_123",
      "topic": "orders-order-created-v1",
      "partition": 3,
      "offset": 98765
    },
    "user_id": "u_789"
  }
}
```

### Para Background Jobs

```json
{
  "context": {
    "job": {
      "id": "job_456",
      "type": "send-email",
      "attempt": 2,
      "max_attempts": 5
    },
    "user_id": "u_789"
  }
}
```

---

## 5) Tratamento de Erros

Logs de erro devem incluir stack trace e contexto:

```json
{
  "timestamp": "2025-01-10T14:30:00.123Z",
  "level": "ERROR",
  "message": "Failed to process payment",
  "service": "payment-service",
  "trace_id": "abc123",
  "error": {
    "type": "PaymentGatewayError",
    "message": "Gateway timeout after 30s",
    "code": "GATEWAY_TIMEOUT",
    "stack": "Error: Gateway timeout...\n  at processPayment (/app/payment.js:45:10)"
  },
  "context": {
    "order_id": "ord_999",
    "amount": 12990,
    "gateway": "stripe"
  }
}
```

### Campos de Erro

```typescript
{
  "error": {
    "type": string,        // Tipo/classe do erro
    "message": string,     // Mensagem de erro
    "code": string,        // Código de erro (interno)
    "stack": string        // Stack trace (apenas em ERROR/FATAL)
  }
}
```

---

## 6) Segurança e PII

### ❌ Nunca Logar

- Senhas ou secrets
- Tokens de autenticação completos
- Números de cartão de crédito
- CPF/RG completos
- Dados bancários

### ✅ Mascarar Dados Sensíveis

```json
{
  "context": {
    "email": "jo***@example.com",
    "cpf": "***.***.123-45",
    "card": "****-****-****-1234",
    "token": "Bearer ey...{truncated}"
  }
}
```

**Regras de sanitização:**
- Mascare PII antes de logar
- Use funções/bibliotecas de sanitização automática
- Revise regularmente logs em produção

---

## 7) Boas Práticas

### Mensagens Claras e Acionáveis

❌ **Ruim:**
```json
{ "message": "Error" }
```

✅ **Bom:**
```json
{ 
  "message": "Failed to connect to database after 3 retries",
  "context": { "host": "db.qbem.net.br", "port": 5432 }
}
```

### Use Structured Logging, não String Concatenation

❌ **Ruim:**
```javascript
logger.info(`User ${userId} logged in from ${ip}`);
```

✅ **Bom:**
```javascript
logger.info('User logged in', {
  user_id: userId,
  ip: ip
});
```

### Log no Momento Certo

- **Antes de operações críticas:** "Starting payment processing"
- **Após operações críticas:** "Payment processed successfully"
- **Em pontos de decisão:** "Payment gateway selected: stripe"
- **Em erros:** Sempre, com contexto completo

### Evite Log Excessivo

❌ **Evite:**
- Logar dentro de loops tight
- Logs de debug esquecidos em produção
- Repetir logs idênticos em burst

✅ **Use:**
- Sampling (1 em N requisições)
- Rate limiting de logs
- Agregação antes de logar

---

## 8) Retenção e Busca

### Retenção Recomendada

| Ambiente | Retenção | Motivo |
|----------|----------|--------|
| Production | 30-90 dias | Compliance, troubleshooting |
| Staging | 7-14 dias | Testes, validação |
| Development | 1-3 dias | Debug local |

### Índices para Busca Eficiente

Garanta índices em:
- `timestamp` (range queries)
- `trace_id` (correlação)
- `service` + `environment` (filtragem)
- `level` (severidade)
- `context.user_id` (user-centric debugging)

---

## 9) Integração com Tracing

Sempre correlacione logs com traces:

```json
{
  "timestamp": "2025-01-10T14:30:00.123Z",
  "level": "INFO",
  "message": "Database query executed",
  "trace_id": "abc123def456",
  "span_id": "span789",
  "context": {
    "query": "SELECT * FROM orders WHERE id = ?",
    "duration_ms": 45
  }
}
```

**Benefício:** Clicar em um log leva diretamente ao trace completo.

---

## 10) Bibliotecas Recomendadas

### Python
- **structlog** — Structured logging com contexto
- **python-json-logger** — JSON formatter para stdlib logging

### C# (.NET)
- **Serilog** — Structured logging com sinks diversos
- **NLog** — Alternativa ao Serilog

### Node.js
- **pino** — Fast JSON logger
- **winston** — Popular, flexível

### Java
- **Logback** — Sucessor do log4j
- **Log4j2** — Com suporte a structured logging

**Configurações detalhadas:** Ver `tooling/observability/`

---

## 11) Checklist

Antes de ir para produção:

- [ ] Logs em formato JSON estruturado
- [ ] Campos obrigatórios presentes (`timestamp`, `level`, `message`, `service`, `trace_id`)
- [ ] Contexto relevante adicionado
- [ ] PII mascarada ou ausente
- [ ] Stack traces apenas em ERROR/FATAL
- [ ] Correlação com traces implementada
- [ ] Nível de log configurável via variável de ambiente
- [ ] Retenção definida (30-90 dias em produção)
- [ ] Índices de busca otimizados
- [ ] Teste de volume (não explodir storage em produção)

---

## 12) Ferramentas Recomendadas

### Aggregation & Storage
- **Loki** (Grafana Labs) — Logs agregados, query similar ao Prometheus
- **Elasticsearch** — Full-text search, análise complexa
- **CloudWatch Logs** (AWS) — Integração nativa com AWS
- **Cloud Logging** (GCP) — Integração nativa com GCP

### Análise & Visualização
- **Grafana** — Dashboards e queries (com Loki)
- **Kibana** — UI para Elasticsearch
- **Seq** — Log server para .NET

---

## Referências

- [Structured Logging Best Practices](https://www.sumologic.com/blog/structured-logging-best-practices/)
- [OpenTelemetry Logs](https://opentelemetry.io/docs/specs/otel/logs/)
- [Google SRE Book - Logging](https://sre.google/sre-book/monitoring-distributed-systems/)
- [12 Factor App - Logs](https://12factor.net/logs)