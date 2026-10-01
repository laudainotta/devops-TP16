#!/bin/bash
set -uo pipefail

echo "================================================="
echo "  VERIFICACIÓN TÉCNICA - TP16 TRIVY SECURITY (v4)"
echo "================================================="
echo ""

# 1. Verificar instalación local o disponibilidad de Docker
if command -v trivy &> /dev/null; then
  echo "  [OK] Trivy instalado localmente ($(trivy --version | head -n 1))"
else
  echo "  [WARN] Trivy no detectado localmente en PATH (Se verificará ejecución mediante CI/CD)"
fi

# 2. Verificar configuración en el pipeline
WORKFLOW_FILE=".github/workflows/cicd.yml"
if [ -f "$WORKFLOW_FILE" ]; then
  if grep -q "trivy-andon-cord" "$WORKFLOW_FILE" && grep -q "manifests-rendered-prod.yaml" "$WORKFLOW_FILE"; then
    echo "  [OK] Workflow configurado con 3 fases y renderizado de Helm TP10B"
  else
    echo "  [FAIL] Falta la configuración de 3 fases o TP10B en $WORKFLOW_FILE"
    exit 1
  fi
else
  echo "  [FAIL] No se encontró el archivo $WORKFLOW_FILE"
  exit 1
fi

echo ""
echo "=== Verificación completada con éxito ==="
