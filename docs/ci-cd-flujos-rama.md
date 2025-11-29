# Flujos CI/CD y Gestión de Ramas

## Estrategia de Ramas

Este documento describe las mejores prácticas sugeridas para integrar este proyecto de Terraform con pipelines de CI/CD, aunque **no incluye implementación de pipelines** (solo documentación).

## Flujo de Ramas Recomendado

```
main/master (producción)
  ↑
  ├── release/qa-* (QA)
  │     ↑
  │     └── develop (desarrollo)
  │           ↑
  │           └── feature/* (features individuales)
```

### Ramas Principales

#### `main` o `master`
- **Propósito**: Código de producción estable
- **Protección**: 
  - Requiere Pull Request aprobado
  - Requiere que los tests pasen
  - No permite push directo
- **Despliegue**: Automático a entorno `prod` después de merge
- **Validación**: `terraform plan` y `terraform validate` deben pasar

#### `release/qa-*` o `qa/*`
- **Propósito**: Código listo para pruebas de QA
- **Ejemplos**: `release/qa-v1.0.0`, `qa/staging`
- **Despliegue**: Automático a entorno `qa` cuando se crea la rama
- **Validación**: Mismas validaciones que producción

#### `develop`
- **Propósito**: Desarrollo activo e integración continua
- **Despliegue**: Automático a entorno `develop` en cada push
- **Validación**: Validaciones básicas (formato, sintaxis)

#### `feature/*`
- **Propósito**: Desarrollo de features individuales
- **Despliegue**: No se despliega automáticamente
- **Validación**: Validaciones básicas en PR

## Integración con Cloud Build

### Configuración Básica

Crea archivos `cloudbuild.yaml` en la raíz del proyecto o en cada carpeta de entorno:

```yaml
# cloudbuild.yaml (ejemplo para develop)
steps:
  # Validar formato de Terraform
  - name: 'hashicorp/terraform:1.5'
    entrypoint: 'terraform'
    args: ['fmt', '-check']
    dir: 'envs/develop'

  # Validar sintaxis
  - name: 'hashicorp/terraform:1.5'
    entrypoint: 'terraform'
    args: ['validate']
    dir: 'envs/develop'
    env:
      - 'TF_VAR_project_id=${PROJECT_ID}'

  # Plan (no destructivo)
  - name: 'hashicorp/terraform:1.5'
    entrypoint: 'terraform'
    args: ['plan', '-out=tfplan']
    dir: 'envs/develop'
    env:
      - 'TF_VAR_project_id=${PROJECT_ID}'

  # Aplicar (solo si es rama develop/main)
  - name: 'hashicorp/terraform:1.5'
    entrypoint: 'terraform'
    args: ['apply', 'tfplan']
    dir: 'envs/develop'
    env:
      - 'TF_VAR_project_id=${PROJECT_ID}'
    waitFor: ['-']
```

### Triggers de Cloud Build

Configura triggers en Cloud Build Console o vía `gcloud`:

```bash
# Trigger para develop
gcloud builds triggers create github \
  --repo-name=gcp-devfest-quito \
  --repo-owner=tu-usuario \
  --branch-pattern="^develop$" \
  --build-config=cloudbuild-develop.yaml \
  --name=terraform-develop

# Trigger para QA
gcloud builds triggers create github \
  --repo-name=gcp-devfest-quito \
  --repo-owner=tu-usuario \
  --branch-pattern="^release/qa-.*$" \
  --build-config=cloudbuild-qa.yaml \
  --name=terraform-qa

# Trigger para producción
gcloud builds triggers create github \
  --repo-name=gcp-devfest-quito \
  --repo-owner=tu-usuario \
  --branch-pattern="^main$" \
  --build-config=cloudbuild-prod.yaml \
  --name=terraform-prod
```

## Integración con GitHub Actions

### Workflow para Develop

Crea `.github/workflows/terraform-develop.yml`:

```yaml
name: Terraform Develop

on:
  push:
    branches:
      - develop
    paths:
      - 'envs/develop/**'
      - 'modules/**'
  pull_request:
    branches:
      - develop
    paths:
      - 'envs/develop/**'
      - 'modules/**'

jobs:
  terraform:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: envs/develop

    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format Check
        run: terraform fmt -check

      - name: Terraform Validate
        run: terraform validate
        env:
          TF_VAR_project_id: ${{ secrets.GCP_PROJECT_DEV }}

      - name: Terraform Plan
        if: github.event_name == 'push'
        run: terraform plan
        env:
          TF_VAR_project_id: ${{ secrets.GCP_PROJECT_DEV }}
          GOOGLE_CREDENTIALS: ${{ secrets.GCP_SA_KEY }}

      - name: Terraform Apply
        if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
        run: terraform apply -auto-approve
        env:
          TF_VAR_project_id: ${{ secrets.GCP_PROJECT_DEV }}
          GOOGLE_CREDENTIALS: ${{ secrets.GCP_SA_KEY }}
```

### Workflow para QA

Similar al de develop, pero:
- Trigger en ramas `release/qa-*`
- Usa proyecto de QA
- Requiere aprobación manual para `apply`

### Workflow para Producción

Similar, pero:
- Trigger solo en `main` o `master`
- Requiere aprobación manual obligatoria
- Ejecuta `terraform plan` en PR, `apply` solo con aprobación

## Secretos y Variables

### GitHub Secrets

Configura los siguientes secrets en GitHub:

- `GCP_PROJECT_DEV`: ID del proyecto de desarrollo
- `GCP_PROJECT_QA`: ID del proyecto de QA
- `GCP_PROJECT_PROD`: ID del proyecto de producción
- `GCP_SA_KEY`: JSON de la service account con permisos
- `CLOUDFLARE_API_TOKEN`: Token de Cloudflare (opcional)

### Cloud Build Variables

En Cloud Build, configura variables de sustitución:

- `_PROJECT_ID_DEV`
- `_PROJECT_ID_QA`
- `_PROJECT_ID_PROD`
- `_CLOUDFLARE_TOKEN`

## Flujo de Trabajo Recomendado

### 1. Desarrollo de Feature

```bash
# Crear rama de feature
git checkout -b feature/nueva-funcionalidad develop

# Hacer cambios en módulos o entornos
# ...

# Commit y push
git commit -m "feat: agregar nueva funcionalidad"
git push origin feature/nueva-funcionalidad

# Crear Pull Request a develop
```

**CI ejecuta**:
- `terraform fmt -check`
- `terraform validate`
- `terraform plan` (dry-run)

### 2. Merge a Develop

```bash
# Después de aprobar PR, merge a develop
git checkout develop
git merge feature/nueva-funcionalidad
git push origin develop
```

**CI ejecuta**:
- Validaciones
- `terraform plan`
- `terraform apply` (despliega a entorno develop)

### 3. Crear Release para QA

```bash
# Crear rama de release
git checkout -b release/qa-v1.0.0 develop
git push origin release/qa-v1.0.0
```

**CI ejecuta**:
- Validaciones
- `terraform plan` en entorno QA
- `terraform apply` (despliega a QA)

### 4. Merge a Producción

```bash
# Después de validar en QA, merge a main
git checkout main
git merge release/qa-v1.0.0
git push origin main
```

**CI ejecuta**:
- Validaciones estrictas
- `terraform plan` en producción
- **Requiere aprobación manual**
- `terraform apply` (despliega a producción)

## Validaciones Automáticas

### Pre-commit Hooks (Opcional)

Instala `pre-commit` y configura `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
```

### Validaciones en CI

1. **Formato**: `terraform fmt -check`
2. **Sintaxis**: `terraform validate`
3. **Plan**: `terraform plan` (verifica que no haya errores)
4. **Security**: `tfsec` o `checkov` (análisis de seguridad)
5. **Costos**: `infracost` (estimación de costos)

## Manejo de Estado Remoto

### Backend en GCS

Configura backend remoto en `envs/<entorno>/backend.tf`:

```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-devfest"
    prefix = "envs/develop"
  }
}
```

**Ventajas**:
- Estado compartido entre miembros del equipo
- Bloqueo de estado (previene conflictos)
- Historial de cambios
- Backup automático

### Backend en Terraform Cloud

Alternativa más simple para equipos pequeños:

```hcl
terraform {
  cloud {
    organization = "devfest-workshop"
    workspaces {
      name = "develop"
    }
  }
}
```

## Buenas Prácticas

### 1. Nunca aplicar directamente desde local a producción
- Siempre usar CI/CD
- Requerir aprobaciones para producción

### 2. Usar workspaces o backends separados
- Un backend/workspace por entorno
- Evita mezclar estados

### 3. Revisar `terraform plan` antes de aplicar
- En producción, siempre revisar el plan
- Usar `terraform plan -out=tfplan` y luego `apply tfplan`

### 4. Versionar módulos
- Usar tags de Git para versionar módulos
- Referenciar versiones específicas en entornos

### 5. Documentar cambios
- Commits descriptivos
- Changelog para releases importantes

### 6. Monitoreo post-despliegue
- Verificar que los servicios estén funcionando
- Revisar logs y métricas
- Tener rollback plan

## Rollback

En caso de problemas:

```bash
# Opción 1: Revertir commit en Git
git revert <commit-hash>
git push origin main

# Opción 2: Aplicar estado anterior
terraform state pull > current-state.json
# Editar para volver a configuración anterior
terraform state push previous-state.json
terraform apply
```

**Nota**: El rollback manual debe hacerse con cuidado y preferiblemente con supervisión.

## Resumen

- **Develop**: Despliegue automático en cada push
- **QA**: Despliegue automático al crear rama de release
- **Prod**: Despliegue con aprobación manual después de validar en QA
- **Validaciones**: Formato, sintaxis, plan, seguridad, costos
- **Estado**: Backend remoto (GCS o Terraform Cloud)
- **Seguridad**: Secrets gestionados, permisos granulares

