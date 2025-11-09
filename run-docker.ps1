# Script PowerShell para ejecutar el proyecto IMDB Movies con Docker
# Uso: .\run-docker.ps1 [build|start|stop|restart|logs|clean|status]

param(
    [Parameter(Position=0)]
    [ValidateSet('build','start','stop','restart','logs','status','shell','analysis','clean','help','')]
    [string]$Command = ''
)

$PROJECT_NAME = "imdb-movies-analysis"
$IMAGE_NAME = "imdb-movies-app"
$PORT = 3838

# Colores para output
function Write-Header {
    param([string]$Message)
    Write-Host "`n==========================================" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "==========================================" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Verificar Docker
function Test-Docker {
    try {
        $null = docker --version
        return $true
    }
    catch {
        Write-Error "Docker no está instalado o no está en el PATH"
        Write-Host "Por favor instala Docker Desktop para Windows" -ForegroundColor Yellow
        Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
        exit 1
    }
}

# Construir imagen
function Build-Image {
    Write-Header "Construyendo imagen Docker"
    Write-Host ""
    
    docker compose build
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Imagen construida exitosamente"
    } else {
        Write-Error "Error al construir la imagen"
        exit 1
    }
}

# Iniciar contenedor
function Start-Container {
    Write-Header "Iniciando contenedor"
    Write-Host ""
    
    # Verificar si ya está corriendo
    $running = docker ps | Select-String $PROJECT_NAME
    if ($running) {
        Write-Warning "El contenedor ya está corriendo"
        Write-Host ""
        Show-Info
        return
    }
    
    docker compose up -d
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "Contenedor iniciado exitosamente"
        Write-Host ""
        Write-Host "Esperando a que Shiny Server esté listo..." -ForegroundColor Cyan
        Start-Sleep -Seconds 10
        Show-Info
    } else {
        Write-Error "Error al iniciar el contenedor"
        exit 1
    }
}

# Detener contenedor
function Stop-Container {
    Write-Header "Deteniendo contenedor"
    Write-Host ""
    
    docker compose down
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Contenedor detenido"
    } else {
        Write-Warning "El contenedor ya está detenido o no existe"
    }
}

# Reiniciar contenedor
function Restart-Container {
    Write-Header "Reiniciando contenedor"
    Write-Host ""
    
    Stop-Container
    Start-Sleep -Seconds 2
    Start-Container
}

# Ver logs
function Show-Logs {
    Write-Header "Logs del contenedor"
    Write-Host ""
    Write-Host "Presione Ctrl+C para salir" -ForegroundColor Yellow
    Write-Host ""
    
    docker compose logs -f
}

# Mostrar estado
function Show-Status {
    Write-Header "Estado del Contenedor"
    Write-Host ""
    
    $running = docker ps | Select-String $PROJECT_NAME
    if ($running) {
        Write-Success "Contenedor CORRIENDO"
        Write-Host ""
        docker ps | Select-String $PROJECT_NAME
        Write-Host ""
        Show-Info
    } else {
        Write-Warning "Contenedor DETENIDO"
        Write-Host ""
        Write-Host "Para iniciar: .\run-docker.ps1 start" -ForegroundColor Cyan
    }
}

# Acceder al shell
function Enter-Shell {
    Write-Header "Acceso al Shell del Contenedor"
    Write-Host ""
    
    $running = docker ps | Select-String $PROJECT_NAME
    if ($running) {
        Write-Host "Conectando al contenedor..." -ForegroundColor Cyan
        Write-Host "Escribe 'exit' para salir" -ForegroundColor Yellow
        Write-Host ""
        docker exec -it $PROJECT_NAME /bin/bash
    } else {
        Write-Error "El contenedor no está corriendo"
        Write-Host "Inicia el contenedor primero: .\run-docker.ps1 start" -ForegroundColor Yellow
        exit 1
    }
}

# Ejecutar análisis
function Run-Analysis {
    Write-Header "Ejecutando Pipeline de Análisis"
    Write-Host ""
    
    $running = docker ps | Select-String $PROJECT_NAME
    if ($running) {
        docker exec $PROJECT_NAME /bin/bash -c @"
cd /home/proyecto && \
Rscript scripts/01_limpieza_datos.R && \
Rscript scripts/02_analisis_exploratorio.R && \
Rscript scripts/03_modelo_regresion.R && \
Rscript scripts/04a_multicolinealidad.R && \
Rscript scripts/04c_forma_funcional.R && \
Rscript scripts/04d_heterocedasticidad.R
"@
        Write-Success "Pipeline de análisis completado"
    } else {
        Write-Error "El contenedor no está corriendo"
        exit 1
    }
}

# Limpiar recursos
function Clean-Resources {
    Write-Header "Limpiando recursos Docker"
    Write-Host ""
    
    Write-Warning "Esta acción eliminará:"
    Write-Host "  - El contenedor $PROJECT_NAME"
    Write-Host "  - La imagen $IMAGE_NAME"
    Write-Host "  - Volúmenes no utilizados"
    Write-Host ""
    
    $confirm = Read-Host "¿Continuar? (S/N)"
    if ($confirm -eq 'S' -or $confirm -eq 's') {
        docker compose down -v
        docker rmi $IMAGE_NAME 2>$null
        docker volume prune -f
        Write-Success "Limpieza completada"
    } else {
        Write-Warning "Limpieza cancelada"
    }
}

# Mostrar información
function Show-Info {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "   Aplicación IMDB Movies Activa" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 URL de la aplicación:" -ForegroundColor Cyan
    Write-Host "   http://localhost:$PORT/app" -ForegroundColor White
    Write-Host ""
    Write-Host "🐳 Comandos útiles:" -ForegroundColor Cyan
    Write-Host "   .\run-docker.ps1 logs     - Ver logs" -ForegroundColor White
    Write-Host "   .\run-docker.ps1 stop     - Detener aplicación" -ForegroundColor White
    Write-Host "   .\run-docker.ps1 restart  - Reiniciar aplicación" -ForegroundColor White
    Write-Host ""
    Write-Host "📂 Directorios montados:" -ForegroundColor Cyan
    Write-Host "   .\data       - Datos del proyecto" -ForegroundColor White
    Write-Host "   .\resultados - Resultados del análisis" -ForegroundColor White
    Write-Host "   .\shiny_app  - Aplicación Shiny" -ForegroundColor White
    Write-Host ""
}

# Inicio rápido
function Quick-Start {
    Write-Header "Proyecto IMDB Movies - Inicio Rápido"
    Write-Host ""
    Write-Host "Iniciando proyecto..." -ForegroundColor Cyan
    Write-Host ""
    
    # Verificar si la imagen existe
    $imageExists = docker images | Select-String $IMAGE_NAME
    if (-not $imageExists) {
        Write-Host "Imagen no encontrada. Construyendo..." -ForegroundColor Yellow
        Build-Image
        Write-Host ""
    }
    
    Start-Container
}

# Ayuda
function Show-Help {
    Write-Host "Uso: .\run-docker.ps1 [comando]"
    Write-Host ""
    Write-Host "Comandos disponibles:"
    Write-Host "  build      - Construir la imagen Docker"
    Write-Host "  start      - Iniciar el contenedor"
    Write-Host "  stop       - Detener el contenedor"
    Write-Host "  restart    - Reiniciar el contenedor"
    Write-Host "  logs       - Ver logs del contenedor"
    Write-Host "  status     - Ver estado del contenedor"
    Write-Host "  shell      - Acceder al shell del contenedor"
    Write-Host "  analysis   - Ejecutar pipeline de análisis"
    Write-Host "  clean      - Limpiar recursos Docker"
    Write-Host "  help       - Mostrar esta ayuda"
    Write-Host ""
    Write-Host "Ejemplos:"
    Write-Host "  .\run-docker.ps1 build     # Primera vez"
    Write-Host "  .\run-docker.ps1 start     # Iniciar aplicación"
    Write-Host "  .\run-docker.ps1 logs      # Ver logs en tiempo real"
    Write-Host ""
}

# Main
Test-Docker

switch ($Command) {
    'build'    { Build-Image }
    'start'    { Start-Container }
    'stop'     { Stop-Container }
    'restart'  { Restart-Container }
    'logs'     { Show-Logs }
    'status'   { Show-Status }
    'shell'    { Enter-Shell }
    'analysis' { Run-Analysis }
    'clean'    { Clean-Resources }
    'help'     { Show-Help }
    default    { Quick-Start }
}
