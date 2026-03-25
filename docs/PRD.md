# PRD — Product Requirements Document
## Flutter Billing App · Offline-First POS System

---

## 1. Visión del Producto

Una aplicación móvil de facturación y punto de venta (POS) diseñada específicamente para negocios minoristas pequeños y medianos que operan en entornos con conectividad limitada o nula. El producto elimina la dependencia de internet como requisito para facturar, escanear productos e imprimir recibos, convirtiendo un smartphone Android en una caja registradora completa y portátil.

---

## 2. Problema que Resuelve

Los sistemas POS tradicionales tienen tres puntos de falla críticos para negocios pequeños:

- **Dependencia de internet**: Una caída de red detiene las ventas por completo.
- **Costo de hardware dedicado**: Lectores de barras, impresoras, terminales — todo costoso y frágil.
- **Complejidad de software**: Sistemas sobredimensionados para negocios que solo necesitan escanear, cobrar e imprimir.

Esta aplicación resuelve los tres con un único dispositivo móvil Android, la cámara del teléfono y una impresora térmica Bluetooth de bajo costo.

---

## 3. Público Objetivo

| Segmento | Descripción |
|---|---|
| Tiendas de abarrotes y retail | Negocio con catálogo fijo de productos y alto volumen de ventas diarias |
| Supermercados pequeños | Requieren rapidez en caja, múltiples cajeros |
| Stands de exposición | Facturación temporal sin infraestructura de red |
| Contadores de venta ambulante | Movilidad total, sin punto fijo |
| Pequeños negocios en formación | Presupuesto limitado, necesidad de empezar a operar rápido |

---

## 4. Propuesta de Valor

- **Sin internet, sin problema**: 100% operativo offline desde el primer día.
- **Hardware mínimo**: Solo un teléfono Android y una impresora Bluetooth de menos de $30.
- **Flujo de caja en segundos**: Escanear → Cobrar → Imprimir en menos de 15 segundos.
- **Curva de aprendizaje cero**: Interfaz intuitiva, sin capacitación necesaria.
- **Arquitectura lista para escalar**: Clean/Hexagonal Architecture permite agregar módulos sin reescribir el core.

---

## 5. Funcionalidades del Producto

### 5.1 Funcionalidades Core (MVP)

**Gestión de Catálogo**
- Crear, editar y eliminar productos con nombre, precio, código de barras y stock.
- Búsqueda por nombre o código de barras.
- Categorías de productos.
- Soporte para productos sin código de barras (ingreso manual).

**Escaneo de Código de Barras**
- Escaneo en tiempo real usando la cámara del dispositivo.
- Compatibilidad con formatos: EAN-13, EAN-8, QR, Code128, Code39, UPC-A.
- Feedback visual y sonoro al detectar un código.
- Manejo de código no encontrado: sugerencia de crear el producto.

**Carrito de Compras**
- Agregar ítems desde escaneo o búsqueda manual.
- Modificar cantidad de cada ítem.
- Eliminar ítems del carrito.
- Aplicar descuentos por ítem o sobre el total (porcentual o monto fijo).
- Resumen en tiempo real: subtotal, descuento aplicado, total final.

**Cobro y Pago**
- Métodos de pago: Efectivo, Tarjeta, Pago mixto.
- Calculadora de cambio para pagos en efectivo.
- Confirmación visual del pago exitoso.

**Impresión de Recibo**
- Conexión a impresoras térmicas Bluetooth.
- Preview del recibo antes de imprimir.
- Impresión de: nombre del negocio, ítems, cantidades, precios, total, método de pago, fecha/hora, mensaje personalizado.
- Opción de reimprimir recibos anteriores.
- Modo sin impresora: continuar operando sin hardware de impresión.

**Historial de Ventas**
- Lista de todas las transacciones con fecha, hora, total y método de pago.
- Filtro por rango de fechas.
- Resumen diario: ventas totales y número de transacciones.
- Vista de detalle por venta.

**Configuración del Negocio**
- Nombre del negocio, RUC/NIT, dirección.
- Logo o texto en el encabezado del recibo.
- Mensaje personalizado en el pie del recibo.
- Impresora Bluetooth predeterminada.

### 5.2 Funcionalidades Futuras (Post-MVP)

- Sincronización en la nube cuando haya conexión disponible.
- Múltiples usuarios / cajeros con control de acceso.
- Reportes de ventas exportables (PDF, CSV).
- Gestión de inventario con alertas de stock bajo.
- Integración con pasarelas de pago digital.
- Modo multi-tienda.

---

## 6. Restricciones y Requisitos No Funcionales

| Categoría | Requisito |
|---|---|
| Plataforma | Android 6.0 (API 23) o superior |
| Conectividad | Funcionamiento completo sin internet |
| Almacenamiento | Base de datos local con Hive (NoSQL embebido) |
| Rendimiento | Escaneo < 500ms de respuesta tras detectar código |
| Impresión | Conexión BT < 3 segundos, impresión < 5 segundos |
| Tamaño de APK | Objetivo < 25MB |
| Datos | Sin telemetría, sin envío de datos a servidores externos |

---

## 7. Métricas de Éxito

- Tiempo promedio de una transacción completa (escanear → cobrar → imprimir): menos de 20 segundos.
- Tasa de error en escaneo de códigos: menos del 2%.
- Tiempo de conexión a impresora BT: consistentemente bajo 3 segundos.
- Cero pérdida de datos de ventas en caídas de la aplicación.
- Retención de usuarios a los 30 días: objetivo 70%.

---

## 8. Fuera de Alcance (MVP)

- Pagos online o pasarelas bancarias.
- Sincronización en la nube.
- Versión iOS.
- Módulo de contabilidad o tributación.
- Integración con sistemas externos (ERP, CRM).
- Gestión de empleados o turnos.
