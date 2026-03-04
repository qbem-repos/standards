#!/bin/bash
# Script para validar configurações OpenTelemetry
# Usa jsonschema (Python) para validar arquivos de configuração
#
# Uso:
#   ./validate-config.sh [path/to/config.json]
#
# Exemplo:
#   ./validate-config.sh my-service-otel-config.json
#
# Requisitos:
#   - Python 3.7+
#   - jsonschema: pip install jsonschema

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arquivo de configuração a validar
CONFIG_FILE="${1:-}"

# Schema JSON
SCHEMA_FILE="$(dirname "$0")/config-schema.json"

echo "🔍 Validador de Configuração OpenTelemetry"
echo ""

# Verificar argumentos
if [ -z "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Erro: Nenhum arquivo especificado${NC}"
    echo ""
    echo "Uso: $0 <config-file.json>"
    echo ""
    echo "Exemplo:"
    echo "  $0 my-service-otel-config.json"
    exit 1
fi

# Verificar se o arquivo existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Erro: Arquivo não encontrado: ${CONFIG_FILE}${NC}"
    exit 1
fi

# Verificar se o schema existe
if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}❌ Erro: Schema não encontrado: ${SCHEMA_FILE}${NC}"
    exit 1
fi

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Erro: Python 3 não encontrado${NC}"
    echo ""
    echo "Instale Python 3:"
    echo "  - macOS: brew install python3"
    echo "  - Ubuntu: sudo apt install python3"
    echo "  - Windows: https://www.python.org/downloads/"
    exit 1
fi

# Verificar se jsonschema está instalado
if ! python3 -c "import jsonschema" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Instalando jsonschema...${NC}"
    pip3 install jsonschema 2>&1 | grep -v "Requirement already satisfied" || true
    echo ""
fi

echo -e "Arquivo: ${BLUE}${CONFIG_FILE}${NC}"
echo -e "Schema: ${BLUE}${SCHEMA_FILE}${NC}"
echo ""

# Validar JSON syntax primeiro
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Validando Sintaxe JSON"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>/dev/null; then
    echo -e "${GREEN}✅ Sintaxe JSON válida${NC}"
else
    echo -e "${RED}❌ Sintaxe JSON inválida${NC}"
    echo ""
    python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>&1 || true
    exit 1
fi

echo ""

# Validar contra o schema
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📐 Validando Schema OpenTelemetry"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Script Python inline para validação
VALIDATION_RESULT=$(python3 << EOF
import json
import sys
from jsonschema import validate, ValidationError, Draft7Validator

try:
    # Carregar schema
    with open('$SCHEMA_FILE', 'r') as f:
        schema = json.load(f)

    # Carregar config
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)

    # Validar
    validator = Draft7Validator(schema)
    errors = list(validator.iter_errors(config))

    if errors:
        print("INVALID")
        for error in errors:
            path = " -> ".join(str(p) for p in error.path) if error.path else "root"
            print(f"  Path: {path}")
            print(f"  Error: {error.message}")
            print("")
        sys.exit(1)
    else:
        print("VALID")
        sys.exit(0)

except ValidationError as e:
    print("INVALID")
    print(f"ValidationError: {e.message}")
    sys.exit(1)
except Exception as e:
    print("ERROR")
    print(f"Unexpected error: {str(e)}")
    sys.exit(2)
EOF
)

VALIDATION_EXIT_CODE=$?

if [ $VALIDATION_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Configuração válida conforme schema OpenTelemetry${NC}"
else
    echo -e "${RED}❌ Configuração inválida${NC}"
    echo ""
    echo "$VALIDATION_RESULT"
    exit 1
fi

echo ""

# Validações adicionais (boas práticas)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Validando Boas Práticas QBEM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

WARNINGS=0

# Extrair valores com Python
SERVICE_NAME=$(python3 -c "import json; config=json.load(open('$CONFIG_FILE')); print(config.get('service', {}).get('name', ''))")
ENVIRONMENT=$(python3 -c "import json; config=json.load(open('$CONFIG_FILE')); print(config.get('service', {}).get('environment', ''))")
EXPORTER_TYPE=$(python3 -c "import json; config=json.load(open('$CONFIG_FILE')); print(config.get('exporters', {}).get('type', ''))")
TRACES_ENABLED=$(python3 -c "import json; config=json.load(open('$CONFIG_FILE')); print(config.get('instrumentation', {}).get('traces', {}).get('enabled', False))")
SAMPLING_TYPE=$(python3 -c "import json; config=json.load(open('$CONFIG_FILE')); print(config.get('instrumentation', {}).get('traces', {}).get('sampling', {}).get('type', ''))")
SAMPLING_RATIO=$(python3 -c "import json; config=json.load(open('$CONFIG_FILE')); print(config.get('instrumentation', {}).get('traces', {}).get('sampling', {}).get('ratio', config.get('instrumentation', {}).get('traces', {}).get('sampling', {}).get('parent_sampler', {}).get('ratio', 1.0)))")
PROPAGATION_FORMAT=$(python3 -c "import json; config=json.load(open('$CONFIG_FILE')); print(config.get('instrumentation', {}).get('traces', {}).get('propagation', {}).get('format', ''))")
BATCH_ENABLED=$(python3 -c "import json; config=json.load(open('$CONFIG_FILE')); print(config.get('processors', {}).get('batch', {}).get('enabled', False))")

# 1. Verificar exporter recomendado
if [ "$EXPORTER_TYPE" != "otlp" ]; then
    echo -e "${YELLOW}⚠️  Exporter não é 'otlp' (recomendado: otlp)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 2. Verificar propagation format
if [ "$TRACES_ENABLED" = "True" ] && [ "$PROPAGATION_FORMAT" != "w3c" ]; then
    echo -e "${YELLOW}⚠️  Propagation format não é 'w3c' (obrigatório: w3c)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 3. Verificar sampling em produção
if [ "$ENVIRONMENT" = "production" ] && [ "$TRACES_ENABLED" = "True" ]; then
    if [ "$SAMPLING_TYPE" = "always_on" ]; then
        echo -e "${YELLOW}⚠️  Sampling 'always_on' em produção (100% pode ser custoso)${NC}"
        echo -e "    ${BLUE}💡 Recomendado: parent_based com ratio 0.01-0.1${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi

    if (( $(echo "$SAMPLING_RATIO > 0.5" | bc -l 2>/dev/null || echo 0) )); then
        echo -e "${YELLOW}⚠️  Sampling ratio > 50% em produção${NC}"
        echo -e "    ${BLUE}💡 Recomendado: 0.01-0.1 (1-10%)${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# 4. Verificar batch processor
if [ "$TRACES_ENABLED" = "True" ] && [ "$BATCH_ENABLED" != "True" ]; then
    echo -e "${YELLOW}⚠️  Batch processor desabilitado (recomendado: habilitado)${NC}"
    echo -e "    ${BLUE}💡 Batch processor melhora performance${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 5. Verificar nome do serviço
if [ ${#SERVICE_NAME} -lt 3 ]; then
    echo -e "${YELLOW}⚠️  Nome do serviço muito curto (mínimo: 3 caracteres)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Nenhuma violação de boas práticas encontrada${NC}"
else
    echo ""
    echo -e "${YELLOW}Total de avisos: ${WARNINGS}${NC}"
    echo ""
    echo "Avisos não impedem o uso, mas é recomendado seguir as boas práticas."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resumo da Configuração"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Serviço:"
echo "  Nome: $SERVICE_NAME"
echo "  Ambiente: ${ENVIRONMENT:-N/A}"
echo ""
echo "Exporter:"
echo "  Tipo: $EXPORTER_TYPE"
echo ""
echo "Tracing:"
echo "  Habilitado: $TRACES_ENABLED"
if [ "$TRACES_ENABLED" = "True" ]; then
    echo "  Sampling: $SAMPLING_TYPE"
    echo "  Ratio: ${SAMPLING_RATIO:-N/A}"
    echo "  Propagation: ${PROPAGATION_FORMAT:-N/A}"
fi
echo ""
echo "Processors:"
echo "  Batch: $BATCH_ENABLED"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Validação concluída com sucesso!${NC}"
echo ""

exit 0
