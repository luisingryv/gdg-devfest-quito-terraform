# Arquitectura del Sistema

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                        Cloudflare                            │
│  - DNS Management                                            │
│  - DDoS Protection                                           │
│  - SSL/TLS Termination                                       │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ HTTPS (443)
                        ↓
┌─────────────────────────────────────────────────────────────┐
│          Google Cloud Platform - HTTP(S) Load Balancer       │
│  - Global Load Balancing                                     │
│  - SSL Certificate (Google Managed)                         │
│  - URL Routing:                                              │
│    • / → Frontend                                            │
│    • /api/* → Backend                                        │
└───────────────┬───────────────────────┬─────────────────────┘
                │                       │
                │                       │
        ┌───────▼────────┐    ┌────────▼────────┐
        │  Cloud Run     │    │   Cloud Run     │
        │  (Frontend)    │    │   (Backend)     │
        │  Next.js       │    │   Strapi        │
        └────────────────┘    └────────┬────────┘
                                       │
                                       │ Private IP
                                       │ (VPC Connector)
                                       ↓
                        ┌──────────────────────────────┐
                        │      Cloud SQL               │
                        │   PostgreSQL                 │
                        │   - Private IP               │
                        │   - Automated Backups        │
                        └──────────────────────────────┘
```

## Componentes Principales

### 1. Cloudflare
**Rol**: Capa de seguridad y gestión DNS

- **DNS**: Resolución de nombres de dominio hacia la IP del Load Balancer
- **Protección**: DDoS, WAF, rate limiting
- **SSL/TLS**: Terminación SSL adicional (opcional, el LB también maneja SSL)

**Configuración por entorno**:
- `develop.devfest-demo.mydomain.com`
- `qa.devfest-demo.mydomain.com`
- `prod.devfest-demo.mydomain.com`

### 2. HTTP(S) Load Balancer (GCP)
**Rol**: Balanceador de carga global y enrutamiento

- **Tipo**: Serverless NEG (Network Endpoint Groups) para Cloud Run
- **Certificados**: SSL gestionados por Google (Let's Encrypt)
- **Routing**:
  - Ruta raíz (`/`) y rutas estáticas → Frontend (Next.js)
  - Rutas `/api/*` → Backend (Strapi)
- **Características**:
  - IP estática global
  - Health checks automáticos
  - Logging y monitoreo integrado

### 3. Cloud Run - Frontend (Next.js)
**Rol**: Aplicación web frontend

- **Runtime**: Node.js
- **Escalado**: 0-3 instancias (configurable)
- **Conectividad**: Pública (accesible vía Load Balancer)
- **Variables de entorno**:
  - `NODE_ENV`: `development` | `qa` | `production`
  - `NEXT_PUBLIC_API_URL`: URL del backend
  - `APP_ENV`: Entorno actual

### 4. Cloud Run - Backend (Strapi)
**Rol**: API y CMS backend

- **Runtime**: Node.js
- **Escalado**: 0-3 instancias (configurable)
- **Conectividad**: 
  - Pública vía Load Balancer
  - Privada vía VPC Connector para Cloud SQL
- **Variables de entorno**:
  - `DATABASE_URL`: Connection string a Cloud SQL
  - `NODE_ENV`: Entorno
  - `APP_ENV`: Entorno actual
  - Variables específicas de Strapi

### 5. Cloud SQL (PostgreSQL)
**Rol**: Base de datos persistente

- **Motor**: PostgreSQL 14 o superior
- **Tier**: `db-f1-micro` (desarrollo) o `db-g1-small` (QA/Prod)
- **Conectividad**: 
  - Solo IP privada (sin IP pública)
  - Acceso vía Serverless VPC Access Connector
- **Características**:
  - Backups automáticos
  - High availability (opcional en prod)
  - Encryption at rest

### 6. Networking (VPC)
**Rol**: Red privada y conectividad

- **VPC**: Red por defecto o VPC dedicada
- **Subred**: Regional para el VPC Connector
- **Serverless VPC Access Connector**: 
  - Permite que Cloud Run acceda a Cloud SQL de forma privada
  - Sin exponer la base de datos a internet

## Entornos

### Develop
- **Propósito**: Desarrollo activo y pruebas rápidas
- **Características**:
  - Recursos mínimos (costos bajos)
  - Escalado limitado (0-1 instancias)
  - Base de datos pequeña (`db-f1-micro`)
  - Sin alta disponibilidad

### QA
- **Propósito**: Pruebas de integración y staging
- **Características**:
  - Recursos intermedios
  - Escalado moderado (0-2 instancias)
  - Base de datos pequeña-media
  - Configuración similar a producción

### Prod
- **Propósito**: Tráfico real de usuarios
- **Características**:
  - Recursos adecuados para carga
  - Escalado completo (0-10+ instancias)
  - Base de datos con alta disponibilidad (opcional)
  - Backups automáticos más frecuentes
  - Monitoreo y alertas

## Decisiones de Diseño

### ¿Por qué Cloud Run?
- **Serverless**: Sin gestión de servidores
- **Escalado a cero**: Ahorro de costos cuando no hay tráfico
- **Pago por uso**: Solo pagas por lo que consumes
- **Integración nativa**: Fácil integración con otros servicios GCP
- **Contenedores estándar**: Compatible con Docker

### ¿Por qué Cloud SQL?
- **Gestionado**: Sin preocuparse por mantenimiento, backups, parches
- **PostgreSQL**: Motor robusto y popular para aplicaciones modernas
- **Integración**: Conexión privada fácil con Cloud Run
- **Escalabilidad**: Fácil escalar verticalmente cuando sea necesario

### ¿Por qué HTTP(S) Load Balancer?
- **Global**: Distribución de tráfico a nivel mundial
- **SSL/TLS**: Certificados gestionados automáticamente
- **Routing avanzado**: Enrutamiento basado en paths
- **Health checks**: Monitoreo automático de salud de servicios
- **Logging**: Integración con Cloud Logging

### ¿Por qué Cloudflare?
- **DNS**: Gestión centralizada de DNS
- **Seguridad**: Capa adicional de protección (DDoS, WAF)
- **Performance**: CDN y optimización de contenido
- **Costo**: Plan gratuito suficiente para muchos casos

### ¿Por qué múltiples entornos?
- **Aislamiento**: Cambios en desarrollo no afectan producción
- **Testing**: Validación completa antes de producción
- **Compliance**: Separación de datos sensibles
- **Costos**: Optimización de recursos por entorno

## Flujo de Datos

1. **Usuario** → Solicita `https://develop.devfest-demo.mydomain.com`
2. **Cloudflare** → Resuelve DNS y aplica reglas de seguridad
3. **Load Balancer** → Enruta según path:
   - `/` → Cloud Run Frontend
   - `/api/*` → Cloud Run Backend
4. **Cloud Run Backend** → Si necesita datos, se conecta a Cloud SQL vía VPC Connector
5. **Cloud SQL** → Retorna datos al Backend
6. **Backend** → Retorna respuesta al Load Balancer
7. **Load Balancer** → Retorna al usuario

## Seguridad

- **Red privada**: Cloud SQL solo accesible vía VPC
- **SSL/TLS**: Encriptación en tránsito (Cloudflare + Load Balancer)
- **IAM**: Permisos granulares por servicio
- **Secrets**: Variables sensibles gestionadas de forma segura
- **Labels**: Organización y auditoría de recursos

## Escalabilidad

- **Horizontal**: Cloud Run escala automáticamente según tráfico
- **Vertical**: Cloud SQL puede escalarse aumentando el tier
- **Global**: Load Balancer distribuye tráfico globalmente
- **CDN**: Cloudflare cachea contenido estático

## Monitoreo y Observabilidad

- **Cloud Logging**: Logs centralizados de todos los servicios
- **Cloud Monitoring**: Métricas de rendimiento y salud
- **Health Checks**: Verificación automática de salud de servicios
- **Alertas**: Configurables para métricas críticas

