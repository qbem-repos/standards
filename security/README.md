# Padrões de Segurança

> Práticas e diretrizes de segurança para toda a stack QBEM

[![Security](https://img.shields.io/badge/security-OWASP-blue.svg)](https://owasp.org)
[![LGPD](https://img.shields.io/badge/compliance-LGPD-green.svg)](https://www.gov.br/cidadania/pt-br/acesso-a-informacao/lgpd)

**Segurança desde o início · Defesa em profundidade · Privacidade por design**

---

## 📖 Sobre

Este diretório contém os padrões e práticas de segurança que devem ser aplicados em todos os serviços, APIs, aplicações frontend e infraestrutura da QBEM.

### 🎯 Princípios

- 🛡️ **Security by Default** — Configurações seguras desde o início
- 🔒 **Defense in Depth** — Múltiplas camadas de proteção
- 🔐 **Least Privilege** — Acesso mínimo necessário
- 🕵️ **Zero Trust** — Nunca confie, sempre valide
- 📊 **Observability** — Detecte e responda rapidamente
- 🔍 **Privacy by Design** — LGPD/GDPR desde a concepção

---

## 📚 Documentação

### ![key](https://api.iconify.design/lucide:key.svg?width=20) [1. Gestão de Segredos](secrets-management.md)

Como gerenciar credenciais, chaves API, tokens e certificados.

- ![lock](https://api.iconify.design/lucide:lock.svg?width=14) Vault / Secret Manager
- ![rotate-cw](https://api.iconify.design/lucide:rotate-cw.svg?width=14) Rotação automática
- ![code](https://api.iconify.design/lucide:code.svg?width=14) Injeção segura em runtime
- ![alert-triangle](https://api.iconify.design/lucide:alert-triangle.svg?width=14) Detecção de vazamento

**Status:** 🚧 Em desenvolvimento

---

### ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=20) [2. Autenticação & Autorização](auth.md)

Padrões para autenticação de usuários e serviços.

- ![user-check](https://api.iconify.design/lucide:user-check.svg?width=14) OAuth 2.0 / OIDC
- ![key-round](https://api.iconify.design/lucide:key-round.svg?width=14) JWT (Bearer tokens)
- ![network](https://api.iconify.design/lucide:network.svg?width=14) Service-to-service (mTLS, API Keys)
- ![fingerprint](https://api.iconify.design/lucide:fingerprint.svg?width=14) MFA quando necessário
- ![lock-keyhole](https://api.iconify.design/lucide:lock-keyhole.svg?width=14) RBAC / ABAC

**Status:** 🚧 Em desenvolvimento

---

### ![package-check](https://api.iconify.design/lucide:package-check.svg?width=20) [3. Dependências & Supply Chain](dependencies.md)

Gestão segura de dependências e supply chain.

- ![search-check](https://api.iconify.design/lucide:search-check.svg?width=14) Auditoria contínua (npm audit, Snyk, Dependabot)
- ![shield-alert](https://api.iconify.design/lucide:shield-alert.svg?width=14) SCA (Software Composition Analysis)
- ![git-branch](https://api.iconify.design/lucide:git-branch.svg?width=14) Lockfiles obrigatórios
- ![check-circle](https://api.iconify.design/lucide:check-circle.svg?width=14) Assinatura de pacotes
- ![ban](https://api.iconify.design/lucide:ban.svg?width=14) Lista de bloqueio

**Status:** 🚧 Em desenvolvimento

---

### ![code-2](https://api.iconify.design/lucide:code-2.svg?width=20) [4. Segurança de Código](code-security.md)

Práticas de desenvolvimento seguro.

- ![scan](https://api.iconify.design/lucide:scan.svg?width=14) SAST (Static Analysis)
- ![bug](https://api.iconify.design/lucide:bug.svg?width=14) Linters de segurança
- ![git-merge](https://api.iconify.design/lucide:git-merge.svg?width=14) Code review com foco em segurança
- ![shield](https://api.iconify.design/lucide:shield.svg?width=14) Input validation
- ![x-circle](https://api.iconify.design/lucide:x-circle.svg?width=14) Prevenção de injeções (SQL, XSS, etc.)

**Status:** 🚧 Em desenvolvimento

---

### ![globe](https://api.iconify.design/lucide:globe.svg?width=20) [5. Segurança de APIs](api-security.md)

Proteção de APIs HTTP.

- ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=14) Autenticação (Bearer JWT)
- ![activity](https://api.iconify.design/lucide:activity.svg?width=14) Rate limiting
- ![zap-off](https://api.iconify.design/lucide:zap-off.svg?width=14) CORS configurado corretamente
- ![file-lock](https://api.iconify.design/lucide:file-lock.svg?width=14) Validação de schemas
- ![shield-alert](https://api.iconify.design/lucide:shield-alert.svg?width=14) OWASP API Security Top 10

**Complementa:** [/apis](../apis/) (convenções gerais)

**Status:** 🚧 Em desenvolvimento

---

### ![database](https://api.iconify.design/lucide:database.svg?width=20) [6. Proteção de Dados](data-protection.md)

Segurança e privacidade de dados.

- ![eye-off](https://api.iconify.design/lucide:eye-off.svg?width=14) Criptografia em repouso e em trânsito
- ![hash](https://api.iconify.design/lucide:hash.svg?width=14) Hashing de senhas (bcrypt, Argon2)
- ![user-x](https://api.iconify.design/lucide:user-x.svg?width=14) Anonimização / Pseudonimização
- ![eraser](https://api.iconify.design/lucide:eraser.svg?width=14) Direito ao esquecimento (LGPD)
- ![file-key](https://api.iconify.design/lucide:file-key.svg?width=14) Gestão de PII (Personally Identifiable Information)

**Status:** 🚧 Em desenvolvimento

---

### ![cloud](https://api.iconify.design/lucide:cloud.svg?width=20) [7. Infraestrutura & Cloud](infrastructure.md)

Hardening de infraestrutura e cloud.

- ![network](https://api.iconify.design/lucide:network.svg?width=14) Segmentação de rede
- ![firewall](https://api.iconify.design/lucide:firewall.svg?width=14) Firewall / Security Groups
- ![server](https://api.iconify.design/lucide:server.svg?width=14) Hardening de OS e containers
- ![key](https://api.iconify.design/lucide:key.svg?width=14) IAM / RBAC na cloud
- ![shield](https://api.iconify.design/lucide:shield.svg?width=14) WAF (Web Application Firewall)

**Status:** 🚧 Em desenvolvimento

---

### ![alert-circle](https://api.iconify.design/lucide:alert-circle.svg?width=20) [8. Threat Modeling](threat-modeling.md)

Modelagem de ameaças para novos serviços.

- ![target](https://api.iconify.design/lucide:target.svg?width=14) Identificação de assets críticos
- ![skull](https://api.iconify.design/lucide:skull.svg?width=14) Análise de ameaças (STRIDE)
- ![shield-question](https://api.iconify.design/lucide:shield-question.svg?width=14) Avaliação de riscos
- ![check-square](https://api.iconify.design/lucide:check-square.svg?width=14) Controles de mitigação
- ![file-text](https://api.iconify.design/lucide:file-text.svg?width=14) Documentação de modelo de ameaças

**Status:** 🚧 Em desenvolvimento

---

### ![bug](https://api.iconify.design/lucide:bug.svg?width=20) [9. Testes de Segurança](security-testing.md)

Validação contínua de segurança.

- ![scan-line](https://api.iconify.design/lucide:scan-line.svg?width=14) SAST (Static Application Security Testing)
- ![search](https://api.iconify.design/lucide:search.svg?width=14) DAST (Dynamic Application Security Testing)
- ![cpu](https://api.iconify.design/lucide:cpu.svg?width=14) Pentest periódico
- ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=14) Security regression tests
- ![zap](https://api.iconify.design/lucide:zap.svg?width=14) Fuzzing

**Status:** 🚧 Em desenvolvimento

---

### ![file-check](https://api.iconify.design/lucide:file-check.svg?width=20) [10. Compliance & LGPD](compliance.md)

Conformidade legal e regulatória.

- ![scale](https://api.iconify.design/lucide:scale.svg?width=14) LGPD (Lei Geral de Proteção de Dados)
- ![book-open](https://api.iconify.design/lucide:book-open.svg?width=14) Bases legais para tratamento de dados
- ![clipboard-list](https://api.iconify.design/lucide:clipboard-list.svg?width=14) RIPD (Relatório de Impacto)
- ![user-check](https://api.iconify.design/lucide:user-check.svg?width=14) Consentimento e opt-out
- ![archive](https://api.iconify.design/lucide:archive.svg?width=14) Retenção e descarte de dados

**Status:** 🚧 Em desenvolvimento

---

### ![bell](https://api.iconify.design/lucide:bell.svg?width=20) [11. Resposta a Incidentes](incident-response.md)

Preparação e resposta a incidentes de segurança.

- ![map](https://api.iconify.design/lucide:map.svg?width=14) Plano de resposta
- ![users](https://api.iconify.design/lucide:users.svg?width=14) Equipe de resposta (CSIRT)
- ![clock](https://api.iconify.design/lucide:clock.svg?width=14) Playbooks por tipo de incidente
- ![megaphone](https://api.iconify.design/lucide:megaphone.svg?width=14) Comunicação e disclosure
- ![rotate-ccw](https://api.iconify.design/lucide:rotate-ccw.svg?width=14) Post-mortem e lições aprendidas

**Status:** 🚧 Em desenvolvimento

---

## 🔒 Requisitos Mínimos de Segurança

Todos os serviços **DEVEM**:

### ![lock](https://api.iconify.design/lucide:lock.svg?width=18) Criptografia

- ✅ **TLS 1.2+** para todas as comunicações externas
- ✅ **TLS 1.3** preferencial
- ✅ Certificados válidos (não self-signed em produção)
- ✅ HSTS habilitado (`Strict-Transport-Security`)

### ![key](https://api.iconify.design/lucide:key.svg?width=18) Gestão de Segredos

- ✅ **NUNCA** commitar segredos no código
- ✅ Usar Vault, AWS Secrets Manager, ou equivalente
- ✅ Injetar secrets via variáveis de ambiente ou montagem de volumes
- ✅ Rotação periódica (máximo 90 dias)

### ![shield](https://api.iconify.design/lucide:shield.svg?width=18) Autenticação & Autorização

- ✅ Autenticação obrigatória para endpoints sensíveis
- ✅ JWT com expiração curta (≤ 15 minutos para access tokens)
- ✅ Refresh tokens com rotação
- ✅ Validação de permissões (não confiar apenas no token)

### ![activity](https://api.iconify.design/lucide:activity.svg?width=18) Rate Limiting

- ✅ Implementar em **todos** os endpoints públicos
- ✅ Limites por IP e por usuário
- ✅ Headers de rate limit (`X-RateLimit-*`)

### ![package](https://api.iconify.design/lucide:package.svg?width=18) Dependências

- ✅ Auditoria automatizada em CI/CD
- ✅ Nenhuma vulnerabilidade **CRITICAL** em produção
- ✅ Atualização de dependências (máximo 30 dias para HIGH)
- ✅ Lockfiles versionados

### ![eye](https://api.iconify.design/lucide:eye.svg?width=18) Observabilidade

- ✅ Logs de segurança (auth, authz, failures)
- ✅ Alertas para tentativas de ataque
- ✅ Métricas de segurança (failed logins, rate limit hits)
- ✅ Trace IDs para investigação

### ![user-x](https://api.iconify.design/lucide:user-x.svg?width=18) Dados Pessoais

- ✅ Minimização de dados (apenas o necessário)
- ✅ Mascaramento em logs (CPF, email, telefone)
- ✅ Criptografia para PII sensível
- ✅ Implementar direito ao esquecimento

---

## 🚨 OWASP Top 10

Todos os serviços devem estar protegidos contra:

1. **A01:2021 – Broken Access Control**
   - Validar permissões server-side
   - Não expor IDs sequenciais
   - Implementar RBAC/ABAC

2. **A02:2021 – Cryptographic Failures**
   - TLS obrigatório
   - Criptografia forte (AES-256, RSA-2048+)
   - Nunca inventar crypto própria

3. **A03:2021 – Injection**
   - Prepared statements / parametrized queries
   - Input validation
   - Output encoding

4. **A04:2021 – Insecure Design**
   - Threat modeling obrigatório
   - Security requirements desde o início
   - Princípio do menor privilégio

5. **A05:2021 – Security Misconfiguration**
   - Desabilitar stack traces em produção
   - Remover endpoints de debug
   - Headers de segurança (CSP, X-Frame-Options, etc.)

6. **A06:2021 – Vulnerable Components**
   - Auditoria contínua
   - Patch management
   - SBOM (Software Bill of Materials)

7. **A07:2021 – Identification and Authentication Failures**
   - MFA para acesso crítico
   - Proteção contra brute force
   - Session management segura

8. **A08:2021 – Software and Data Integrity Failures**
   - Verificação de assinaturas
   - CI/CD pipeline seguro
   - Proteção contra supply chain attacks

9. **A09:2021 – Security Logging and Monitoring Failures**
   - Logs de eventos de segurança
   - Detecção de anomalias
   - Resposta a incidentes

10. **A10:2021 – Server-Side Request Forgery (SSRF)**
    - Validar e sanitizar URLs
    - Whitelist de destinos
    - Segregação de rede

---

## 📋 Checklist de Segurança

Use este checklist ao criar ou revisar serviços:

### ![code](https://api.iconify.design/lucide:code.svg?width=16) Desenvolvimento

- [ ] Threat model documentado
- [ ] Segredos gerenciados via Vault/Secret Manager
- [ ] Input validation em todos os endpoints
- [ ] Output encoding para prevenir XSS
- [ ] Prepared statements para queries
- [ ] CSRF protection (quando aplicável)
- [ ] CORS configurado corretamente
- [ ] Security headers aplicados
- [ ] Rate limiting implementado
- [ ] Logs de segurança estruturados

### ![test-tube](https://api.iconify.design/lucide:test-tube.svg?width=16) Testes

- [ ] SAST executado em CI/CD
- [ ] Dependency scanning ativo
- [ ] Testes de autenticação/autorização
- [ ] Testes de rate limiting
- [ ] Validação de schemas OpenAPI
- [ ] Fuzzing para inputs críticos

### ![rocket](https://api.iconify.design/lucide:rocket.svg?width=16) Deploy

- [ ] TLS configurado e testado
- [ ] Secrets injetados corretamente
- [ ] Permissões mínimas (IAM/RBAC)
- [ ] Network policies aplicadas
- [ ] WAF configurado (se aplicável)
- [ ] Monitoramento de segurança ativo
- [ ] Alertas críticos configurados
- [ ] Plano de resposta a incidentes

### ![shield-check](https://api.iconify.design/lucide:shield-check.svg?width=16) Produção

- [ ] Pentest realizado (serviços críticos)
- [ ] DAST executado
- [ ] Compliance validado (LGPD)
- [ ] Documentação de segurança atualizada
- [ ] Runbooks de incidentes prontos
- [ ] Backups testados
- [ ] Disaster recovery plan

---

## 🛠️ Ferramentas Recomendadas

### ![scan](https://api.iconify.design/lucide:scan.svg?width=16) SAST / Linting

- **Semgrep** — Análise estática multiplataforma
- **SonarQube** — Code quality + security
- **ESLint security plugins** — JavaScript/TypeScript
- **Bandit** — Python
- **Brakeman** — Ruby on Rails

### ![package-search](https://api.iconify.design/lucide:package-search.svg?width=16) Dependency Scanning

- **Snyk** — Vulnerabilidades em dependências
- **Dependabot** — GitHub native
- **npm audit / yarn audit** — JavaScript
- **OWASP Dependency-Check** — Multiplataforma

### ![key](https://api.iconify.design/lucide:key.svg?width=16) Secrets Management

- **HashiCorp Vault** — Secrets management
- **AWS Secrets Manager** — AWS native
- **GCP Secret Manager** — GCP native
- **Azure Key Vault** — Azure native

### ![search](https://api.iconify.design/lucide:search.svg?width=16) DAST / Pentest

- **OWASP ZAP** — Security scanner
- **Burp Suite** — Web vulnerability scanner
- **Nuclei** — Fast vulnerability scanner
- **ffuf** — Web fuzzer

### ![eye](https://api.iconify.design/lucide:eye.svg?width=16) Monitoramento

- **Falco** — Runtime security (Kubernetes)
- **OSSEC** — HIDS (Host Intrusion Detection)
- **Wazuh** — Security monitoring
- **ELK/Loki** — Log aggregation + security analytics

---

## 🎓 Treinamento

Todo desenvolvedor deve ter conhecimento básico de:

- ✅ OWASP Top 10 (Web + API)
- ✅ LGPD / GDPR fundamentals
- ✅ Secure coding practices
- ✅ Threat modeling basics
- ✅ Incident response procedures

**Recursos:**

- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [OWASP API Security Project](https://owasp.org/www-project-api-security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS Controls](https://www.cisecurity.org/controls)

---

## 📞 Suporte

- ![shield-alert](https://api.iconify.design/lucide:shield-alert.svg?width=16) **Vulnerabilidades** — Reporte via [SECURITY.md](../SECURITY.md)
- ![message-circle](https://api.iconify.design/lucide:message-circle.svg?width=16) **Dúvidas** — Abra issue ou consulte time de segurança
- ![book-open](https://api.iconify.design/lucide:book-open.svg?width=16) **Revisão de segurança** — Solicite security review antes do deploy

---

## 🔄 Evolução

Este documento evolui continuamente. Para propor mudanças:

1. Abra issue descrevendo a proposta
2. Discuta com o time de segurança
3. Crie PR com as alterações
4. Documente decisão em ADR (se necessário)

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](../LICENSE).

---

**[⬆ Voltar ao topo](#padrões-de-segurança)**

---

> 🛡️ **Segurança é responsabilidade de todos.** Não é apenas o trabalho do time de segurança, mas de cada desenvolvedor, arquiteto e tech lead.
