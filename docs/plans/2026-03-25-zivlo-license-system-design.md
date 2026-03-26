# Zivlo License System — Diseño de Arquitectura

**Fecha:** 25 de marzo de 2026  
**Estado:** Aprobado para implementación  
**Autor:** Zivlo Development Team

---

## 1. Visión General

Sistema de licencias comercial para transformar Zivlo en una aplicación profesional con modelo de negocio freemium (7 días demo + $1.99/mes). El sistema permite validación offline de licencias vinculadas al dispositivo mediante JWT con firma HMAC.

---

## 2. Problema que Resuelve

| Problema | Solución |
|----------|----------|
| Usuarios prueban la app pero no pagan | Demo de 7 días con bloqueo automático |
| Piratería y compartición de licencias | Licencia vinculada al Android ID del dispositivo |
| Validación en entornos sin internet | JWT con firma HMAC verificable localmente |
| Control de funciones por tipo de licencia | Feature Gatekeeper que valida permisos antes de ejecutar |

---

## 3. Arquitectura del Sistema

```
┌──────────────────────────────────────────────────────────────┐
│                    Zivlo License Ecosystem                   │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────┐         ┌────────────────┐              │
│  │  Zivlo Mobile  │         │ License        │              │
│  │  App           │         │ Generator      │              │
│  │                │         │ (External Repo)│              │
│  │  ┌──────────┐  │         │                │              │
│  │  │ License  │  │         │  ┌──────────┐  │              │
│  │  │ Validator│  │         │  │ HMAC     │  │              │
│  │  │          │  │         │  │ Signer   │  │              │
│  │  └──────────┘  │         │  └──────────┘  │              │
│  │        ▲       │         │        │       │              │
│  │        │       │         │        ▼       │              │
│  │  ┌──────────┐  │         │  ┌──────────┐  │              │
│  │  │ Feature  │  │         │  │ JWT      │  │              │
│  │  │ Gatekeeper│ │         │  │ Generator│  │              │
│  │  └──────────┘  │         │  └──────────┘  │              │
│  │        ▲       │         └────────────────┘              │
│  │        │       │                  │                       │
│  │  ┌──────────┐  │                  ▼                       │
│  │  │ Android  │  │         ┌────────────────┐              │
│  │  │ ID       │──┼────────▶│ Zivlo License  │              │
│  │  │ Extractor│  │         │ (JWT String)   │              │
│  │  └──────────┘  │         └────────────────┘              │
│  └────────────────┘                  │                       │
│                                      │ (Usuario ingresa)     │
│                                      ▼                       │
│                          ┌────────────────┐                  │
│                          │ License        │                  │
│                          │ Validator      │                  │
│                          │ (Mobile App)   │                  │
│                          └────────────────┘                  │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. Componentes Principales

### 4.1 Android ID Extractor

**Responsabilidad:** Obtener identificador único del dispositivo de forma consistente.

```dart
// lib/features/licensing/domain/ports/device_id_provider.dart
abstract class DeviceIdProvider {
  Future<String> getDeviceId();
}

// lib/features/licensing/infrastructure/adapters/android_device_id_provider.dart
class AndroidDeviceIdProvider implements DeviceIdProvider {
  @override
  Future<String> getDeviceId() async {
    // Usar Settings.Secure.ANDROID_ID de Android
    // Fallback a UUID si falla
  }
}
```

**Consideraciones:**
- ANDROID_ID es único por dispositivo + usuario
- Persiste entre reinstalaciones de la app
- Se resetea solo con factory reset del dispositivo

---

### 4.2 License Generator (Repositorio Externo)

**Responsabilidad:** Generar JWT firmado con HMAC-SHA256 para licencias.

**Payload del JWT:**
```json
{
  "deviceId": "abc123def456",
  "issuedAt": "2026-03-25T00:00:00Z",
  "expiresAt": "2026-04-25T00:00:00Z",
  "features": ["pos", "cart", "catalog", "printer", "qr-menu"],
  "licenseType": "monthly",
  "storeId": "tienda-001"
}
```

**Claves de firma:**
- **Secret Key:** Almacenada en variables de entorno del generador
- **Algoritmo:** HMAC-SHA256
- **Librería sugerida:** `dart_jsonwebtoken` o `package:jwt`

---

### 4.3 License Validator (Mobile App)

**Responsabilidad:** Validar JWT localmente sin conexión a internet.

```dart
// lib/features/licensing/domain/ports/license_validator.dart
abstract class LicenseValidator {
  Future<Either<LicenseFailure, License>> validate(String licenseKey);
  Future<bool> isLicenseActive();
  Future<LicenseStatus> getLicenseStatus();
}

enum LicenseStatus {
  demo,
  active,
  expired,
  invalid,
  deviceMismatch,
}
```

**Proceso de validación:**
1. Decodificar JWT (header + payload + signature)
2. Verificar firma HMAC con clave embebida (ofuscada)
3. Validar `deviceId` coincide con dispositivo actual
4. Validar `expiresAt` > fecha actual
5. Retornar `License` si todo es válido

---

### 4.4 Feature Gatekeeper

**Responsabilidad:** Controlar acceso a funciones según estado de licencia.

```dart
// lib/features/licensing/domain/ports/feature_gatekeeper.dart
abstract class FeatureGatekeeper {
  Future<Either<LicenseFailure, void>> checkAccess(Feature feature);
}

enum Feature {
  pos,          // Escanear y cobrar
  cart,         // Carrito de compras
  catalog,      // Agregar/modificar productos
  printer,      // Impresión Bluetooth
  qrMenu,       // Menú QR para clientes
  salesHistory, // Historial de ventas (siempre disponible)
}
```

**Matriz de acceso:**

| Feature | Demo | Activa | Expirada |
|---------|------|--------|----------|
| `pos` | ✅ | ✅ | ❌ |
| `cart` | ✅ | ✅ | ❌ |
| `catalog` | ✅ | ✅ | ❌ |
| `printer` | ✅ | ✅ | ❌ |
| `qrMenu` | ✅ | ✅ | ❌ |
| `salesHistory` | ✅ | ✅ | ✅ (solo lectura) |

---

## 5. Flujo de Activación de Licencia

### 5.1 Primera Instalación (Demo Automática)

```
┌─────────┐     ┌─────────────┐     ┌──────────────┐     ┌──────────┐
│  Usuario│     │  Zivlo App  │     │ Hive Storage │     │  UI      │
└────┬────┘     └──────┬──────┘     └──────┬───────┘     └────┬─────┘
     │                 │                   │                   │
     │ Instalar app    │                   │                   │
     │────────────────▶│                   │                   │
     │                 │                   │                   │
     │                 │ Generar Device ID │                   │
     │                 │──────────────────▶│                   │
     │                 │                   │                   │
     │                 │ Guardar           │                   │
     │                 │ demoStartDate     │                   │
     │                 │──────────────────▶│                   │
     │                 │                   │                   │
     │                 │                   │ Mostrar           │
     │                 │                   │ "Demo: 7 días"    │
     │                 │──────────────────────────────────────▶│
     │                 │                   │                   │
```

---

### 5.2 Validación en Checkout

```dart
// lib/features/licensing/domain/usecases/check_license_for_checkout.dart
class CheckLicenseForCheckout {
  final LicenseValidator _validator;
  
  Future<Either<LicenseFailure, void>> execute() async {
    final status = await _validator.getLicenseStatus();
    
    if (status == LicenseStatus.expired || 
        status == LicenseStatus.invalid) {
      return Left(LicenseFailure.expired);
    }
    
    if (status == LicenseStatus.demo) {
      final daysRemaining = await _calculateDemoDaysRemaining();
      if (daysRemaining <= 0) {
        return Left(LicenseFailure.demoExpired);
      }
    }
    
    return Right(unit);
  }
}
```

---

### 5.3 Ingreso de Licencia

```
┌─────────┐     ┌─────────────┐     ┌──────────────┐     ┌──────────┐
│  Usuario│     │  Zivlo App  │     │ License      │     │  UI      │
│         │     │             │     │ Validator    │     │          │
└────┬────┘     └──────┬──────┘     └──────┬───────┘     └────┬─────┘
     │                 │                   │                   │
     │ Ingresa        │                   │                   │
     │ licencia       │                   │                   │
     │────────────────▶│                   │                   │
     │                 │                   │                   │
     │                 │ Validar JWT       │                   │
     │                 │──────────────────▶│                   │
     │                 │                   │                   │
     │                 │                   │ Verificar firma   │
     │                 │                   │ Verificar deviceId│
     │                 │                   │ Verificar expiry  │
     │                 │                   │                   │
     │                 │◀──────────────────│                   │
     │                 │ Either<Failure,   │                   │
     │                 │ License>          │                   │
     │                 │                   │                   │
     │                 │ Guardar licencia  │                   │
     │                 │ en Hive           │                   │
     │                 │──────────────────────────────────────▶│
     │                 │                   │                   │
     │◀─────────────────────────────────────────────────────────│
     │ "✅ Licencia activada hasta 2026-04-25"                  │
     │                 │                   │                   │
```

---

## 6. Protección Anti-Manipulación

### 6.1 Detección de Retroceso de Reloj

```dart
class DemoProtection {
  final Box _hiveBox;
  
  Future<bool> isClockTampered() async {
    final now = DateTime.now();
    final lastKnownDate = _hiveBox.get('lastKnownDate');
    
    if (lastKnownDate != null && now.isBefore(lastKnownDate)) {
      // El usuario atrasó el reloj
      return true;
    }
    
    // Actualizar lastKnownDate
    await _hiveBox.put('lastKnownDate', now);
    return false;
  }
}
```

### 6.2 Persistencia Multi-Capa de Demo Start Date

| Capa | Ubicación | Propósito |
|------|-----------|-----------|
| Primaria | Hive Box (`license_box`) | Almacenamiento principal |
| Secundaria | SharedPreferences | Backup si Hive se corrompe |
| Terciaria | Archivo oculto (`.zivlo_demo`) | Persistencia extra |

**Lógica de recuperación:**
```dart
DateTime _getDemoStartDate() {
  // Intentar Hive primero
  // Si falla, intentar SharedPreferences
  // Si falla, intentar archivo oculto
  // Si todo falla, usar fecha actual (primera instalación)
}
```

### 6.3 Ofuscación de Clave HMAC

```dart
// lib/core/security/hmac_key_obfuscator.dart
class HmacKeyObfuscator {
  // Clave dividida y ofuscada
  static const _part1 = 'aGVsbG8td29ybGQ=';
  static const _part2 = 'c2VjcmV0LWtleQ==';
  
  static String getSecretKey() {
    // Decodificar y combinar en runtime
    return base64Decode(_part1) + base64Decode(_part2);
  }
}
```

---

## 7. Modelo de Datos

### 7.1 License Entity

```dart
// lib/features/licensing/domain/entities/license.dart
class License extends Equatable {
  final String deviceId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final List<Feature> features;
  final LicenseType licenseType;
  final String storeId;
  
  const License({
    required this.deviceId,
    required this.issuedAt,
    required this.expiresAt,
    required this.features,
    required this.licenseType,
    required this.storeId,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isDemo => licenseType == LicenseType.demo;
  
  @override
  List<Object?> get props => [deviceId, expiresAt, features];
}

enum LicenseType { demo, monthly, annual }
```

### 7.2 LicenseFailure

```dart
// lib/features/licensing/domain/entities/license_failure.dart
sealed class LicenseFailure extends Equatable {
  const LicenseFailure();
  
  String get message;
  
  @override
  List<Object?> get props => [];
}

class LicenseFailureExpired extends LicenseFailure {
  const LicenseFailureExpired();
  
  @override
  String get message => 'Licencia expirada. Renueva para continuar.';
}

class LicenseFailureDeviceMismatch extends LicenseFailure {
  const LicenseFailureDeviceMismatch();
  
  @override
  String get message => 'Licencia no válida para este dispositivo.';
}

class LicenseFailureInvalidSignature extends LicenseFailure {
  const LicenseFailureInvalidSignature();
  
  @override
  String get message => 'Licencia inválida. Verifica el código.';
}

class LicenseFailureDemoExpired extends LicenseFailure {
  const LicenseFailureDemoExpired();
  
  @override
  String get message => 'Período de demo de 7 días finalizado.';
}
```

---

## 8. UI/UX de Licencias

### 8.1 Pantalla de Activación

```
┌─────────────────────────────────────────────┐
│  ⚙️ Activar Zivlo                           │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ Código de Registro:                   │ │
│  │ ABC123-DEF456-GHI789                  │ │
│  │                                       │ │
│  │ [Copiar] [Compartir]                  │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  Envía este código al desarrollador para   │
│  obtener tu licencia.                       │
│                                             │
│  ─────────── o ───────────                  │
│                                             │
│  ¿Ya tienes licencia?                       │
│  ┌───────────────────────────────────────┐ │
│  │ Ingresa tu código de licencia:        │ │
│  │ ┌───────────────────────────────────┐ │ │
│  │ │ eyJhbGciOiJIUzI1NiIsInR5cCI6...   │ │ │
│  │ └───────────────────────────────────┘ │ │
│  │                                       │ │
│  │           [Activar Licencia]          │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  💰 Plan Mensual: $1.99                     │
│  ✅ Escaneo ilimitado                       │
│  ✅ Carrito y cobro                         │
│  ✅ Impresión Bluetooth                     │
│  ✅ Menú QR para clientes                   │
│  ✅ Soporte técnico                         │
└─────────────────────────────────────────────┘
```

### 8.2 Pantalla de Bloqueo (Demo Expirada)

```
┌─────────────────────────────────────────────┐
│  ⚠️ Licencia Expirada                       │
│                                             │
│  Tu período de demo de 7 días ha            │
│  finalizado.                                │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │                                       │ │
│  │  Para continuar usando Zivlo:         │ │
│  │                                       │ │
│  │  💰 $1.99/mes                         │ │
│  │     Cancela cuando quieras            │ │
│  │                                       │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [ Ver Planes ]     [ Ingresar Licencia ]  │
│                                             │
│  ─────────────────────────────────────────  │
│                                             │
│  ¿Problemas? [Contactar Soporte]            │
└─────────────────────────────────────────────┘
```

### 8.3 Banner de Demo Activa

```
┌─────────────────────────────────────────────┐
│  📦 Demo: 5 días restantes                  │
│  [Activar Licencia]                         │
└─────────────────────────────────────────────┘
```

---

## 9. Estructura de Directorios

```
lib/features/licensing/
├── domain/
│   ├── entities/
│   │   ├── license.dart
│   │   ├── license_failure.dart
│   │   └── feature.dart
│   ├── ports/
│   │   ├── device_id_provider.dart
│   │   ├── license_validator.dart
│   │   ├── license_repository.dart
│   │   └── feature_gatekeeper.dart
│   └── usecases/
│       ├── get_device_registration_code.dart
│       ├── validate_license.dart
│       ├── check_license_for_checkout.dart
│       └── check_feature_access.dart
│
├── infrastructure/
│   ├── adapters/
│   │   ├── android_device_id_provider.dart
│   │   ├── jwt_license_validator.dart
│   │   └── hive_license_repository.dart
│   ├── models/
│   │   └── license_hive_model.dart
│   └── gatekeepers/
│       └── licensing_feature_gatekeeper.dart
│
└── presentation/
    ├── bloc/
    │   ├── license_bloc.dart
    │   └── license_event.dart
    ├── screens/
    │   ├── license_activation_screen.dart
    │   ├── license_expired_screen.dart
    │   └── license_info_screen.dart
    └── widgets/
        ├── demo_banner.dart
        ├── license_status_card.dart
        └── feature_lock_overlay.dart
```

---

## 10. Dependencias Requeridas

```yaml
# pubspec.yaml
dependencies:
  # JWT para validación de licencias
  dart_jsonwebtoken: ^2.11.0
  
  # Criptografía para HMAC
  crypto: ^3.0.3
  
  # Device Info para Android ID
  device_info_plus: ^9.1.0
  
  # Hive (ya existente)
  hive_flutter: ^1.1.0
  
  # BLoC (ya existente)
  flutter_bloc: ^8.1.3
  
  # fpdart (ya existente)
  fpdart: ^1.1.0
```

---

## 11. Tests Requeridos

### 11.1 Tests Unitarios de Dominio

```dart
// test/features/licensing/domain/usecases/validate_license_test.dart
test('debe retornar License cuando JWT es válido', () async {
  // Arrange
  when(() => mockValidator.validate(validJWT))
    .thenAnswer((_) async => Right(license));
  
  // Act
  final result = await usecase.execute(validJWT);
  
  // Assert
  expect(result, Right(license));
});

test('debe retornar Failure cuando deviceId no coincide', () async {
  // Arrange
  when(() => mockValidator.validate(mismatchJWT))
    .thenAnswer((_) async => Left(LicenseFailureDeviceMismatch()));
  
  // Act
  final result = await usecase.execute(mismatchJWT);
  
  // Assert
  expect(result, Left(LicenseFailureDeviceMismatch()));
});
```

### 11.2 Tests de BLoC

```dart
// test/features/licensing/bloc/license_bloc_test.dart
blocTest<LicenseBloc, LicenseState>(
  'debe emitir [loading, active] cuando validación es exitosa',
  build: () {
    when(() => mockValidator.validate(any()))
      .thenAnswer((_) async => Right(mockLicense));
    return licenseBloc;
  },
  act: (bloc) => bloc.add(ActivateLicense(validJWT)),
  expect: () => [
    LicenseLoading(),
    LicenseActive(mockLicense),
  ],
);
```

### 11.3 Tests de Protección Anti-Manipulación

```dart
// test/features/licensing/domain/usecases/demo_protection_test.dart
test('debe detectar retroceso de reloj', () async {
  // Arrange
  await hiveBox.put('lastKnownDate', DateTime.now().add(Duration(days: 1)));
  
  // Act
  final isTampered = await demoProtection.isClockTampered();
  
  // Assert
  expect(isTampered, true);
});
```

---

## 12. Métricas de Éxito

| Métrica | Objetivo |
|---------|----------|
| Tiempo de validación de licencia | < 500ms |
| Tasa de falsos positivos (bloqueo incorrecto) | < 1% |
| Conversión demo → pago | 30% en primeros 30 días |
| Retención a los 90 días | 70% |

---

## 13. Roadmap de Implementación

### Fase 1: Core de Licencias (Semana 1-2)
- [ ] Implementar `AndroidDeviceIdProvider`
- [ ] Implementar `JwtLicenseValidator`
- [ ] Implementar `HiveLicenseRepository`
- [ ] Crear entidad `License` y `LicenseFailure`
- [ ] Tests unitarios de dominio

### Fase 2: Feature Gatekeeper (Semana 2)
- [ ] Implementar `LicensingFeatureGatekeeper`
- [ ] Integrar con casos de uso existentes (checkout, escaneo, impresión)
- [ ] Tests de integración

### Fase 3: UI de Licencias (Semana 3)
- [ ] Pantalla de activación de licencia
- [ ] Pantalla de licencia expirada
- [ ] Banner de demo activa
- [ ] Overlay de bloqueo de funciones
- [ ] Tests de widgets

### Fase 4: License Generator (Repo Externo) (Semana 3-4)
- [ ] Crear repositorio `zivlo-license-generator`
- [ ] Implementar generación de JWT con HMAC
- [ ] Interfaz web simple para generar licencias
- [ ] Documentación para desarrollador

### Fase 5: Protección y Hardening (Semana 4)
- [ ] Implementar detección de retroceso de reloj
- [ ] Persistencia multi-capa de demo start date
- [ ] Ofuscación de clave HMAC
- [ ] Tests de seguridad

---

## 14. Consideraciones de Seguridad

### 14.1 Clave HMAC

| Riesgo | Mitigación |
|--------|------------|
| Clave embebida en app | Ofuscación + división en múltiples partes |
| Reverse engineering | ProGuard/R8 + ofuscación de nombre de clase |
| Extracción de APK | Análisis estático difícil, clave dividida en runtime |

### 14.2 Recomendaciones Futuras

1. **Certificate Pinning** — Si se agrega validación online
2. **Root/Jailbreak Detection** — Bloquear dispositivos rooteados
3. **License Server** — Validación online opcional para mayor seguridad
4. **Hardware Attestation** — Usar Play Integrity API de Google

---

## 15. Apéndice: Ejemplo de JWT

### Header
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### Payload
```json
{
  "deviceId": "abc123def456",
  "issuedAt": "2026-03-25T00:00:00Z",
  "expiresAt": "2026-04-25T00:00:00Z",
  "features": ["pos", "cart", "catalog", "printer", "qr-menu"],
  "licenseType": "monthly",
  "storeId": "tienda-001"
}
```

### Signature
```
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  "tu-secret-key-aqui"
)
```

---

## 16. Referencias

- [JWT Specification](https://jwt.io/)
- [HMAC-SHA256](https://en.wikipedia.org/wiki/HMAC)
- [Android ID Documentation](https://developer.android.com/reference/android/provider/Settings.Secure#ANDROID_ID)
- [dart_jsonwebtoken Package](https://pub.dev/packages/dart_jsonwebtoken)

---

<div align="center">

**Zivlo License System — v1.0**

*Documento aprobado para implementación*

</div>
