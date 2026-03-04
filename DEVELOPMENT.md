# Guia de Desenvolvimento

> Documentação mínima para contribuir com os padrões QBEM

---

## 🚀 GitHub Pages (Deploy Automático)

A documentação é publicada automaticamente via GitHub Pages usando Jekyll nativo.

**Não é necessário instalar nada para contribuir!**

Apenas edite os arquivos `.md` e faça push para `main`.

### URL da Documentação

```
https://qbem-repos.github.io/standards/
```

---

## 📝 Contribuindo

### 1. Editar Documentação

```bash
# Clone o repositório
git clone https://github.com/qbem-repos/standards.git
cd standards

# Crie um branch
git checkout -b docs/minha-contribuicao

# Edite os arquivos .md com seu editor favorito
# Todos os arquivos Markdown são processados automaticamente
```

### 2. Commit e Push

```bash
git add .
git commit -m "docs: adiciona documentação sobre X"
git push origin docs/minha-contribuicao
```

### 3. Abrir Pull Request

- Abra um PR no GitHub
- Aguarde revisão
- Após merge, o deploy é automático em ~1-2 minutos

---

## 💻 Desenvolvimento Local (Opcional)

Se quiser visualizar localmente antes do push:

### Instalar Jekyll

**macOS:**
```bash
brew install ruby
gem install bundler jekyll
```

**Windows:**
- Baixe [RubyInstaller](https://rubyinstaller.org/)
- Execute: `gem install bundler jekyll`

**Linux:**
```bash
sudo apt-get install ruby-full build-essential
gem install bundler jekyll
```

### Rodar Localmente

```bash
# No diretório do projeto
bundle install
bundle exec jekyll serve

# Acesse: http://localhost:4000/standards/
```

---

## 📖 Guia de Markdown

### Títulos
```markdown
# H1 - Título Principal
## H2 - Seção
### H3 - Subseção
```

### Código
````markdown
```javascript
const exemplo = "código";
```
````

### Links
```markdown
[Texto do Link](./caminho/arquivo.md)
[Link Externo](https://example.com)
```

### Listas
```markdown
- Item 1
- Item 2
  - Subitem

1. Primeiro
2. Segundo
```

### Tabelas
```markdown
| Coluna 1 | Coluna 2 |
|----------|----------|
| Valor A  | Valor B  |
```

### Checklists
```markdown
- [ ] Tarefa pendente
- [x] Tarefa completa
```

### Blockquotes
```markdown
> Citação ou nota importante
```

---

## 📁 Estrutura

```
standards/
├── _config.yml          # Config Jekyll (não mexer geralmente)
├── assets/css/          # Estilos customizados
├── apis/                # Docs de APIs
├── async/               # Docs de mensageria
├── security/            # Docs de segurança
└── *.md                 # Todos os Markdown são processados
```

---

## 🔧 Configuração

### _config.yml

Configuração minimalista do Jekyll:

```yaml
title: QBEM Standards
theme: jekyll-theme-minimal
plugins:
  - jekyll-relative-links
  - jekyll-optional-front-matter
```

### Customizar CSS

Edite `assets/css/style.scss` para ajustar estilos.

---

## ✅ Checklist para PRs

- [ ] Arquivos `.md` editados
- [ ] Links relativos funcionando
- [ ] Sem erros de sintaxe Markdown
- [ ] Commit seguindo [Conventional Commits](https://conventionalcommits.org)
- [ ] Descrição clara no PR

---

## 🐛 Problemas Comuns

### Links quebrados

Use links relativos:
```markdown
✅ [Correto](./apis/conventions.md)
❌ [Errado](/apis/conventions.md)
```

### Imagens não aparecem

Coloque imagens em `assets/` e referencie:
```markdown
![Alt](./assets/imagem.png)
```

---

## 📚 Recursos

- [Markdown Guide](https://www.markdownguide.org/)
- [Jekyll Docs](https://jekyllrb.com/docs/)
- [GitHub Pages](https://docs.github.com/en/pages)

---

## 📞 Suporte

- **Issues**: Para dúvidas e sugestões
- **Pull Requests**: Para contribuições
- **Discussões**: Para conversas mais longas

---

**Simples assim!** Edite Markdown, faça push, e pronto. 🚀