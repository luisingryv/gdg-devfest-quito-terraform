# DevFest GCP Workshop - Infraestructura como Código con Terraform

## 🎯 Objetivo del Proyecto

Este proyecto es una demostración práctica de **Infraestructura como Código (IaC)** usando Terraform para desplegar una aplicación completa en Google Cloud Platform. Está diseñado para ser presentado en un workshop de DevFest de 45 minutos.

La aplicación incluye:
- **Backend**: Strapi corriendo en Cloud Run
- **Frontend**: Next.js corriendo en Cloud Run
- **Base de datos**: Cloud SQL (PostgreSQL)
- **Balanceadores de carga**: HTTP(S) Load Balancer delante de los servicios Cloud Run
- **DNS y seguridad**: Integración con Cloudflare

Todo desplegado en **3 entornos separados** (develop, qa, prod), cada uno en su propio proyecto de GCP.

## 📋 Arquitectura General

```
Cloudflare DNS
    ↓
HTTP(S) Load Balancer (GCP)
    ↓
    ├──→ Cloud Run (Frontend - Next.js)
    └──→ Cloud Run (Backend - Strapi)
            ↓
        Cloud SQL (PostgreSQL)
```

Cada entorno tiene su propia infraestructura replicada, permitiendo desarrollo, pruebas y producción completamente aislados.

## 📁 Estructura del Proyecto

```
repo-root/
├── README.md
├── docs/
│   ├── arquitectura.md
│   └── ci-cd-flujos-rama.md
├── modules/
│   ├── project/          # Gestión de proyectos GCP
│   ├── networking/       # VPC, subredes, VPC Connector
│   ├── cloud_sql/        # Instancias de Cloud SQL
│   ├── cloud_run_service/ # Servicios Cloud Run (reutilizable)
│   ├── http_lb_serverless/ # HTTP(S) Load Balancer
│   └── cloudflare_dns/   # Registros DNS en Cloudflare
└── envs/
    ├── develop/          # Entorno de desarrollo
    ├── qa/               # Entorno de QA
    └── prod/             # Entorno de producción
```

## 🧩 Módulos

### `modules/project`
Gestiona la creación y configuración de proyectos GCP, incluyendo la activación de APIs necesarias.

### `modules/networking`
Configura la red VPC, subredes y el Serverless VPC Access Connector para conectar Cloud Run con Cloud SQL de forma privada.

### `modules/cloud_sql`
Crea instancias de Cloud SQL (PostgreSQL) con configuración privada y acceso seguro.

### `modules/cloud_run_service`
Módulo genérico para crear servicios Cloud Run. Se instancia dos veces por entorno (backend y frontend).

### `modules/http_lb_serverless`
Configura un HTTP(S) Load Balancer con certificados SSL gestionados por Google, routing inteligente y serverless NEGs.

### `modules/cloudflare_dns`
Gestiona registros DNS en Cloudflare, apuntando al Load Balancer de GCP.

## 🚀 Cómo Ejecutar

### Requisitos Previos

1. **Terraform instalado** (>= 1.5)
   ```bash
   terraform version
   ```

2. **Google Cloud SDK configurado**
   ```bash
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Proyectos GCP creados** (opcional, el módulo puede crearlos)
   - `myapp-dev` (o el nombre que prefieras)
   - `myapp-qa`
   - `myapp-prod`

4. **Token de Cloudflare** (opcional, solo si vas a usar DNS)
   - Obtén un token con permisos de edición DNS en tu zona
   - Puedes proporcionarlo en `terraform.tfvars` como `cloudflare_api_token`
   - O como variable de entorno: `export CLOUDFLARE_API_TOKEN="tu-token"`
   - Si no proporcionas token, el módulo de Cloudflare DNS no se creará

### Pasos para Desplegar un Entorno

#### 1. Configurar variables

Edita `envs/<entorno>/variables.tf` o crea un archivo `terraform.tfvars`:

```hcl
project_id = "myapp-dev"
region     = "us-central1"
billing_account_id = "01XXXX-XXXXXX-XXXXXX"

# Cloudflare (opcional)
cloudflare_api_token = "your-token"
cloudflare_zone_id   = "your-zone-id"

# Base de datos
db_user     = "strapi_user"
db_password = "your-secure-password"
db_name     = "strapi_db"
```

#### 2. Inicializar Terraform

```bash
cd envs/develop
terraform init
```

#### 3. Planificar cambios

```bash
terraform plan
```

#### 4. Aplicar infraestructura

```bash
terraform apply
```

### Orden Recomendado de Despliegue

Aunque Terraform maneja las dependencias automáticamente, el orden lógico es:

1. **Proyecto** → Crea/verifica el proyecto GCP
2. **Networking** → Configura VPC y conectores
3. **Cloud SQL** → Crea la base de datos
4. **Cloud Run** → Despliega backend y frontend
5. **Load Balancer** → Configura el balanceador
6. **Cloudflare DNS** → Apunta el dominio al LB

En la práctica, ejecutar `terraform apply` una vez debería crear todo en el orden correcto gracias a las dependencias declaradas.

## 🔐 Variables Importantes

### Variables Globales (por entorno)

- `project_id`: ID del proyecto GCP
- `region`: Región donde se desplegará todo (ej: `us-central1`)
- `environment`: `develop`, `qa` o `prod`
- `billing_account_id`: ID de la cuenta de facturación

### Variables de Base de Datos

- `db_name`: Nombre de la base de datos
- `db_user`: Usuario de la base de datos
- `db_password`: Contraseña (usar secretos, no hardcodear)

### Variables de Cloudflare

- `cloudflare_api_token`: Token de API de Cloudflare
- `cloudflare_zone_id`: ID de la zona DNS
- `domain_name`: Dominio base (ej: `devfest-demo.mydomain.com`)

## 🏷️ Etiquetas (Labels)

Todos los recursos usan las siguientes etiquetas estándar:

- `environment`: `develop` | `qa` | `prod`
- `project`: `devfest-gcp-workshop`
- `owner`: Configurable (ej: `luis-ramirez`)
- `managed_by`: `terraform`
- `provisioned_by`: `cursor`
- `cost_center`: Opcional

## 📚 Documentación Adicional

- [Arquitectura Detallada](docs/arquitectura.md)
- [Flujos CI/CD y Ramas](docs/ci-cd-flujos-rama.md)

## ⚠️ Notas Importantes

1. **Costos**: Este proyecto crea recursos reales en GCP que generan costos. Recuerda destruir los recursos cuando termines:
   ```bash
   terraform destroy
   ```

2. **Backend Remoto**: El proyecto incluye un ejemplo comentado de backend remoto en GCS. Se recomienda usarlo en producción.

3. **Secretos**: Nunca commitees contraseñas o tokens en el repositorio. Usa:
   - Variables de entorno
   - Google Secret Manager
   - Terraform Cloud Variables

4. **Estado de Terraform**: En producción, usa un backend remoto (GCS, S3, Terraform Cloud) para compartir el estado entre miembros del equipo.

## 🤝 Contribuciones

Este es un proyecto de demostración para workshops. Siéntete libre de adaptarlo a tus necesidades.

## 📄 Licencia

Este proyecto es de código abierto y está disponible para uso educativo y de demostración.

