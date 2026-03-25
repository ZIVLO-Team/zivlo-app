# AppFlow.md — Flujos de la Aplicación
## Flutter Billing App · Offline-First POS System

---

## 1. Flujo Principal de Navegación

```
SplashScreen
    │
    ├── [Primera vez] ──→ OnboardingFlow ──→ SetupNegocio ──→ HomePage
    │
    └── [App configurada] ──→ HomePage
```

---

## 2. Estructura de Rutas (GoRouter)

```
/                    → HomePage (Shell principal)
├── /catalog         → CatalogPage
│   ├── /catalog/new               → ProductFormPage (crear)
│   └── /catalog/:productId        → ProductFormPage (editar)
│
├── /scanner         → ScannerPage
│
├── /cart            → CartPage
│   └── /cart/checkout             → CheckoutPage
│       └── /cart/checkout/success → PaymentSuccessPage
│
├── /history         → SalesHistoryPage
│   └── /history/:saleId           → SaleDetailPage
│
├── /receipt/:saleId → ReceiptPreviewPage
│
└── /settings        → SettingsPage
```

---

## 3. Flujos de Usuario Detallados

---

### Flujo A — Venta Completa (Happy Path)

Este es el flujo más importante del producto. Debe ser el más rápido y sin fricción.

```
[HomePage]
    │
    │  Usuario presiona "Escanear"
    ▼
[ScannerPage]
    │  Cámara activa, overlay de guía visible
    │  Usuario apunta al código de barras
    ▼
[Detección de código]
    │
    ├── [Producto encontrado]
    │       │
    │       ▼
    │   [ScanResultBottomSheet]
    │       │  Muestra: nombre, precio, cantidad (default 1)
    │       │  Usuario puede ajustar cantidad
    │       │  Presiona "Agregar al carrito"
    │       │
    │       ├── [Continuar escaneando] ──→ vuelve a ScannerPage
    │       └── [Ver carrito]           ──→ CartPage
    │
    └── [Producto NO encontrado]
            │
            ▼
        [AlertDialog: "Código no registrado"]
            │
            ├── [Crear producto] ──→ ProductFormPage (con barcode pre-cargado)
            └── [Cancelar]       ──→ vuelve a escanear
```

```
[CartPage]
    │  Lista de ítems, subtotal, total visible
    │  Usuario puede modificar cantidades o eliminar ítems
    │  Usuario puede aplicar descuento
    │
    │  Presiona "Cobrar"
    ▼
[CheckoutPage]
    │  Selecciona método de pago
    │
    ├── [Efectivo]
    │       │  Ingresa monto recibido
    │       │  App calcula cambio
    │       │  Presiona "Confirmar pago"
    │       ▼
    │   [PaymentSuccessPage]
    │
    ├── [Tarjeta]
    │       │  Presiona "Confirmar pago"
    │       ▼
    │   [PaymentSuccessPage]
    │
    └── [Mixto]
            │  Ingresa monto en efectivo + monto en tarjeta
            │  App verifica que la suma cubra el total
            │  Presiona "Confirmar pago"
            ▼
        [PaymentSuccessPage]
```

```
[PaymentSuccessPage]
    │  Muestra: total cobrado, método de pago, cambio (si aplica)
    │  Opciones disponibles:
    │
    ├── [Imprimir recibo]
    │       │
    │       ├── [Impresora BT conectada] ──→ PrinterBloc envía impresión ──→ feedback de estado
    │       └── [Sin impresora conectada] ──→ PrinterSelectorSheet ──→ conectar ──→ imprimir
    │
    ├── [Ver recibo en pantalla] ──→ ReceiptPreviewPage
    │
    └── [Nueva venta] ──→ limpia CartBloc ──→ HomePage o ScannerPage
```

---

### Flujo B — Agregar Producto al Catálogo

```
[CatalogPage] o [ScannerPage (código no encontrado)]
    │
    ▼
[ProductFormPage]
    │  Campos: nombre*, precio*, código de barras, categoría, stock inicial
    │  Si viene del escáner: barcode pre-cargado y no editable
    │
    ├── [Guardar] ──→ validación ──→ CatalogBloc guarda ──→ vuelve a la pantalla anterior
    └── [Cancelar] ──→ vuelve sin cambios
```

---

### Flujo C — Consultar Historial de Ventas

```
[HomePage]
    │
    ▼
[SalesHistoryPage]
    │  Lista de ventas ordenada por fecha (más reciente primero)
    │  Resumen del día visible en la parte superior
    │  Filtros: hoy, esta semana, este mes, rango personalizado
    │
    │  Usuario toca una venta
    ▼
[SaleDetailPage]
    │  Muestra: fecha, hora, ítems vendidos, totales, método de pago
    │
    ├── [Reimprimir recibo] ──→ mismo flujo de impresión de Flujo A
    └── [Volver]            ──→ SalesHistoryPage
```

---

### Flujo D — Conectar Impresora Bluetooth

```
[PaymentSuccessPage] o [SettingsPage]
    │
    ▼
[PrinterSelectorSheet] (BottomSheet)
    │  Muestra lista de dispositivos BT disponibles
    │  Botón "Buscar dispositivos"
    │
    │  Usuario selecciona impresora
    ▼
[PrinterBloc: estado Connecting]
    │
    ├── [Éxito] ──→ estado Connected ──→ cierra sheet ──→ continúa flujo anterior
    └── [Error]  ──→ estado Error ──→ muestra mensaje ──→ opción de reintentar
```

---

### Flujo E — Configuración Inicial del Negocio

```
[OnboardingStep1] → Nombre del negocio
    │
    ▼
[OnboardingStep2] → RUC/NIT y dirección (opcional, puede omitirse)
    │
    ▼
[OnboardingStep3] → Mensaje en recibo (opcional, puede omitirse)
    │
    ▼
[OnboardingStep4] → Conectar impresora (opcional, puede omitirse)
    │
    ▼
[HomePage]
```

Este flujo solo se ejecuta en el primer arranque. Todos los pasos excepto el nombre son omitibles.

---

## 4. Estados de la Aplicación por BLoC

### CartBloc — Estados
- `CartEmpty` — carrito vacío, sin ítems
- `CartLoaded` — tiene ítems, muestra subtotal y total
- `CartUpdating` — procesando cambio de cantidad o descuento

### ScannerBloc — Estados
- `ScannerInitial` — cámara inactiva
- `ScannerActive` — cámara en vivo, buscando códigos
- `ScannerProductFound(product)` — código detectado, producto encontrado
- `ScannerProductNotFound(barcode)` — código detectado, producto no en catálogo
- `ScannerError(message)` — error de cámara o permiso denegado

### CheckoutBloc — Estados
- `CheckoutIdle` — esperando interacción
- `CheckoutProcessing` — procesando la transacción
- `CheckoutSuccess(sale)` — venta completada, sale contiene los datos
- `CheckoutError(message)` — error al procesar

### PrinterBloc — Estados
- `PrinterDisconnected` — sin impresora conectada
- `PrinterDiscovering` — buscando dispositivos BT
- `PrinterConnecting` — intentando conectar
- `PrinterConnected(device)` — conectado y listo
- `PrinterPrinting` — enviando datos
- `PrinterPrintSuccess` — impresión completada
- `PrinterError(message)` — fallo de conexión o impresión

---

## 5. Decisiones de UX Clave

- **El escáner es la entrada principal**: La acción más prominente en HomePage es "Escanear". No hay menú de hamburguesa ni navegación compleja.
- **Carrito persistente**: El carrito sobrevive al cambio de pantalla. Si el usuario va al catálogo y vuelve, el carrito está intacto.
- **Feedback inmediato en hardware**: Cualquier interacción con la impresora o el escáner tiene feedback visual en menos de 200ms (loader, animación, icono de estado).
- **Modo degradado sin impresora**: La app permite completar ventas sin tener una impresora conectada. La impresión es opcional, nunca bloqueante.
- **Sin confirmaciones innecesarias**: Eliminar un ítem del carrito no pide confirmación. La acción se puede deshacer dentro de los siguientes 3 segundos con un Snackbar de "Deshacer".
