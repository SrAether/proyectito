# 🐳 Guía de Uso con Docker

## 🪟 ¿Estás en Windows?

**Ver guía específica:** [`WINDOWS_README.md`](WINDOWS_README.md)

- Usa `run-docker.bat` para CMD
- Usa `run-docker.ps1` para PowerShell
- Usa `run-docker.sh` para Git Bash/WSL

---

## Inicio Rápido (Linux/macOS)

### Opción 1: Script Automatizado (Recomendado)

```bash
# Dar permisos de ejecución al script
chmod +x run-docker.sh

# Construir y arrancar en un solo comando
./run-docker.sh
```

La aplicación estará disponible en: **http://localhost:3838/app**

### Opción 2: Docker Compose Manual

```bash
# Construir la imagen
docker compose build

# Iniciar el contenedor
docker compose up -d

# Ver logs
docker compose logs -f
```

## 📋 Requisitos Previos

- **Docker**: versión 20.10 o superior
- **Docker Compose**: versión 2.0 o superior
- **Sistema Operativo**: Linux, macOS, o Windows con WSL2
- **Memoria RAM**: Mínimo 2GB disponibles
- **Espacio en Disco**: ~2GB para la imagen y datos

### Verificar instalación de Docker:

```bash
docker --version
docker compose version
```

## 🚀 Comandos del Script

El script `run-docker.sh` proporciona los siguientes comandos:

| Comando | Descripción |
|---------|-------------|
| `./run-docker.sh build` | Construir la imagen Docker |
| `./run-docker.sh start` | Iniciar el contenedor |
| `./run-docker.sh stop` | Detener el contenedor |
| `./run-docker.sh restart` | Reiniciar el contenedor |
| `./run-docker.sh logs` | Ver logs en tiempo real |
| `./run-docker.sh status` | Ver estado actual |
| `./run-docker.sh shell` | Acceder al shell del contenedor |
| `./run-docker.sh analysis` | Ejecutar pipeline de análisis |
| `./run-docker.sh clean` | Limpiar recursos Docker |
| `./run-docker.sh help` | Mostrar ayuda |

## 📊 Estructura de la Aplicación

### Puertos Expuestos

- **3838**: Shiny Server (principal)
- **8080**: Puerto alternativo (reservado)

### Directorios Montados (Volúmenes)

Los siguientes directorios se comparten entre tu sistema y el contenedor:

```
./data        → /home/proyecto/data
./resultados  → /home/proyecto/resultados
./shiny_app   → /home/proyecto/shiny_app
./scripts     → /home/proyecto/scripts (solo lectura)
```

Esto significa que:
- ✅ Los cambios en la app Shiny se reflejan inmediatamente
- ✅ Los resultados se guardan en tu sistema local
- ✅ Los datos persisten después de detener el contenedor

## 🔧 Flujo de Trabajo Típico

### Primera Vez

```bash
# 1. Clonar o descargar el proyecto
cd /home/aether/Proyectos/Valeria/proyecto

# 2. Dar permisos al script
chmod +x run-docker.sh

# 3. Construir la imagen (solo primera vez, ~5-10 minutos)
./run-docker.sh build

# 4. Iniciar el contenedor
./run-docker.sh start

# 5. Abrir navegador
# http://localhost:3838/app
```

### Uso Diario

```bash
# Iniciar aplicación
./run-docker.sh start

# Ver si está corriendo
./run-docker.sh status

# Ver logs
./run-docker.sh logs

# Detener cuando termines
./run-docker.sh stop
```

### Desarrollo

```bash
# Editar archivos localmente
# Los cambios en shiny_app/ se reflejan automáticamente

# Si modificas scripts, reinicia:
./run-docker.sh restart

# Para probar cambios en el Dockerfile:
./run-docker.sh clean
./run-docker.sh build
./run-docker.sh start
```

## 🐛 Solución de Problemas

### Problema 1: Puerto 3838 ya en uso

```bash
# Ver qué proceso usa el puerto
sudo lsof -i :3838

# Detener el proceso o cambiar el puerto en docker-compose.yml
# Editar: ports: - "8080:3838"
```

### Problema 2: Contenedor no inicia

```bash
# Ver logs detallados
./run-docker.sh logs

# O con docker compose
docker compose logs imdb-movies-app

# Verificar estado
docker ps -a
```

### Problema 3: Cambios no se reflejan

```bash
# Reiniciar contenedor
./run-docker.sh restart

# Si persiste, reconstruir
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Problema 4: Error al construir imagen

```bash
# Limpiar caché de Docker
docker system prune -a

# Reconstruir desde cero
./run-docker.sh clean
./run-docker.sh build
```

### Problema 5: Dataset no encontrado

```bash
# Verificar que el archivo existe
ls -lh "IMDB Movies 2000 - 2020.csv"

# O en el directorio data/
ls -lh data/

# El contenedor busca en ambas ubicaciones
```

## 📦 Gestión de Recursos

### Ver uso de recursos

```bash
# Estadísticas en tiempo real
docker stats imdb-movies-analysis

# Espacio usado por Docker
docker system df

# Imágenes descargadas
docker images
```

### Limpiar recursos

```bash
# Opción 1: Script (recomendado)
./run-docker.sh clean

# Opción 2: Manual
docker compose down -v
docker system prune -a
```

## 🔒 Seguridad y Buenas Prácticas

### Variables de Entorno

Puedes personalizar variables en `docker-compose.yml`:

```yaml
environment:
  - SHINY_LOG_LEVEL=DEBUG  # INFO, WARNING, ERROR
  - R_REPOS=https://cloud.r-project.org
```

### Límites de Recursos

Para limitar CPU y memoria, edita `docker-compose.yml`:

```yaml
services:
  imdb-movies-app:
    # ... otras configuraciones ...
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          memory: 1G
```

### Healthcheck

El contenedor incluye un healthcheck automático:

```bash
# Ver estado de salud
docker inspect imdb-movies-analysis | grep -A 10 Health
```

## 📊 Pipeline de Análisis

El contenedor ejecuta automáticamente el pipeline al iniciar **si no existen datos limpios**.

### Ejecución Manual del Pipeline

```bash
# Desde fuera del contenedor
./run-docker.sh analysis

# Desde dentro del contenedor
./run-docker.sh shell
cd /home/proyecto
Rscript scripts/01_limpieza_datos.R
Rscript scripts/02_analisis_exploratorio.R
# ... etc
```

### Saltarse el Pipeline Automático

Si ya tienes `data/datos_limpios.csv`, el pipeline se omite.

Para forzar re-ejecución:

```bash
rm data/datos_limpios.csv
./run-docker.sh restart
```

## 🌐 Acceso Remoto

### Opción 1: Túnel SSH

```bash
# En el servidor
./run-docker.sh start

# En tu máquina local
ssh -L 3838:localhost:3838 usuario@servidor

# Abre en navegador: http://localhost:3838/app
```

### Opción 2: Nginx Reverse Proxy

Ejemplo de configuración Nginx:

```nginx
server {
    listen 80;
    server_name tu-dominio.com;

    location /imdb-app/ {
        proxy_pass http://localhost:3838/app/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
```

## 🔄 Actualización del Proyecto

```bash
# 1. Detener contenedor
./run-docker.sh stop

# 2. Actualizar código (git pull, etc.)
git pull origin main

# 3. Reconstruir imagen
./run-docker.sh build

# 4. Reiniciar
./run-docker.sh start
```

## 📝 Archivos Docker Incluidos

| Archivo | Propósito |
|---------|-----------|
| `Dockerfile` | Define la imagen del contenedor |
| `docker-compose.yml` | Orquestación y configuración |
| `docker-entrypoint.sh` | Script de inicio automático |
| `.dockerignore` | Archivos excluidos de la imagen |
| `run-docker.sh` | Script de gestión principal |
| `DOCKER_README.md` | Esta guía |

## 🎯 Ventajas de Usar Docker

✅ **Portabilidad**: Funciona igual en cualquier sistema  
✅ **Reproducibilidad**: Entorno idéntico siempre  
✅ **Aislamiento**: No afecta tu sistema local  
✅ **Facilidad**: Un comando para todo  
✅ **Escalabilidad**: Fácil de replicar  
✅ **Versionado**: Control de versiones de la imagen  

## 🆘 Soporte

### Logs Detallados

```bash
# Logs del contenedor
./run-docker.sh logs

# Logs de un servicio específico
docker compose logs -f imdb-movies-app

# Últimas 100 líneas
docker compose logs --tail=100
```

### Acceso Interactivo

```bash
# Shell interactivo
./run-docker.sh shell

# O directamente
docker exec -it imdb-movies-analysis /bin/bash

# Ejecutar R interactivo
docker exec -it imdb-movies-analysis R
```

### Verificar Instalación

```bash
# Versión de R
docker exec imdb-movies-analysis R --version

# Paquetes instalados
docker exec imdb-movies-analysis R -e "installed.packages()[,c('Package','Version')]"

# Estado de Shiny Server
docker exec imdb-movies-analysis ps aux | grep shiny
```

## 📚 Referencias

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Rocker Project](https://rocker-project.org/)
- [Shiny Server](https://posit.co/products/open-source/shinyserver/)

---

## 🎬 ¡Listo para Analizar!

Una vez iniciado el contenedor, accede a:

### 🌐 http://localhost:3838/app

Disfruta explorando el análisis de películas IMDB 2000-2020! 📊🎥

---

**Versión**: 3.0  
**Actualizado**: Noviembre 2025  
**Proyecto**: Análisis IMDB Movies con Corrección de Heterocedasticidad
