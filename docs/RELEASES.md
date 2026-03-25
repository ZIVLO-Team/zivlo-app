# Guía de Releases - Zivlo

## 📋 Convención de Versionado

Usamos [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

- **MAJOR**: Cambios incompatibles (breaking changes)
- **MINOR**: Features nuevas (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

Ejemplos:
- `v1.0.0` → Primer release estable
- `v1.1.0` → Features nuevas, compatible
- `v1.1.1` → Bug fix, compatible
- `v2.0.0` → Breaking changes

## 🚀 Flujo de Release

### 1. Preparar Release

```bash
# Asegurar que main está actualizado
git checkout main
git pull origin main

# Verificar que CI pasó
gh run list --limit 1
```

### 2. Crear Tag

```bash
# Tag anotado con mensaje descriptivo
git tag -a v1.2.0 -m "feat: checkout feature complete"

# O para patch release
git tag -a v1.1.1 -m "fix: scanner connection issues"
```

### 3. Push del Tag

```bash
# Push del tag (trigger del release workflow)
git push origin --tags
```

### 4. Monitorear Build

```bash
# Ver progreso del workflow
gh run watch

# O en GitHub: https://github.com/mowgliph/zivlo/actions
```

### 5. Verificar Release

```bash
# Ver release creado
gh release view v1.2.0

# O en GitHub: https://github.com/mowgliph/zivlo/releases/tag/v1.2.0
```

## 📦 Artifacts del Release

Cada release incluye:

| Archivo | Descripción | Tamaño Aprox |
|---------|-------------|--------------|
| `zivlo-{v}-arm64-v8a.apk` | Dispositivos modernos (64-bit) | ~15 MB |
| `zivlo-{v}-armeabi-v7a.apk` | Dispositivos antiguos (32-bit) | ~14 MB |
| `zivlo-{v}-x86_64.apk` | Emuladores | ~16 MB |
| `zivlo-{v}.aab` | Google Play Store | ~20 MB |
| `checksums-{v}.txt` | SHA256 checksums | 1 KB |

### ¿Cuál APK descargar?

- **arm64-v8a**: 95% de dispositivos Android modernos (2019+)
- **armeabi-v7a**: Dispositivos anteriores a 2019
- **x86_64**: Solo emuladores de Android Studio

## ✅ Checklist de Release

Antes de crear el release:

- [ ] Todos los tests pasan en main
- [ ] `flutter analyze` sin errores
- [ ] CHANGELOG.md actualizado
- [ ] Features completas y testeadas
- [ ] Documentación actualizada
- [ ] Version bump en pubspec.yaml
- [ ] Release notes preparadas

## 🔐 Verificar Checksums

### Linux/macOS

```bash
# Verificar checksum de un APK
sha256sum -c checksums-v1.2.0.txt

# Verificar un archivo específico
sha256sum zivlo-v1.2.0-arm64-v8a.apk | grep <checksum>
```

### Windows (PowerShell)

```powershell
# Verificar checksum
Get-FileHash zivlo-v1.2.0-arm64-v8a.apk -Algorithm SHA256
```

### Verificación Manual

```bash
# Calcular checksum local
sha256sum zivlo-v1.2.0-arm64-v8a.apk

# Comparar con checksums.txt
# Deben coincidir exactamente
```

## 🚨 Hotfix Release

Para releases de emergencia (critical bugs):

### Procedimiento

```bash
# 1. Crear branch desde el tag del release
git checkout -b hotfix/scanner-issue v1.1.0

# 2. Aplicar fix
# (hacer cambios necesarios)
git add -A
git commit -m "fix: critical scanner connection issue"

# 3. Merge a main
git checkout main
git merge --no-ff hotfix/scanner-issue

# 4. Crear tag patch
git tag -a v1.1.1 -m "fix: critical scanner connection issue"

# 5. Push
git push origin main --tags
```

### Consideraciones

- **Solo bug fixes**, no features nuevas
- **Testing mínimo requerido** antes de push
- **Comunicar** a usuarios afectados
- **Post-mortem** después del hotfix

## 📚 Ejemplos

### Ejemplo 1: Feature Release (MINOR)

```bash
# Contexto: Nueva feature de historial completada
git checkout main
git pull origin main

# Verificar tests
flutter test

# Crear tag
git tag -a v1.2.0 -m "feat: complete transaction history with filters"

# Push
git push origin --tags

# Release notes en GitHub:
# ## What's New
# - Transaction history view
# - Filter by date, type, amount
# - Export to CSV/PDF
# - Performance improvements
```

### Ejemplo 2: Bug Fix Release (PATCH)

```bash
# Contexto: Fix para crash en scanner
git checkout main
git pull origin main

# Verificar fix
flutter test
flutter analyze

# Crear tag
git tag -a v1.1.1 -m "fix: scanner crash on low-light conditions"

# Push
git push origin --tags

# Release notes:
# ## Bug Fixes
# - Fixed scanner crash in low-light conditions
# - Improved error handling for camera permissions
```

### Ejemplo 3: Breaking Change Release (MAJOR)

```bash
# Contexto: Nueva arquitectura con breaking changes
git checkout main
git pull origin main

# Migración completa testeada
flutter test
# Tests de migración adicionales

# Crear tag
git tag -a v2.0.0 -m "feat: new architecture with improved performance"

# Push
git push origin --tags

# Release notes:
# ## ⚠️ Breaking Changes
# - Minimum Android version: 8.0 → 10.0
# - Database migration required
# - API endpoints updated
#
# ## What's New
# - 50% faster app startup
# - New modern UI
# - Enhanced security
#
# ## Migration Guide
# - Backup data before update
# - Auto-migration on first launch
```

## 🔗 Recursos

- [Semantic Versioning Spec](https://semver.org/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Flutter Build APK](https://docs.flutter.dev/deployment/android)
