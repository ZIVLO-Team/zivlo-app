# AGENTS.md — Guía para Agentes de Desarrollo

## 🚫 Regla FUNDAMENTAL: No Ejecución Local

**ESTÁ ESTRICTAMENTE PROHIBIDO ejecutar, compilar o verificar código Flutter/Dart en el entorno local.**

### Comandos PROHIBIDOS en local:
```bash
🚫 flutter run
🚫 flutter build
🚫 flutter pub get
🚫 flutter analyze
🚫 flutter test
🚫 dart run
🚫 dart analyze
```

### Flujo CORRECTO:
1. ✅ Escribes código puro en local
2. ✅ Haces commit
3. ✅ GitHub Actions compila, testea y valida
4. ✅ Revisas resultados en GitHub Actions tab

**Razón**: El entorno local es SOLO para edición. GitHub Actions maneja toda la validación, compilación y publicación de releases.

---

## 🎯 Tu Rol como Agente

Eres un agente de desarrollo especializado en Flutter con expertise en:

1. **Arquitectura Hexagonal** — Clean Architecture, separación de capas
2. **BLoC Pattern** — Gestión de estado con flutter_bloc
3. **Offline-First** — Hive, almacenamiento local
4. **Hardware Integration** — Bluetooth, cámaras, impresoras térmicas
5. **fpdart** — Programación funcional con Either/Option

---

## 📚 Documentación de Referencia

Antes de escribir código, DEBES consultar:

| Archivo | Propósito |
|---------|-----------|
| `docs/PRD.md` | Requisitos del producto |
| `docs/Stack.md` | Stack tecnológico y dependencias |
| `docs/Design.md` | Especificaciones de cada pantalla |
| `docs/Styles.md` | Sistema de diseño (colores, tipografía) |
| `docs/Brand.md` | Identidad de marca |
| `docs/Context.md` | Arquitectura y decisiones técnicas |
| `docs/AppFlow.md` | Flujos de usuario y navegación |

---

## 🏗️ Arquitectura del Proyecto

### Capas (DEBES respetar esta separación):

```
Domain (Puro Dart, sin Flutter)
├── Entidades: Product, Cart, Sale, Receipt
├── Value Objects: Barcode, Money, Quantity
├── Puertos: IProductRepository, IPrinterPort
└── Reglas de negocio puras

Application (Dart + fpdart)
├── Casos de uso: GetProductByBarcode, CreateSale
├── Retorna: Either<Failure, T>
└── Sin dependencias de Flutter

Infrastructure (Dart + Flutter packages)
├── Adaptadores: BtThermalPrinterAdapter
├── Repositorios: HiveProductRepository
├── Modelos: ProductHiveModel (DTOs)
└── Implementa puertos del dominio

Presentation (Flutter puro)
├── BLoCs: CatalogBloc, CartBloc
├── Widgets: ProductCard, CartPage
├── UI: Sin lógica de negocio
└── Observa estados, dispara eventos
```

---

## 📁 Estructura de Directorios

```
lib/
├── core/
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── utils/
│   │   └── constants.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── catalog/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── product.dart
│   │   │   ├── repositories/
│   │   │   │   └── product_repository.dart
│   │   │   └── value_objects/
│   │   │       ├── barcode.dart
│   │   │       └── product_name.dart
│   │   ├── application/
│   │   │   ├── usecases/
│   │   │   │   ├── get_product_by_barcode.dart
│   │   │   │   └── create_product.dart
│   │   │   └── dtos/
│   │   │       └── product_dto.dart
│   │   ├── infrastructure/
│   │   │   ├── repositories/
│   │   │   │   └── hive_product_repository.dart
│   │   │   └── models/
│   │   │       └── product_hive_model.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── catalog_bloc.dart
│   │       │   ├── catalog_event.dart
│   │       │   └── catalog_state.dart
│   │       └── pages/
│   │           ├── catalog_page.dart
│   │           └── product_form_page.dart
│   ├── cart/
│   ├── scanner/
│   ├── checkout/
│   ├── printer/
│   ├── sales_history/
│   └── settings/
└── injection_container.dart
```

---

## 🎨 Design System

### Colores (usar SIEMPRE estos valores):

```dart
// Primarios
static const colorPrimary = Color(0xFF1A1A2E);      // Azul-negro
static const colorAccent = Color(0xFFE94560);       // Rojo coral

// Superficies
static const colorSurface = Color(0xFF0F3460);      // Azul marino
static const colorBackground = Color(0xFF0A0A1A);   // Fondo base

// Funcionales
static const colorSuccess = Color(0xFF00D97E);      // Verde
static const colorWarning = Color(0xFFFFB830);      // Ámbar
static const colorError = Color(0xFFE94560);        // Rojo
```

### Tipografía:

```dart
// Display/Números — Space Mono
headlineLarge: TextStyle(
  fontFamily: 'Space Mono',
  fontSize: 32,
  fontWeight: FontWeight.bold,
)

// Body/UI — DM Sans
bodyLarge: TextStyle(
  fontFamily: 'DM Sans',
  fontSize: 16,
  fontWeight: FontWeight.normal,
)
```

---

## 🧪 Testing Strategy

### Tests Unitarios (Dominio y Casos de Uso):

```dart
// ✅ CORRECTO: Test de caso de uso con mocks
test('debe retornar producto cuando el barcode existe', () async {
  // Arrange
  when(() => mockRepository.getByBarcode('123'))
    .thenAnswer((_) async => Right(product));
  
  // Act
  final result = await usecase.execute('123');
  
  // Assert
  expect(result, Right(product));
});
```

### BLoC Tests:

```dart
// ✅ CORRECTO: BLoC test con bloc_test
blocTest<CatalogBloc, CatalogState>(
  'emite [CartLoaded] cuando se agrega producto',
  build: () => CatalogBloc(),
  act: (bloc) => bloc.add(AddToCart(product, quantity: 1)),
  expect: () => [CartLoaded(items: [CartItem(product, 1)])],
);
```

---

## 🔧 GitHub Actions Workflows

### Workflow Principal (`.github/workflows/ci.yml`):

```yaml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  release:
    types: [published]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze
      
      - name: Run tests
        run: flutter test
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

### Workflow de Release (`.github/workflows/release.yml`):

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 📝 Convenciones de Código

### Naming Conventions:

```dart
// ✅ CORRECTO
class Product {}                    // Entidad
class Barcode {}                    // Value Object
abstract class IProductRepository {} // Puerto
class GetProductByBarcode {}        // Caso de uso
class CatalogBloc {}                // BLoC
class ProductCard {}                // Widget
```

### Error Handling con fpdart:

```dart
// ✅ CORRECTO: Either para manejo de errores
Future<Either<Failure, Product>> execute(String barcode) async {
  final product = await repository.getByBarcode(barcode);
  
  if (product == null) {
    return Left(ProductNotFound(barcode));
  }
  
  return Right(product);
}

// ❌ INCORRECTO: Excepciones en el dominio
throw ProductNotFoundException();  // NUNCA hacer esto
```

---

## 🚀 Flujo de Trabajo del Agente

### Al recibir una tarea:

1. **LEER** documentación relevante en `docs/`
2. **IDENTIFICAR** capas afectadas (domain, application, infrastructure, presentation)
3. **ESCRIBIR** código siguiendo arquitectura hexagonal
4. **NO COMPILAR** ni ejecutar nada en local
5. **COMMIT** de cambios
6. **ESPERAR** resultados de GitHub Actions

### Al completar una feature:

1. ✅ Verificar que todo el código sigue las convenciones
2. ✅ Asegurar que los tests están escritos (TDD)
3. ✅ Confirmar que no hay lógica de negocio en widgets
4. ✅ Hacer commit con mensaje descriptivo
5. ✅ GitHub Actions validará automáticamente

---

## ⚠️ Anti-Patrones a Evitar

```dart
// ❌ Lógica de negocio en widgets
class ProductCard extends StatelessWidget {
  build() {
    if (product.price < 0) {  // ERROR: Validación en UI
      return Text('Precio inválido');
    }
  }
}

// ❌ Excepciones en el dominio
class Product {
  void setPrice(double price) {
    if (price < 0) throw ArgumentError();  // ERROR
  }
}

// ❌ Dependencias de Flutter en el dominio
import 'package:flutter/material.dart';  // ERROR en domain/

class Product {  // ERROR: Domain no importa Flutter
  Color get color => Colors.red;
}
```

---

## 🎯 Checklist de Calidad

Antes de considerar una tarea completada:

- [ ] ¿El código sigue arquitectura hexagonal?
- [ ] ¿Las entidades no tienen dependencias de Flutter?
- [ ] ¿Los casos de uso retornan `Either<Failure, T>`?
- [ ] ¿Los widgets no tienen lógica de negocio?
- [ ] ¿Los tests están escritos y pasan?
- [ ] ¿Se usan los colores del design system?
- [ ] ¿La tipografía es Space Mono / DM Sans?
- [ ] ¿No hay compilación/ejecución local?

---

## 📞 Recursos Adicionales

- **Skills de Flutter**: `flutter-best-practices`, `bloc-state-management`
- **Skills de Arquitectura**: `architecture-patterns`, `clean-architecture`
- **Skills de Testing**: `test-driven-development`, `python-testing-patterns`
- **Skills de UI/UX**: `ui-ux-pro-max`, `interaction-design`

---

## 🔐 Seguridad

- **Nunca** agregar telemetría o analytics
- **Nunca** enviar datos a servidores externos
- **Nunca** solicitar permisos innecesarios
- **Siempre** validar datos de entrada
- **Siempre** usar tipos seguros con fpdart

---

**RECUERDA**: Tu trabajo es escribir código limpio y bien estructurado. GitHub Actions se encarga del resto. **NUNCA compiles localmente.**
