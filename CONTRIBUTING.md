# Contribuindo com os Standards

Obrigado por ajudar a melhorar os padrões da QBEM!
Este repositório é a **fonte da verdade** para APIs, eventos, webhooks, observabilidade e segurança.
Para manter tudo organizado, siga as instruções abaixo.

---

## Como propor mudanças

1. **Abra uma issue** descrevendo sua proposta ou dúvida.

   * Use o template de *RFC curta* para mudanças em padrões.
2. **Crie um fork** e trabalhe em um branch descritivo:

   ```
   git checkout -b feat/api-error-handling
   ```
3. **Faça commits claros** usando [Conventional Commits](https://www.conventionalcommits.org):

   * `feat: adicionar guia de paginação em APIs`
   * `fix: corrigir exemplo inválido no webhook`
   * `docs: atualizar checklist de novo serviço`
4. **Abra um Pull Request**.

   * Preencha o template (o “porquê” é tão importante quanto o “como”).
   * Peça revisão de pelo menos um CODEOWNER.

---

## Fluxo de aprovação

* **Pequenas melhorias** (typos, links, exemplos): podem ser aprovadas rapidamente.
* **Novos padrões ou mudanças relevantes**:

  * Devem ser discutidas em **RFC curta** via PR/issue.
  * Uma vez aprovadas, geram um **ADR** em `/adr`.

---

## Checklist antes do PR

* [ ] Commits seguem Conventional Commits.
* [ ] Documentação clara e em português/inglês simples.
* [ ] Exemplos testados (quando aplicável).
* [ ] ADR criado/atualizado se for uma decisão arquitetural.
* [ ] PR template preenchido corretamente.

---

## Ferramentas de apoio

* **Markdownlint** e **link-check** rodam no CI — mantenha tudo válido.
* Linters específicos (Spectral, AsyncAPI) ficam em `/tooling`.
* Use `pre-commit` para evitar problemas antes do push.

---

## Código de Conduta

Todos devem seguir o [CODE\_OF\_CONDUCT.md](CODE_OF_CONDUCT.md).
Respeito e colaboração são obrigatórios.
