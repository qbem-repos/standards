# Proteção de Dados & LGPD

Objetivo: garantir **privacidade**, **segurança** e **conformidade legal** no tratamento de dados pessoais.

---

## 1) Princípios (LGPD)

### Finalidade
- ✅ Coletar dados **apenas** para propósitos específicos e legítimos
- ✅ Comunicar claramente ao titular a finalidade
- ✅ Não usar dados para fins incompatíveis com a finalidade original

### Adequação
- ✅ Tratamento compatível com as finalidades informadas
- ✅ Alinhamento com expectativas do titular

### Necessidade
- ✅ **Minimização de dados** — coletar apenas o essencial
- ✅ Evitar dados excessivos ou irrelevantes

### Livre Acesso
- ✅ Titular pode **consultar** seus dados a qualquer momento
- ✅ Gratuito e facilitado

### Qualidade dos Dados
- ✅ Dados **exatos, claros e atualizados**
- ✅ Correção quando necessário

### Transparência
- ✅ Informações claras e acessíveis sobre o tratamento
- ✅ Sem práticas abusivas ou enganosas

### Segurança
- ✅ Medidas técnicas e administrativas para proteção
- ✅ Prevenção de acessos não autorizados e vazamentos

### Prevenção
- ✅ Adotar medidas para prevenir danos
- ✅ Privacy by Design e Privacy by Default

### Não Discriminação
- ✅ Impossibilidade de tratamento para fins discriminatórios

### Responsabilização e Prestação de Contas
- ✅ Demonstrar conformidade com a LGPD
- ✅ Adotar medidas eficazes e comprovar eficácia

---

## 2) Bases Legais

Toda coleta de dados **DEVE** ter uma base legal:

### Consentimento
```json
{
  "consent": {
    "given_at": "2024-01-15T10:30:00Z",
    "purpose": "Envio de newsletter sobre produtos",
    "can_revoke": true,
    "revoked_at": null,
    "version": "1.0"
  }
}
```

- ✅ Livre, informado e inequívoco
- ✅ Destacado das demais cláusulas
- ✅ Revogável a qualquer momento
- ✅ Granular (por finalidade)

### Execução de Contrato
- Dados necessários para **cumprir contrato** com o titular
- Ex: Nome, endereço para entrega de produto

### Exercício Regular de Direitos
- Uso em processo judicial, administrativo ou arbitral

### Proteção da Vida
- Tutela da saúde em emergências

### Interesse Legítimo
- Controlador tem interesse legítimo
- **DEVE** respeitar expectativas do titular
- **DEVE** fazer Teste de Balanceamento de Interesses (LIA)

### Cumprimento de Obrigação Legal
- Lei/regulamento obriga o tratamento
- Ex: Guarda de NF-e por 5 anos

---

## 3) Classificação de Dados

### Dados Públicos
- **Definição:** Já são públicos (ex: informação em site oficial)
- **Proteção:** Baixa
- **Exemplos:** Nome de empresa, endereço comercial

### Dados Pessoais
- **Definição:** Identificam ou tornam identificável uma pessoa
- **Proteção:** Média
- **Exemplos:** Nome, email, telefone, CPF, IP, cookie ID

### Dados Pessoais Sensíveis
- **Definição:** Dados sobre origem racial, saúde, orientação sexual, etc.
- **Proteção:** Alta
- **Exemplos:** Biometria, dado de saúde, religião, filiação sindical

### Dados de Crianças e Adolescentes
- **Definição:** Dados de menores de 18 anos
- **Proteção:** Muito Alta
- **Requisitos:** Consentimento dos pais (< 18 anos)

---

## 4) Criptografia

### Em Trânsito (TLS)

```nginx
# Nginx - TLS 1.3
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers on;
```

- ✅ **TLS 1.2+** obrigatório
- ✅ TLS 1.3 preferencial
- ✅ Certificados válidos
- ✅ Perfect Forward Secrecy (PFS)

### Em Repouso

**Banco de Dados:**

```sql
-- PostgreSQL - pgcrypto
CREATE EXTENSION pgcrypto;

-- Inserir com criptografia
INSERT INTO users (email, ssn_encrypted) 
VALUES ('user@example.com', pgp_sym_encrypt('12345678901', 'encryption-key'));

-- Consultar
SELECT pgp_sym_decrypt(ssn_encrypted::bytea, 'encryption-key') FROM users;
```

**Filesystem:**

```bash
# LUKS - Linux Unified Key Setup
cryptsetup luksFormat /dev/sdb
cryptsetup luksOpen /dev/sdb encrypted_volume
mkfs.ext4 /dev/mapper/encrypted_volume
```

**Cloud Storage:**

- **AWS S3:** Server-Side Encryption (SSE-S3, SSE-KMS)
- **GCP Cloud Storage:** Customer-managed encryption keys (CMEK)
- **Azure Blob:** Azure Storage Service Encryption (SSE)

### Application-Level Encryption

```javascript
const crypto = require('crypto');

// Criptografar
function encrypt(text, key) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv('aes-256-gcm', Buffer.from(key, 'hex'), iv);
  
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const authTag = cipher.getAuthTag();
  
  return {
    iv: iv.toString('hex'),
    encryptedData: encrypted,
    authTag: authTag.toString('hex')
  };
}

// Descriptografar
function decrypt(encrypted, key) {
  const decipher = crypto.createDecipheriv(
    'aes-256-gcm',
    Buffer.from(key, 'hex'),
    Buffer.from(encrypted.iv, 'hex')
  );
  
  decipher.setAuthTag(Buffer.from(encrypted.authTag, 'hex'));
  
  let decrypted = decipher.update(encrypted.encryptedData, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}
```

---

## 5) Hashing de Senhas

### ❌ NUNCA Usar

- MD5
- SHA-1
- SHA-256 sem salt

### ✅ Algoritmos Recomendados

**bcrypt (recomendado):**

```javascript
const bcrypt = require('bcrypt');

// Hash
const saltRounds = 12;
const hash = await bcrypt.hash(password, saltRounds);

// Verificar
const isValid = await bcrypt.compare(password, hash);
```

**Argon2 (mais moderno):**

```javascript
const argon2 = require('argon2');

// Hash
const hash = await argon2.hash(password, {
  type: argon2.argon2id,
  memoryCost: 65536,
  timeCost: 3,
  parallelism: 4
});

// Verificar
const isValid = await argon2.verify(hash, password);
```

**PBKDF2:**

```javascript
const crypto = require('crypto');

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, stored) {
  const [salt, hash] = stored.split(':');
  const hashToVerify = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return hash === hashToVerify;
}
```

---

## 6) Mascaramento & Anonimização

### Mascaramento em Logs

```javascript
function maskSensitiveData(obj) {
  const sensitiveFields = ['cpf', 'email', 'phone', 'password', 'credit_card'];
  
  return JSON.parse(JSON.stringify(obj), (key, value) => {
    if (sensitiveFields.includes(key.toLowerCase())) {
      if (key === 'cpf') return value.replace(/(\d{3})\d{6}(\d{2})/, '$1******$2');
      if (key === 'email') return value.replace(/(.{2}).*(@.*)/, '$1***$2');
      if (key === 'phone') return value.replace(/(\d{2})\d{5}(\d{4})/, '$1*****$2');
      return '***REDACTED***';
    }
    return value;
  });
}

// Uso
logger.info('User created', maskSensitiveData(user));
// Output: { cpf: "123******90", email: "us***@example.com" }
```

### Pseudonimização

```javascript
const crypto = require('crypto');

function pseudonymize(data, secret) {
  return crypto
    .createHmac('sha256', secret)
    .update(data)
    .digest('hex');
}

// CPF → ID irreversível (sem secret)
const userId = pseudonymize(user.cpf, process.env.PSEUDO_SECRET);
// Armazenar userId ao invés do CPF
```

### Anonimização Irreversível

```javascript
// k-anonymity - Generalização
function anonymizeAge(age) {
  if (age < 18) return '<18';
  if (age < 30) return '18-29';
  if (age < 50) return '30-49';
  return '50+';
}

function anonymizeLocation(zipCode) {
  return zipCode.substring(0, 3) + '**-***'; // 010** -> 010**-***
}
```

---

## 7) Direitos dos Titulares

### Confirmação e Acesso

```javascript
// GET /v1/me/data
app.get('/v1/me/data', authenticate, async (req, res) => {
  const userData = await User.findById(req.user.id);
  const orders = await Order.findByUserId(req.user.id);
  
  res.json({
    personal_data: userData,
    orders: orders,
    data_processing: {
      purposes: ['Execução de contrato', 'Newsletter (consentimento)'],
      retention_period: '5 anos após última compra',
      shared_with: ['Transportadora XYZ', 'Gateway de Pagamento ABC']
    }
  });
});
```

### Correção

```javascript
// PATCH /v1/me
app.patch('/v1/me', authenticate, async (req, res) => {
  const allowedUpdates = ['name', 'email', 'phone', 'address'];
  const updates = pick(req.body, allowedUpdates);
  
  await User.update(req.user.id, updates);
  
  // Log da correção
  await AuditLog.create({
    user_id: req.user.id,
    action: 'data_correction',
    fields: Object.keys(updates),
    timestamp: new Date()
  });
  
  res.json({ message: 'Dados atualizados com sucesso' });
});
```

### Anonimização / Eliminação (Direito ao Esquecimento)

```javascript
// DELETE /v1/me
app.delete('/v1/me', authenticate, async (req, res) => {
  const userId = req.user.id;
  
  // Verificar se há obrigação legal de retenção
  const hasLegalObligation = await checkLegalRetention(userId);
  
  if (hasLegalObligation) {
    // Anonimizar ao invés de deletar
    await User.anonymize(userId);
  } else {
    // Deletar completamente
    await User.delete(userId);
  }
  
  // Log LGPD
  await LGPDLog.create({
    user_id: userId,
    action: 'data_deletion',
    reason: 'User request',
    timestamp: new Date()
  });
  
  res.status(204).send();
});
```

### Portabilidade

```javascript
// GET /v1/me/export
app.get('/v1/me/export', authenticate, async (req, res) => {
  const userData = await User.findById(req.user.id);
  const orders = await Order.findByUserId(req.user.id);
  const payments = await Payment.findByUserId(req.user.id);
  
  const exportData = {
    personal_data: userData,
    orders: orders,
    payments: payments,
    exported_at: new Date().toISOString(),
    format_version: '1.0'
  };
  
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Content-Disposition', 'attachment; filename=my-data.json');
  res.json(exportData);
});
```

### Revogação de Consentimento

```javascript
// DELETE /v1/me/consents/{purpose}
app.delete('/v1/me/consents/:purpose', authenticate, async (req, res) => {
  await Consent.revoke({
    user_id: req.user.id,
    purpose: req.params.purpose
  });
  
  // Parar tratamento baseado neste consentimento
  await stopProcessing(req.user.id, req.params.purpose);
  
  res.json({ message: 'Consentimento revogado com sucesso' });
});
```

---

## 8) Retenção e Descarte

### Políticas de Retenção

```javascript
const retentionPolicies = {
  'user_profile': {
    active: 'indefinite',
    inactive: '2 years after last login',
    after_deletion_request: '30 days'
  },
  'orders': {
    active: '5 years', // Obrigação fiscal
    archived: '7 years total'
  },
  'logs': {
    application: '90 days',
    security: '1 year',
    audit: '5 years'
  },
  'backups': {
    daily: '7 days',
    weekly: '30 days',
    monthly: '1 year'
  }
};
```

### Descarte Automatizado

```javascript
// Cron job diário
async function purgeExpiredData() {
  const now = new Date();
  
  // Usuários inativos > 2 anos
  const inactiveUsers = await User.find({
    last_login: { $lt: new Date(now - 2 * 365 * 24 * 60 * 60 * 1000) }
  });
  
  for (const user of inactiveUsers) {
    await User.anonymize(user.id);
    logger.info('User anonymized due to inactivity', { user_id: user.id });
  }
  
  // Logs > 90 dias
  await Log.deleteMany({
    created_at: { $lt: new Date(now - 90 * 24 * 60 * 60 * 1000) },
    type: 'application'
  });
  
  // Backups diários > 7 dias
  await Backup.deleteMany({
    created_at: { $lt: new Date(now - 7 * 24 * 60 * 60 * 1000) },
    type: 'daily'
  });
}
```

---

## 9) Transferência Internacional

### Requisitos LGPD

- ✅ País com nível adequado de proteção (ANPD)
- ✅ OU cláusulas contratuais padrão
- ✅ OU consentimento específico
- ✅ OU BCRs (Binding Corporate Rules)

### Documentação

```markdown
## Transferências Internacionais

### AWS US-EAST-1 (Virginia, EUA)
- **Dados:** Backups criptografados
- **Base Legal:** Cláusulas Contratuais Padrão (AWS Data Processing Addendum)
- **Proteções:** Criptografia AES-256, acesso restrito

### SendGrid (EUA)
- **Dados:** Email, nome (para envio de emails transacionais)
- **Base Legal:** Interesse legítimo (comunicação com cliente)
- **Proteções:** TLS 1.2+, DPA assinado
```

---

## 10) Incident Response (Vazamento)

### Procedimento

1. **Detecção** (0-1h)
   - Identificar escopo do vazamento
   - Isolar sistemas afetados

2. **Contenção** (1-4h)
   - Bloquear acesso não autorizado
   - Preservar evidências

3. **Avaliação** (4-24h)
   - Quantos titulares afetados?
   - Quais dados vazaram?
   - Qual o risco?

4. **Notificação ANPD** (até 72h se alto risco)
   - Natureza do incidente
   - Dados afetados
   - Titulares impactados
   - Medidas tomadas

5. **Notificação Titulares** (razoável, se alto risco)
   - O que aconteceu
   - Quais dados foram afetados
   - Medidas tomadas
   - Como se proteger

6. **Remediação**
   - Corrigir vulnerabilidade
   - Reforçar segurança
   - Monitoramento adicional

7. **Post-mortem**
   - Lições aprendidas
   - Melhorias de processo

### Template de Notificação

```markdown
Assunto: Notificação de Incidente de Segurança

Prezado(a) Cliente,

Informamos que em [DATA], detectamos um incidente de segurança que 
pode ter afetado seus dados pessoais.

**O que aconteceu:**
[Descrição breve e clara]

**Dados possivelmente afetados:**
- Nome
- Email
- [outros campos]

**Dados NÃO afetados:**
- Senhas (armazenadas com hash seguro)
- Dados de pagamento (não armazenamos)

**Medidas tomadas:**
1. [Ação 1]
2. [Ação 2]

**O que você deve fazer:**
- Recomendamos trocar sua senha
- Fique atento a emails suspeitos (phishing)

Para dúvidas: privacidade@qbem.com.br

Atenciosamente,
Equipe QBEM
```

---

## 11) Checklist LGPD

### ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) Governança

- [ ] DPO (Encarregado de Dados) nomeado
- [ ] Política de Privacidade publicada
- [ ] Inventário de dados mapeado
- [ ] RIPD realizado (dados sensíveis)
- [ ] Contratos com processadores adequados

### ![shield](https://api.iconify.design/lucide:shield.svg?width=14) Segurança

- [ ] Criptografia em trânsito (TLS 1.2+)
- [ ] Criptografia em repouso (dados sensíveis)
- [ ] Controle de acesso (least privilege)
- [ ] Logs de auditoria ativos
- [ ] Backup e disaster recovery testados

### ![user-check](https://api.iconify.design/lucide:user-check.svg?width=14) Direitos dos Titulares

- [ ] Portal de privacidade implementado
- [ ] Confirmação e acesso (GET /me/data)
- [ ] Correção (PATCH /me)
- [ ] Eliminação (DELETE /me)
- [ ] Portabilidade (GET /me/export)
- [ ] Revogação de consentimento

### ![database](https://api.iconify.design/lucide:database.svg?width=14) Tratamento de Dados

- [ ] Base legal documentada para cada tratamento
- [ ] Minimização de dados aplicada
- [ ] Finalidades específicas e legítimas
- [ ] Consentimento granular (quando aplicável)
- [ ] Retenção definida e aplicada

### ![bell](https://api.iconify.design/lucide:bell.svg?width=14) Incidentes

- [ ] Plano de resposta a incidentes
- [ ] Procedimento de notificação ANPD
- [ ] Template de comunicação com titulares
- [ ] Equipe treinada

---

## 12) Ferramentas

### Compliance

- **OneTrust** — Privacy management platform
- **TrustArc** — Privacy compliance automation
- **Securiti.ai** — Data privacy automation

### Descoberta de Dados

- **BigID** — Data discovery and classification
- **Varonis** — Data security platform
- **Microsoft Purview** — Data governance

### Criptografia

- **Vault (HashiCorp)** — Secrets and encryption
- **AWS KMS** — Key Management Service
- **Azure Key Vault** — Encryption keys management

---

## 📚 Referências

- [LGPD - Lei 13.709/2018](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)
- [ANPD - Autoridade Nacional](https://www.gov.br/anpd/pt-br)
- [Guia de Boas Práticas LGPD - SERPRO](https://www.gov.br/serpro/pt-br/lgpd)
- [GDPR (Referência)](https://gdpr.eu/)
- [ISO/IEC 27701 - Privacy Information Management](https://www.iso.org/standard/71670.html)

---

**[⬆ Voltar](README.md)**