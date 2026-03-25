#!/bin/bash
# Script para inicializar proyecto Flutter Android
# Esto se ejecuta SOLO en GitHub Actions, NO localmente

set -e

echo "🔧 Inicializando proyecto Flutter Android..."

# Verificar si ya existe android/
if [ -d "android" ] && [ -f "android/build.gradle" ]; then
    echo "✅ Proyecto Android ya existe"
    # Eliminar test por defecto de Flutter
    rm -f test/widget_test.dart
    exit 0
fi

# Crear proyecto Flutter temporalmente para obtener la estructura Android
echo "📦 Creando estructura Android..."

# Usar flutter create solo para generar la estructura
flutter create --org com.example --project-name zivlo --platforms android .

# Eliminar test por defecto de Flutter
rm -f test/widget_test.dart

echo "✅ Estructura Android creada exitosamente"
