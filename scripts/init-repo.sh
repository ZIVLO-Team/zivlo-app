#!/bin/bash

# Zivlo Project Initialization Script
# Este script NO compila ni ejecuta Flutter - solo configura el repositorio

set -e  # Exit on error

echo "🚀 Zivlo - Inicialización del Repositorio"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado. Por favor instálalo primero."
    exit 1
fi
print_success "Git verificado"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml no encontrado. ¿Estás en el directorio correcto?"
    exit 1
fi
print_success "Directorio del proyecto verificado"

# Initialize git repository
print_info "Inicializando repositorio git..."
if [ -d ".git" ]; then
    print_warning "El repositorio git ya existe. Saltando git init."
else
    git init
    print_success "Repositorio git inicializado"
fi

# Add all files
print_info "Agregando archivos al staging..."
git add .
print_success "Archivos agregados"

# Check if main branch exists
if git show-ref --verify --quiet refs/heads/main; then
    print_info "La rama main ya existe"
else
    print_info "Creando rama main..."
    git branch -M main
    print_success "Rama main creada"
fi

# Create initial commit if there are changes
if git diff --cached --quiet; then
    print_warning "No hay cambios para commit. Saltando commit inicial."
else
    print_info "Creando commit inicial..."
    git commit -m "feat: initial project structure with hexagonal architecture

- Clean/Hexagonal Architecture con 4 capas (domain, application, infrastructure, presentation)
- Core layer: error handling, theme, constants
- Catalog feature: entities, value objects, use cases, BLoC
- Design system con colores, tipografía y spacing
- GitHub Actions workflows para CI/CD y releases automáticos
- Documentación completa: PRD, Stack, Design, Styles, Brand, Context, AppFlow
- QWEN.md y AGENTS.md con reglas de no-compilación local
- README, LICENSE, SECURITY, CONTRIBUTING, CHANGELOG

Tech stack:
- Flutter 3.x, Dart 3.x
- BLoC para state management
- Hive para base de datos local
- fpdart para manejo funcional de errores
- GoRouter para navegación
- GetIt para inyección de dependencias

CI/CD:
- GitHub Actions para análisis, tests y build automático
- Release automático de APK al crear tag
- No compilación local - solo código puro"
    print_success "Commit inicial creado"
fi

# Check if remote exists
if git remote -v | grep -q origin; then
    print_info "Remote origin ya configurado"
else
    print_warning "Remote origin no configurado."
    print_info "Para agregar el remote de GitHub, ejecuta:"
    echo ""
    echo "  git remote add origin https://github.com/mowgliph/zivlo.git"
    echo ""
fi

# Show status
echo ""
print_info "Estado del repositorio:"
git status --short

echo ""
echo "=========================================="
echo "✅ Inicialización completada!"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1. Crear repositorio en GitHub:"
echo "   - Ve a https://github.com/new"
echo "   - Nombre: zivlo"
echo "   - Visibilidad: Privado"
echo "   - NO inicializar con README/.gitignore/license"
echo ""
echo "2. Agregar remote y hacer push:"
echo "   git remote add origin https://github.com/mowgliph/zivlo.git"
echo "   git push -u origin main"
echo ""
echo "3. (Opcional) Crear primer release:"
echo "   git tag v1.0.0"
echo "   git push origin v1.0.0"
echo ""
echo "4. Verificar GitHub Actions:"
echo "   - Ve a https://github.com/mowgliph/zivlo/actions"
echo "   - Espera a que los workflows se completen"
echo ""
echo "⚠️  RECORDATORIO IMPORTANTE:"
echo "   - NUNCA ejecutes 'flutter run', 'flutter build', etc. en local"
echo "   - GitHub Actions se encarga de compilar y validar"
echo "   - Local es SOLO para edición de código"
echo ""
echo "📚 Más información en:"
echo "   - .qwen/QWEN.md"
echo "   - .qwen/AGENTS.md"
echo "   - INIT.md"
echo ""
