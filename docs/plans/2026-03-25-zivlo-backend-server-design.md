# Zivlo Backend Server — Diseño de Arquitectura

**Fecha:** 25 de marzo de 2026  
**Estado:** Aprobado para implementación (Repositorio Separado)  
**Autor:** Zivlo Development Team

---

## 1. Visión General

Servidor backend para soportar la funcionalidad de **Menú QR Híbrido** de Zivlo. Permite a las tiendas publicar sus catálogos en un servidor centralizado para que los clientes puedan descargarlos vía internet cuando el modo WiFi local no esté disponible.

---

## 2. Problema que Resuelve

| Problema | Solución |
|----------|----------|
| Tiendas sin WiFi o con WiFi inestable | Catálogo alojado en servidor central |
| Clientes no pueden acceder al menú sin internet local | Fallback a internet desde cualquier lugar |
| Dueños necesitan sincronizar catálogo en la nube | API REST para subir/actualizar catálogo |
| Múltiples tiendas en una sola plataforma | Multi-tenant con identificación por `storeId` |

---

## 3. Arquitectura del Sistema

```
┌────────────────────────────────────────────────────────────────┐
│                   Zivlo Backend Ecosystem                      │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌────────────────┐          ┌────────────────┐               │
│  │  Zivlo App    │          │  Zivlo App     │               │
│  │  (Dueño)      │          │  (Cliente)     │               │
│  │               │          │                │               │
│  │  [Subir       │          │  [Descargar    │               │
│  │   Catálogo]   │          │   Catálogo]    │               │
│  │       │       │          │       │        │               │
│  │       ▼       │          │       ▼        │               │
│  │  ┌─────────┐  │          │  ┌─────────┐  │               │
│  │  │ HTTPS   │  │          │  │ HTTPS   │  │               │
│  │  │ API     │  │          │  │ API     │  │               │
│  │  └─────────┘  │          │  └─────────┘  │               │
│  └────────────────┘          └────────────────┘               │
│         │                          │                          │
│         │                          │                          │
│         ▼                          ▼                          │
│  ┌─────────────────────────────────────────────────┐         │
│  │           Zivlo Backend Server                  │         │
│  │                                                 │         │
│  │  ┌──────────────┐    ┌──────────────┐          │         │
│  │  │  API         │    │  Static      │          │         │
│  │  │  Gateway     │    │  File Server │          │         │
│  │  │  (FastAPI)   │    │  (JSON)      │          │         │
│  │  └──────────────┘    └──────────────┘          │         │
│  │         │                    │                  │         │
│  │         ▼                    ▼                  │         │
│  │  ┌─────────────────────────────────────┐       │         │
│  │  │         PostgreSQL Database         │       │         │
│  │  │                                     │       │         │
│  │  │  - stores                           │       │         │
│  │  │  - catalogs                         │       │         │
│  │  │  - products                         │       │         │
│  │  └─────────────────────────────────────┘       │         │
│  └─────────────────────────────────────────────────┘         │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## 4. Stack Tecnológico Recomendado

| Capa | Tecnología | Justificación |
|------|------------|---------------|
| **Framework** | FastAPI (Python) | Rápido, async, auto-documentación OpenAPI |
| **Base de Datos** | PostgreSQL | Multi-tenant, JSONB para catálogos |
| **ORM** | SQLAlchemy 2.0 + Async | Type hints, async support |
| **Cache** | Redis (opcional) | Cache de catálogos frecuentes |
| **Static Files** | Nginx o S3 | Servir JSON de catálogos |
| **Deploy** | Docker + Docker Compose | Contenedores reproducibles |
| **CI/CD** | GitHub Actions | Build y deploy automático |

---

## 5. Modelo de Datos

### 5.1 Store (Tienda)

```sql
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    owner_device_id VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    logo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_stores_slug ON stores(slug);
CREATE INDEX idx_stores_owner_device_id ON stores(owner_device_id);
```

### 5.2 Catalog (Catálogo)

```sql
CREATE TABLE catalogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    version INTEGER NOT NULL DEFAULT 1,
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(store_id, version)
);

CREATE INDEX idx_catalogs_store_id ON catalogs(store_id);
CREATE INDEX idx_catalogs_published ON catalogs(is_published);
```

### 5.3 Product (Producto)

```sql
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    catalog_id UUID REFERENCES catalogs(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    barcode VARCHAR(50),
    category VARCHAR(50),
    stock INTEGER DEFAULT 0,
    description TEXT,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT positive_price CHECK (price >= 0),
    CONSTRAINT non_negative_stock CHECK (stock >= 0)
);

CREATE INDEX idx_products_catalog_id ON products(catalog_id);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_category ON products(category);
```

---

## 6. API Endpoints

### 6.1 Autenticación (Device-Based)

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "device_id": "abc123-android-id",
  "store_name": "Tienda La Esquina",
  "store_slug": "tienda-la-esquina"
}

Response:
{
  "store_id": "uuid-del-tienda",
  "api_key": "zivlo_api_key_xyz789",
  "message": "Tienda registrada exitosamente"
}
```

---

### 6.2 Gestión de Catálogo

```http
# Subir catálogo completo
PUT /api/v1/stores/{store_id}/catalog
Authorization: Bearer {api_key}
Content-Type: application/json

{
  "products": [
    {
      "name": "Arroz 1kg",
      "price": 1.50,
      "barcode": "123456789",
      "category": "Granos",
      "stock": 100,
      "description": "Arroz blanco premium",
      "is_available": true
    },
    {
      "name": "Leche 1L",
      "price": 2.00,
      "barcode": "987654321",
      "category": "Lácteos",
      "stock": 50,
      "is_available": true
    }
  ]
}

Response:
{
  "catalog_id": "uuid-catalog",
  "version": 1,
  "products_count": 2,
  "status": "draft"
}
```

---

```http
# Publicar catálogo
POST /api/v1/stores/{store_id}/catalog/{catalog_id}/publish
Authorization: Bearer {api_key}

Response:
{
  "catalog_id": "uuid-catalog",
  "version": 1,
  "status": "published",
  "published_at": "2026-03-25T12:00:00Z",
  "public_url": "https://zivlo.app/menu/tienda-la-esquina"
}
```

---

```http
# Obtener catálogo publicado (Cliente)
GET /api/v1/stores/{store_id}/catalog/published

Response:
{
  "store": {
    "id": "uuid-store",
    "name": "Tienda La Esquina",
    "slug": "tienda-la-esquina",
    "logo_url": "https://cdn.zivlo.app/logos/store-uuid.png"
  },
  "catalog": {
    "version": 3,
    "published_at": "2026-03-25T12:00:00Z",
    "products": [
      {
        "id": "uuid-product",
        "name": "Arroz 1kg",
        "price": 1.50,
        "barcode": "123456789",
        "category": "Granos",
        "stock": 100,
        "is_available": true
      }
    ]
  }
}
```

---

### 6.3 Generación de QR

```http
# Generar QR para tienda
GET /api/v1/stores/{store_id}/qr
Authorization: Bearer {api_key}

Response:
{
  "qr_code_base64": "iVBORw0KGgoAAAANSUhEUgAA...",
  "qr_payload": {
    "storeId": "tienda-la-esquina",
    "wifiSSID": "Zivlo_TiendaLaEsquina",
    "wifiIP": "192.168.4.1",
    "fallbackURL": "https://zivlo.app/menu/tienda-la-esquina"
  },
  "download_url": "https://zivlo.app/qr/tienda-la-esquina.png"
}
```

---

## 7. Estructura del Catálogo JSON

### 7.1 Formato Público (Cliente)

```json
{
  "$schema": "https://zivlo.app/schemas/catalog-v1.json",
  "version": "1.0",
  "generated_at": "2026-03-25T12:00:00Z",
  "store": {
    "id": "uuid-store",
    "name": "Tienda La Esquina",
    "slug": "tienda-la-esquina",
    "description": "Tu tienda de confianza desde 1990",
    "logo_url": "https://cdn.zivlo.app/logos/store-uuid.png",
    "contact": {
      "phone": "+53 5555-5555",
      "address": "Calle 10 #123 e/ 1ra y 3ra"
    }
  },
  "catalog": {
    "version": 3,
    "published_at": "2026-03-25T12:00:00Z",
    "currency": "CUP",
    "categories": [
      {
        "id": "granos",
        "name": "Granos",
        "product_count": 15
      },
      {
        "id": "lacteos",
        "name": "Lácteos",
        "product_count": 8
      }
    ],
    "products": [
      {
        "id": "uuid-product-1",
        "name": "Arroz 1kg",
        "price": 1.50,
        "barcode": "123456789",
        "category_id": "granos",
        "stock": 100,
        "description": "Arroz blanco premium",
        "image_url": "https://cdn.zivlo.app/products/arroz-1kg.jpg",
        "is_available": true
      }
    ]
  },
  "metadata": {
    "total_products": 23,
    "last_updated": "2026-03-25T12:00:00Z",
    "cache_ttl": 3600
  }
}
```

---

## 8. Flujo de Sincronización

### 8.1 Dueño Sube Catálogo

```
┌─────────┐     ┌─────────────┐     ┌──────────────┐     ┌──────────┐
│  Zivlo  │     │  Zivlo      │     │  Backend     │     │  PostgreSQL │
│  App    │     │  App        │     │  Server      │     │  Database   │
│  (Dueño)│     │             │     │              │     │             │
└────┬────┘     └──────┬──────┘     └──────┬───────┘     └────┬─────┘
     │                 │                   │                   │
     │ Editar catálogo │                   │                   │
     │ en la app       │                   │                   │
     │────────────────▶│                   │                   │
     │                 │                   │                   │
     │                 │ PUT /catalog      │                   │
     │                 │ (productos)       │                   │
     │                 │──────────────────▶│                   │
     │                 │                   │                   │
     │                 │                   │ Guardar en DB     │
     │                 │                   │ (versión draft)   │
     │                 │                   │──────────────────▶│
     │                 │                   │                   │
     │                 │◀──────────────────│                   │
     │                 │ {"catalog_id":    │                   │
     │                 │  "uuid",          │                   │
     │                 │  "status":        │                   │
     │                 │  "draft"}         │                   │
     │                 │                   │                   │
     │◀────────────────│                   │                   │
     │ "Catálogo       │                   │                   │
     │  guardado"      │                   │                   │
     │                 │                   │                   │
     │                 │ Publicar catálogo │                   │
     │                 │──────────────────▶│                   │
     │                 │                   │                   │
     │                 │                   │ Actualizar        │
     │                 │                   │ is_published=true │
     │                 │                   │──────────────────▶│
     │                 │                   │                   │
     │                 │◀──────────────────│                   │
     │                 │ {"status":        │                   │
     │                 │  "published",     │                   │
     │                 │  "public_url":    │                   │
     │                 │  "..."}           │                   │
     │                 │                   │                   │
     │◀────────────────│                   │                   │
     │ "✅ Publicado   │                   │                   │
     │  https://..."   │                   │                   │
     │                 │                   │                   │
```

---

### 8.2 Cliente Descarga Catálogo

```
┌─────────┐     ┌─────────────┐     ┌──────────────┐     ┌──────────┐
│  Zivlo  │     │  Zivlo      │     │  Backend     │     │  PostgreSQL │
│  App    │     │  App        │     │  Server      │     │  Database   │
│(Cliente)│     │             │     │              │     │             │
└────┬────┘     └──────┬──────┘     └──────┬───────┘     └────┬─────┘
     │                 │                   │                   │
     │ Escanear QR     │                   │                   │
     │ (tienda QR)     │                   │                   │
     │────────────────▶│                   │                   │
     │                 │                   │                   │
     │                 │ Intentar WiFi     │                   │
     │                 │ Local primero     │                   │
     │                 │──────────────────▶│                   │
     │                 │ (192.168.4.1)     │                   │
     │                 │                   │                   │
     │                 │ ❌ WiFi falla     │                   │
     │                 │ (no hay hotspot)  │                   │
     │                 │                   │                   │
     │                 │ Usar fallback     │                   │
     │                 │ Internet          │                   │
     │                 │──────────────────▶│                   │
     │                 │ GET /menu/        │                   │
     │                 │ tienda-la-esquina │                   │
     │                 │──────────────────▶│                   │
     │                 │                   │                   │
     │                 │                   │ Buscar catálogo   │
     │                 │                   │ publicado en DB   │
     │                 │                   │──────────────────▶│
     │                 │                   │                   │
     │                 │◀──────────────────│                   │
     │                 │ {catalog JSON}    │                   │
     │                 │                   │                   │
     │                 │ Guardar en Hive   │                   │
     │                 │ (offline)         │                   │
     │                 │──────────────────▶│                   │
     │                 │                   │                   │
     │◀────────────────│                   │                   │
     │ "✅ Catálogo    │                   │                   │
     │  descargado"    │                   │                   │
     │                 │                   │                   │
```

---

## 9. Estructura de Directorios del Proyecto

```
zivlo-backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app factory
│   ├── config.py               # Configuración (env vars)
│   ├── database.py             # Conexión PostgreSQL async
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── routes/
│   │   │   │   ├── auth.py
│   │   │   │   ├── stores.py
│   │   │   │   ├── catalog.py
│   │   │   │   └── qr.py
│   │   │   └── dependencies.py
│   │   └── deps.py
│   │
│   ├── core/
│   │   ├── __init__.py
│   │   ├── security.py         # API key generation
│   │   └── exceptions.py
│   │
│   ├── models/
│   │   ├── __init__.py
│   │   ├── store.py
│   │   ├── catalog.py
│   │   └── product.py
│   │
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── store.py
│   │   ├── catalog.py
│   │   └── product.py
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── catalog_service.py
│   │   ├── store_service.py
│   │   └── qr_generator.py
│   │
│   └── utils/
│       ├── __init__.py
│       └── slugify.py
│
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_auth.py
│   ├── test_catalog.py
│   └── test_stores.py
│
├── migrations/
│   ├── versions/
│   └── env.py
│
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── nginx.conf
│
├── requirements.txt
├── requirements-dev.txt
├── alembic.ini
├── .env.example
└── README.md
```

---

## 10. Configuración de Docker

### 10.1 Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar aplicación
COPY . .

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

### 10.2 Docker Compose

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://zivlo:password@db:5432/zivlo
      - SECRET_KEY=tu-secret-key-aqui
      - ENVIRONMENT=production
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=zivlo
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=zivlo
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx.conf:/etc/nginx/nginx.conf
      - ./static:/var/www/static
    depends_on:
      - api
    restart: unless-stopped

volumes:
  postgres_data:
```

---

## 11. Seguridad

### 11.1 Autenticación por API Key

```python
# app/core/security.py
import secrets
from datetime import datetime, timedelta

def generate_api_key() -> str:
    """Generar API key única para cada tienda."""
    return f"zivlo_{secrets.token_urlsafe(32)}"

def verify_api_key(api_key: str) -> bool:
    """Verificar formato de API key."""
    return api_key.startswith("zivlo_") and len(api_key) == 39
```

---

### 11.2 Rate Limiting

```python
# app/api/v1/dependencies.py
from fastapi import Request, HTTPException
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

async def rate_limit_handler(request: Request, exc: Exception):
    raise HTTPException(status_code=429, detail="Demasiadas solicitudes")
```

---

### 11.3 Validación de Datos

```python
# app/schemas/product.py
from pydantic import BaseModel, Field, validator

class ProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    price: float = Field(..., ge=0)
    barcode: Optional[str] = Field(None, max_length=50)
    category: Optional[str] = Field(None, max_length=50)
    stock: int = Field(default=0, ge=0)
    description: Optional[str] = Field(None, max_length=500)
    is_available: bool = True
    
    @validator('name')
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError('Nombre no puede estar vacío')
        return v.strip()
```

---

## 12. Deploy y CI/CD

### 12.1 GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: password
          POSTGRES_DB: zivlo_test
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: pip install -r requirements-dev.txt
      
      - name: Run tests
        run: pytest -v
      
      - name: Run linter
        run: ruff check app/

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to server
        run: |
          # SSH deploy script
          ssh ${{ secrets.DEPLOY_USER }}@${{ secrets.DEPLOY_HOST }} << 'EOF'
            cd /opt/zivlo-backend
            git pull
            docker-compose up -d --build
          EOF
```

---

## 13. Variables de Entorno

```bash
# .env.example

# Database
DATABASE_URL=postgresql+asyncpg://zivlo:password@localhost:5432/zivlo

# Security
SECRET_KEY=tu-secret-key-aqui-cambiar-en-produccion
API_KEY_PREFIX=zivlo_

# Application
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=INFO

# CORS
ALLOWED_ORIGINS=https://zivlo.app,https://www.zivlo.app

# Rate Limiting
RATE_LIMIT_PER_MINUTE=60
```

---

## 14. Roadmap de Implementación

### Fase 1: Core API (Semana 1-2)
- [ ] Configurar proyecto FastAPI
- [ ] Modelos SQLAlchemy (Store, Catalog, Product)
- [ ] Endpoints de autenticación (registro de tiendas)
- [ ] Endpoints de catálogo (CRUD)
- [ ] Tests unitarios

### Fase 2: Publicación y QR (Semana 2-3)
- [ ] Endpoint de publicación de catálogo
- [ ] Generador de QR (librería `qrcode`)
- [ ] Endpoint público de descarga de catálogo
- [ ] Static file server para JSON
- [ ] Tests de integración

### Fase 3: Deploy y Hardening (Semana 3-4)
- [ ] Dockerización completa
- [ ] Configuración de Nginx
- [ ] SSL/TLS con Let's Encrypt
- [ ] Rate limiting
- [ ] Logging y monitoreo
- [ ] Deploy a producción

---

## 15. Métricas de Éxito

| Métrica | Objetivo |
|---------|----------|
| Tiempo de respuesta API (p95) | < 200ms |
| Tiempo de descarga de catálogo | < 2 segundos |
| Disponibilidad (uptime) | 99.9% |
| Catálogos publicados activos | 1000+ en primer año |

---

## 16. Consideraciones de Costos

### Infraestructura Mínima (DigitalOcean / Linode)

| Recurso | Costo Mensual |
|---------|---------------|
| VPS 2GB RAM / 1 CPU | $12/mes |
| PostgreSQL gestionado | $15/mes (opcional) |
| Dominio + SSL | $10/año |
| **Total estimado** | **~$27/mes** |

### Escalamiento

| Usuarios | Infraestructura | Costo |
|----------|-----------------|-------|
| 0-100 tiendas | VPS básico | $12/mes |
| 100-1000 tiendas | VPS 4GB + DB gestionado | $50/mes |
| 1000+ tiendas | Load balancer + múltiples workers | $150+/mes |

---

## 17. Apéndice: Comandos de Inicio Rápido

```bash
# Clonar repositorio
git clone https://github.com/mowgliph/zivlo-backend.git
cd zivlo-backend

# Crear entorno virtual
python -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Copiar variables de entorno
cp .env.example .env

# Iniciar base de datos (Docker)
docker-compose up -d db

# Correr migraciones
alembic upgrade head

# Iniciar servidor de desarrollo
uvicorn app.main:app --reload

# Acceder a documentación
# http://localhost:8000/docs
```

---

## 18. Referencias

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy 2.0](https://docs.sqlalchemy.org/en/20/)
- [AsyncPG](https://magicstack.github.io/asyncpg/)
- [Alembic Migrations](https://alembic.sqlalchemy.org/)
- [Docker Compose](https://docs.docker.com/compose/)

---

<div align="center">

**Zivlo Backend Server — v1.0**

*Documento aprobado para implementación en repositorio separado*

</div>
