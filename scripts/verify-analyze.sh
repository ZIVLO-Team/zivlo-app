#!/bin/bash
set -e

echo "🔍 Verificando build del proyecto..."

# 1. Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# 2. Analizar código
echo "🔬 Analizando código..."
flutter analyze --no-fatal-infos --no-fatal-warnings

# 3. Resumen
echo ""
echo "✅ ¡Verificación completada!"
echo ""
