# Design.md — Especificaciones de Diseño por Pantalla
## Flutter Billing App · Offline-First POS System

---

## 1. Principios de Diseño de Pantallas

Antes de detallar cada pantalla, tres reglas que aplican globalmente:

**Regla 1 — El número más importante siempre es el más grande.** En CartPage es el total. En CheckoutPage es el monto recibido. En PaymentSuccessPage es el cambio. El ojo del cajero va al número primero.

**Regla 2 — Las acciones primarias siempre están abajo.** Los pulgares llegan al fondo de la pantalla con más comodidad. El botón "Cobrar", "Confirmar pago", "Agregar al carrito" siempre están en el 25% inferior de la pantalla.

**Regla 3 — Una pantalla, una decisión.** Cada pantalla hace una pregunta implícita al usuario. ScannerPage: "¿Qué producto escaneas?" CartPage: "¿Este es tu pedido?" CheckoutPage: "¿Cómo pagas?" Sin preguntas simultáneas.

---

## 2. SplashScreen

**Propósito**: Inicialización de Hive, carga de configuración y decisión de routing.

**Diseño**:
- Fondo negro (`colorBackground`).
- Logo/nombre del negocio centrado verticalmente. Si no hay nombre configurado, muestra el nombre de la app.
- Indicador de carga mínimo: tres puntos pulsantes en `colorAccent`, 24dp, alineados horizontalmente bajo el logo.
- Duración visible: solo el tiempo real de inicialización (objetivo bajo 800ms en cold start).

---

## 3. HomePage

**Propósito**: Hub central de la app. Acceso a todas las funciones y resumen rápido del día.

**Layout general**:
- AppBar compacta con nombre del negocio a la izquierda e icono de configuración a la derecha.
- Contenido principal en scroll vertical.
- FAB prominente en la esquina inferior derecha para la acción de escaneo.

**Sección superior — DailySummaryCard**:
Card de ancho completo con fondo `colorSurface`. Muestra dos métricas grandes lado a lado: total de ventas del día (en `displayMedium`, `colorAccent`) y número de transacciones (en `displayMedium`, blanco). Debajo de cada número, una etiqueta pequeña en `colorOnSurfaceMuted`. Fecha de hoy en la esquina superior derecha de la card.

**Sección central — Accesos rápidos**:
Grid de 2×2 con cuatro tiles de acción: "Catálogo", "Historial", "Impresora", "Configuración". Cada tile tiene un icono de 32dp, título en `titleMedium` y un subtexto descriptivo corto en `bodyMedium`. Fondo `colorSurface`, borde redondeado con `radiusMedium`.

**FAB**:
Color `colorAccent`, icono `barcode_scanner` de 28dp, label "Escanear" visible (Extended FAB). Posición: bottom-right con padding 16dp del borde. Es el elemento más grande e importante visualmente en la pantalla.

**Badge en FAB**:
Si hay ítems en el carrito activo, el FAB muestra un badge numérico en la esquina superior derecha con el count de ítems. Color del badge: `colorSurface`, texto `colorAccent`. Esto permite al cajero retomar un carrito en progreso sin buscar el ícono de carrito.

---

## 4. ScannerPage

**Propósito**: Escaneo de códigos de barras para agregar productos al carrito.

**Layout**:
- Pantalla completa ocupada por la cámara. No hay AppBar visible para maximizar el área de captura.
- Botón de cierre (X) flotante en la esquina superior izquierda con fondo semitransparente.
- Overlay de guía de escaneo centrado.

**ScanOverlay**:
Área central rectangular aproximada de 280×180dp. El resto de la pantalla tiene un overlay negro al 60% de opacidad, creando un efecto de spotlight sobre el área de escaneo. Las esquinas del área están marcadas con segmentos de línea de 20dp en `colorAccent`. La línea animada de escaneo (horizontal, 2dp, `colorAccent`, opacidad 80%) se mueve de arriba a abajo en loop continuo.

**Texto guía**:
Debajo del área de escaneo, en blanco con sombra, "Apunta el código de barras al área". Se oculta automáticamente en el primer escaneo exitoso de la sesión.

**Flash toggle**:
Botón circular flotante en la esquina inferior izquierda para activar/desactivar la linterna del teléfono.

**ScanResultBottomSheet**:
Aparece desde abajo al detectar un código. Drag handle visible. Contenido:
- Nombre del producto en `titleLarge`.
- Precio unitario en `displayMedium` con `colorAccent`.
- Control de cantidad: botón "−" | número en `displayMedium` | botón "+". Botones de 48×48dp mínimo.
- Botón primario "Agregar al carrito" a ancho completo.
- Link secundario "Continuar escaneando" para añadir más sin cerrar el sheet.

---

## 5. CatalogPage

**Propósito**: Gestión visual del catálogo de productos.

**Layout**:
- AppBar con título "Catálogo" y botón "+" para agregar producto.
- SearchBar debajo del AppBar, siempre visible.
- Chips de filtro por categoría en scroll horizontal bajo el SearchBar.
- Grid de 2 columnas con ProductCards.

**ProductCard**:
Card cuadrada de ancho fijo (la mitad del ancho de pantalla menos márgenes). Contenido:
- Área superior: placeholder de imagen (icono de producto centrado sobre fondo `colorSurfaceVariant`).
- Chip de categoría en la esquina superior izquierda (si aplica).
- Nombre del producto en `titleMedium`, máximo 2 líneas con ellipsis.
- Precio en `Space Mono`, `titleLarge`, `colorAccent`.
- Badge de stock: verde si hay stock, amarillo si es bajo (< 5), rojo si es cero.

**Estado vacío**:
Icono `inventory_2` grande en `colorOnSurfaceMuted` + "No hay productos aún" + botón "Agregar primer producto".

---

## 6. ProductFormPage

**Propósito**: Crear o editar un producto del catálogo.

**Layout**:
- AppBar con título "Nuevo producto" o "Editar producto" y botón de guardar a la derecha.
- Formulario en scroll vertical.

**Campos del formulario**:
- **Nombre**: Campo de texto grande, siempre el primero. Label flotante.
- **Precio**: Campo numérico con prefijo de moneda (símbolo configurable). Teclado numérico con decimales.
- **Código de barras**: Campo de texto con botón de escaneo inline (icono de cámara en el sufijo del campo). Si viene de ScannerPage con código no encontrado, este campo está pre-cargado y deshabilitado.
- **Categoría**: Dropdown con opciones existentes + opción "Nueva categoría".
- **Stock inicial**: Campo numérico. Teclado numérico entero.

**Validación visual**:
Los errores de validación aparecen bajo cada campo en rojo con el ícono de error. El botón guardar se deshabilita visualmente si hay errores activos.

---

## 7. CartPage

**Propósito**: Revisión del pedido antes del cobro.

**Layout**:
- AppBar con título "Carrito" y badge de items count. Botón "Vaciar" a la derecha (acción destructiva, requiere confirmación).
- Lista de CartItemTiles en scroll.
- Sección fija inferior (no hace scroll): resumen financiero + botón cobrar.

**CartItemTile**:
Altura mínima 80dp. Layout de tres columnas:
- Izquierda: nombre del producto en `titleMedium` (2 líneas máx) + precio unitario en `bodyMedium` con `colorOnSurfaceMuted`.
- Centro: Control de cantidad (−, número, +). Los botones tienen mínimo 40×40dp de touch target.
- Derecha: Subtotal del ítem en `Space Mono`, `titleLarge`. Alineado a la derecha.

Swipe left en el tile revela botón rojo de eliminar. El tile puede eliminarse tocando ese botón o con swipe completo. Al eliminar, aparece Snackbar de "Deshacer" por 3 segundos.

**Sección de descuento**:
Colapsable con header "Aplicar descuento ▼". Al expandir: dos tabs — "%" y "$". Input numérico + botón "Aplicar". El descuento aplicado se muestra como línea en el resumen con icono de tijera y color `colorSuccess`.

**Resumen financiero fijo**:
Card sobre el botón de cobrar. Líneas:
- Subtotal: `bodyLarge` derecha.
- Descuento (si aplica): `bodyLarge` derecha, `colorSuccess`.
- **Total**: `displayMedium` `Space Mono` `colorAccent` derecha. Es el número más grande.

**Botón "Cobrar"**:
Primario, ancho completo, 56dp de altura, texto "Cobrar $[total]" con el monto en tiempo real.

---

## 8. CheckoutPage

**Propósito**: Selección de método de pago y confirmación de la transacción.

**Layout**:
- AppBar con "← Volver al carrito" y total en el título.
- Selector de método de pago.
- Área de input según método seleccionado.
- Botón de confirmación fijo abajo.

**PaymentMethodSelector**:
Tres tabs con icono + label: "Efectivo 💵", "Tarjeta 💳", "Mixto 🔄". El tab activo tiene fondo `colorAccent` y texto blanco. El resto tienen borde `colorSurface` y texto `colorOnSurfaceMuted`.

**Vista Efectivo**:
- Total a cobrar en `displayLarge` centrado.
- Campo "Monto recibido" con teclado numérico. Campo grande, prominente.
- Calculadora de cambio: debajo del campo, en tiempo real, muestra "Cambio: $XX.XX" en `displayMedium` `colorChange` (ámbar). Si el monto es insuficiente, muestra "Falta: $XX.XX" en `colorError`.
- Botones de monto rápido: chips con valores predefinidos ($50, $100, $200, $500) para completar el campo rápido.

**Vista Tarjeta**:
Solo el total y el botón de confirmación. Sin campos adicionales en MVP.

**Vista Mixto**:
Dos campos: "Monto en efectivo" y "Monto en tarjeta". El campo de tarjeta se auto-completa con el saldo restante al llenar el de efectivo. Total de ambos debe igualar el total de la venta.

---

## 9. PaymentSuccessPage

**Propósito**: Confirmación visual de pago completado y acceso a opciones post-venta.

**Diseño**:
- Fondo `colorBackground`.
- Ícono `check_circle` de 80dp en `colorSuccess` con animación de entrada (scale + fade, 400ms).
- Texto "¡Pago completado!" en `headlineMedium` centrado.
- Card con resumen: total cobrado (grande), método de pago, cambio si aplica.
- Tres acciones en vertical:
  1. Botón primario "Imprimir recibo"
  2. Botón secundario "Ver recibo en pantalla"
  3. Link de texto "Nueva venta →"

La pantalla no tiene AppBar ni botón de volver. La única salida es una de las tres acciones. Esto evita que el cajero vuelva accidentalmente al carrito ya procesado.

---

## 10. ReceiptPreviewPage

**Propósito**: Preview visual del recibo antes de imprimir o para referencia.

**Layout**:
- Fondo oscuro.
- El recibo renderizado como una tarjeta blanca con bordes ligeramente rasgados (efecto papel) centrada en pantalla, con scroll vertical si excede la altura.
- Botones flotantes abajo: "Imprimir" y "Compartir" (para el futuro).

**ReceiptWidget** (el recibo en sí):
Fondo blanco, texto negro, fuente `Space Mono` para todo el contenido del recibo. Simula fielmente cómo se verá impreso en papel térmico de 58mm o 80mm.
- Encabezado: nombre del negocio en bold centrado, RUC/dirección en tamaño pequeño.
- Separador: línea de guiones `- - - - - - - - - -`.
- Fecha y hora del lado derecho, número de recibo del lado izquierdo.
- Separador.
- Lista de ítems: cada ítem en su propia línea con nombre a la izquierda, cantidad × precio y subtotal a la derecha.
- Separador doble `= = = = = = = = = =`.
- Total en bold y centrado.
- Método de pago y cambio si aplica.
- Separador.
- Mensaje personalizado del negocio centrado e itálico.

---

## 11. SalesHistoryPage

**Propósito**: Consulta del historial de transacciones.

**Layout**:
- AppBar con "Historial".
- DailySummaryCard compacta en la parte superior (total del período filtrado).
- Chips de filtro rápido: "Hoy", "Esta semana", "Este mes".
- Lista de SaleTiles en scroll.

**SaleTile**:
Tile de altura fija 68dp. Layout:
- Izquierda: icono de recibo con fondo `colorSurface`. Debajo, hora de la transacción en `labelMedium` `colorOnSurfaceMuted`.
- Centro: fecha o "Hace X minutos" en `bodyMedium`. Número de ítems en `labelMedium` `colorOnSurfaceMuted`.
- Derecha: total en `titleLarge` `Space Mono` `colorAccent`. Badge de método de pago (chip pequeño).

---

## 12. PrinterSelectorSheet

**Propósito**: Selección y conexión de impresora Bluetooth.

**Layout** (BottomSheet):
- Drag handle.
- Título "Conectar impresora" + botón "Buscar" a la derecha.
- Lista de dispositivos BT encontrados.
- Impresora predeterminada (si existe) destacada al topo con badge "Predeterminada".

**PrinterDeviceTile**:
Icono de impresora + nombre del dispositivo + dirección MAC en gris. Estado de conexión como icono a la derecha: sin conectar (gris), conectando (spinner), conectado (verde check). Al tocar un tile conectado, pregunta si quiere establecerlo como predeterminado.

---

## 13. SettingsPage

**Propósito**: Configuración del negocio y la aplicación.

**Layout**:
- AppBar "Configuración".
- Secciones separadas por headers en `labelMedium` `colorOnSurfaceMuted`.

**Sección "Mi negocio"**: BusinessInfoForm con campos de nombre, RUC, dirección, mensaje en recibo.

**Sección "Impresora"**: PrinterConfigCard mostrando estado actual, impresora conectada y botón para cambiar.

**Sección "Preferencias"**: Moneda, separador decimal, tamaño de papel de impresora (58mm / 80mm).

**Sección "Datos"**: Botón "Exportar historial de ventas" (para el futuro, visible pero deshabilitado en MVP). Botón "Limpiar datos del catálogo" (destructivo, requiere confirmación de doble-tap).
