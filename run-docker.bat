@echo off
REM Script para ejecutar el proyecto IMDB Movies con Docker en Windows
REM Uso: run-docker.bat [build|start|stop|restart|logs|clean|status]

setlocal enabledelayedexpansion

set PROJECT_NAME=imdb-movies-analysis
set IMAGE_NAME=imdb-movies-app
set PORT=3838

REM Verificar que Docker está instalado
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker no esta instalado o no esta en el PATH
    echo Por favor instala Docker Desktop para Windows
    echo https://www.docker.com/products/docker-desktop
    exit /b 1
)

REM Procesar comando
if "%~1"=="" goto quick_start
if /i "%~1"=="build" goto build
if /i "%~1"=="start" goto start
if /i "%~1"=="stop" goto stop
if /i "%~1"=="restart" goto restart
if /i "%~1"=="logs" goto logs
if /i "%~1"=="status" goto status
if /i "%~1"=="shell" goto shell
if /i "%~1"=="analysis" goto analysis
if /i "%~1"=="clean" goto clean
if /i "%~1"=="help" goto help
goto help

:build
echo ==========================================
echo   Construyendo imagen Docker
echo ==========================================
echo.
docker compose build
if %errorlevel% equ 0 (
    echo [OK] Imagen construida exitosamente
) else (
    echo [ERROR] Error al construir la imagen
    exit /b 1
)
goto end

:start
echo ==========================================
echo   Iniciando contenedor
echo ==========================================
echo.

REM Verificar si ya está corriendo
docker ps | findstr %PROJECT_NAME% >nul 2>nul
if %errorlevel% equ 0 (
    echo [AVISO] El contenedor ya esta corriendo
    echo.
    goto print_info
)

docker compose up -d
if %errorlevel% equ 0 (
    echo.
    echo [OK] Contenedor iniciado exitosamente
    echo.
    echo Esperando a que Shiny Server este listo...
    timeout /t 10 /nobreak >nul
    goto print_info
) else (
    echo [ERROR] Error al iniciar el contenedor
    exit /b 1
)

:stop
echo ==========================================
echo   Deteniendo contenedor
echo ==========================================
echo.
docker compose down
if %errorlevel% equ 0 (
    echo [OK] Contenedor detenido
) else (
    echo [AVISO] El contenedor ya esta detenido o no existe
)
goto end

:restart
echo ==========================================
echo   Reiniciando contenedor
echo ==========================================
echo.
call :stop
timeout /t 2 /nobreak >nul
call :start
goto end

:logs
echo ==========================================
echo   Logs del contenedor
echo ==========================================
echo.
echo Presione Ctrl+C para salir
echo.
docker compose logs -f
goto end

:status
echo ==========================================
echo   Estado del Contenedor
echo ==========================================
echo.
docker ps | findstr %PROJECT_NAME% >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Contenedor CORRIENDO
    echo.
    docker ps | findstr %PROJECT_NAME%
    echo.
    goto print_info
) else (
    echo [AVISO] Contenedor DETENIDO
    echo.
    echo Para iniciar: run-docker.bat start
)
goto end

:shell
echo ==========================================
echo   Acceso al Shell del Contenedor
echo ==========================================
echo.
docker ps | findstr %PROJECT_NAME% >nul 2>nul
if %errorlevel% equ 0 (
    echo Conectando al contenedor...
    echo Escribe 'exit' para salir
    echo.
    docker exec -it %PROJECT_NAME% /bin/bash
) else (
    echo [ERROR] El contenedor no esta corriendo
    echo Inicia el contenedor primero: run-docker.bat start
    exit /b 1
)
goto end

:analysis
echo ==========================================
echo   Ejecutando Pipeline de Analisis
echo ==========================================
echo.
docker ps | findstr %PROJECT_NAME% >nul 2>nul
if %errorlevel% equ 0 (
    docker exec %PROJECT_NAME% /bin/bash -c "cd /home/proyecto && Rscript scripts/01_limpieza_datos.R && Rscript scripts/02_analisis_exploratorio.R && Rscript scripts/03_modelo_regresion.R && Rscript scripts/04a_multicolinealidad.R && Rscript scripts/04c_forma_funcional.R && Rscript scripts/04d_heterocedasticidad.R"
    echo [OK] Pipeline de analisis completado
) else (
    echo [ERROR] El contenedor no esta corriendo
    exit /b 1
)
goto end

:clean
echo ==========================================
echo   Limpiando recursos Docker
echo ==========================================
echo.
echo Esta accion eliminara:
echo   - El contenedor %PROJECT_NAME%
echo   - La imagen %IMAGE_NAME%
echo   - Volumenes no utilizados
echo.
set /p CONFIRM="Continuar? (S/N): "
if /i "%CONFIRM%"=="S" (
    docker compose down -v
    docker rmi %IMAGE_NAME% 2>nul
    docker volume prune -f
    echo [OK] Limpieza completada
) else (
    echo [AVISO] Limpieza cancelada
)
goto end

:print_info
echo.
echo ==========================================
echo    Aplicacion IMDB Movies Activa
echo ==========================================
echo.
echo URL de la aplicacion:
echo    http://localhost:%PORT%/app
echo.
echo Comandos utiles:
echo    run-docker.bat logs     - Ver logs
echo    run-docker.bat stop     - Detener aplicacion
echo    run-docker.bat restart  - Reiniciar aplicacion
echo.
echo Directorios montados:
echo    .\data       - Datos del proyecto
echo    .\resultados - Resultados del analisis
echo    .\shiny_app  - Aplicacion Shiny
echo.
goto :eof

:quick_start
echo ==========================================
echo   Proyecto IMDB Movies - Inicio Rapido
echo ==========================================
echo.
echo Iniciando proyecto...
echo.

REM Verificar si la imagen existe
docker images | findstr %IMAGE_NAME% >nul 2>nul
if %errorlevel% neq 0 (
    echo Imagen no encontrada. Construyendo...
    call :build
    echo.
)

call :start
goto end

:help
echo Uso: run-docker.bat [comando]
echo.
echo Comandos disponibles:
echo   build      - Construir la imagen Docker
echo   start      - Iniciar el contenedor
echo   stop       - Detener el contenedor
echo   restart    - Reiniciar el contenedor
echo   logs       - Ver logs del contenedor
echo   status     - Ver estado del contenedor
echo   shell      - Acceder al shell del contenedor
echo   analysis   - Ejecutar pipeline de analisis
echo   clean      - Limpiar recursos Docker
echo   help       - Mostrar esta ayuda
echo.
echo Ejemplos:
echo   run-docker.bat build     # Primera vez
echo   run-docker.bat start     # Iniciar aplicacion
echo   run-docker.bat logs      # Ver logs en tiempo real
echo.
goto end

:end
endlocal
