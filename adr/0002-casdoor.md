# ADR 0002 – Adoção do Casdoor como provedor de autenticação e autorização

**Data:** 2025-09-11
**Status:** Aprovado

---

## Contexto

Precisamos padronizar a autenticação e autorização das aplicações do ecossistema **Qbem**.
Atualmente, existem diferentes formas de login e gestão de permissões espalhadas entre os sistemas, o que gera:

* Dificuldade de manutenção e auditoria.
* Duplicação de código de autenticação.
* Baixa consistência na experiência do usuário.

O objetivo é definir um **Identity Provider (IdP)** único, que seja open source,
flexível e capaz de integrar com protocolos modernos (OAuth2, OIDC, SAML) e que
permita fácil integração com diferentes clientes (frontends, backends, mobile).

Após avaliação, consideramos o **Casdoor** como opção principal.

---

## Decisão

Adotar o **Casdoor** como provedor central de autenticação e autorização para
todas as aplicações do ecossistema Qbem.

---

## Alternativas consideradas

* **Keycloak**

  * Prós: amplamente utilizado, comunidade grande, suporte a integrações corporativas.
  * Contras: instalação e manutenção mais complexa, curva de aprendizado alta,
  consumo de recursos elevado para os casos de uso atuais.

* **Auth0 (SaaS)**

  * Prós: facilidade de uso, escalabilidade, suporte comercial.
  * Contras: custo recorrente elevado, dependência de fornecedor externo, menor controle sobre dados sensíveis.

* **Construir solução própria**

  * Prós: controle total sobre a implementação.
  * Contras: alto custo de desenvolvimento e manutenção, risco de falhas de segurança, não é foco estratégico.

---

## Consequências

* **Positivas**

  * Solução open source, sem custos de licença.
  * Suporte nativo a múltiplos protocolos (OAuth2, OIDC, SAML, LDAP).
  * Gestão centralizada de usuários, papéis e permissões.
  * Integração simples com aplicações existentes.
  * UI pronta para fluxo de autenticação.

* **Negativas**

  * Comunidade e documentação menores comparadas ao Keycloak.
  * Possível necessidade de ajustes customizados para cenários avançados.
  * Menor histórico de uso em larga escala em comparação com alternativas mais consolidadas.

* **Implicações futuras**

  * Caso o projeto cresça exponencialmente, pode ser necessário reavaliar a escalabilidade.
  * Precisaremos definir um plano de **migração gradual** das aplicações já existentes para o Casdoor.
  * Manutenção contínua exigirá monitoramento de atualizações de segurança do projeto.

---

## Referências

* [Documentação oficial do Casdoor](https://casdoor.org/)
* [Repositório GitHub – Casdoor](https://github.com/casdoor/casdoor)
* Discussões internas sobre padronização de autenticação (Qbem Standards – 2025-09)
