# Zivlo Backend Server

> **API REST para sincronización de catálogos y menú QR híbrido**

[![License](https://img.shields.io/github/license/ZIVLO-Team/zivlo-backend?style=for-the-badge&color=00D97E)](LICENSE)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

---

## 📖 Descripción

Backend server para soportar la funcionalidad de **Menú QR Híbrido** de Zivlo. Permite a las tiendas publicar sus catálogos en un servidor centralizado para que los clientes puedan descargarlos vía internet cuando el modo WiFi local no esté disponible.

---

## ✨ Características

- 🏪 **Multi-tenant** — Múltiples tiendas en una sola plataforma
- 📱 **API REST** — Endpoints para gestión de catálogos
- 🔄 **Sincronización** — Subida/bajada de catálogos en tiempo real
- 🌐 **Fallback Internet** — Cuando WiFi local falla, usa el servidor central
- 🔐 **API Keys** — Autenticación por tienda con API keys únicas
- 📊 **Versionado** — Control de versiones de catálogos

---

## 🏗️ Arquitectura

```
┌─────────────────┐         ┌─────────────────┐
│  Zivlo App      │         │  Zivlo App      │
│  (Dueño)        │         │  (Cliente)      │
│                 │         │                 │
│  [Subir         │         │  [Descargar     │
│   Catálogo]     │         │   Catálogo]     │
│        │        │         │        │        │
│        ▼        │         │        ▼        │
│  ┌─────────┐    │         │  ┌─────────┐    │
│  │ HTTPS   │    │         │  │ HTTPS   │    │
│  │ API     │    │         │  │ API     │    │
│  └─────────┘    │         │  └─────────┘    │
└─────────────────┘         └─────────────────┘
         │                          │
         │                          │
         ▼                          ▼
┌─────────────────────────────────────────────────┐
│           Zivlo Backend Server                  │
│                                                 │
│  ┌──────────────┐    ┌──────────────┐          │
│  │  FastAPI     │    │  Static      │          │
│  │  Gateway     │    │  File Server │          │
│  └──────────────┘    └──────────────┘          │
│         │                    │                  │
│         ▼                    ▼                  │
│  ┌─────────────────────────────────────┐       │
│  │         PostgreSQL Database         │       │
│  └─────────────────────────────────────┘       │
└─────────────────────────────────────────────────┘
```

---

## 🛠️ Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| **Framework** | FastAPI (Python 3.11+) |
| **Base de Datos** | PostgreSQL 15+ |
| **ORM** | SQLAlchemy 2.0 + Async |
| **Migraciones** | Alembic |
| **Cache** | Redis (opcional) |
| **Deploy** | Docker + Docker Compose |
| **Web Server** | Nginx (reverse proxy) |

---

## 🚀 Inicio Rápido

### Prerrequisitos

- Python 3.11+
- Docker + Docker Compose
- PostgreSQL (o usar Docker)

### Instalación Local

```bash
# Clonar repositorio
git clone https://github.com/ZIVLO-Team/zivlo-backend.git
cd zivlo-backend

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# o
.\venv\Scripts\activate  # Windows

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

## 📡 Endpoints Principales

### Autenticación

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
  "api_key": "zivlo_api_key_xyz789"
}
```

---

### Gestión de Catálogo

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
      "stock": 100
    }
  ]
}
```

---

```http
# Publicar catálogo
POST /api/v1/stores/{store_id}/catalog/{catalog_id}/publish
Authorization: Bearer {api_key}

Response:
{
  "status": "published",
  "public_url": "https://zivlo.app/menu/tienda-la-esquina"
}
```

---

```http
# Obtener catálogo publicado (Cliente)
GET /api/v1/stores/{store_id}/catalog/published

Response:
{
  "store": { ... },
  "catalog": {
    "version": 3,
    "products": [ ... ]
  }
}
```

---

## 📁 Estructura del Proyecto

```
zivlo-backend/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   │
│   ├── api/
│   │   └── v1/
│   │       ├── routes/
│   │       │   ├── auth.py
│   │       │   ├── stores.py
│   │       │   ├── catalog.py
│   │       │   └── qr.py
│   │       └── dependencies.py
│   │
│   ├── models/
│   │   ├── store.py
│   │   ├── catalog.py
│   │   └── product.py
│   │
│   ├── schemas/
│   │   ├── store.py
│   │   ├── catalog.py
│   │   └── product.py
│   │
│   └── services/
│       ├── catalog_service.py
│       ├── store_service.py
│       └── qr_generator.py
│
├── migrations/
├── tests/
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── nginx.conf
│
├── requirements.txt
├── requirements-dev.txt
├── alembic.ini
└── README.md
```

---

## 🧪 Testing

```bash
# Tests unitarios
pytest tests/unit/

# Tests de integración
pytest tests/integration/

# Con coverage
pytest --cov=app tests/
```

---

## 📦 Deploy a Producción

### Docker Compose

```bash
# Construir imágenes
docker-compose build

# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f
```

### Variables de Entorno

```bash
# .env
DATABASE_URL=postgresql+asyncpg://zivlo:password@db:5432/zivlo
SECRET_KEY=tu-secret-key-aqui-cambiar-en-produccion
ENVIRONMENT=production
DEBUG=false
ALLOWED_ORIGINS=https://zivlo.app
```

---

## 📊 Modelo de Datos

### Store (Tienda)

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
```

### Catalog (Catálogo)

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
```

### Product (Producto)

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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 🔐 Seguridad

- **API Keys** — Autenticación por tienda con `zivlo_` prefix
- **Rate Limiting** — 60 requests por minuto por IP
- **CORS** — Orígenes permitidos configurables
- **Validación de Datos** — Pydantic schemas con validación estricta
- **HTTPS** — Requerido en producción (Let's Encrypt)

---

## 📈 Roadmap

### Fase 1: Core API (Semana 1-2)
- [ ] Configurar proyecto FastAPI
- [ ] Modelos SQLAlchemy
- [ ] Endpoints de autenticación
- [ ] Endpoints de catálogo (CRUD)

### Fase 2: Publicación y QR (Semana 2-3)
- [ ] Endpoint de publicación
- [ ] Generador de QR
- [ ] Endpoint público de descarga
- [ ] Static file server

### Fase 3: Deploy y Hardening (Semana 3-4)
- [ ] Dockerización completa
- [ ] Configuración de Nginx
- [ ] SSL/TLS con Let's Encrypt
- [ ] Rate limiting
- [ ] Logging y monitoreo

---

## 📚 Documentación Relacionada

- [Diseño de Arquitectura](https://github.com/ZIVLO-Team/zivlo/blob/main/docs/plans/2026-03-25-zivlo-backend-server-design.md)
- [API Documentation](http://localhost:8000/docs) (local)
- [Zivlo App](https://github.com/ZIVLO-Team/zivlo)

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-feature`)
3. Escribe tests para tu código
4. Haz commit (`git commit -m 'feat: agrega nueva feature'`)
5. Push a la rama (`git push origin feature/nueva-feature`)
6. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está licenciado bajo la licencia **MIT**. Ver [LICENSE](LICENSE) para detalles.

---

<div align="center">

**Zivlo Backend Server**

*Hecho con ❤️ para el comercio real*

[`Cobra en segundos. Sin internet. Sin complicaciones.`](https://github.com/ZIVLO-Team/zivlo)

</div>
