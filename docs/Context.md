# Context.md — Contexto del Proyecto
## Flutter Billing App · Offline-First POS System

---

## 1. Contexto General

Este proyecto nace de una necesidad real y específica: pequeños comercios que operan en zonas con conectividad intermitente o nula necesitan una solución de facturación que no dependa de internet, que sea barata de implementar y que un comerciante sin formación técnica pueda operar desde el primer día.

El mercado objetivo está en economías emergentes donde el hardware dedicado de POS (terminales Verifone, sistemas Micros, etc.) es financieramente inaccesible para negocios con menos de $50,000 de facturación anual. Un smartphone Android de gama media + una impresora Bluetooth de $20 resuelven el mismo problema a menos del 5% del costo.

---

## 2. Arquitectura: Por qué Hexagonal

La decisión de usar Clean/Hexagonal Architecture en lugar de una arquitectura más simple (MVVM básico, por ejemplo) responde a tres problemas concretos que aparecen cuando se trabaja con hardware físico:

**Problema 1 — Los paquetes de hardware cambian.**
El ecosistema de Flutter para Bluetooth e impresoras térmicas es inestable. Los paquetes se deprecan, cambian de API o dejan de mantenerse. Si el código de impresión estuviera diseminado por los widgets, un cambio de paquete implicaría reescribir la mitad de la app. Con el adaptador `BtThermalPrinterAdapter` implementando el puerto `IPrinterPort`, cambiar el paquete significa reemplazar un único archivo sin tocar el dominio ni la UI.

**Problema 2 — Testing sin hardware.**
No se puede correr un test automatizado conectando una impresora Bluetooth o apuntando la cámara a un código de barras. Los puertos (interfaces) permiten crear mocks perfectos (`MockScannerAdapter`, `MockPrinterAdapter`) que simulan cualquier comportamiento: escaneo exitoso, código no encontrado, impresora desconectada, error de BT. Los usecases y BLoCs se testean completamente sin hardware.

**Problema 3 — Escalabilidad controlada.**
El producto actual es offline-only. La versión 2.0 probablemente necesitará sincronización en la nube. Con arquitectura hexagonal, agregar un `CloudSyncAdapter` que implemente el mismo puerto de repositorio es un cambio aditivo. No rompe nada existente.

---

## 3. Capas y sus Responsabilidades

### Capa de Dominio (el corazón)
Contiene las reglas de negocio puras. No importa Flutter, no importa Hive, no importa ningún paquete externo. Solo Dart puro.

- **Entidades**: `Product`, `Cart`, `CartItem`, `Sale`, `Receipt`, `PrinterDevice`, `BusinessConfig`. Cada una con sus invariantes de dominio (un precio no puede ser negativo, una cantidad no puede ser cero o negativa).
- **Value Objects**: `Barcode`, `Money`, `Quantity`, `Discount`, `ProductName`. Encapsulan validación y comparación por valor, no por referencia.
- **Puertos**: Interfaces que definen lo que el dominio necesita del mundo exterior, sin decir cómo se implementa.

### Capa de Aplicación (los casos de uso)
Orquesta el dominio para responder a intenciones del usuario. Cada caso de uso tiene una sola responsabilidad y retorna `Either<Failure, T>`.

No toma decisiones de negocio (eso es dominio). No sabe nada de Flutter (eso es presentación). Solo conecta piezas.

### Capa de Infraestructura (los adaptadores)
Implementa los puertos usando tecnología concreta. Aquí vive Hive, aquí viven los paquetes de hardware.

- Los modelos de Hive (`ProductHiveModel`) son DTOs de infraestructura. Se mapean a entidades de dominio y viceversa. El dominio nunca conoce `@HiveType` ni `@HiveField`.
- Los adaptadores de hardware (`BtThermalPrinterAdapter`, `MobileScannerAdapter`) traducen entre la API del paquete y el lenguaje del dominio.

### Capa de Presentación (los adaptadores de UI)
Flutter vive aquí. Los BLoCs consumen usecases y exponen estados. Los widgets observan estados y disparan eventos. Los widgets no tienen lógica de negocio.

---

## 4. Modelo de Datos

### Product
Representa un artículo vendible en el catálogo.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | String (UUID) | Identificador único inmutable |
| `name` | String | Nombre del producto (max 60 chars) |
| `price` | double | Precio de venta en moneda local |
| `barcode` | String? | Código de barras (puede ser null para productos sin código) |
| `category` | String? | Categoría libre (ej: "Lácteos", "Bebidas") |
| `stock` | int | Cantidad disponible en inventario |
| `createdAt` | DateTime | Fecha de creación |

### CartItem
Representación de un ítem dentro del carrito activo.

| Campo | Tipo | Descripción |
|---|---|---|
| `product` | Product | Snapshot del producto al momento de agregar |
| `quantity` | int | Cantidad seleccionada (mínimo 1) |
| `unitPrice` | double | Precio al momento de agregar (inmutable) |

### Sale
Registro inmutable de una transacción completada.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | String (UUID) | Identificador único |
| `items` | List<SaleItem> | Ítems vendidos (snapshot) |
| `subtotal` | double | Total antes de descuento |
| `discount` | double | Monto de descuento aplicado |
| `total` | double | Total final cobrado |
| `paymentMethod` | Enum | `cash`, `card`, `mixed` |
| `amountReceived` | double? | Monto recibido (solo para efectivo) |
| `change` | double? | Cambio devuelto (solo para efectivo) |
| `createdAt` | DateTime | Fecha y hora de la transacción |

### BusinessConfig
Configuración del negocio almacenada como objeto singleton.

| Campo | Tipo | Descripción |
|---|---|---|
| `name` | String | Nombre del negocio |
| `taxId` | String? | RUC / NIT / número de contribuyente |
| `address` | String? | Dirección |
| `receiptHeader` | String? | Texto personalizado en encabezado del recibo |
| `receiptFooter` | String? | Texto personalizado en pie del recibo |
| `defaultPrinterAddress` | String? | MAC address de la impresora predeterminada |

---

## 5. Principios de Diseño de Código

**Sin lógica en widgets.** Los widgets son puramente declarativos. Toda decisión lógica vive en el BLoC correspondiente o en un usecase.

**Errores explícitos, no excepciones.** Ningún usecase lanza excepciones en el flujo normal. Todo error del dominio es un `Failure` tipado que el BLoC maneja y traduce a un estado de error para la UI.

**Inmutabilidad en estados y entidades.** Los estados de BLoC y las entidades de dominio son inmutables. Cambiar un estado significa crear uno nuevo, no mutar el existente. `Equatable` garantiza comparación por valor.

**Un feature, un directorio.** Todo el código relacionado a una funcionalidad (catálogo, billing, escáner, impresora, settings) vive bajo su propio directorio `features/`. No hay dependencias cruzadas entre features excepto a través de la capa de aplicación.

**Inyección explícita.** Nada se instancia con `new` dentro de los widgets o BLoCs. Todo se resuelve a través de `GetIt`. Esto hace que el grafo de dependencias sea auditable en un único lugar.

---

## 6. Consideraciones de Seguridad y Privacidad

- **Sin telemetría**: La app no envía ningún dato a servidores externos. Todo permanece en el dispositivo.
- **Sin analytics**: No hay integración con Firebase, Sentry ni herramientas similares en el MVP.
- **Datos financieros locales**: Los datos de ventas son sensibles. El almacenamiento en Hive no está cifrado en el MVP, pero el directorio de datos de la app está protegido por el sandbox de Android.
- **Permisos mínimos**: La app solo solicita `CAMERA` y permisos de `BLUETOOTH`. No solicita acceso a internet, contactos, ni almacenamiento externo.

---

## 7. Decisiones Pendientes para el Futuro

Estas decisiones no aplican al MVP pero están documentadas para que no sorprendan cuando sea momento de tomarlas:

- **¿Cifrado de base de datos?** Si el producto escala a negocios con facturación alta, cifrar el Hive box de ventas con `hive_cipher` sería el paso natural.
- **¿Multi-tenant?** Soportar múltiples negocios en un mismo dispositivo (franquicias, por ejemplo) requeriría un nivel adicional de aislamiento de datos en Hive.
- **¿Sincronización?** La arquitectura hexagonal hace que agregar un repositorio remoto sea aditivo, pero habría que definir una estrategia de resolución de conflictos (offline-first con CRDT o last-write-wins).
- **¿iOS?** Flutter soporta iOS nativamente. Los cambios necesarios serían principalmente en los paquetes de hardware (Bluetooth en iOS requiere el protocolo MFi y la revisión de App Store) y los permisos del sistema.
