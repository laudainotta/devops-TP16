
## TP16 — Escaneo de Seguridad de Contenedores, Dependencias e IaC con Trivy (Pipeline 3 Fases)

Integración de **Trivy** en la fábrica de software (CI/CD) aplicando la arquitectura de **3 Fases con Paso de Artefactos** y la resolución de falsos positivos mediante el patrón **Render First (TP10B)**.

### Matriz de Control e Integración (Formato CSV)

```csv
Fase / Job;Dominio Evaluado;Severidades;Exit Code;Acción ante Hallazgos;Evidencia
Fase 1: build-and-package;Compilación Docker;-;0;Exporta app-image.tar como artefacto;Artefacto en GitHub Actions
Fase 2A: trivy-andon-cord;SCA, Contenedor e IaC Renderizado (TP10B);HIGH, CRITICAL;1;Andon Cord: Detiene el pipeline y bloquea el despliegue;Resumen en $GITHUB_STEP_SUMMARY
Fase 2B: trivy-audit-report;Contenedores y Dependencias;LOW, MEDIUM;0;Informativo: Genera reporte de inspección;Artifact descargable + $GITHUB_STEP_SUMMARY
Fase 3: deploy-k8s-helm;Publicación y Despliegue;-;0;Promueve la imagen aprobada a Docker Hub y Helm;Release en Kubernetes
```

### Comandos de Auditoría Local (desde `guia-10/`)

```bash
# 1. Auditoría SCA
trivy fs ./backend

# 2. Auditoría de Imagen
docker build -t devops-portfolio:latest ./backend
trivy image --severity HIGH,CRITICAL devops-portfolio:latest

# 3. Renderizado previo e IaC Scanning (TP10B)
helm template mi-app ./devops-portfolio -f values-prod.yaml > manifests-rendered-prod.yaml
trivy config manifests-rendered-prod.yaml
```

### Cambios v2 respecto de la guía

- Rutas reales del repositorio: `guia-10/backend`, `guia-10/devops-portfolio` y `guia-10/values-prod.yaml`.
- `aquasecurity/trivy-action` fijado por SHA (v0.36.0) en lugar de `@master` (CVE-2026-33634).
- `output:` movido dentro de `with:` (la versión original es rechazada por GitHub: `Unexpected value 'output'`).
- Ambos escaneos de la Fase 2A se ejecutan siempre (`continue-on-error`) y el corte se decide en un paso final.
- `manifests-rendered-*.yaml` excluido de Git: contiene el Secret de producción en Base64.
