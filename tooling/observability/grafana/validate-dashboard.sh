#!/bin/bash
# Script para validar dashboards Grafana
# Valida sintaxe JSON e estrutura de dashboards conforme padrões QBEM
#
# Uso:
#   ./validate-dashboard.sh [path/to/dashboard.json]
#
# Exemplo:
#   ./validate-dashboard.sh ../../observability/examples/grafana/dashboard-red.json
#
# Requisitos:
#   - jq (JSON processor)
#   - Instalar: brew install jq (macOS) ou apt install jq (Ubuntu)

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arquivo de dashboard
DASHBOARD_FILE="${1:-}"

echo "🔍 Validador de Dashboard Grafana"
echo ""

# Verificar argumentos
if [ -z "$DASHBOARD_FILE" ]; then
    echo -e "${RED}❌ Erro: Nenhum arquivo especificado${NC}"
    echo ""
    echo "Uso: $0 <dashboard-file.json>"
    echo ""
    echo "Exemplo:"
    echo "  $0 my-dashboard.json"
    exit 1
fi

# Verificar se o arquivo existe
if [ ! -f "$DASHBOARD_FILE" ]; then
    echo -e "${RED}❌ Erro: Arquivo não encontrado: ${DASHBOARD_FILE}${NC}"
    exit 1
fi

# Verificar se jq está instalado
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ Erro: jq não encontrado${NC}"
    echo ""
    echo "Instale jq para processar JSON:"
    echo "  - macOS: brew install jq"
    echo "  - Ubuntu: sudo apt install jq"
    echo "  - Windows: https://stedolan.github.io/jq/download/"
    exit 1
fi

echo -e "Arquivo: ${BLUE}${DASHBOARD_FILE}${NC}"
echo ""

# Validar JSON syntax
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Validando Sintaxe JSON"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if jq empty "$DASHBOARD_FILE" 2>/dev/null; then
    echo -e "${GREEN}✅ Sintaxe JSON válida${NC}"
else
    echo -e "${RED}❌ Sintaxe JSON inválida${NC}"
    echo ""
    jq empty "$DASHBOARD_FILE" 2>&1 || true
    exit 1
fi

echo ""

# Validar estrutura do dashboard
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📐 Validando Estrutura do Dashboard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0

# Extrair valores
DASHBOARD=$(jq '.dashboard // .' "$DASHBOARD_FILE")

# 1. Verificar campos obrigatórios
TITLE=$(echo "$DASHBOARD" | jq -r '.title // empty')
UID=$(echo "$DASHBOARD" | jq -r '.uid // empty')
PANELS=$(echo "$DASHBOARD" | jq '.panels // []')
PANEL_COUNT=$(echo "$PANELS" | jq 'length')

if [ -z "$TITLE" ]; then
    echo -e "${RED}❌ Campo obrigatório ausente: dashboard.title${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ Título presente: ${TITLE}${NC}"
fi

if [ -z "$UID" ]; then
    echo -e "${YELLOW}⚠️  Campo recomendado ausente: dashboard.uid${NC}"
    echo -e "    ${BLUE}💡 UID garante consistência ao reimportar${NC}"
else
    echo -e "${GREEN}✅ UID presente: ${UID}${NC}"
fi

if [ "$PANEL_COUNT" -eq 0 ]; then
    echo -e "${RED}❌ Dashboard sem painéis${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ Painéis encontrados: ${PANEL_COUNT}${NC}"
fi

echo ""

# Validações de boas práticas
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Validando Boas Práticas QBEM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

WARNINGS=0

# 1. Verificar template variables
TEMPLATING=$(echo "$DASHBOARD" | jq '.templating.list // []')
TEMPLATE_COUNT=$(echo "$TEMPLATING" | jq 'length')

if [ "$TEMPLATE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Dashboard sem variáveis de template${NC}"
    echo -e "    ${BLUE}💡 Recomendado: adicionar \$service, \$environment${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ Variáveis de template: ${TEMPLATE_COUNT}${NC}"

    # Verificar variáveis recomendadas
    HAS_SERVICE=$(echo "$TEMPLATING" | jq '[.[].name] | contains(["service"])')
    HAS_ENVIRONMENT=$(echo "$TEMPLATING" | jq '[.[].name] | contains(["environment"])')

    if [ "$HAS_SERVICE" != "true" ]; then
        echo -e "${YELLOW}   ⚠️  Variável \$service não encontrada (recomendada)${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi

    if [ "$HAS_ENVIRONMENT" != "true" ]; then
        echo -e "${YELLOW}   ⚠️  Variável \$environment não encontrada (recomendada)${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# 2. Verificar refresh interval
REFRESH=$(echo "$DASHBOARD" | jq -r '.refresh // empty')

if [ -z "$REFRESH" ] || [ "$REFRESH" = "null" ]; then
    echo -e "${YELLOW}⚠️  Auto-refresh não configurado${NC}"
    echo -e "    ${BLUE}💡 Recomendado: 30s ou 1m${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ Auto-refresh: ${REFRESH}${NC}"
fi

# 3. Verificar tags
TAGS=$(echo "$DASHBOARD" | jq '.tags // []')
TAG_COUNT=$(echo "$TAGS" | jq 'length')

if [ "$TAG_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Dashboard sem tags${NC}"
    echo -e "    ${BLUE}💡 Recomendado: adicionar tags (ex: observability, red, slo)${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ Tags: ${TAG_COUNT}${NC}"
fi

# 4. Verificar painéis
echo ""
echo "Analisando painéis individuais..."
echo ""

PANELS_WITHOUT_TITLE=0
PANELS_WITHOUT_DESCRIPTION=0
PANELS_WITHOUT_TARGETS=0
PANELS_WITH_THRESHOLDS=0

for i in $(seq 0 $((PANEL_COUNT - 1))); do
    PANEL=$(echo "$PANELS" | jq ".[$i]")
    PANEL_ID=$(echo "$PANEL" | jq -r '.id // "unknown"')
    PANEL_TITLE=$(echo "$PANEL" | jq -r '.title // empty')
    PANEL_DESCRIPTION=$(echo "$PANEL" | jq -r '.description // empty')
    PANEL_TARGETS=$(echo "$PANEL" | jq '.targets // []')
    TARGET_COUNT=$(echo "$PANEL_TARGETS" | jq 'length')
    PANEL_THRESHOLDS=$(echo "$PANEL" | jq '.thresholds // .fieldConfig.defaults.thresholds // empty')

    # Verificar título
    if [ -z "$PANEL_TITLE" ]; then
        PANELS_WITHOUT_TITLE=$((PANELS_WITHOUT_TITLE + 1))
    fi

    # Verificar descrição
    if [ -z "$PANEL_DESCRIPTION" ]; then
        PANELS_WITHOUT_DESCRIPTION=$((PANELS_WITHOUT_DESCRIPTION + 1))
    fi

    # Verificar targets (queries)
    if [ "$TARGET_COUNT" -eq 0 ]; then
        PANELS_WITHOUT_TARGETS=$((PANELS_WITHOUT_TARGETS + 1))
    fi

    # Verificar thresholds
    if [ ! -z "$PANEL_THRESHOLDS" ] && [ "$PANEL_THRESHOLDS" != "null" ]; then
        PANELS_WITH_THRESHOLDS=$((PANELS_WITH_THRESHOLDS + 1))
    fi
done

if [ "$PANELS_WITHOUT_TITLE" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  ${PANELS_WITHOUT_TITLE} painel(is) sem título${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if [ "$PANELS_WITHOUT_DESCRIPTION" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  ${PANELS_WITHOUT_DESCRIPTION} painel(is) sem descrição${NC}"
    echo -e "    ${BLUE}💡 Descrições ajudam a entender o propósito do painel${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if [ "$PANELS_WITHOUT_TARGETS" -gt 0 ]; then
    echo -e "${RED}❌ ${PANELS_WITHOUT_TARGETS} painel(is) sem queries/targets${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ "$PANELS_WITH_THRESHOLDS" -gt 0 ]; then
    echo -e "${GREEN}✅ ${PANELS_WITH_THRESHOLDS} painel(is) com thresholds configurados${NC}"
else
    echo -e "${YELLOW}⚠️  Nenhum painel com thresholds${NC}"
    echo -e "    ${BLUE}💡 Thresholds ajudam a identificar problemas visualmente${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 5. Verificar annotations
ANNOTATIONS=$(echo "$DASHBOARD" | jq '.annotations.list // []')
ANNOTATION_COUNT=$(echo "$ANNOTATIONS" | jq 'length')

if [ "$ANNOTATION_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Dashboard sem annotations${NC}"
    echo -e "    ${BLUE}💡 Recomendado: adicionar annotations de deploys/restarts${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ Annotations: ${ANNOTATION_COUNT}${NC}"
fi

# 6. Verificar time range
TIME_FROM=$(echo "$DASHBOARD" | jq -r '.time.from // empty')
TIME_TO=$(echo "$DASHBOARD" | jq -r '.time.to // empty')

if [ -z "$TIME_FROM" ] || [ -z "$TIME_TO" ]; then
    echo -e "${YELLOW}⚠️  Time range não configurado${NC}"
    echo -e "    ${BLUE}💡 Recomendado: now-6h to now${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ Time range: ${TIME_FROM} to ${TIME_TO}${NC}"
fi

# 7. Verificar se é editable
EDITABLE=$(echo "$DASHBOARD" | jq -r '.editable // true')

if [ "$EDITABLE" = "false" ]; then
    echo -e "${YELLOW}⚠️  Dashboard marcado como não-editável${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Resumo de avisos
if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Nenhuma violação de boas práticas encontrada${NC}"
else
    echo -e "${YELLOW}Total de avisos: ${WARNINGS}${NC}"
    echo ""
    echo "Avisos não impedem o uso, mas é recomendado seguir as boas práticas."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resumo do Dashboard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Informações Gerais:"
echo "  Título: ${TITLE:-N/A}"
echo "  UID: ${UID:-N/A}"
echo "  Tags: ${TAG_COUNT}"
echo "  Editável: ${EDITABLE}"
echo ""
echo "Configurações:"
echo "  Refresh: ${REFRESH:-Manual}"
echo "  Time Range: ${TIME_FROM:-N/A} to ${TIME_TO:-N/A}"
echo "  Template Variables: ${TEMPLATE_COUNT}"
echo "  Annotations: ${ANNOTATION_COUNT}"
echo ""
echo "Painéis:"
echo "  Total: ${PANEL_COUNT}"
echo "  Com Thresholds: ${PANELS_WITH_THRESHOLDS}"
echo "  Sem Título: ${PANELS_WITHOUT_TITLE}"
echo "  Sem Descrição: ${PANELS_WITHOUT_DESCRIPTION}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Exit code baseado em erros críticos
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Validação falhou: ${ERRORS} erro(s) crítico(s)${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Validação concluída com sucesso!${NC}"
    exit 0
fi
