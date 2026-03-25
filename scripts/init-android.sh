#!/bin/bash
# Script para inicializar proyecto Flutter Android
# Esto se ejecuta SOLO en GitHub Actions, NO localmente

set -e

echo "🔧 Inicializando proyecto Flutter Android..."

# Verificar si ya existe android/
if [ -d "android" ] && [ -f "android/build.gradle" ]; then
    echo "✅ Proyecto Android ya existe"
    exit 0
fi

# Crear proyecto Flutter temporalmente para obtener la estructura Android
echo "📦 Creando estructura Android..."

# Usar flutter create solo para generar la estructura
flutter create --org com.example --project-name zivlo --platforms android .

echo "✅ Estructura Android creada exitosamente"
