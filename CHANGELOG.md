# Changelog

Todos los cambios notables en este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2024-03-25

### Added
- **CI/CD Profesional**: Separación de workflows CI y Release
- **Release Automation**: APK naming con versión, checksums SHA256, changelog automático
- **Download Links**: Tabla de descargas en README con links directos a APKs por arquitectura
- **Documentation**: Guía completa de releases en `docs/RELEASES.md`
- **Release Template**: Plantilla para release notes en `.github/RELEASE_TEMPLATE.md`

### Changed
- **CI Workflow**: Ahora solo validación (analyze + test) en ~8 minutos
- **Release Workflow**: Build completo + release en GitHub en ~20 minutos
- **README**: Badges de CI/CD, release y downloads

### Fixed
- **Scanner**: MobileScannerAdapter API para mobile_scanner v5.1.1
- **Printer**: AppSpacing naming (padding → spacing)
- **ReceiptWidget**: Type inference con ReceiptItem
- **Icons**: barcode_scanner → qr_code_scanner (icono no existía)
- **Router**: debugLogDiagnostics tipo bool (no función)
- **ProductForm**: Type safety con ProductDTO? en lugar de dynamic
- **Checkout**: Failure constructor con named parameters
- **Duplicate Class**: PaymentValidationFailure definida una sola vez

## [1.1.0] - 2024-03-24

### Added
- **Feature Scanner**: Completa con 5 capas (Domain, Application, Infrastructure, Presentation, DI)
  - Escaneo de códigos de barras con mobile_scanner v5.1.1
  - BLoC con 7 events y 7 states
  - ScannerPage con overlay y animación
  - ProductNotFoundDialog con opción de crear producto
  - 28 archivos, ~3,500 líneas

- **Feature Catalog**: UI completa
  - CatalogPage con grid de productos
  - ProductFormPage para crear/editar
  - Widgets: ProductCard, SearchBar, FilterChip, EmptyState
  - 7 archivos UI

- **Feature Checkout**: Completa con 5 capas
  - 3 métodos de pago: Efectivo, Tarjeta, Mixto
  - Calculadora de cambio en tiempo real
  - CheckoutBLoC con 11 events, 8 states
  - CheckoutPage y PaymentSuccessPage
  - 30 archivos, ~4,500 líneas

- **Feature Printer**: Completa con 5 capas
  - MockBluetoothPrinterAdapter (listo para bluetooth_print)
  - ReceiptWidget con formato ESC/POS 58mm
  - PrinterBLoC con 8 events, 7 states
  - ReceiptPreviewPage y PrinterSelectorSheet
  - 22 archivos, ~3,000 líneas

### Changed
- **Barcode VO**: Movido a core/domain/value_objects para compartir entre scanner y catalog
- **Architecture**: Clean/Hexagonal Architecture en todas las features
- **State Management**: BLoC pattern consistente
- **Error Handling**: fpdart Either<Failure, T> en todos los use cases

### Fixed
- **Build Errors**: Todos los errores de flutter analyze resueltos
- **Import Paths**: Relative → absolute imports
- **Type Safety**: dynamic → tipos específicos con null safety

## [1.0.0] - 2024-01-01

### Added
- Proyecto inicial
- Documentación base (PRD, Stack, Design, Styles, Brand, Context, AppFlow)
- Estructura Clean Architecture
- Cart feature completa
- Configuración de CI/CD básica

---

## Notas

### Versiones

- **MAJOR** (1.x.x): Cambios incompatibles
- **MINOR** (x.1.x): Features nuevas (backward compatible)
- **PATCH** (x.x.1): Bug fixes (backward compatible)

### Convención de Commits

- `feat:` - Features nuevas
- `fix:` - Bug fixes
- `docs:` - Documentación
- `style:` - Formato/código estético
- `refactor:` - Refactorización
- `test:` - Tests
- `chore:` - Tareas de mantenimiento

### Releases

Los releases se crean automáticamente al hacer push de tags:

```bash
git tag -a v1.2.0 -m "feat: checkout feature complete"
git push origin --tags
```

GitHub Actions genera:
- APKs con naming: `zivlo-v1.2.0-{arch}.apk`
- App Bundle: `zivlo-v1.2.0.aab`
- Checksums: `checksums-v1.2.0.txt`
- Release notes con changelog automático

---

**Full Changelog**: https://github.com/mowgliph/zivlo/releases
