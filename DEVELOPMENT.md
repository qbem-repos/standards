# Guia de Desenvolvimento

> Instruções para contribuir e desenvolver a documentação localmente

---

## 🚀 Setup Local

### Pré-requisitos

- **Python 3.11+**
- **Git**

### Instalação

```bash
# Clone o repositório
git clone https://github.com/qbem-repos/standards.git
cd standards

# Instale as dependências
pip install -r requirements.txt
```

---

## 📖 Executando a Documentação Localmente

### Servidor de Desenvolvimento

```bash
# Inicia o servidor local com hot-reload
mkdocs serve
```

A documentação estará disponível em: **http://localhost:8000**

### Build da Documentação

```bash
# Gera os arquivos estáticos em /site
mkdocs build

# Build com validação rigorosa
mkdocs build --strict
```

---

## 📝 Estrutura do Projeto

```plaintext
standards/
├── .github/
│   ├── workflows/
│   │   └── deploy-docs.yml    # CI/CD para GitHub Pages
│   └── docs/
│       └── extra.css          # Estilos customizados
├── apis/                      # Documentação de APIs HTTP
│   ├── README.md
│   ├── conventions.md
│   ├── error-model.md
│   ├── openapi-style-guide.md
│   └── versioning.md
├── async/                     # Mensageria Assíncrona
│   ├── README.md
│   ├── conventions.md
│   ├── headers.md
│   ├── reliability.md
│   ├── schema-evolution.md
│   └── security.md
├── security/                  # Segurança
│   ├── README.md
│   ├── secrets-management.md
│   ├── auth.md
│   ├── api-security.md
│   └── data-protection.md
├── webhooks/                  # Webhooks (em desenvolvimento)
├── observability/             # Observabilidade (em desenvolvimento)
├── tooling/                   # Ferramentas
├── checklists/                # Checklists
├── frontend/                  # Frontend (em desenvolvimento)
├── adr/                       # Architecture Decision Records
├── mkdocs.yml                 # Configuração do MkDocs
├── requirements.txt           # Dependências Python
└── README.md                  # Página inicial
```

---

## ✍️ Contribuindo com Documentação

### 1. Criar um Branch

```bash
git checkout -b docs/minha-contribuicao
```

### 2. Editar Arquivos Markdown

- Os arquivos Markdown estão diretamente na raiz e subpastas do projeto
- Use a sintaxe Markdown padrão
- Adicione emojis via `:emoji_name:` ou diretamente
- Use ícones do Iconify quando apropriado

### 3. Testar Localmente

```bash
# Inicie o servidor
mkdocs serve

# Abra http://localhost:8000 e verifique suas alterações
```

### 4. Validar

```bash
# Build com validação
mkdocs build --strict

# Verificar links quebrados (opcional)
# pip install mkdocs-linkcheck
# mkdocs build --strict --site-dir test_site
```

### 5. Commit e Push

```bash
git add .
git commit -m "docs: adiciona documentação sobre X"
git push origin docs/minha-contribuicao
```

### 6. Abrir Pull Request

- Abra um PR no GitHub
- Descreva suas mudanças
- Aguarde revisão

---

## 🎨 Guia de Estilo

### Títulos

```markdown
# Título Principal (H1) - Apenas um por página

## Seção (H2)

### Subseção (H3)

#### Detalhes (H4)
```

### Blocos de Código

````markdown
```javascript
// Use a linguagem apropriada para syntax highlighting
const example = "code";
```

```bash
# Para comandos shell
npm install
```

```json
{
  "formato": "json"
}
```
````

### Admonitions (Blocos de Destaque)

```markdown
!!! note "Nota"
    Informação importante

!!! warning "Atenção"
    Cuidado com isso

!!! danger "Perigo"
    Não faça isso!

!!! tip "Dica"
    Sugestão útil

!!! example "Exemplo"
    Veja como fazer
```

### Listas

```markdown
- Item não ordenado
- Outro item
  - Subitem

1. Item ordenado
2. Segundo item
3. Terceiro item
```

### Tabelas

```markdown
| Coluna 1 | Coluna 2 | Coluna 3 |
|----------|----------|----------|
| Valor 1  | Valor 2  | Valor 3  |
| Valor 4  | Valor 5  | Valor 6  |
```

### Links

```markdown
[Texto do link](url-relativa.md)
[Link externo](https://exemplo.com)
[Link com título](url.md "Título ao passar o mouse")
```

### Checklists

```markdown
- [ ] Tarefa não concluída
- [x] Tarefa concluída
```

### Ícones (via Iconify)

```markdown
![shield](https://api.iconify.design/lucide:shield.svg?width=16)
![check](https://api.iconify.design/lucide:check.svg?color=%2351cf66&width=16)
```

---

## 🔧 Configuração Avançada

### Adicionar Nova Página

1. Crie o arquivo `.md` na pasta apropriada
2. Adicione ao `nav` em `mkdocs.yml`:

```yaml
nav:
  - Nova Seção:
      - nova-secao/README.md
      - Documento: nova-secao/documento.md
```

### Customizar CSS

Edite `.github/docs/extra.css` para adicionar estilos customizados.

### Adicionar Plugins

1. Adicione ao `requirements.txt`
2. Configure em `mkdocs.yml` na seção `plugins:`

---

## 🚀 Deploy

### GitHub Pages (Automático)

O deploy é automático via GitHub Actions quando há push para `main`:

1. Workflow: `.github/workflows/deploy-docs.yml`
2. Trigger: Push ou PR para `main`
3. Build com MkDocs
4. Deploy para GitHub Pages

### Deploy Manual

```bash
# Build e deploy (requer permissões)
mkdocs gh-deploy --force
```

---

## 🐛 Troubleshooting

### Erro: "Module not found"

```bash
pip install --upgrade -r requirements.txt
```

### Erro: "Config file not found"

Certifique-se de estar no diretório raiz do projeto onde está o `mkdocs.yml`.

### Links Quebrados

```bash
# Instale o plugin
pip install mkdocs-linkcheck

# Execute verificação
mkdocs build --strict
```

### Hot-reload não está funcionando

```bash
# Pare o servidor (Ctrl+C) e reinicie
mkdocs serve --clean
```

---

## 📚 Recursos

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Markdown Guide](https://www.markdownguide.org/)
- [PyMdown Extensions](https://facelessuser.github.io/pymdown-extensions/)
- [Iconify](https://iconify.design/)

---

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/qbem-repos/standards/issues)
- **Discussões**: [GitHub Discussions](https://github.com/qbem-repos/standards/discussions)
- **Email**: Entre em contato com o time de arquitetura

---

**[⬆ Voltar ao início](README.md)**