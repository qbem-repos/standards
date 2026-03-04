#!/bin/bash
# Script para validar regras de alerta e recording rules do Prometheus
# Usa promtool (CLI oficial do Prometheus) para validar sintaxe e semântica
#
# Uso:
#   ./validate-rules.sh [path/to/rules/directory]
#
# Exemplo:
#   ./validate-rules.sh ../../observability/examples/prometheus/
#
# Requisitos:
#   - promtool instalado (vem com Prometheus)
#   - Instalar: https://prometheus.io/download/

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório padrão de regras
RULES_DIR="${1:-../../observability/examples/prometheus}"

echo "🔍 Validando regras Prometheus em: ${RULES_DIR}"
echo ""

# Verificar se promtool está instalado
if ! command -v promtool &> /dev/null; then
    echo -e "${RED}❌ Erro: promtool não encontrado${NC}"
    echo ""
    echo "Instale o Prometheus para obter o promtool:"
    echo "  - macOS: brew install prometheus"
    echo "  - Linux: https://prometheus.io/download/"
    echo "  - Docker: docker run --rm -v \$(pwd):/rules prom/prometheus promtool check rules /rules/*.yml"
    exit 1
fi

# Verificar se o diretório existe
if [ ! -d "$RULES_DIR" ]; then
    echo -e "${RED}❌ Erro: Diretório não encontrado: ${RULES_DIR}${NC}"
    exit 1
fi

# Contador de arquivos
TOTAL_FILES=0
VALID_FILES=0
INVALID_FILES=0

# Validar cada arquivo .yml ou .yaml
echo "📋 Arquivos encontrados:"
echo ""

for file in "${RULES_DIR}"/*.{yml,yaml}; do
    # Verificar se o arquivo existe (glob pode não retornar nada)
    [ -e "$file" ] || continue

    TOTAL_FILES=$((TOTAL_FILES + 1))
    filename=$(basename "$file")

    echo -e "Validando: ${YELLOW}${filename}${NC}"

    # Executar promtool check rules
    if promtool check rules "$file" 2>&1; then
        echo -e "${GREEN}✅ ${filename} - Válido${NC}"
        VALID_FILES=$((VALID_FILES + 1))
    else
        echo -e "${RED}❌ ${filename} - Inválido${NC}"
        INVALID_FILES=$((INVALID_FILES + 1))
    fi

    echo ""
done

# Resumo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resumo da Validação"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total de arquivos: ${TOTAL_FILES}"
echo -e "${GREEN}Válidos: ${VALID_FILES}${NC}"
echo -e "${RED}Inválidos: ${INVALID_FILES}${NC}"
echo ""

# Validações adicionais (boas práticas)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Validando Boas Práticas"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

WARNINGS=0

for file in "${RULES_DIR}"/*.{yml,yaml}; do
    [ -e "$file" ] || continue
    filename=$(basename "$file")

    # 1. Verificar se alertas têm severidade
    if grep -q "alert:" "$file"; then
        if ! grep -q "severity:" "$file"; then
            echo -e "${YELLOW}⚠️  ${filename}: Alertas sem label 'severity'${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi

    # 2. Verificar se alertas têm annotations (summary, description)
    if grep -q "alert:" "$file"; then
        if ! grep -q "annotations:" "$file"; then
            echo -e "${YELLOW}⚠️  ${filename}: Alertas sem 'annotations'${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi

        if ! grep -q "summary:" "$file"; then
            echo -e "${YELLOW}⚠️  ${filename}: Alertas sem 'summary' nas annotations${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi

        if ! grep -q "description:" "$file"; then
            echo -e "${YELLOW}⚠️  ${filename}: Alertas sem 'description' nas annotations${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi

    # 3. Verificar se alertas têm runbook_url
    if grep -q "alert:" "$file"; then
        if ! grep -q "runbook_url:" "$file"; then
            echo -e "${YELLOW}⚠️  ${filename}: Alertas sem 'runbook_url'${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi

    # 4. Verificar se alertas têm 'for' (evitar alertas instantâneos)
    if grep -q "alert:" "$file"; then
        if ! grep -q "for:" "$file"; then
            echo -e "${YELLOW}⚠️  ${filename}: Alertas sem 'for:' (podem ser muito sensíveis)${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Nenhuma violação de boas práticas encontrada${NC}"
else
    echo ""
    echo -e "${YELLOW}Total de avisos: ${WARNINGS}${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Exit code baseado em arquivos inválidos
if [ $INVALID_FILES -gt 0 ]; then
    echo -e "${RED}❌ Validação falhou: ${INVALID_FILES} arquivo(s) inválido(s)${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Validação concluída com sucesso!${NC}"
    exit 0
fi
