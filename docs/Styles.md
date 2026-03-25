# Styles.md — Sistema de Diseño Visual
## Flutter Billing App · Offline-First POS System

---

## 1. Filosofía Visual

La app vive en las manos de cajeros en movimiento: ruido de fondo, luz solar directa, velocidad de operación, dedos a veces húmedos. El diseño responde a ese contexto con una filosofía de **claridad brutal y jerarquía sin ambigüedades**. Cada elemento en pantalla tiene un único trabajo. Nada es decorativo si no es funcional.

La estética es **industrial-utilitaria con temperatura cálida**. Ni el minimalismo frío de una fintech, ni la saturación de una app de delivery. Algo intermedio que transmite confianza, velocidad y solidez.

---

## 2. Paleta de Colores

### Colores Primarios

| Token | Valor | Uso |
|---|---|---|
| `colorPrimary` | `#1A1A2E` | Azul-negro profundo. Fondo de superficies principales, AppBar |
| `colorPrimaryVariant` | `#16213E` | Variante más oscura para contraste de superficie |
| `colorAccent` | `#E94560` | Rojo coral vibrante. CTAs principales, precio total, alertas |
| `colorAccentSoft` | `#FF6B7A` | Versión suave del accent para estados hover/pressed |

### Colores de Superficie

| Token | Valor | Uso |
|---|---|---|
| `colorSurface` | `#0F3460` | Azul marino. Cards, BottomSheets, campos de input |
| `colorSurfaceVariant` | `#1A4A80` | Variante para diferenciar capas de superficie |
| `colorBackground` | `#0A0A1A` | Fondo base de la app |
| `colorOnSurface` | `#FFFFFF` | Texto e iconos sobre superficies oscuras |
| `colorOnSurfaceMuted` | `#8899AA` | Texto secundario, placeholders, labels |

### Colores Funcionales

| Token | Valor | Uso |
|---|---|---|
| `colorSuccess` | `#00D97E` | Verde eléctrico. Confirmación de pago, stock disponible |
| `colorWarning` | `#FFB830` | Amarillo ámbar. Advertencias, stock bajo |
| `colorError` | `#E94560` | Mismo que accent. Error y acción destructiva comparten intensidad |
| `colorInfo` | `#4DA3FF` | Azul claro. Información neutral, tooltips |

### Colores de Precio y Números

| Token | Valor | Uso |
|---|---|---|
| `colorPrice` | `#FFFFFF` | Precio unitario. Blanco puro para máxima legibilidad |
| `colorTotal` | `#E94560` | Total a cobrar. El número más importante siempre en accent |
| `colorDiscount` | `#00D97E` | Descuentos en verde. Psicología de ahorro |
| `colorChange` | `#FFB830` | Cambio a devolver en ámbar. Diferenciado del total |

---

## 3. Tipografía

### Fuentes

**Display / Headings**: `Space Mono` (Google Fonts)
Fuente monoespaciada con carácter técnico. Evoca terminals, recibos de caja, sistemas industriales. Perfecta para el contexto POS. Usada en títulos, totales grandes y números de recibo.

**Body / UI**: `DM Sans` (Google Fonts)
Sans-serif humanista con excelente legibilidad en tamaños pequeños y pantallas de baja densidad. Usada para nombres de productos, labels, botones y texto de navegación.

**Números / Precios**: `Space Mono` siempre para números. La monoespaciación alinea columnas de precios perfectamente sin trabajo adicional.

### Escala Tipográfica

| Token | Fuente | Tamaño | Peso | Uso |
|---|---|---|---|---|
| `displayLarge` | Space Mono | 32sp | Bold | Total a cobrar en checkout |
| `displayMedium` | Space Mono | 24sp | Bold | Totales en CartPage, encabezados de sección |
| `headlineMedium` | DM Sans | 20sp | SemiBold | Títulos de página (AppBar) |
| `titleLarge` | DM Sans | 18sp | SemiBold | Nombres de productos en carrito |
| `titleMedium` | DM Sans | 16sp | Medium | Nombres de productos en catálogo |
| `bodyLarge` | DM Sans | 16sp | Regular | Texto principal en formularios |
| `bodyMedium` | DM Sans | 14sp | Regular | Descripciones, categorías, fechas |
| `labelLarge` | DM Sans | 14sp | SemiBold | Texto de botones |
| `labelMedium` | DM Sans | 12sp | Medium | Badges, chips, tags |
| `priceDisplay` | Space Mono | 28sp | Bold | Precio individual en carrito |
| `receiptText` | Space Mono | 12sp | Regular | Contenido del recibo en preview |

---

## 4. Espaciado y Grid

El sistema de espaciado es múltiplo de 4dp (compatible con Material Design).

| Token | Valor | Uso |
|---|---|---|
| `spacing2` | 2dp | Separación mínima entre elementos inline |
| `spacing4` | 4dp | Padding interno de chips, badges |
| `spacing8` | 8dp | Separación entre elementos relacionados |
| `spacing12` | 12dp | Padding vertical de list tiles |
| `spacing16` | 16dp | Padding horizontal de página (margen estándar) |
| `spacing20` | 20dp | Separación entre secciones dentro de una card |
| `spacing24` | 24dp | Padding de cards y BottomSheets |
| `spacing32` | 32dp | Separación entre secciones principales de página |
| `spacing48` | 48dp | Espaciado extra en páginas de confirmación |

**Margen horizontal de página**: 16dp en todos los lados. Los elementos de ancho completo (botones primarios, listas) tocan los márgenes.

---

## 5. Bordes y Radios

| Token | Valor | Uso |
|---|---|---|
| `radiusSmall` | 6dp | Chips, badges, input fields |
| `radiusMedium` | 12dp | Cards de producto, tiles de carrito |
| `radiusLarge` | 16dp | BottomSheets, modales, cards grandes |
| `radiusXL` | 24dp | FAB, botones de acción principales |
| `radiusFull` | 999dp | Botones pill, avatars circulares |

Los bordes de las cards tienen un trazo sutil de `1dp` en `colorSurface` con 20% de opacidad para definir límites sin usar sombras pesadas (las sombras consumen GPU en dispositivos de gama baja).

---

## 6. Iconografía

**Familia**: Material Icons Outlined (el set outlined, no filled). La versión outlined tiene un peso visual más ligero que encaja con la tipografía DM Sans.

**Tamaños estándar**:
- Iconos en AppBar y NavigationBar: 24dp
- Iconos en list tiles y botones: 20dp
- Iconos decorativos en estados vacíos: 48dp
- Icono de escáner (CTA principal): 32dp

**Iconos clave del proyecto:**
- Escáner: `barcode_scanner` o `qr_code_scanner`
- Carrito: `shopping_cart`
- Imprimir: `print`
- Producto: `inventory_2`
- Historial: `receipt_long`
- Configuración: `tune`
- Éxito: `check_circle`
- Error: `error`
- Bluetooth: `bluetooth`

---

## 7. Componentes UI Principales

### Botón Primario
Fondo `colorAccent`, texto blanco, fuente `labelLarge`, border radius `radiusXL` (pill), altura 56dp. En estados activos de pago (checkout) y confirmación siempre usa este componente.

### Botón Secundario
Borde `1dp colorAccent`, fondo transparente, texto `colorAccent`, mismas dimensiones que el primario. Para acciones secundarias como "Ver recibo" o "Cancelar".

### Botón de Acción Flotante (FAB)
Color `colorAccent`, icono blanco, border radius `radiusXL`. Usado exclusivamente para la acción de escaneo en HomePage.

### Card de Producto
Fondo `colorSurface`, border radius `radiusMedium`, padding `spacing16`. Contiene: nombre en `titleMedium`, precio en `priceDisplay` con `colorAccent`, badge de categoría en `labelMedium`.

### Tile de Carrito
Altura mínima 72dp. Layout: nombre + precio unitario a la izquierda, controles de cantidad (+/−) al centro, subtotal del ítem a la derecha. El subtotal usa `Space Mono` para alineación perfecta.

### BottomSheet
Fondo `colorSurface`, border radius top `radiusLarge`, drag handle visible de 4dp × 32dp en `colorOnSurfaceMuted`. Siempre ocupa entre 40% y 85% de la pantalla.

### Overlay del Escáner
El 100% de la pantalla es la cámara. Sobre ella, una capa semitransparente negra (60% opacidad) con un recorte rectangular central transparente que define el área de escaneo. Una línea horizontal animada recorre el área de escaneo de arriba a abajo en loop (animación CSS-style con `AnimationController`). Borde del área de escaneo: 2dp en `colorAccent`.

---

## 8. Estados de UI

Cada componente que carga datos tiene cuatro estados visuales definidos:

**Estado vacío**: Icono grande (48dp) en `colorOnSurfaceMuted` + texto descriptivo en `bodyMedium`. Sin ilustraciones complejas que pesen en el APK.

**Estado de carga**: Skeleton shimmer usando un degradado animado de `colorSurface` a `colorSurfaceVariant`. Nunca un `CircularProgressIndicator` en el centro de pantalla.

**Estado de error**: Icono `error` en `colorError` + mensaje en `bodyMedium` + botón "Reintentar" en estilo secundario.

**Estado de éxito**: Icono `check_circle` animado con escala (zoom in + bounce) en `colorSuccess`. Usado en PaymentSuccessPage y confirmación de impresión.

---

## 9. Animaciones y Micro-interacciones

**Principio**: Las animaciones sirven para dar feedback, no para decorar. Duración máxima de cualquier animación de UI: 300ms.

| Animación | Duración | Tipo | Trigger |
|---|---|---|---|
| Aparición de BottomSheet | 250ms | Ease out | Al abrir sheet |
| Navegación entre páginas | 200ms | Fade + slide horizontal sutil | Cambio de ruta |
| Adición de ítem al carrito | 300ms | Bounce en FAB de carrito | Tras agregar producto |
| Línea de escaneo | Loop 1500ms | Linear | Siempre activo en ScannerPage |
| Confirmación de pago | 400ms | Scale + fade in del ícono check | Al llegar a PaymentSuccessPage |
| Feedback de cantidad | 150ms | Scale 0.95 y vuelta | Tap en botón +/− |
| Snackbar de deshacer | Slide from bottom | 200ms | Al eliminar ítem de carrito |

---

## 10. Tema de la Aplicación (ThemeData)

El tema es **oscuro** (`ThemeMode.dark`). No hay modo claro. La razón es pragmática: en entornos de tienda con luz fluorescente o sol directo, las pantallas oscuras con texto blanco son más legibles que las blancas. Además, reduce el consumo de batería en pantallas OLED (frecuentes en dispositivos Android de gama media-alta).

El `ThemeData` de Flutter se configura con `useMaterial3: true` para aprovechar los componentes de Material 3, pero con el color scheme personalizado que reemplaza completamente la paleta por defecto de Material You.
