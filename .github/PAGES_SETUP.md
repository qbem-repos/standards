# GitHub Pages Setup

Este documento explica como configurar o GitHub Pages para publicar a documentação automaticamente.

## 📋 Pré-requisitos

- Repositório no GitHub
- Permissões de administrador no repositório

## 🚀 Configuração

### 1. Habilitar GitHub Pages

1. Acesse as configurações do repositório:
   ```
   Settings → Pages
   ```

2. Configure a fonte:
   - **Source**: GitHub Actions
   - **Branch**: Não selecione nenhum (o workflow vai gerenciar)

### 2. Configurar Permissões do Workflow

1. Vá em `Settings → Actions → General`

2. Na seção **Workflow permissions**, selecione:
   - ✅ **Read and write permissions**

3. Marque também:
   - ✅ **Allow GitHub Actions to create and approve pull requests**

4. Clique em **Save**

### 3. Verificar o Workflow

O workflow `.github/workflows/deploy-docs.yml` já está configurado e será executado automaticamente quando:

- Houver push para `main`
- Houver pull request para `main`
- For acionado manualmente

### 4. Verificar Deploy

1. Acesse a aba **Actions** do repositório
2. Verifique se o workflow "Deploy Documentation to GitHub Pages" foi executado
3. Se bem-sucedido, a documentação estará em:
   ```
   https://qbem-repos.github.io/standards/
   ```

## 🔧 Workflow Explicado

O workflow faz o seguinte:

1. **Checkout** do código
2. **Setup Python** 3.11
3. **Instala dependências** MkDocs
4. **Build** da documentação (`mkdocs build`)
5. **Deploy** para GitHub Pages

## 🐛 Troubleshooting

### Erro: "Workflow does not have write permissions"

**Solução**: Verifique as permissões em Settings → Actions → General

### Erro: "Pages build failed"

**Solução**: 
1. Vá em Actions e veja o log do erro
2. Verifique se o `mkdocs.yml` está correto
3. Execute `mkdocs build --strict` localmente para validar

### Deploy não acontece em PRs

**Comportamento esperado**: O workflow apenas faz build em PRs, mas não publica. Apenas pushes para `main` fazem deploy.

### Custom Domain

Para usar um domínio customizado:

1. Crie arquivo `CNAME` na raiz com o domínio:
   ```
   docs.qbem.com.br
   ```

2. Configure o DNS:
   ```
   Type: CNAME
   Name: docs
   Value: qbem-repos.github.io
   ```

3. Em Settings → Pages, configure o custom domain

## 📚 Recursos

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [MkDocs Deploy Guide](https://www.mkdocs.org/user-guide/deploying-your-docs/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

## ✅ Checklist de Configuração

- [ ] GitHub Pages habilitado com Source = GitHub Actions
- [ ] Workflow permissions configurado (Read and write)
- [ ] Primeiro deploy executado com sucesso
- [ ] Documentação acessível na URL do GitHub Pages
- [ ] Custom domain configurado (opcional)

---

**Status**: ✅ Configurado e funcionando