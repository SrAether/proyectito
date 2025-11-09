#!/bin/bash

# Script para ejecutar el proyecto IMDB Movies con Docker
# Uso: ./run-docker.sh [build|start|stop|restart|logs|clean]

set -e

PROJECT_NAME="imdb-movies-analysis"
IMAGE_NAME="imdb-movies-app"
PORT=3838

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones auxiliares
print_header() {
    echo -e "${BLUE}=========================================="
    echo -e "  $1"
    echo -e "==========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función: Construir imagen Docker
build_image() {
    print_header "Construyendo imagen Docker"
    echo ""
    
    if docker compose build; then
        print_success "Imagen construida exitosamente"
    else
        print_error "Error al construir la imagen"
        exit 1
    fi
}

# Función: Iniciar contenedor
start_container() {
    print_header "Iniciando contenedor"
    echo ""
    
    # Verificar si ya está corriendo
    if docker ps | grep -q $PROJECT_NAME; then
        print_warning "El contenedor ya está corriendo"
        echo ""
        print_info
        return 0
    fi
    
    # Iniciar con docker-compose
    if docker compose up -d; then
        echo ""
        print_success "Contenedor iniciado exitosamente"
        echo ""
        
        # Esperar a que el servicio esté listo
        echo "Esperando a que Shiny Server esté listo..."
        sleep 10
        
        print_info
    else
        print_error "Error al iniciar el contenedor"
        exit 1
    fi
}

# Función: Detener contenedor
stop_container() {
    print_header "Deteniendo contenedor"
    echo ""
    
    if docker compose down; then
        print_success "Contenedor detenido"
    else
        print_warning "El contenedor ya está detenido o no existe"
    fi
}

# Función: Reiniciar contenedor
restart_container() {
    print_header "Reiniciando contenedor"
    echo ""
    
    stop_container
    sleep 2
    start_container
}

# Función: Ver logs
view_logs() {
    print_header "Logs del contenedor"
    echo ""
    echo "Presione Ctrl+C para salir"
    echo ""
    
    docker compose logs -f
}

# Función: Limpiar todo
clean_all() {
    print_header "Limpiando recursos Docker"
    echo ""
    
    print_warning "Esta acción eliminará:"
    echo "  - El contenedor $PROJECT_NAME"
    echo "  - La imagen $IMAGE_NAME"
    echo "  - Volúmenes no utilizados"
    echo ""
    
    read -p "¿Continuar? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose down -v
        docker rmi $IMAGE_NAME 2>/dev/null || true
        docker volume prune -f
        print_success "Limpieza completada"
    else
        print_warning "Limpieza cancelada"
    fi
}

# Función: Mostrar información
print_info() {
    echo ""
    echo -e "${GREEN}=========================================="
    echo "   Aplicación IMDB Movies Activa"
    echo -e "==========================================${NC}"
    echo ""
    echo "📊 URL de la aplicación:"
    echo "   http://localhost:$PORT/app"
    echo ""
    echo "🐳 Comandos útiles:"
    echo "   ./run-docker.sh logs     - Ver logs"
    echo "   ./run-docker.sh stop     - Detener aplicación"
    echo "   ./run-docker.sh restart  - Reiniciar aplicación"
    echo ""
    echo "📂 Directorios montados:"
    echo "   ./data       - Datos del proyecto"
    echo "   ./resultados - Resultados del análisis"
    echo "   ./shiny_app  - Aplicación Shiny"
    echo ""
}

# Función: Mostrar estado
show_status() {
    print_header "Estado del Contenedor"
    echo ""
    
    if docker ps | grep -q $PROJECT_NAME; then
        print_success "Contenedor CORRIENDO"
        echo ""
        docker ps | grep $PROJECT_NAME
        echo ""
        print_info
    else
        print_warning "Contenedor DETENIDO"
        echo ""
        echo "Para iniciar: ./run-docker.sh start"
    fi
}

# Función: Acceder al shell del contenedor
shell_access() {
    print_header "Acceso al Shell del Contenedor"
    echo ""
    
    if docker ps | grep -q $PROJECT_NAME; then
        echo "Conectando al contenedor..."
        echo "Escribe 'exit' para salir"
        echo ""
        docker exec -it $PROJECT_NAME /bin/bash
    else
        print_error "El contenedor no está corriendo"
        echo "Inicia el contenedor primero: ./run-docker.sh start"
        exit 1
    fi
}

# Función: Ejecutar pipeline de análisis manualmente
run_analysis() {
    print_header "Ejecutando Pipeline de Análisis"
    echo ""
    
    if docker ps | grep -q $PROJECT_NAME; then
        docker exec $PROJECT_NAME /bin/bash -c "
            cd /home/proyecto && \
            Rscript scripts/01_limpieza_datos.R && \
            Rscript scripts/02_analisis_exploratorio.R && \
            Rscript scripts/03_modelo_regresion.R && \
            Rscript scripts/04a_multicolinealidad.R && \
            Rscript scripts/04c_forma_funcional.R && \
            Rscript scripts/04d_heterocedasticidad.R
        "
        print_success "Pipeline de análisis completado"
    else
        print_error "El contenedor no está corriendo"
        exit 1
    fi
}

# Menú principal
show_usage() {
    echo "Uso: ./run-docker.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  build      - Construir la imagen Docker"
    echo "  start      - Iniciar el contenedor"
    echo "  stop       - Detener el contenedor"
    echo "  restart    - Reiniciar el contenedor"
    echo "  logs       - Ver logs del contenedor"
    echo "  status     - Ver estado del contenedor"
    echo "  shell      - Acceder al shell del contenedor"
    echo "  analysis   - Ejecutar pipeline de análisis"
    echo "  clean      - Limpiar recursos Docker"
    echo "  help       - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./run-docker.sh build     # Primera vez"
    echo "  ./run-docker.sh start     # Iniciar aplicación"
    echo "  ./run-docker.sh logs      # Ver logs en tiempo real"
}

# Main
case "${1:-}" in
    build)
        build_image
        ;;
    start)
        start_container
        ;;
    stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    logs)
        view_logs
        ;;
    status)
        show_status
        ;;
    shell)
        shell_access
        ;;
    analysis)
        run_analysis
        ;;
    clean)
        clean_all
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_header "Proyecto IMDB Movies - Docker Runner"
        echo ""
        
        if [ -z "${1:-}" ]; then
            # Sin argumentos, hacer inicio rápido
            print_warning "Iniciando proyecto (inicio rápido)..."
            echo ""
            
            # Verificar si la imagen existe
            if ! docker images | grep -q $IMAGE_NAME; then
                echo "Imagen no encontrada. Construyendo..."
                build_image
                echo ""
            fi
            
            start_container
        else
            print_error "Comando desconocido: $1"
            echo ""
            show_usage
            exit 1
        fi
        ;;
esac
