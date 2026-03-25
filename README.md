# Zivlo — Punto de Venta Offline-First

[![CI/CD](https://img.shields.io/github/actions/workflow/status/mowgliph/zivlo/ci.yml?branch=main&style=for-the-badge&logo=github-actions&logoColor=white&color=1A1A2E)](https://github.com/mowgliph/zivlo/actions)
[![Release](https://img.shields.io/github/v/release/mowgliph/zivlo?style=for-the-badge&logo=github&logoColor=white&color=E94560)](https://github.com/mowgliph/zivlo/releases)
[![Downloads](https://img.shields.io/github/downloads/mowgliph/zivlo/latest/total)](https://github.com/mowgliph/zivlo/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/github/license/mowgliph/zivlo?style=for-the-badge&color=00D97E)](LICENSE)

> **Cobra en segundos. Sin internet. Sin complicaciones.**

Zivlo convierte tu Android en una caja registradora completa. Escanea productos con la cámara, cobra en efectivo o tarjeta e imprime el recibo en segundos — sin necesidad de internet ni hardware costoso.

---

## ✨ Características

- 📷 **Escaneo de código de barras** — Usa la cámara del teléfono para escanear EAN, QR, Code128, UPC-A
- 🛒 **Carrito de compras** — Agrega ítems, modifica cantidades, aplica descuentos
- 💵 **Múltiples métodos de pago** — Efectivo, tarjeta, pago mixto con calculadora de cambio
- 🖨️ **Impresión Bluetooth** — Conecta impresoras térmicas de 58mm/80mm sin cables
- 📊 **Historial de ventas** — Consulta transacciones por fecha con resumen diario
- 📦 **Gestión de catálogo** — Crea y edita productos con stock y categorías
- 🚫 **100% offline** — Funciona sin internet, sin suscripciones, sin complicaciones

---

## 🎯 ¿Para quién es Zivlo?

- 🏪 **Tiendas de abarrotes** — Negocios con catálogo fijo y alto volumen de ventas
- 🛒 **Supermercados pequeños** — Requieren rapidez en caja con múltiples cajeros
- 🎪 **Stands de exposición** — Facturación temporal sin infraestructura de red
- 🚚 **Vendedores ambulantes** — Movilidad total, sin punto fijo
- 💼 **Emprendedores** — Presupuesto limitado, necesidad de empezar rápido

---

## 📥 Descargas

### Última Versión

| Arquitectura | Dispositivos | Descarga |
|-------------|--------------|----------|
| **arm64-v8a** | Modernos (64-bit) | [Descargar APK](https://github.com/mowgliph/zivlo/releases/latest/download/zivlo-latest-arm64-v8a.apk) |
| armeabi-v7a | Antiguos (32-bit) | [Descargar APK](https://github.com/mowgliph/zivlo/releases/latest/download/zivlo-latest-armeabi-v7a.apk) |
| x86_64 | Emuladores | [Descargar APK](https://github.com/mowgliph/zivlo/releases/latest/download/zivlo-latest-x86_64.apk) |

📦 **Google Play**: [Zivlo en Play Store](#) (próximamente)

🔐 **Verificar Integridad**: [checksums-latest.txt](https://github.com/mowgliph/zivlo/releases/latest/download/checksums-latest.txt)

### Instalación

1. Descargar el APK según tu arquitectura
2. Habilitar "Instalar aplicaciones de fuentes desconocidas" en tu dispositivo Android
3. Abrir el APK descargado y seguir las instrucciones de instalación
4. ¡Listo! La aplicación se instalará automáticamente

### ¿Cuál arquitectura usar?

- **arm64-v8a**: 95% de dispositivos Android modernos (2019+) - **Recomendado**
- **armeabi-v7a**: Dispositivos anteriores a 2019
- **x86_64**: Solo emuladores de Android Studio

---

## 🏗️ Arquitectura

Zivlo usa **Arquitectura Hexagonal/Clean Architecture** para mantener el código limpio, testeable y escalable.

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (Flutter, BLoCs, Widgets, UI)        │
├─────────────────────────────────────────┤
│       Application Layer                 │
│  (Use Cases, Either<Failure, T>)        │
├─────────────────────────────────────────┤
│          Domain Layer                   │
│ (Entities, Value Objects, Ports)        │
├─────────────────────────────────────────┤
│      Infrastructure Layer               │
│ (Adapters, Hive, Hardware, Repos)       │
└─────────────────────────────────────────┘
```

### Capas:

1. **Domain** — Reglas de negocio puras, sin dependencias de Flutter
2. **Application** — Casos de uso que orquestan el dominio
3. **Infrastructure** — Implementaciones concretas (Hive, Bluetooth, Cámara)
4. **Presentation** — UI con BLoC pattern para gestión de estado

---

## 🛠️ Stack Tecnológico

| Categoría | Tecnología |
|------------|------------|
| **Framework** | Flutter 3.x, Dart 3.x |
| **Estado** | BLoC (`flutter_bloc`, `bloc`) |
| **Base de Datos** | Hive (NoSQL embebido) |
| **Navegación** | GoRouter |
| **Errores** | fpdart (`Either<Failure, T>`) |
| **Escáner** | `mobile_scanner` |
| **Impresora** | `bluetooth_thermal` |
| **Inyección de Dependencias** | `get_it` |
| **Utils** | `equatable`, `uuid` |

Ver [`docs/Stack.md`](docs/Stack.md) para detalles completos.

---

## 📚 Documentación

La documentación completa está en el directorio [`docs/`](docs/):

| Archivo | Descripción |
|---------|-------------|
| [`PRD.md`](docs/PRD.md) | Requisitos del producto |
| [`Stack.md`](docs/Stack.md) | Stack tecnológico y dependencias |
| [`Design.md`](docs/Design.md) | Especificaciones de diseño por pantalla |
| [`Styles.md`](docs/Styles.md) | Sistema de diseño visual (colores, tipografía) |
| [`Brand.md`](docs/Brand.md) | Identidad de marca y posicionamiento |
| [`Context.md`](docs/Context.md) | Arquitectura y decisiones técnicas |
| [`AppFlow.md`](docs/AppFlow.md) | Flujos de usuario y navegación |

---

## 🔧 Desarrollo

### Modelo de Desarrollo

**Importante**: Este proyecto sigue un modelo de desarrollo donde **GitHub Actions** maneja toda la validación, compilación y publicación.

**En local SOLO escribes código**:
- ❌ No compilar con `flutter build`
- ❌ No ejecutar con `flutter run`
- ❌ No instalar dependencias con `flutter pub get`
- ✅ Escribir código puro
- ✅ Hacer commit
- ✅ GitHub Actions valida automáticamente

### Workflows de GitHub Actions

#### CI/CD (`.github/workflows/ci.yml`)

Se ejecuta en cada push o pull request:

```yaml
✅ flutter analyze      — Análisis estático
✅ flutter test         — Tests unitarios
✅ flutter build apk    — Compilación de release
✅ Upload artifact      — Sube APK como artifact
```

#### Release (`.github/workflows/release.yml`)

Se ejecuta al crear un tag (`v*.*.*`):

```yaml
✅ Build APK
✅ Create GitHub Release
✅ Upload APK al release
```

---

## 🧪 Testing

El proyecto usa TDD (Test-Driven Development) con los siguientes tipos de tests:

```bash
# Tests unitarios de dominio y casos de uso
flutter test test/unit/

# Tests de BLoC
flutter test test/bloc/

# Tests de widgets (opcional, en GitHub Actions)
flutter test test/widget/
```

### Ejemplo de Test:

```dart
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

---

## 🎨 Design System

### Colores

| Nombre | Hex | Uso |
|--------|-----|-----|
| `colorPrimary` | `#1A1A2E` | Azul-negro profundo, fondos |
| `colorAccent` | `#E94560` | Rojo coral, CTAs principales |
| `colorSurface` | `#0F3460` | Azul marino, cards |
| `colorSuccess` | `#00D97E` | Verde, confirmaciones |
| `colorWarning` | `#FFB830` | Ámbar, advertencias |

### Tipografía

- **Display/Números**: `Space Mono` (Google Fonts)
- **Body/UI**: `DM Sans` (Google Fonts)

Ver [`docs/Styles.md`](docs/Styles.md) para especificación completa.

---

## 🔐 Seguridad y Privacidad

- ✅ **Sin telemetría** — No envía datos a servidores externos
- ✅ **Sin analytics** — No hay Firebase, Sentry ni similares
- ✅ **Datos locales** — Todo se almacena en Hive localmente
- ✅ **Permisos mínimos** — Solo `CAMERA` y `BLUETOOTH`
- ✅ **Sin internet** — La app funciona 100% offline

---

## 📦 Roadmap

### MVP (Actual)
- [x] Escaneo de código de barras
- [x] Carrito de compras
- [x] Cobro con múltiples métodos
- [x] Impresión Bluetooth
- [x] Historial de ventas
- [x] Gestión de catálogo

### Futuro (Post-MVP)
- [ ] Sincronización en la nube
- [ ] Múltiples usuarios/cajeros
- [ ] Reportes exportables (PDF, CSV)
- [ ] Gestión de inventario con alertas
- [ ] Integración con pasarelas de pago
- [ ] Modo multi-tienda

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor, lee [`CONTRIBUTING.md`](CONTRIBUTING.md) para detalles sobre cómo contribuir.

### Pasos para contribuir:

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-feature`)
3. Escribe tests para tu código
4. Haz commit (`git commit -m 'feat: agrega nueva feature'`)
5. Push a la rama (`git push origin feature/nueva-feature`)
6. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está licenciado bajo la licencia **MIT**. Ver [`LICENSE`](LICENSE) para detalles.

---

## 📞 Contacto

- **Repositorio**: [github.com/mowgliph/zivlo](https://github.com/mowgliph/zivlo)
- **Issues**: [github.com/mowgliph/zivlo/issues](https://github.com/mowgliph/zivlo/issues)
- **Releases**: [github.com/mowgliph/zivlo/releases](https://github.com/mowgliph/zivlo/releases)

---

## 🙏 Agradecimientos

- **Flutter Team** — Por el framework increíble
- **Comunidad Flutter** — Por los paquetes de hardware
- **Comerciantes latinoamericanos** — Por inspirar este producto

---

<div align="center">

**Hecho con ❤️ para el comercio real**

[`Cobra en segundos. Sin internet. Sin complicaciones.`](https://github.com/mowgliph/zivlo)

</div>
