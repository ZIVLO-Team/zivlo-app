# ⚡ Inicio Rápido - Zivlo

## 🚀 Inicializar Repositorio (3 pasos)

### Paso 1: Ejecutar script de inicialización

```bash
cd /home/mowgli/zivlo
./scripts/init-repo.sh
```

### Paso 2: Crear repositorio en GitHub

1. Ve a https://github.com/new
2. Nombre: **zivlo**
3. Visibilidad: **Privado**
4. Owner: **mowgliph**
5. ❌ NO marcar "Add a README file"
6. ❌ NO marcar "Add .gitignore"
7. ❌ NO marcar "Choose a license"
8. Click en "Create repository"

### Paso 3: Conectar y hacer push

```bash
# Copia y pega estos comandos:
git remote add origin https://github.com/mowgliph/zivlo.git
git branch -M main
git push -u origin main
```

---

## ✅ Verificación

Después del push:

1. **Verifica el repositorio**: https://github.com/mowgliph/zivlo
2. **Verifica Actions**: https://github.com/mowgliph/zivlo/actions
   - El workflow "CI/CD" debería estar corriendo
   - Espera a que todos los jobs estén en verde ✅

---

## 🎯 Primer Release (Opcional)

Para crear el primer release automático con APK:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Esto triggerará el workflow de release que:
- ✅ Compilará el APK
- ✅ Creará release en GitHub
- ✅ Subirá el APK como asset

---

## ⚠️ IMPORTANTE: No Compilar Local

```bash
🚫 NUNCA ejecutes:
   flutter run
   flutter build
   flutter pub get
   flutter analyze
   flutter test

✅ El flujo es:
   1. Escribes código en local
   2. Haces commit
   3. Push a GitHub
   4. GitHub Actions compila y valida
```

---

## 📚 Documentación

| Archivo | Propósito |
|---------|-----------|
| `.qwen/QWEN.md` | Configuración del proyecto |
| `.qwen/AGENTS.md` | Guía para agentes (NO COMPILAR) |
| `INIT.md` | Guía detallada de inicialización |
| `PROJECT_SUMMARY.md` | Resumen completo del proyecto |
| `README.md` | Descripción general |
| `CONTRIBUTING.md` | Cómo contribuir |
| `docs/` | Documentación completa del producto |

---

## 🆘 Problemas Comunes

### Git no está instalado
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install git

# macOS
brew install git

# Windows
winget install Git.Git
```

### Permiso denegado para el script
```bash
chmod +x scripts/init-repo.sh
./scripts/init-repo.sh
```

### Error al hacer push
```bash
# Verifica las credenciales de GitHub
# Usa un Personal Access Token si tienes 2FA activado
# https://github.com/settings/tokens
```

---

## 🎉 Listo!

Una vez completado, tu repositorio tendrá:
- ✅ Estructura hexagonal completa
- ✅ CI/CD configurado con GitHub Actions
- ✅ Releases automáticos de APK
- ✅ Documentación completa
- ✅ Design system implementado
- ✅ Feature Catalog como ejemplo

**Próximo**: Implementar las features restantes (Cart, Scanner, Checkout, etc.)

---

**Recuerda**: Local es SOLO para escribir código. GitHub Actions se encarga del resto! 🚀
