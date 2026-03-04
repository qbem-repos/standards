# Autenticação & Autorização

Objetivo: garantir que **apenas usuários e serviços autorizados** acessem recursos, com **permissões adequadas**.

---

## 1) Autenticação vs Autorização

### Autenticação (AuthN)
**"Quem é você?"**

- ✅ Verificar identidade do usuário/serviço
- ✅ Validar credenciais (senha, token, certificado)
- ✅ Gerar token de sessão/acesso

### Autorização (AuthZ)
**"O que você pode fazer?"**

- ✅ Verificar permissões do usuário/serviço
- ✅ Validar acesso ao recurso específico
- ✅ Aplicar políticas de controle de acesso

---

## 2) Autenticação de Usuários

### OAuth 2.0 + OIDC (Recomendado)

**Fluxo Authorization Code com PKCE:**

```plaintext
1. App → Authorization Server: /authorize?response_type=code&client_id=...&code_challenge=...
2. Usuário autentica e autoriza
3. Auth Server → App: redirect com code
4. App → Auth Server: /token (code + code_verifier)
5. Auth Server → App: access_token + id_token + refresh_token
6. App → API: Authorization: Bearer <access_token>
```

**Configuração (exemplo com Auth0):**

```javascript
const { auth } = require('express-openid-connect');

app.use(auth({
  authRequired: false,
  auth0Logout: true,
  issuerBaseURL: 'https://qbem.us.auth0.com',
  baseURL: 'https://app.qbem.com.br',
  clientID: process.env.AUTH0_CLIENT_ID,
  clientSecret: process.env.AUTH0_CLIENT_SECRET,
  secret: process.env.SESSION_SECRET,
  authorizationParams: {
    response_type: 'code',
    scope: 'openid profile email',
    audience: 'https://api.qbem.com.br'
  }
}));
```

### JWT (JSON Web Token)

**Estrutura:**

```plaintext
Header.Payload.Signature

eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyXzEyMzQ1IiwiaWF0IjoxNjQyNTk3MjAwLCJleHAiOjE2NDI1OTgxMDAsImlzcyI6Imh0dHBzOi8vYXV0aC5xYmVtLmNvbS5iciIsImF1ZCI6Im9yZGVycy1hcGkiLCJzY29wZSI6Im9yZGVyczpyZWFkIG9yZGVyczp3cml0ZSJ9.signature
```

**Payload (claims):**

```json
{
  "sub": "user_12345",
  "iat": 1642597200,
  "exp": 1642598100,
  "iss": "https://auth.qbem.com.br",
  "aud": "orders-api",
  "scope": "orders:read orders:write",
  "email": "user@example.com",
  "roles": ["customer", "premium"]
}
```

**Validação:**

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: 'https://auth.qbem.com.br/.well-known/jwks.json',
  cache: true,
  cacheMaxAge: 86400000 // 24h
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      type: "https://docs.qbem.com.br/errors/unauthorized",
      title: "Autenticação necessária",
      status: 401
    });
  }
  
  const token = authHeader.substring(7);
  
  jwt.verify(token, getKey, {
    audience: 'orders-api',
    issuer: 'https://auth.qbem.com.br',
    algorithms: ['RS256']
  }, (err, decoded) => {
    if (err) {
      return res.status(401).json({
        type: "https://docs.qbem.com.br/errors/unauthorized",
        title: "Token inválido",
        status: 401,
        detail: err.message
      });
    }
    
    req.user = decoded;
    next();
  });
}
```

**Requisitos JWT:**

- ✅ **Algoritmo:** RS256, ES256, ou PS256 (nunca HS256 em multi-serviço)
- ✅ **Access Token TTL:** ≤ 15 minutos
- ✅ **Refresh Token TTL:** 7-30 dias (com rotação)
- ✅ **Claims obrigatórios:** sub, iat, exp, iss, aud
- ✅ **Validar:** Assinatura, expiração, issuer, audience

### Refresh Token Rotation

```javascript
app.post('/v1/auth/refresh', async (req, res) => {
  const { refresh_token } = req.body;
  
  // Validar refresh token
  const decoded = jwt.verify(refresh_token, process.env.REFRESH_TOKEN_SECRET);
  
  // Verificar se não foi revogado
  const isRevoked = await redis.get(`revoked:${refresh_token}`);
  if (isRevoked) {
    return res.status(401).json({
      type: "https://docs.qbem.com.br/errors/unauthorized",
      title: "Refresh token revogado",
      status: 401
    });
  }
  
  // Revogar refresh token antigo
  await redis.setex(`revoked:${refresh_token}`, 2592000, '1'); // 30 dias
  
  // Gerar novos tokens
  const newAccessToken = generateAccessToken(decoded.sub);
  const newRefreshToken = generateRefreshToken(decoded.sub);
  
  res.json({
    access_token: newAccessToken,
    refresh_token: newRefreshToken,
    token_type: 'Bearer',
    expires_in: 900 // 15 min
  });
});
```

### MFA (Multi-Factor Authentication)

**TOTP (Time-based One-Time Password):**

```javascript
const speakeasy = require('speakeasy');

// Setup - Gerar secret
app.post('/v1/auth/mfa/setup', authenticate, async (req, res) => {
  const secret = speakeasy.generateSecret({
    name: `QBEM (${req.user.email})`,
    issuer: 'QBEM'
  });
  
  await User.update(req.user.id, {
    mfa_secret: secret.base32,
    mfa_enabled: false // Ativa após verificar
  });
  
  res.json({
    secret: secret.base32,
    qr_code: secret.otpauth_url
  });
});

// Ativar MFA
app.post('/v1/auth/mfa/enable', authenticate, async (req, res) => {
  const { token } = req.body;
  const user = await User.findById(req.user.id);
  
  const verified = speakeasy.totp.verify({
    secret: user.mfa_secret,
    encoding: 'base32',
    token: token,
    window: 1
  });
  
  if (!verified) {
    return res.status(400).json({
      type: "https://docs.qbem.com.br/errors/validation",
      title: "Código inválido",
      status: 400
    });
  }
  
  await User.update(req.user.id, { mfa_enabled: true });
  res.json({ message: 'MFA ativado com sucesso' });
});

// Login com MFA
app.post('/v1/auth/login', async (req, res) => {
  const { email, password, mfa_token } = req.body;
  
  const user = await User.findByEmail(email);
  if (!user || !await user.verifyPassword(password)) {
    return res.status(401).json({
      type: "https://docs.qbem.com.br/errors/unauthorized",
      title: "Credenciais inválidas",
      status: 401
    });
  }
  
  if (user.mfa_enabled) {
    if (!mfa_token) {
      return res.status(403).json({
        type: "https://docs.qbem.com.br/errors/mfa-required",
        title: "MFA necessário",
        status: 403
      });
    }
    
    const verified = speakeasy.totp.verify({
      secret: user.mfa_secret,
      encoding: 'base32',
      token: mfa_token,
      window: 1
    });
    
    if (!verified) {
      return res.status(401).json({
        type: "https://docs.qbem.com.br/errors/unauthorized",
        title: "Código MFA inválido",
        status: 401
      });
    }
  }
  
  const token = generateAccessToken(user.id);
  res.json({ access_token: token });
});
```

---

## 3) Autenticação Service-to-Service

### mTLS (Mutual TLS)

**Servidor (Nginx):**

```nginx
server {
  listen 443 ssl;
  server_name api-internal.qbem.com.br;
  
  # Certificado do servidor
  ssl_certificate /etc/nginx/certs/server.crt;
  ssl_certificate_key /etc/nginx/certs/server.key;
  
  # CA para validar clientes
  ssl_client_certificate /etc/nginx/certs/ca.crt;
  ssl_verify_client on;
  ssl_verify_depth 2;
  
  location / {
    # Passar informação do cliente
    proxy_set_header X-Client-DN $ssl_client_s_dn;
    proxy_set_header X-Client-Verify $ssl_client_verify;
    proxy_pass http://backend;
  }
}
```

**Cliente (Node.js):**

```javascript
const https = require('https');
const fs = require('fs');

const options = {
  hostname: 'api-internal.qbem.com.br',
  port: 443,
  path: '/v1/orders',
  method: 'GET',
  cert: fs.readFileSync('/certs/client.crt'),
  key: fs.readFileSync('/certs/client.key'),
  ca: fs.readFileSync('/certs/ca.crt')
};

const req = https.request(options, (res) => {
  // Handle response
});
```

### API Keys

**Formato:**

```plaintext
qbem_prod_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
qbem_test_x9y8z7w6v5u4t3s2r1q0p9o8n7m6l5k4

Formato: {prefix}_{env}_{random}
- prefix: qbem
- env: prod, test, dev
- random: 32 chars (128 bits entropy)
```

**Geração:**

```javascript
const crypto = require('crypto');

function generateApiKey(env = 'prod') {
  const randomBytes = crypto.randomBytes(24); // 192 bits
  const random = randomBytes.toString('hex'); // 48 chars hex
  return `qbem_${env}_${random}`;
}

// Armazenar hash, não plaintext
async function storeApiKey(service, apiKey) {
  const hash = crypto
    .createHash('sha256')
    .update(apiKey)
    .digest('hex');
  
  await db.query(
    'INSERT INTO api_keys (service, key_hash, created_at) VALUES ($1, $2, NOW())',
    [service, hash]
  );
  
  return apiKey; // Retornar UMA VEZ para o cliente
}
```

**Validação:**

```javascript
async function authenticateApiKey(req, res, next) {
  const apiKey = req.headers['x-api-key'];
  
  if (!apiKey) {
    return res.status(401).json({
      type: "https://docs.qbem.com.br/errors/unauthorized",
      title: "API Key necessária",
      status: 401
    });
  }
  
  const hash = crypto
    .createHash('sha256')
    .update(apiKey)
    .digest('hex');
  
  const key = await db.query(
    'SELECT * FROM api_keys WHERE key_hash = $1 AND revoked = false',
    [hash]
  );
  
  if (!key) {
    return res.status(401).json({
      type: "https://docs.qbem.com.br/errors/unauthorized",
      title: "API Key inválida",
      status: 401
    });
  }
  
  // Atualizar last_used
  await db.query(
    'UPDATE api_keys SET last_used_at = NOW() WHERE id = $1',
    [key.id]
  );
  
  req.service = key.service;
  next();
}
```

### Service Account Tokens (Cloud)

**AWS IAM Roles:**

```javascript
const AWS = require('aws-sdk');

// Usar IAM role da instância/pod
const s3 = new AWS.S3();
s3.getObject({ Bucket: 'my-bucket', Key: 'file.txt' }, (err, data) => {
  // Credenciais gerenciadas automaticamente
});
```

**GCP Service Accounts:**

```javascript
const { Storage } = require('@google-cloud/storage');

// Usar service account do pod (Workload Identity)
const storage = new Storage();
const bucket = storage.bucket('my-bucket');
```

**Kubernetes Service Accounts:**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: orders-service
  namespace: production
---
apiVersion: v1
kind: Pod
metadata:
  name: orders-service
spec:
  serviceAccountName: orders-service
  containers:
  - name: app
    image: orders-service:latest
```

---

## 4) Autorização

### RBAC (Role-Based Access Control)

**Modelo de dados:**

```sql
-- Roles
CREATE TABLE roles (
  id UUID PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT
);

-- Permissions
CREATE TABLE permissions (
  id UUID PRIMARY KEY,
  resource VARCHAR(50) NOT NULL, -- orders, invoices, users
  action VARCHAR(20) NOT NULL,   -- read, create, update, delete
  UNIQUE(resource, action)
);

-- Role <-> Permission
CREATE TABLE role_permissions (
  role_id UUID REFERENCES roles(id),
  permission_id UUID REFERENCES permissions(id),
  PRIMARY KEY (role_id, permission_id)
);

-- User <-> Role
CREATE TABLE user_roles (
  user_id UUID REFERENCES users(id),
  role_id UUID REFERENCES roles(id),
  PRIMARY KEY (user_id, role_id)
);
```

**Seeds:**

```sql
-- Roles
INSERT INTO roles (id, name, description) VALUES
  ('role_customer', 'customer', 'Cliente regular'),
  ('role_premium', 'premium', 'Cliente premium'),
  ('role_admin', 'admin', 'Administrador'),
  ('role_support', 'support', 'Suporte');

-- Permissions
INSERT INTO permissions (id, resource, action) VALUES
  ('perm_orders_read', 'orders', 'read'),
  ('perm_orders_create', 'orders', 'create'),
  ('perm_orders_cancel', 'orders', 'cancel'),
  ('perm_users_read', 'users', 'read'),
  ('perm_users_update', 'users', 'update'),
  ('perm_users_delete', 'users', 'delete');

-- Role permissions
INSERT INTO role_permissions (role_id, permission_id) VALUES
  -- Customer
  ('role_customer', 'perm_orders_read'),
  ('role_customer', 'perm_orders_create'),
  -- Premium (herda customer + extras)
  ('role_premium', 'perm_orders_read'),
  ('role_premium', 'perm_orders_create'),
  ('role_premium', 'perm_orders_cancel'),
  -- Admin (tudo)
  ('role_admin', 'perm_orders_read'),
  ('role_admin', 'perm_orders_create'),
  ('role_admin', 'perm_orders_cancel'),
  ('role_admin', 'perm_users_read'),
  ('role_admin', 'perm_users_update'),
  ('role_admin', 'perm_users_delete');
```

**Middleware de autorização:**

```javascript
function requirePermission(resource, action) {
  return async (req, res, next) => {
    const permissions = await getUserPermissions(req.user.id);
    
    const hasPermission = permissions.some(
      p => p.resource === resource && p.action === action
    );
    
    if (!hasPermission) {
      return res.status(403).json({
        type: "https://docs.qbem.com.br/errors/forbidden",
        title: "Acesso negado",
        status: 403,
        detail: `Permissão '${resource}:${action}' necessária`
      });
    }
    
    next();
  };
}

// Uso
app.get('/v1/orders', 
  authenticate, 
  requirePermission('orders', 'read'), 
  getOrders
);

app.delete('/v1/users/:id', 
  authenticate, 
  requirePermission('users', 'delete'), 
  deleteUser
);
```

### ABAC (Attribute-Based Access Control)

**Política baseada em atributos:**

```json
{
  "policy": "allow_order_access",
  "rules": [
    {
      "effect": "allow",
      "resource": "orders",
      "actions": ["read", "update"],
      "conditions": [
        { "attribute": "order.user_id", "operator": "equals", "value": "{{user.id}}" }
      ]
    },
    {
      "effect": "allow",
      "resource": "orders",
      "actions": ["read"],
      "conditions": [
        { "attribute": "user.roles", "operator": "contains", "value": "admin" }
      ]
    }
  ]
}
```

**Implementação:**

```javascript
async function evaluatePolicy(user, resource, action, context) {
  const policies = await getPolicies(user);
  
  for (const policy of policies) {
    for (const rule of policy.rules) {
      if (rule.resource !== resource) continue;
      if (!rule.actions.includes(action)) continue;
      
      const conditionsMet = rule.conditions.every(condition => {
        return evaluateCondition(condition, user, context);
      });
      
      if (conditionsMet) {
        return rule.effect === 'allow';
      }
    }
  }
  
  return false; // Deny by default
}

function evaluateCondition(condition, user, context) {
  const attrValue = getAttributeValue(condition.attribute, user, context);
  const expectedValue = interpolate(condition.value, user, context);
  
  switch (condition.operator) {
    case 'equals':
      return attrValue === expectedValue;
    case 'contains':
      return Array.isArray(attrValue) && attrValue.includes(expectedValue);
    case 'greaterThan':
      return attrValue > expectedValue;
    default:
      return false;
  }
}

// Uso
app.get('/v1/orders/:id', authenticate, async (req, res) => {
  const order = await Order.findById(req.params.id);
  
  const allowed = await evaluatePolicy(
    req.user,
    'orders',
    'read',
    { order }
  );
  
  if (!allowed) {
    return res.status(404).json({
      type: "https://docs.qbem.com.br/errors/not-found",
      title: "Pedido não encontrado",
      status: 404
    });
  }
  
  res.json(order);
});
```

### Resource-Level Authorization

```javascript
async function getOrder(req, res) {
  const order = await Order.findById(req.params.id);
  
  if (!order) {
    return res.status(404).json({
      type: "https://docs.qbem.com.br/errors/not-found",
      title: "Pedido não encontrado",
      status: 404
    });
  }
  
  // Verificar ownership
  const isOwner = order.userId === req.user.id;
  const isAdmin = req.user.roles.includes('admin');
  
  if (!isOwner && !isAdmin) {
    // Retornar 404 ao invés de 403 (não revelar existência)
    return res.status(404).json({
      type: "https://docs.qbem.com.br/errors/not-found",
      title: "Pedido não encontrado",
      status: 404
    });
  }
  
  res.json(order);
}
```

---

## 5) Checklist

### ![user](https://api.iconify.design/lucide:user.svg?width=14) Autenticação de Usuários

- [ ] OAuth 2.0 / OIDC implementado
- [ ] JWT com RS256/ES256
- [ ] Access token TTL ≤ 15 min
- [ ] Refresh token com rotação
- [ ] MFA disponível para operações críticas
- [ ] Rate limiting em /login
- [ ] Proteção contra brute force

### ![network](https://api.iconify.design/lucide:network.svg?width=14) Service-to-Service

- [ ] mTLS ou API Keys
- [ ] Certificados válidos
- [ ] API Keys com prefixo e entropy adequada
- [ ] Hash de API Keys armazenado
- [ ] Rotação periódica de credenciais

### ![shield](https://api.iconify.design/lucide:shield.svg?width=14) Autorização

- [ ] RBAC ou ABAC implementado
- [ ] Validação server-side obrigatória
- [ ] Resource-level authorization
- [ ] Least privilege aplicado
- [ ] Auditoria de acessos

---

## 📚 Referências

- [OAuth 2.0 RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)
- [OIDC Specification](https://openid.net/connect/)
- [JWT RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)
- [JWT Best Practices RFC 8725](https://datatracker.ietf.org/doc/html/rfc8725)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [NIST Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)

---

**[⬆ Voltar](README.md)**