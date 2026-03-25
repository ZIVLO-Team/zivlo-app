# QWEN.md — Configuración del Proyecto Zivlo

## 📋 Descripción del Proyecto

**Zivlo** es una aplicación Flutter de punto de venta (POS) offline-first para pequeños comercios en Latinoamérica. Permite escanear productos, cobrar e imprimir recibos sin necesidad de internet.

**Documentación principal**: `docs/`
- `PRD.md` — Requisitos del producto
- `Stack.md` — Stack tecnológico
- `Design.md` — Especificaciones de diseño por pantalla
- `Styles.md` — Sistema de diseño visual
- `Brand.md` — Identidad de marca
- `Context.md` — Contexto y arquitectura
- `AppFlow.md` — Flujos de la aplicación

---

## 🚫 Regla CRÍTICA: No Compilación Local

**NUNCA ejecutes, compiles o verifiques código Flutter/Dart localmente.**

### Lo que NO debes hacer:
```bash
❌ flutter run
❌ flutter build
❌ flutter pub get
❌ dart run
❌ flutter analyze
❌ flutter test
```

### Lo que SÍ debes hacer:
- ✅ Escribir código puro en local
- ✅ GitHub Actions se encarga de compilar, testear y validar
- ✅ Los workflows verifican errores y crean releases automáticamente
- ✅ El entorno local es SOLO para edición de código

**Razón**: Este proyecto sigue un modelo de desarrollo donde GitHub Actions maneja toda la validación, compilación y publicación. El entorno local es un entorno de edición puro.

---

## 🏗️ Arquitectura: Hexagonal/Clean Architecture

El proyecto usa arquitectura hexagonal con 4 capas:

1. **Domain** (dominio) — Entidades, value objects, puertos (interfaces), reglas de negocio puras
2. **Application** (aplicación) — Casos de uso, orquestación, retorna `Either<Failure, T>`
3. **Infrastructure** (infraestructura) — Adaptadores, implementaciones de puertos, Hive, hardware
4. **Presentation** (presentación) — Flutter, BLoCs, widgets, UI

### Estructura de directorios:
```
lib/
├── core/
│   ├── error/
│   ├── utils/
│   └── theme/
├── features/
│   ├── catalog/
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   ├── cart/
│   ├── scanner/
│   ├── checkout/
│   ├── printer/
│   ├── sales_history/
│   └── settings/
└── injection_container.dart
```

---

## 🛠️ Skills Requeridas

### Skills de Flutter y Arquitectura:
- `architecture-patterns` — Clean/Hexagonal Architecture
- `flutter-best-practices` — Patrones de Flutter
- `bloc-state-management` — Gestión de estado con BLoC
- `mobile-ios-design` / `mobile-android-design` — Diseño móvil

### Skills de Testing y Calidad:
- `test-driven-development` — TDD workflow
- `github-actions-templates` — CI/CD pipelines
- `code-review-excellence` — Revisión de código

### Skills de UI/UX:
- `ui-ux-pro-max` — Diseño de interfaces
- `interaction-design` — Microinteracciones
- `accessibility-compliance` — Accesibilidad WCAG

### Skills de Backend y Datos:
- `postgresql-table-design` — Para futura sincronización
- `data-quality-frameworks` — Validación de datos

---

## 📦 Stack Tecnológico

| Categoría | Tecnología |
|-----------|-----------|
| Framework | Flutter 3.x, Dart 3.x |
| Estado | BLoC (`flutter_bloc`, `bloc`) |
| DB Local | Hive (`hive_flutter`, `hive_generator`) |
| Navegación | GoRouter (`go_router`) |
| Errores | fpdart (`Either<Failure, T>`)) |
| Escáner | `mobile_scanner` |
| Impresora | `bluetooth_thermal` |
| DI | `get_it` |
| Utils | `equatable`, `uuid` |

---

## 🎨 Design System

**Tema**: Oscuro (dark mode único)

### Colores Principales:
- `colorPrimary`: `#1A1A2E` (azul-negro profundo)
- `colorAccent`: `#E94560` (rojo coral vibrante)
- `colorSurface`: `#0F3460` (azul marino)
- `colorBackground`: `#0A0A1A` (fondo base)
- `colorSuccess`: `#00D97E` (verde eléctrico)
- `colorWarning`: `#FFB830` (ámbar)

### Tipografía:
- **Display/Números**: `Space Mono` (Google Fonts)
- **Body/UI**: `DM Sans` (Google Fonts)

Ver `docs/Styles.md` para especificación completa.

---

## 🔄 Workflow de Desarrollo

1. **Escribir código** en local (sin compilar)
2. **Commit** de cambios
3. **GitHub Actions** automáticamente:
   - Ejecuta `flutter analyze`
   - Corre tests con `flutter test`
   - Compila APK con `flutter build apk --release`
   - Crea release en GitHub si es tag
4. **Verificar** resultados en Actions tab

---

## 📝 Convenciones de Código

### Naming:
- Entidades: `Product`, `CartItem`, `Sale`
- Value Objects: `Barcode`, `Money`, `Quantity`
- Puertos: `IProductRepository`, `IPrinterPort`, `IScannerPort`
- Casos de uso: `GetProductByBarcode`, `CreateSale`, `ConnectPrinter`
- BLoCs: `CatalogBloc`, `CartBloc`, `CheckoutBloc`
- Widgets: `ProductCard`, `CartItemTile`, `PaymentSuccessPage`

### Errores:
- Usar `Either<Failure, T>` de fpdart
- Nunca lanzar excepciones en el dominio
- Failors tipados: `ProductNotFound`, `PrinterConnectionFailed`

### Testing:
- Tests unitarios para dominio y casos de uso
- Mocks con `mocktail` para puertos
- BLoC tests con `bloc_test`

---

## 🚀 Comandos Útiles (Solo GitHub Actions)

Estos comandos SOLO se ejecutan en GitHub Actions:

```bash
# Análisis estático
flutter analyze

# Tests
flutter test

# Build de release
flutter build apk --release

# Build de app bundle (Play Store)
flutter build appbundle --release
```

---

## 📚 Recursos

- **Documentación**: `docs/` folder
- **Brand**: `docs/Brand.md`
- **Flujos**: `docs/AppFlow.md`
- **Design**: `docs/Design.md`
- **Stack**: `docs/Stack.md`

---

## ⚠️ Consideraciones de Seguridad

- **Sin telemetría**: No hay envío de datos a servidores externos
- **Datos locales**: Todo se almacena en Hive localmente
- **Permisos mínimos**: Solo `CAMERA` y `BLUETOOTH`
- **Sin internet**: La app funciona 100% offline

---

## 🎯 Métricas de Éxito

- Tiempo de transacción completa: < 20 segundos
- Tasa de error en escaneo: < 2%
- Conexión BT: < 3 segundos
- Retención a 30 días: 70%

---

## 📞 Contacto

Repositorio: `mowgliph/zivlo`
Documentación: `docs/`
