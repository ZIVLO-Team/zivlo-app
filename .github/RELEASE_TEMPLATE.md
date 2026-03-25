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
   - **arm64-v8a**: Dispositivos modernos (64-bit)
   - **armeabi-v7a**: Dispositivos antiguos (32-bit)
   - **x86_64**: Emuladores
2. Habilitar "Instalar apps desconocidas" en Android
3. Instalar APK

## 🔐 Verificar Integridad
```bash
sha256sum -c checksums-{{version}}.txt
```

## 📝 Notas de la Versión
- Offline-first: No requiere internet
- Datos almacenados localmente en Hive
- Requiere Android 6.0 (API 23) o superior

---
**Comparar cambios**: https://github.com/mowgliph/zivlo/compare/{{previous_tag}}...{{version}}
