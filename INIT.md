# Inicialización del Repositorio Zivlo

## Pasos para inicializar el repositorio en GitHub

### 1. Crear repositorio en GitHub

```bash
# Ir a github.com y crear nuevo repositorio
Nombre: zivlo
Descripción: Punto de venta offline-first para pequeños comercios en Latinoamérica
Visibilidad: Privado (o Público si se desea open source)
NO inicializar con README, .gitignore, o license (ya los tenemos)
```

### 2. Inicializar git localmente

```bash
cd /home/mowgli/zivlo

# Inicializar repositorio git
git init

# Agregar todos los archivos
git add .

# Crear commit inicial
git commit -m "feat: initial project structure with hexagonal architecture

- Clean/Hexagonal Architecture con 4 capas (domain, application, infrastructure, presentation)
- Core layer: error handling, theme, constants
- Catalog feature: entities, value objects, use cases, BLoC
- Design system con colores, tipografía y spacing
- GitHub Actions workflows para CI/CD y releases automáticos
- Documentación completa: PRD, Stack, Design, Styles, Brand, Context, AppFlow
- QWEN.md y AGENTS.md con reglas de no-compilación local
- README, LICENSE, SECURITY, CONTRIBUTING, CHANGELOG

Tech stack:
- Flutter 3.x, Dart 3.x
- BLoC para state management
- Hive para base de datos local
- fpdart para manejo funcional de errores
- GoRouter para navegación
- GetIt para inyección de dependencias

CI/CD:
- GitHub Actions para análisis, tests y build automático
- Release automático de APK al crear tag
- No compilación local - solo código puro"

# Agregar remote de GitHub
git remote add origin https://github.com/mowgliph/zivlo.git

# Renombrar branch a main
git branch -M main

# Push a GitHub
git push -u origin main
```

### 3. Crear primer tag de release (opcional)

```bash
# Crear tag de versión
git tag v1.0.0

# Push del tag (trigger del release workflow)
git push origin v1.0.0
```

### 4. Verificar GitHub Actions

Después del push:
1. Ir a https://github.com/mowgliph/zivlo/actions
2. Verificar que el workflow "CI/CD" se esté ejecutando
3. Esperar a que todos los jobs pasen (analyze, test, build-apk)
4. Si se creó un tag, verificar que el workflow "Release" cree el release

### 5. Configurar secrets (si es necesario)

Para funcionalidades futuras:
- `CODECOV_TOKEN` - Para Codecov coverage reporting
- Otros secrets según se necesiten

---

## Estructura del Proyecto

```
zivlo/
├── .github/
│   └── workflows/
│       ├── ci.yml          # CI/CD: analyze, test, build
│       └── release.yml     # Release automático con APK
├── .qwen/
│   ├── QWEN.md            # Configuración del proyecto
│   └── AGENTS.md          # Guía para agentes (NO COMPILAR LOCAL)
├── docs/
│   ├── PRD.md             # Product Requirements Document
│   ├── Stack.md           # Stack tecnológico
│   ├── Design.md          # Diseño por pantalla
│   ├── Styles.md          # Design system
│   ├── Brand.md           # Identidad de marca
│   ├── Context.md         # Arquitectura y contexto
│   ├── AppFlow.md         # Flujos de usuario
│   └── assets/            # Assets de documentación
├── lib/
│   ├── core/
│   │   ├── error/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── utils/
│   │   │   └── constants.dart
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── features/
│   │   └── catalog/
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── product.dart
│   │       │   ├── repositories/
│   │       │   │   └── product_repository.dart
│   │       │   └── value_objects/
│   │       │       ├── barcode.dart
│   │       │       ├── product_name.dart
│   │       │       ├── money.dart
│   │       │       └── quantity.dart
│   │       ├── application/
│   │       │   ├── usecases/
│   │       │   │   └── product_usecases.dart
│   │       │   └── dtos/
│   │       │       └── product_dto.dart
│   │       ├── infrastructure/
│   │       │   ├── repositories/
│   │       │   │   └── hive_product_repository.dart
│   │       │   └── models/
│   │       │       └── product_hive_model.dart
│   │       └── presentation/
│   │           ├── bloc/
│   │           │   ├── catalog_event.dart
│   │           │   ├── catalog_state.dart
│   │           │   └── catalog_bloc.dart
│   │           └── pages/
│   │           └── widgets/
│   │   [cart/ scanner/ checkout/ printer/ sales_history/ settings/]
│   ├── injection_container.dart
│   └── main.dart
├── test/
│   ├── unit/              # Tests unitarios de dominio
│   ├── bloc/              # Tests de BLoC
│   └── widget/            # Tests de widgets
├── assets/
│   ├── images/
│   └── fonts/
├── .gitignore
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── LICENSE
├── SECURITY.md
├── CONTRIBUTING.md
└── CHANGELOG.md
```

---

## Reglas de Desarrollo

### ⚠️ NUNCA ejecutar en local:

```bash
❌ flutter run
❌ flutter build
❌ flutter pub get
❌ flutter analyze
❌ flutter test
❌ dart run
```

### ✅ Flujo correcto:

1. Escribir código en local
2. Hacer commit
3. Push a GitHub
4. GitHub Actions compila y valida
5. Verificar resultados en Actions tab

---

## Próximos Pasos

### Features a implementar:

1. **Cart Feature** - Carrito de compras
2. **Scanner Feature** - Escaneo de código de barras
3. **Checkout Feature** - Proceso de pago
4. **Printer Feature** - Impresión Bluetooth
5. **Sales History Feature** - Historial de ventas
6. **Settings Feature** - Configuración del negocio

### Para cada feature:

1. Crear estructura hexagonal completa
2. Implementar dominio (entities, value objects, repositories)
3. Implementar casos de uso (application)
4. Implementar infraestructura (Hive, hardware)
5. Implementar presentación (BLoC, widgets)
6. Escribir tests unitarios
7. Commit y push
8. GitHub Actions valida

---

## Soporte

Para dudas sobre la arquitectura o implementación:
- Revisar documentación en `docs/`
- Leer `.qwen/QWEN.md` y `.qwen/AGENTS.md`
- Ver ejemplos en la feature `catalog`

---

**Importante**: Este proyecto es LOCAL-CODE-ONLY. GitHub Actions se encarga de todo lo demás.
