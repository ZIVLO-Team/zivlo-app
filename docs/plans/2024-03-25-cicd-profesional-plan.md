# CI/CD Profesional - Separación CI y Release Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task.

**Goal:** Implementar CI/CD profesional con separación clara de responsabilidades: CI para validación rápida (analyze + test) y Release para builds y publicación con changelog automático.

**Architecture:** Dos workflows independientes: `ci.yml` (validación en cada push/PR, ~8 min) y `release.yml` (build completo + release en GitHub con tags, ~20 min). Los artifacts se nombran con convención `zivlo-{version}-{architecture}.apk`.

**Tech Stack:** GitHub Actions, Flutter 3.x, conventional commits, requarks/changelog-action, softprops/action-gh-release, SHA256 checksums.

---

## Tarea 1: Modificar `ci.yml` - Eliminar Jobs de Build

**Files:**
- Modify: `.github/workflows/ci.yml`

**Objetivo:** Eliminar los jobs `build-apk` y `build-appbundle` para que CI solo haga validación rápida.

**Paso 1: Leer archivo actual**

```bash
cat .github/workflows/ci.yml
```

**Paso 2: Identificar líneas a eliminar**

Eliminar desde `# Job de build de APK` hasta el final del job `build-appbundle` (aproximadamente líneas 67-120).

**Paso 3: Editar archivo**

Eliminar completamente:
- Job `build-apk` (líneas ~67-93)
- Job `build-appbundle` (líneas ~96-117)
- Job `notify` (líneas ~120-132)

**Paso 4: Verificar que solo queden jobs `analyze` y `test`**

El archivo final debe tener solo:
- Job `analyze` (~3 min)
- Job `test` (~5 min)

**Paso 5: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: remove build jobs for faster validation

CI ahora solo valida código (analyze + test) en ~8 minutos.
Los builds de APK/AppBundle se hacen solo en releases.
"
```

---

## Tarea 2: Mejorar `release.yml` - Naming de APKs y Changelog

**Files:**
- Modify: `.github/workflows/release.yml`

**Objetivo:** Agregar naming personalizado a APKs, changelog automático y estructura profesional de release.

**Paso 1: Leer archivo actual**

```bash
cat .github/workflows/release.yml
```

**Paso 2: Agregar job de checksums**

Agregar después del build:

```yaml
- name: Generate SHA256 Checksums
  run: |
    cd build/app/outputs/flutter-apk
    sha256sum *.apk > checksums.txt
    cd ../../bundle/release
    sha256sum *.aab >> ../../flutter-apk/checksums.txt
    mv ../../flutter-apk/checksums.txt .
```

**Paso 3: Renombrar APKs con convención**

Agregar antes de crear release:

```yaml
- name: Rename APKs with version
  run: |
    VERSION=${{ github.ref_name }}
    cd build/app/outputs/flutter-apk
    mv app-armeabi-v7a-release.apk zivlo-${VERSION}-armeabi-v7a.apk
    mv app-arm64-v8a-release.apk zivlo-${VERSION}-arm64-v8a.apk
    mv app-x86_64-release.apk zivlo-${VERSION}-x86_64.apk
    cd ../bundle/release
    mv app-release.aab zivlo-${VERSION}.aab
```

**Paso 4: Mejorar changelog con conventional commits**

Reemplazar el step `Generate Changelog`:

```yaml
- name: Generate Changelog
  id: changelog
  uses: requarks/changelog-action@v1
  with:
    token: ${{ github.token }}
    tag: ${{ github.ref_name }}
    writeToFile: false
    excludeTypes: chore,docs,style
```

**Paso 5: Mejorar release notes**

Reemplazar el body del release:

```yaml
body: |
  ## 📋 Resumen
  Release ${{ github.ref_name }} de Zivlo - Punto de venta offline-first.

  ## 🚀 Features Nuevas
  ${{ steps.changelog.outputs.changes }}

  ## 📦 Instalación
  1. Descargar APK según arquitectura:
     - **arm64-v8a**: Dispositivos modernos (recomendado)
     - **armeabi-v7a**: Dispositivos antiguos
     - **x86_64**: Emuladores
  2. Habilitar "Instalar apps desconocidas"
  3. Instalar APK

  ## ⚠️ Breaking Changes
  _Ninguno_ - Compatible con versiones anteriores

  ## 📝 Notas
  - Offline-first: No requiere internet
  - Datos almacenados localmente en Hive
  - Requiere Android 6.0+

  ---
  **Full Changelog**: https://github.com/mowgliph/zivlo/compare/${{ github.ref_name }}
```

**Paso 6: Actualizar archivos del release**

Actualizar el campo `files`:

```yaml
files: |
  build/app/outputs/flutter-apk/zivlo-${{ github.ref_name }}-armeabi-v7a.apk
  build/app/outputs/flutter-apk/zivlo-${{ github.ref_name }}-arm64-v8a.apk
  build/app/outputs/flutter-apk/zivlo-${{ github.ref_name }}-x86_64.apk
  build/app/outputs/bundle/release/zivlo-${{ github.ref_name }}.aab
  build/app/outputs/flutter-apk/checksums.txt
```

**Paso 7: Commit**

```bash
git add .github/workflows/release.yml
git commit -m "ci(release): professional release with changelog and named APKs

- Rename APKs: zivlo-{version}-{architecture}.apk
- Generate SHA256 checksums
- Automatic changelog from conventional commits
- Professional release notes template
- Organized assets in GitHub releases
"
```

---

## Tarea 3: Agregar Validación Final en Release

**Files:**
- Modify: `.github/workflows/release.yml`

**Objetivo:** Agregar analyze y test antes del build para asegurar calidad.

**Paso 1: Agregar steps de validación**

Agregar después de `Get dependencies`:

```yaml
- name: Run Flutter Analyze
  run: flutter analyze --no-fatal-infos --no-fatal-warnings

- name: Run Flutter Tests
  run: flutter test test/unit/ test/bloc/
```

**Paso 2: Commit**

```bash
git add .github/workflows/release.yml
git commit -m "ci(release): add validation before build

Run analyze and tests before building to catch issues early.
"
```

---

## Tarea 4: Crear Plantilla de Release Notes

**Files:**
- Create: `.github/RELEASE_TEMPLATE.md`

**Paso 1: Crear archivo con plantilla**

```markdown
# Zivlo {{version}} - {{title}}

## 📋 Resumen
{{description}}

## 🚀 Features Nuevas
{{features}}

## 🐛 Bug Fixes
{{fixes}}

## ⚠️ Breaking Changes
{{breaking}}

## 📦 Instalación
1. Descargar APK según arquitectura:
   - **arm64-v8a**: Dispositivos modernos (recomendado)
   - **armeabi-v7a**: Dispositivos antiguos
   - **x86_64**: Emuladores
2. Habilitar "Instalar apps desconocidas"
3. Instalar APK

## 🔐 Checksums
Verificar integridad: `sha256sum -c checksums-{{version}}.txt`

---
**Full Changelog**: https://github.com/mowgliph/zivlo/compare/{{previous_tag}}...{{version}}
```

**Paso 2: Commit**

```bash
git add .github/RELEASE_TEMPLATE.md
git commit -m "docs: add release notes template

Template for consistent release notes with sections for:
- Features
- Bug fixes
- Breaking changes
- Installation instructions
- Checksums verification
"
```

---

## Tarea 5: Crear Guía de Versionado

**Files:**
- Create: `docs/RELEASES.md`

**Paso 1: Crear guía completa**

```markdown
# Guía de Releases - Zivlo

## 📋 Convención de Versionado

Usamos [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

- **MAJOR**: Cambios incompatibles (breaking changes)
- **MINOR**: Features nuevas (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

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

| Archivo | Descripción | Tamaño |
|---------|-------------|--------|
| `zivlo-{v}-arm64-v8a.apk` | Dispositivos modernos (64-bit) | ~15 MB |
| `zivlo-{v}-armeabi-v7a.apk` | Dispositivos antiguos (32-bit) | ~14 MB |
| `zivlo-{v}-x86_64.apk` | Emuladores | ~16 MB |
| `zivlo-{v}.aab` | Google Play Store | ~20 MB |
| `checksums-{v}.txt` | SHA256 checksums | 1 KB |

## ✅ Checklist de Release

- [ ] Todos los tests pasan en main
- [ ] CHANGELOG.md actualizado (automático)
- [ ] Tag semántico creado
- [ ] Release workflow completado
- [ ] APKs verificados con checksums
- [ ] Release notes revisadas
- [ ] Anunciar en canales (opcional)

## 🔐 Verificar Checksums

```bash
# Descargar checksums
wget https://github.com/mowgliph/zivlo/releases/download/v1.2.0/checksums-v1.2.0.txt

# Verificar APK
sha256sum -c checksums-v1.2.0.txt
```

## ⚠️ Hotfix Release

Para hotfixes urgentes:

```bash
# Crear rama de hotfix
git checkout -b hotfix/critical-fix main

# Hacer fix, commit, merge a main
# Luego crear tag
git tag -a v1.1.1 -m "fix: critical security fix"
git push origin --tags
```

## 📝 Ejemplos

### Feature Release
```bash
git tag -a v1.2.0 -m "feat: checkout feature with 3 payment methods"
git push origin --tags
```

### Bug Fix Release
```bash
git tag -a v1.1.1 -m "fix: scanner crash on Android 12+"
git push origin --tags
```

### Breaking Change Release
```bash
git tag -a v2.0.0 -m "BREAKING: migrate to Flutter 3.20"
git push origin --tags
```
```

**Paso 2: Commit**

```bash
git add docs/RELEASES.md
git commit -m "docs: add comprehensive releases guide

Covers:
- Semantic versioning
- Release workflow
- Artifact verification
- Hotfix procedure
- Examples
"
```

---

## Tarea 6: Actualizar README con Badges de Release

**Files:**
- Modify: `README.md`

**Paso 1: Agregar badges al inicio del README**

Agregar después del título principal:

```markdown
[![CI/CD](https://github.com/mowgliph/zivlo/actions/workflows/ci.yml/badge.svg)](https://github.com/mowgliph/zivlo/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/mowgliph/zivlo?label=latest&color=blue)](https://github.com/mowgliph/zivlo/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/mowgliph/zivlo/latest/total)](https://github.com/mowgliph/zivlo/releases/latest)
```

**Paso 2: Agregar sección de Descargas**

Agregar sección después de "Instalación":

```markdown
## 📥 Descargas

### Última Versión: v1.2.0

| Arquitectura | Dispositivos | Descarga |
|-------------|--------------|----------|
| **arm64-v8a** | Modernos (64-bit) | [Descargar](https://github.com/mowgliph/zivlo/releases/latest/download/zivlo-latest-arm64-v8a.apk) |
| armeabi-v7a | Antiguos (32-bit) | [Descargar](https://github.com/mowgliph/zivlo/releases/latest/download/zivlo-latest-armeabi-v7a.apk) |
| x86_64 | Emuladores | [Descargar](https://github.com/mowgliph/zivlo/releases/latest/download/zivlo-latest-x86_64.apk) |

📦 **Google Play**: [Zivlo en Play Store](#) (próximamente)

🔐 **Verificar**: [checksums-latest.txt](https://github.com/mowgliph/zivlo/releases/latest/download/checksums-latest.txt)
```

**Paso 3: Commit**

```bash
git add README.md
git commit -m "docs: add release badges and download links

- CI/CD status badge
- Latest release badge
- Download count badge
- Download table with architecture options
- Direct links to latest APKs
"
```

---

## Tarea 7: Probar Workflow de Release

**Files:**
- None (testing)

**Paso 1: Crear tag de prueba**

```bash
# Crear tag de prueba
git tag -a v1.2.0-test -m "test: release workflow test"

# Push del tag
git push origin --tags
```

**Paso 2: Monitorear workflow**

```bash
# Ver runs
gh run list --limit 3

# Ver logs del último run
gh run view --log
```

**Paso 3: Verificar artifacts**

Ir a: https://github.com/mowgliph/zivlo/releases/tag/v1.2.0-test

Verificar:
- [ ] 3 APKs con nombres correctos
- [ ] 1 AAB con nombre correcto
- [ ] checksums.txt generado
- [ ] Changelog automático
- [ ] Release notes con formato

**Paso 4: Limpiar tag de prueba**

```bash
# Borrar tag local
git tag -d v1.2.0-test

# Borrar tag remoto
git push origin --delete v1.2.0-test

# Borrar release (manual en GitHub UI)
```

**Paso 5: Commit (si todo funcionó)**

```bash
git commit --allow-empty -m "test: verify release workflow

Release workflow tested successfully with v1.2.0-test
All artifacts generated correctly.
"
```

---

## Tarea 8: Crear CHANGELOG.md Inicial

**Files:**
- Create: `CHANGELOG.md`

**Paso 1: Crear changelog inicial**

```markdown
# Changelog

Todos los cambios notables en este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2024-03-24

### Added
- Feature: Scanner completo con detección de códigos de barras
- Feature: Catálogo con CRUD de productos
- Feature: Checkout con 3 métodos de pago (efectivo, tarjeta, mixto)
- Feature: Printer con vista previa de recibos
- CI/CD: Workflows separados para CI y Release

### Fixed
- MobileScannerAdapter API para mobile_scanner v5.1.1
- AppSpacing naming consistency
- Type inference en ReceiptWidget

## [1.0.0] - 2024-01-01

### Added
- Proyecto inicial
- Documentación base
- Estructura Clean Architecture
```

**Paso 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: add initial CHANGELOG.md

Start changelog with v1.1.0 (current release) and v1.0.0 (initial).
Format based on Keep a Changelog.
"
```

---

## Criterios de Aceptación

- [ ] `ci.yml` solo tiene jobs `analyze` y `test`
- [ ] `release.yml` genera APKs con nombres `zivlo-{version}-{arch}.apk`
- [ ] `release.yml` genera `checksums.txt` con SHA256
- [ ] `release.yml` usa conventional commits para changelog
- [ ] Release notes tienen formato profesional
- [ ] README tiene badges de CI/CD y release
- [ ] README tiene tabla de descargas
- [ ] `docs/RELEASES.md` guía creada
- [ ] `CHANGELOG.md` inicial creado
- [ ] Workflow de release probado exitosamente

---

## Notas de Implementación

1. **Conventional Commits**: El changelog automático usa los tipos:
   - `feat:` → Features
   - `fix:` → Bug Fixes
   - `BREAKING CHANGE:` → Breaking Changes
   - Se excluyen: `chore:`, `docs:`, `style:`

2. **Arquitecturas APK**:
   - `arm64-v8a`: 95% de dispositivos modernos
   - `armeabi-v7a`: Dispositivos anteriores a 2019
   - `x86_64`: Emuladores de Android Studio

3. **Checksums**: SHA256 para verificar integridad de descargas

4. **Release Workflow**: Se activa solo con tags (`v*.*.*`), no con pushes normales

---

**Plan aprobado para implementación** ✅
