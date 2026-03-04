# Segurança de APIs

Objetivo: proteger APIs HTTP contra ameaças e garantir acesso controlado, validação de dados e prevenção de abusos.

---

## 1) Autenticação

### JWT (Bearer Token)

**Padrão recomendado** para APIs stateless.

```http
GET /v1/users/me
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Requisitos:**

- ✅ **Algoritmo:** RS256 ou ES256 (nunca HS256 em produção multi-serviço)
- ✅ **Expiração:** Access token ≤ 15 minutos
- ✅ **Refresh token:** Rotação obrigatória
- ✅ **Claims mínimos:** `sub`, `iat`, `exp`, `iss`, `aud`
- ✅ **Validação:** Assinatura, expiração e issuer

```json
{
  "sub": "user_12345",
  "iat": 1642597200,
  "exp": 1642598100,
  "iss": "https://auth.qbem.com.br",
  "aud": "orders-api",
  "scope": "orders:read orders:write"
}
```

### API Keys

**Apenas para integrações M2M** (machine-to-machine).

```http
GET /v1/webhooks
X-API-Key: qbem_prod_a1b2c3d4e5f6g7h8i9j0
```

**Requisitos:**

- ✅ Prefixo identificável (`qbem_prod_`, `qbem_test_`)
- ✅ Entropy suficiente (≥ 128 bits)
- ✅ Hash armazenado (nunca plaintext)
- ✅ Rate limit por API key
- ✅ Rotação anual ou sob demanda
- ✅ Revogação instantânea

### OAuth 2.0 / OIDC

**Para delegação de acesso** (third-party apps).

- ✅ Authorization Code Flow (com PKCE)
- ✅ Client Credentials para M2M
- ✅ Nunca Implicit Flow
- ✅ State parameter obrigatório

---

## 2) Autorização

### RBAC (Role-Based Access Control)

```json
{
  "user_id": "user_12345",
  "roles": ["customer", "premium_member"],
  "permissions": [
    "orders:read",
    "orders:create",
    "invoices:read"
  ]
}
```

**Validação server-side:**

```javascript
function requirePermission(permission) {
  return (req, res, next) => {
    if (!req.user.permissions.includes(permission)) {
      return res.status(403).json({
        type: "https://docs.qbem.com.br/errors/forbidden",
        title: "Acesso negado",
        status: 403,
        detail: `Permissão '${permission}' necessária`
      });
    }
    next();
  };
}

// Uso
app.get('/v1/orders', 
  authenticate,
  requirePermission('orders:read'),
  getOrders
);
```

### Resource-Level Authorization

Validar **ownership** além de permissão:

```javascript
async function getOrder(req, res) {
  const order = await Order.findById(req.params.id);
  
  // Verificar se user tem acesso a ESTE recurso
  if (order.userId !== req.user.id && !req.user.isAdmin) {
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

## 3) Rate Limiting

### Níveis de Rate Limit

```plaintext
1. Global (por IP)         → 1000 req/min
2. Por usuário autenticado → 100 req/min
3. Por endpoint sensível   → 10 req/min (ex: /auth/login)
```

### Headers de Resposta

```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 73
X-RateLimit-Reset: 1642598400
```

### Resposta ao Exceder

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 60

{
  "type": "https://docs.qbem.com.br/errors/rate-limit",
  "title": "Limite de requisições excedido",
  "status": 429,
  "detail": "Você excedeu o limite de 100 requisições por minuto",
  "retry_after": 60
}
```

### Implementação (Express + Redis)

```javascript
const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');
const redis = require('redis');

const limiter = rateLimit({
  store: new RedisStore({
    client: redis.createClient()
  }),
  windowMs: 60 * 1000, // 1 minuto
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      type: "https://docs.qbem.com.br/errors/rate-limit",
      title: "Limite de requisições excedido",
      status: 429,
      detail: "Tente novamente em 1 minuto"
    });
  }
});

app.use('/v1/', limiter);
```

---

## 4) Validação de Input

### Schema Validation

**OpenAPI + Validator:**

```yaml
paths:
  /v1/users:
    post:
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [email, password]
              properties:
                email:
                  type: string
                  format: email
                  maxLength: 255
                password:
                  type: string
                  minLength: 12
                  maxLength: 128
```

**Validação programática:**

```javascript
const { z } = require('zod');

const createUserSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(12).max(128),
  name: z.string().min(2).max(100)
});

app.post('/v1/users', (req, res) => {
  const result = createUserSchema.safeParse(req.body);
  
  if (!result.success) {
    return res.status(400).json({
      type: "https://docs.qbem.com.br/errors/validation",
      title: "Dados inválidos",
      status: 400,
      errors: result.error.flatten()
    });
  }
  
  // Processar dados validados
});
```

### Sanitização

```javascript
const validator = require('validator');

function sanitizeInput(data) {
  return {
    email: validator.normalizeEmail(data.email),
    name: validator.escape(data.name.trim())
  };
}
```

---

## 5) Prevenção de Injeções

### SQL Injection

✅ **Usar prepared statements:**

```javascript
// ✅ CORRETO
const user = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// ❌ ERRADO
const user = await db.query(
  `SELECT * FROM users WHERE email = '${email}'`
);
```

### NoSQL Injection

```javascript
// ❌ VULNERÁVEL
const user = await User.findOne({ 
  email: req.body.email 
});

// Ataque: { "email": { "$ne": null } }

// ✅ SEGURO
const user = await User.findOne({ 
  email: String(req.body.email) 
});
```

### Command Injection

```javascript
// ❌ VULNERÁVEL
exec(`convert ${filename} output.png`);

// ✅ SEGURO
const { spawn } = require('child_process');
spawn('convert', [filename, 'output.png']);
```

---

## 6) CORS

### Configuração Restritiva

```javascript
const cors = require('cors');

app.use(cors({
  origin: [
    'https://app.qbem.com.br',
    'https://admin.qbem.com.br'
  ],
  methods: ['GET', 'POST', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400 // 24h
}));
```

### ❌ Nunca Fazer

```javascript
// NÃO fazer isso em produção!
app.use(cors({ origin: '*' }));
```

---

## 7) Security Headers

### Headers Obrigatórios

```javascript
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  frameguard: { action: 'deny' },
  noSniff: true,
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
}));
```

### Headers Customizados

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

---

## 8) HTTPS / TLS

### Requisitos

- ✅ **TLS 1.2+** obrigatório (TLS 1.3 preferencial)
- ✅ Certificados válidos (Let's Encrypt, DigiCert, etc.)
- ✅ Redirect HTTP → HTTPS automático
- ✅ HSTS habilitado
- ✅ Perfect Forward Secrecy (PFS)

### Nginx Config

```nginx
server {
  listen 443 ssl http2;
  server_name api.qbem.com.br;

  ssl_certificate /etc/letsencrypt/live/api.qbem.com.br/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/api.qbem.com.br/privkey.pem;
  
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
  
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
}

# Redirect HTTP → HTTPS
server {
  listen 80;
  server_name api.qbem.com.br;
  return 301 https://$server_name$request_uri;
}
```

---

## 9) Idempotência

### Header Idempotency-Key

```http
POST /v1/payments
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{
  "amount": 10000,
  "currency": "BRL"
}
```

### Implementação

```javascript
const idempotencyCache = new Map();

async function handleIdempotentRequest(req, res, next) {
  const key = req.headers['idempotency-key'];
  
  if (!key) {
    return res.status(400).json({
      type: "https://docs.qbem.com.br/errors/validation",
      title: "Idempotency-Key obrigatório",
      status: 400
    });
  }
  
  // Verificar cache
  const cached = await redis.get(`idempotency:${key}`);
  if (cached) {
    const response = JSON.parse(cached);
    return res.status(response.status).json(response.body);
  }
  
  // Processar e cachear
  const originalSend = res.send;
  res.send = function(body) {
    redis.setex(`idempotency:${key}`, 86400, JSON.stringify({
      status: res.statusCode,
      body: JSON.parse(body)
    }));
    originalSend.call(this, body);
  };
  
  next();
}
```

---

## 10) Proteção de Endpoints Sensíveis

### Login Endpoint

```javascript
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 5, // 5 tentativas
  skipSuccessfulRequests: true,
  handler: (req, res) => {
    res.status(429).json({
      type: "https://docs.qbem.com.br/errors/rate-limit",
      title: "Muitas tentativas de login",
      status: 429,
      detail: "Aguarde 15 minutos antes de tentar novamente"
    });
  }
});

app.post('/v1/auth/login', loginLimiter, login);
```

### Password Reset

```javascript
// Adicionar delay progressivo
const loginAttempts = new Map();

async function login(req, res) {
  const { email, password } = req.body;
  const attempts = loginAttempts.get(email) || 0;
  
  // Delay progressivo: 0s, 1s, 2s, 4s, 8s...
  if (attempts > 0) {
    await sleep(Math.pow(2, attempts - 1) * 1000);
  }
  
  const user = await User.findByEmail(email);
  
  if (!user || !await user.verifyPassword(password)) {
    loginAttempts.set(email, attempts + 1);
    return res.status(401).json({
      type: "https://docs.qbem.com.br/errors/unauthorized",
      title: "Credenciais inválidas",
      status: 401
    });
  }
  
  loginAttempts.delete(email);
  // Gerar token...
}
```

---

## 11) Proteção CSRF

### Para APIs com sessões

```javascript
const csrf = require('csurf');
const cookieParser = require('cookie-parser');

app.use(cookieParser());
app.use(csrf({ cookie: true }));

app.get('/v1/csrf-token', (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

app.post('/v1/orders', (req, res) => {
  // CSRF token validado automaticamente
});
```

### Para APIs stateless (JWT)

- ✅ CSRF não necessário se usando **apenas** Bearer tokens
- ✅ Nunca armazenar JWT em cookies
- ✅ SameSite=Strict se usar cookies

---

## 12) Auditoria & Logging

### Logs de Segurança

```javascript
function auditLog(req, action, result) {
  logger.info({
    event: 'security_audit',
    action,
    result,
    user_id: req.user?.id,
    ip: req.ip,
    user_agent: req.headers['user-agent'],
    trace_id: req.headers['x-trace-id'],
    timestamp: new Date().toISOString()
  });
}

// Uso
app.post('/v1/auth/login', async (req, res) => {
  const user = await authenticate(req.body);
  
  if (!user) {
    auditLog(req, 'login_failed', 'invalid_credentials');
    return res.status(401).json({...});
  }
  
  auditLog(req, 'login_success', user.id);
  res.json({ token });
});
```

### Eventos a Auditar

- ✅ Login / Logout
- ✅ Falhas de autenticação
- ✅ Mudanças de senha
- ✅ Acesso a recursos sensíveis
- ✅ Criação/remoção de API keys
- ✅ Rate limit excedido
- ✅ Erros 403 (forbidden)

---

## 13) OWASP API Security Top 10

### A1 - Broken Object Level Authorization

```javascript
// ❌ VULNERÁVEL
app.get('/v1/orders/:id', async (req, res) => {
  const order = await Order.findById(req.params.id);
  res.json(order); // Qualquer um pode acessar qualquer pedido!
});

// ✅ SEGURO
app.get('/v1/orders/:id', authenticate, async (req, res) => {
  const order = await Order.findById(req.params.id);
  
  if (order.userId !== req.user.id) {
    return res.status(404).json({...}); // 404, não 403
  }
  
  res.json(order);
});
```

### A2 - Broken Authentication

- ✅ Tokens com expiração curta
- ✅ Refresh token rotation
- ✅ MFA para operações críticas
- ✅ Rate limiting em endpoints de auth

### A3 - Broken Object Property Level Authorization

```javascript
// ❌ VULNERÁVEL - Mass Assignment
app.patch('/v1/users/:id', async (req, res) => {
  await User.update(req.params.id, req.body);
  // Usuário pode enviar { "role": "admin" }!
});

// ✅ SEGURO - Whitelist de campos
const allowedFields = ['name', 'email'];
app.patch('/v1/users/:id', async (req, res) => {
  const updates = pick(req.body, allowedFields);
  await User.update(req.params.id, updates);
});
```

### A4 - Unrestricted Resource Consumption

- ✅ Rate limiting
- ✅ Paginação obrigatória
- ✅ Timeout em requests
- ✅ Limite de payload size

### A5 - Broken Function Level Authorization

```javascript
// Verificar role além de autenticação
function requireAdmin(req, res, next) {
  if (!req.user.roles.includes('admin')) {
    return res.status(403).json({...});
  }
  next();
}

app.delete('/v1/users/:id', authenticate, requireAdmin, deleteUser);
```

---

## 14) Checklist

### ![code](https://api.iconify.design/lucide:code.svg?width=14) Desenvolvimento

- [ ] Autenticação implementada (JWT/OAuth)
- [ ] Autorização validada (RBAC + resource-level)
- [ ] Rate limiting configurado
- [ ] Input validation com schemas
- [ ] Prepared statements (SQL)
- [ ] CORS restritivo
- [ ] Security headers aplicados
- [ ] HTTPS obrigatório

### ![test-tube](https://api.iconify.design/lucide:test-tube.svg?width=14) Testes

- [ ] Testes de autenticação/autorização
- [ ] Testes de rate limiting
- [ ] Testes de validação de input
- [ ] Testes de CORS
- [ ] Tentativas de bypass de authz

### ![rocket](https://api.iconify.design/lucide:rocket.svg?width=14) Produção

- [ ] TLS 1.2+ configurado
- [ ] Certificados válidos
- [ ] WAF habilitado (se aplicável)
- [ ] Auditoria de acesso ativa
- [ ] Alertas de segurança configurados
- [ ] Documentação OpenAPI com security schemes

---

## 📚 Referências

- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [OWASP Cheat Sheet - REST Security](https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html)
- [JWT Best Practices](https://datatracker.ietf.org/doc/html/rfc8725)
- [OAuth 2.0 Security Best Practices](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)

---

**[⬆ Voltar](README.md)**