# GitHub Pages Setup

> Configuração simples do GitHub Pages com Jekyll nativo

---

## ✅ Configuração Rápida (3 passos)

### 1. Habilitar GitHub Pages

1. Vá em **Settings → Pages**
2. Em **Source**, selecione: **GitHub Actions**
3. Pronto! Não precisa selecionar branch.

### 2. Configurar Permissões

1. Vá em **Settings → Actions → General**
2. Em **Workflow permissions**, marque:
   - ✅ **Read and write permissions**
3. Clique em **Save**

### 3. Fazer Deploy

```bash
git push origin main
```

Aguarde ~1-2 minutos e acesse:
```
https://qbem-repos.github.io/standards/
```

---

## 🎯 Como Funciona

O Jekyll é **nativo** do GitHub Pages. Não precisa instalar nada!

- ✅ Qualquer arquivo `.md` é processado automaticamente
- ✅ `README.md` vira a página inicial
- ✅ Links relativos funcionam automaticamente
- ✅ Tema aplicado automaticamente

---

## 🔧 Workflow

O arquivo `.github/workflows/deploy-docs.yml` faz:

1. Checkout do código
2. Build com Jekyll (nativo do GitHub)
3. Deploy para GitHub Pages

**Trigger**: Push para `main` ou manual via "Run workflow"

---

## 🐛 Problemas Comuns

### ❌ Erro: "Workflow does not have write permissions"

**Solução**: Verifique `Settings → Actions → General → Read and write permissions`

### ❌ Página 404

**Causa**: `baseurl` errado no `_config.yml`

**Solução**: Para repositório `qbem-repos/standards`:
```yaml
baseurl: "/standards"
url: "https://qbem-repos.github.io"
```

### ❌ Deploy não acontece

**Verificar**:
1. Push foi para `main`?
2. Workflow está habilitado?
3. Veja logs em `Actions → Deploy to GitHub Pages`

---

## 🌐 Custom Domain (Opcional)

Para usar `docs.qbem.com.br`:

### 1. Criar arquivo CNAME
```
docs.qbem.com.br
```

### 2. Configurar DNS
```
Type: CNAME
Name: docs
Value: qbem-repos.github.io
```

### 3. Atualizar _config.yml
```yaml
url: "https://docs.qbem.com.br"
baseurl: ""
```

---

## 📚 Recursos

- [GitHub Pages Docs](https://docs.github.com/en/pages)
- [Jekyll Docs](https://jekyllrb.com/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)

---

## ✅ Checklist

- [ ] GitHub Pages habilitado (Source: GitHub Actions)
- [ ] Workflow permissions: Read and write
- [ ] Primeiro deploy executado
- [ ] Docs acessível em https://qbem-repos.github.io/standards/

---

**Simples e funcional!** 🚀