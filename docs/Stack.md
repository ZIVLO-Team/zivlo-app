# Stack.md — Technology Stack
## Flutter Billing App · Offline-First POS System

---

## 1. Lenguaje y Framework

### Flutter (Dart)
El framework principal. Se eligió Flutter sobre React Native o desarrollo nativo por tres razones específicas para este proyecto:

- **Un solo codebase** para el APK Android (objetivo actual) con posibilidad de expandir a iOS sin reescritura.
- **Rendimiento nativo en UI**: El motor de renderizado propio de Flutter garantiza 60fps en dispositivos de gama baja, donde se usará la app.
- **Ecosistema maduro para hardware móvil**: Los paquetes de escaneo por cámara e impresión Bluetooth tienen soporte estable en Flutter.

**Versión objetivo**: Flutter 3.x estable, Dart 3.x (null safety completo).

---

## 2. Gestión de Estado

### BLoC (Business Logic Component)
Patrón de gestión de estado usando los paquetes `flutter_bloc` y `bloc`.

**¿Por qué BLoC y no Riverpod o Provider?**

En este proyecto, BLoC encaja naturalmente con la arquitectura hexagonal porque separa de forma explícita los eventos de UI (entradas) de los estados resultantes (salidas), sin que la lógica de negocio tenga ningún conocimiento de Flutter. Cada feature tiene su propio BLoC desacoplado, lo que facilita el testing unitario de la lógica sin necesidad de widgets.

**BLoCs del proyecto:**
- `CatalogBloc` — estado del catálogo de productos
- `CartBloc` — estado del carrito activo
- `CheckoutBloc` — flujo de pago
- `ScannerBloc` — resultado del escaneo y lookup de producto
- `PrinterBloc` — estado de conexión e impresión BT
- `SalesHistoryBloc` — historial y filtros de ventas
- `SettingsBloc` — configuración del negocio

---

## 3. Base de Datos Local

### Hive
Base de datos NoSQL embebida, escrita en Dart puro. Es la única dependencia de almacenamiento en el proyecto.

**¿Por qué Hive y no SQLite (sqflite) o Drift?**

- **Velocidad**: Hive es hasta 10x más rápido que sqflite en lecturas simples por clave, que es el patrón dominante en este app (buscar producto por barcode).
- **Sin dependencias nativas**: No requiere compilación nativa adicional, simplificando el build con Buildozer o Flutter build.
- **Tipos Dart nativos**: Los modelos se serializan con TypeAdapters generados, sin SQL ni migrations manuales.
- **Suficiente para el dominio**: El modelo de datos no tiene relaciones complejas que justifiquen un ORM o SQL.

**Boxes (colecciones) de Hive:**
- `products` — catálogo de productos
- `sales` — historial de ventas con ítems embebidos
- `settings` — configuración única del negocio

---

## 4. Navegación

### GoRouter
Enrutador declarativo oficial de Flutter para navegación basada en rutas nombradas.

- Soporta deep linking (útil si en el futuro se integran notificaciones o shortcuts).
- Navegación type-safe con parámetros tipados.
- Guarda y restaura el estado de navegación correctamente con BLoC.

---

## 5. Manejo Funcional de Errores

### fpdart
Biblioteca de programación funcional para Dart. Se usa exclusivamente en la capa de dominio y aplicación para representar resultados de operaciones que pueden fallar.

**Uso principal:**
- `Either<Failure, T>` — resultado de cualquier usecase. El lado izquierdo es un `Failure` (error del dominio), el lado derecho es el valor esperado.
- `Option<T>` — cuando un valor puede no existir (producto no encontrado por barcode, por ejemplo).

Esto elimina el uso de excepciones como control de flujo y hace explícito en los tipos cuándo una operación puede fallar.

---

## 6. Hardware: Escaneo de Código de Barras

### mobile_scanner
Paquete Flutter para escaneo de códigos usando la cámara nativa del dispositivo. Se eligió sobre `flutter_barcode_scanner` por:

- Mantenimiento activo y compatibilidad con Flutter 3.x.
- API de stream continuo (escaneo en tiempo real sin pulsar botón).
- Control granular sobre la resolución de cámara y el área de escaneo.
- Soporte para todos los formatos de código relevantes: EAN-13, EAN-8, QR, Code128, UPC-A.

**Patrón de integración**: El paquete vive completamente detrás del puerto `IScanner` en la capa de dominio. La capa de aplicación nunca importa `mobile_scanner` directamente.

---

## 7. Hardware: Impresión Bluetooth Térmica

### bluetooth_thermal (o esc_pos_bluetooth)
Paquete para comunicación con impresoras térmicas Bluetooth usando el protocolo ESC/POS.

**Patrón de integración**: Al igual que el escáner, el paquete de impresión vive exclusivamente en el adaptador `BtThermalPrinterAdapter`, implementando el puerto `IPrinterPort`. El dominio solo conoce entidades como `PrinterDevice` y `Receipt`, nunca clases del paquete BT.

**Compatibilidad de impresoras objetivo**: Impresoras térmicas de 58mm y 80mm con chip común (Goojprt, Xprinter, HOIN), que representan el 95% del mercado de bajo costo.

---

## 8. Inyección de Dependencias

### get_it
Locator de servicios para registrar e inyectar implementaciones concretas de los puertos (interfaces). Toda la configuración de dependencias se centraliza en `injection_container.dart`.

**Patrón de registro:**
- Los repositorios e implementaciones de puertos se registran como `LazySingleton`.
- Los BLoCs se registran como `Factory` (nueva instancia por cada widget que los consume).
- Los usecases se registran como `LazySingleton` ya que son stateless.

---

## 9. Generación de Código

### build_runner + hive_generator
Generación automática de los TypeAdapters de Hive para serializar/deserializar los modelos de infraestructura. Se ejecuta manualmente con `flutter pub run build_runner build`.

---

## 10. Resumen de Dependencias

### Dependencias de producción

| Paquete | Versión | Propósito |
|---|---|---|
| `flutter_bloc` | ^8.x | Gestión de estado BLoC |
| `bloc` | ^8.x | Core de BLoC |
| `hive_flutter` | ^1.x | Base de datos local + adaptador Flutter |
| `go_router` | ^13.x | Navegación declarativa |
| `fpdart` | ^1.x | Either / Option para errores funcionales |
| `mobile_scanner` | ^5.x | Escaneo de códigos de barras |
| `bluetooth_thermal` | ^1.x | Impresión térmica Bluetooth |
| `get_it` | ^7.x | Inyección de dependencias |
| `equatable` | ^2.x | Comparación de value objects y estados |
| `uuid` | ^4.x | Generación de IDs únicos |

### Dependencias de desarrollo

| Paquete | Propósito |
|---|---|
| `hive_generator` | Generación de TypeAdapters |
| `build_runner` | Runner de generación de código |
| `bloc_test` | Testing de BLoCs |
| `mocktail` | Mocking para tests unitarios |
| `flutter_test` | Testing de widgets |

---

## 11. Herramientas de Build

- **Flutter CLI**: Build del APK de release (`flutter build apk --release`).
- **GitHub Actions**: Pipeline de CI/CD para compilar el APK automáticamente en cada push a `main`.
- **Target mínimo de Android**: API 23 (Android 6.0).
- **Permisos requeridos en AndroidManifest**: `CAMERA`, `BLUETOOTH`, `BLUETOOTH_ADMIN`, `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN`.
