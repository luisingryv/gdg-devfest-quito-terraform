# Inicio Rápido - DevFest GCP Workshop

Esta guía te ayudará a desplegar la infraestructura en menos de 10 minutos.

## Prerrequisitos

1. **Terraform** instalado (>= 1.5)
   ```bash
   terraform version
   ```

2. **Google Cloud SDK** configurado
   ```bash
   gcloud auth application-default login
   ```

3. **Proyectos GCP** creados (o permisos para crearlos)
   - `myapp-dev`
   - `myapp-qa`
   - `myapp-prod`

4. **Token de Cloudflare** (opcional, solo si usas DNS)

## Pasos Rápidos

### 1. Configurar Variables

```bash
cd envs/develop
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores:

```hcl
project_id = "myapp-dev"
region     = "us-central1"
billing_account_id = "01XXXX-XXXXXX-XXXXXX"
db_password = "TuContraseñaSegura123!"
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Ver Plan

```bash
terraform plan
```

Revisa los recursos que se van a crear.

### 4. Aplicar

```bash
terraform apply
```

Confirma con `yes` cuando se solicite.

### 5. Ver Outputs

Después del despliegue, verás las URLs:

```bash
terraform output
```

## Estructura de Comandos por Entorno

### Desarrollo
```bash
cd envs/develop
terraform init
terraform plan
terraform apply
```

### QA
```bash
cd envs/qa
terraform init
terraform plan
terraform apply
```

### Producción
```bash
cd envs/prod
terraform init
terraform plan
terraform apply  # ⚠️ Revisar cuidadosamente antes de aplicar
```

## Variables Importantes

### Obligatorias
- `project_id`: ID del proyecto GCP
- `billing_account_id`: Si creas proyectos nuevos
- `db_password`: Contraseña de la base de datos

### Opcionales pero Recomendadas
- `cloudflare_zone_id`: Para DNS
- `cloudflare_api_token`: Para DNS
- `domain_name`: Dominio base

## Troubleshooting

### Error: "API not enabled"
```bash
# Habilitar APIs manualmente
gcloud services enable run.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable sqladmin.googleapis.com
```

### Error: "Permission denied"
Verifica que tu cuenta tenga los permisos necesarios:
- `roles/owner` o
- `roles/editor` + permisos específicos

### Error: "VPC peering failed"
El peering de VPC puede tardar varios minutos. Espera y vuelve a intentar.

## Limpieza

Para destruir todos los recursos:

```bash
terraform destroy
```

⚠️ **Cuidado**: Esto eliminará todos los recursos, incluyendo la base de datos.

## Siguiente Paso

Una vez desplegada la infraestructura:

1. Construye y despliega tus imágenes de contenedor a Artifact Registry
2. Actualiza las variables `backend_image` y `frontend_image`
3. Aplica nuevamente: `terraform apply`

## Recursos Creados

Por entorno, se crean aproximadamente:
- 1 proyecto GCP (o referencia)
- 1 VPC y subred
- 1 VPC Connector
- 1 instancia Cloud SQL
- 2 servicios Cloud Run (backend + frontend)
- 1 Load Balancer HTTP(S)
- 1 registro DNS en Cloudflare (opcional)

## Costos Estimados

**Desarrollo** (db-f1-micro, 0-1 instancias):
- ~$10-20/mes

**QA** (db-f1-micro, 0-2 instancias):
- ~$15-30/mes

**Producción** (db-g1-small, 1-10 instancias):
- ~$50-200/mes (depende del tráfico)

⚠️ Los costos reales pueden variar. Monitorea en Cloud Console.

