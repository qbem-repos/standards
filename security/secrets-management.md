# Gestão de Segredos

Objetivo: garantir que **credenciais, chaves API, tokens e certificados** sejam armazenados, acessados e rotacionados de forma segura.

---

## 1) Princípios

- 🚫 **NUNCA** commitar segredos no código-fonte
- 🔒 Segredos devem ser armazenados em **cofres dedicados**
- 🔄 **Rotação automática** sempre que possível
- 🎯 **Least privilege** — acesso mínimo necessário
- 📊 **Auditoria completa** — quem acessou o quê e quando
- ⏱️ **Tempo de vida limitado** — secrets com TTL curto

---

## 2) Onde Armazenar

### ✅ Correto

- **HashiCorp Vault** (on-premise ou cloud)
- **AWS Secrets Manager**
- **GCP Secret Manager**
- **Azure Key Vault**
- **Kubernetes Secrets** (com criptografia habilitada)

### ❌ Nunca Fazer

- ❌ Hardcoded no código
- ❌ Arquivos `.env` commitados
- ❌ Variáveis de ambiente em Dockerfile
- ❌ Logs ou stack traces
- ❌ Comentários no código
- ❌ Issues públicas ou wiki

---

## 3) Tipos de Segredos

### 🔑 Credenciais de Banco de Dados

```plaintext
db/postgres/production/username
db/postgres/production/password
db/postgres/production/connection-string
```

**Rotação:** Automática a cada 30-90 dias

### 🌐 API Keys & Tokens

```plaintext
api/stripe/secret-key
api/sendgrid/api-key
api/google-maps/api-key
```

**Rotação:** Sob demanda ou 90 dias

### 🔐 Certificados TLS

```plaintext
tls/api.qbem.com.br/cert
tls/api.qbem.com.br/key
```

**Rotação:** Automática antes da expiração (Let's Encrypt)

### 🎫 OAuth Secrets

```plaintext
oauth/google/client-id
oauth/google/client-secret
oauth/github/client-secret
```

**Rotação:** Anual ou quando comprometido

### 🔏 Chaves de Criptografia

```plaintext
encryption/aes-master-key
encryption/jwt-signing-key
encryption/hmac-secret
```

**Rotação:** Trimestral com re-encriptação

---

## 4) Padrão de Nomenclatura

```plaintext
<ambiente>/<serviço>/<tipo>/<nome>

Exemplos:
production/orders-service/db/password
staging/billing-service/api/stripe-key
development/notification-service/smtp/password
```

### Convenções

- ✅ Lowercase com hífens
- ✅ Ambiente como prefixo
- ✅ Contexto do serviço
- ✅ Tipo claramente identificado

---

## 5) Como Injetar Segredos

### Kubernetes (Vault Injector)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: orders-service
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "orders-service"
    vault.hashicorp.com/agent-inject-secret-db: "secret/data/production/orders/db"
spec:
  containers:
  - name: app
    image: orders-service:latest
    env:
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: orders-db-secret
          key: connection-string
```

### AWS (Secrets Manager + IAM)

```javascript
// Node.js
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager();

async function getSecret(secretName) {
  const data = await secretsManager.getSecretValue({ 
    SecretId: secretName 
  }).promise();
  
  return JSON.parse(data.SecretString);
}

// Uso
const dbCreds = await getSecret('production/orders-service/db');
const db = createConnection(dbCreds.connectionString);
```

### Vault CLI

```bash
# Ler secret
vault kv get secret/production/orders-service/db

# Usar em script
export DB_PASSWORD=$(vault kv get -field=password secret/production/orders-service/db)
```

### Docker (secrets como volumes)

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    image: orders-service
    secrets:
      - db_password
    environment:
      DB_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    external: true
```

---

## 6) Rotação de Segredos

### Automática (Recomendado)

**Vault Dynamic Secrets:**

```hcl
# Vault config
path "database/creds/orders-readonly" {
  capabilities = ["read"]
}
```

```javascript
// App consome credenciais dinâmicas
const creds = await vault.read('database/creds/orders-readonly');
// TTL: 1 hora, renovação automática
```

### Manual (Procedimento)

1. 🔑 Gerar novo secret
2. 🔄 Atualizar Vault/Secret Manager
3. 🚀 Fazer rollout gradual dos serviços
4. ✅ Validar funcionamento
5. 🗑️ Remover secret antigo após 24h

---

## 7) Detecção de Vazamento

### Git Hooks (pre-commit)

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

### GitHub Actions

```yaml
name: Scan Secrets
on: [push, pull_request]
jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Gitleaks
        uses: gitleaks/gitleaks-action@v2
```

### Ferramentas

- **Gitleaks** — Scan histórico do Git
- **TruffleHog** — Busca secrets em commits
- **detect-secrets** — Pre-commit hook
- **GitGuardian** — Monitoramento contínuo

---

## 8) Resposta a Vazamento

Se um secret for exposto:

1. ⚠️ **Revogar imediatamente**
2. 🔄 **Gerar novo secret**
3. 🚀 **Deploy urgente** com novo secret
4. 📊 **Auditar acesso** — quem usou o secret comprometido?
5. 🔍 **Investigar impacto** — que ações foram feitas?
6. 📝 **Documentar incidente** e lições aprendidas

---

## 9) Acesso de Desenvolvedores

### Desenvolvimento Local

```bash
# Nunca compartilhar secrets de produção!
# Use secrets de desenvolvimento

# Obter secret de dev
vault login -method=oidc
vault kv get secret/development/orders-service/db
```

### Ambientes

- **Production** — Acesso restrito (apenas CI/CD + SRE on-call)
- **Staging** — Time de desenvolvimento
- **Development** — Todos os desenvolvedores

### Política de Acesso

```hcl
# Vault policy - developers
path "secret/data/development/*" {
  capabilities = ["read", "list"]
}

path "secret/data/staging/*" {
  capabilities = ["read", "list"]
}

path "secret/data/production/*" {
  capabilities = ["deny"]
}
```

---

## 10) Auditoria

### Logs Obrigatórios

- ✅ Quem acessou qual secret
- ✅ Quando foi acessado
- ✅ De onde (IP, serviço)
- ✅ Operação (read, write, delete)
- ✅ Sucesso ou falha

### Vault Audit Log

```json
{
  "time": "2024-01-15T10:30:00Z",
  "type": "response",
  "auth": {
    "display_name": "orders-service",
    "policies": ["orders-service-policy"]
  },
  "request": {
    "operation": "read",
    "path": "secret/data/production/orders-service/db"
  },
  "response": {
    "secret": true
  }
}
```

### Alertas

- 🚨 Acesso de produção fora do horário comercial
- 🚨 Múltiplas falhas de autenticação
- 🚨 Acesso de IP desconhecido
- 🚨 Secret lido mas não usado (suspeito)

---

## 11) Checklist

### ![code](https://api.iconify.design/lucide:code.svg?width=14) Desenvolvimento

- [ ] Nenhum secret hardcoded
- [ ] `.env` no `.gitignore`
- [ ] Pre-commit hook configurado
- [ ] Secrets apenas de dev/staging localmente

### ![rocket](https://api.iconify.design/lucide:rocket.svg?width=14) Deploy

- [ ] Secrets armazenados em Vault/Secret Manager
- [ ] Injeção via variáveis de ambiente ou volumes
- [ ] Permissões de acesso mínimas (IAM/RBAC)
- [ ] TTL configurado (quando aplicável)

### ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=14) Produção

- [ ] Rotação automática habilitada
- [ ] Auditoria de acesso ativa
- [ ] Alertas configurados
- [ ] Backup dos secrets (criptografado)
- [ ] Plano de resposta a vazamento

---

## 12) Exemplos

### Node.js com Vault

```javascript
const vault = require('node-vault')({
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN
});

async function initDatabase() {
  const { data } = await vault.read('secret/data/production/orders-service/db');
  
  return createConnection({
    host: data.host,
    user: data.username,
    password: data.password,
    database: data.database
  });
}
```

### Python com AWS Secrets Manager

```python
import boto3
import json

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# Uso
db_creds = get_secret('production/orders-service/db')
connection = psycopg2.connect(
    host=db_creds['host'],
    user=db_creds['username'],
    password=db_creds['password']
)
```

### Go com GCP Secret Manager

```go
import (
    secretmanager "cloud.google.com/go/secretmanager/apiv1"
    "context"
)

func getSecret(name string) (string, error) {
    ctx := context.Background()
    client, _ := secretmanager.NewClient(ctx)
    defer client.Close()

    result, err := client.AccessSecretVersion(ctx, &secretmanagerpb.AccessSecretVersionRequest{
        Name: name,
    })
    
    return string(result.Payload.Data), err
}
```

---

## 📚 Referências

- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [HashiCorp Vault Best Practices](https://learn.hashicorp.com/tutorials/vault/production-hardening)
- [AWS Secrets Manager Best Practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [12-Factor App: Config](https://12factor.net/config)

---

**[⬆ Voltar](README.md)**