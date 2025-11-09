# 🚀 Inicio Rápido - Proyecto IMDB Movies

## Para Usuarios de Windows 🪟

### Opción 1: CMD (Más Simple)
```cmd
cd C:\ruta\a\tu\proyecto
run-docker.bat
```

### Opción 2: PowerShell (Recomendado)
```powershell
cd C:\ruta\a\tu\proyecto
.\run-docker.ps1
```

### Opción 3: Git Bash/WSL
```bash
cd /c/ruta/a/tu/proyecto
chmod +x run-docker.sh
./run-docker.sh
```

## Para Usuarios de Linux/macOS 🐧🍎

```bash
cd /ruta/a/tu/proyecto
chmod +x run-docker.sh
./run-docker.sh
```

## 🌐 Acceso a la Aplicación

Una vez iniciado, abre tu navegador:

**http://localhost:3838/app**

## 📚 Más Información

- **Windows**: Lee [`WINDOWS_README.md`](WINDOWS_README.md)
- **Docker General**: Lee [`DOCKER_README.md`](DOCKER_README.md)
- **Proyecto**: Lee [`README.md`](README.md)

## 🐳 Requisito Único

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Windows: Docker Desktop para Windows
  - macOS: Docker Desktop para Mac
  - Linux: Docker Engine + Docker Compose

## 🎯 Comandos Útiles

### Windows (CMD)
```cmd
run-docker.bat build     # Construir imagen
run-docker.bat start     # Iniciar aplicación
run-docker.bat logs      # Ver logs
run-docker.bat stop      # Detener aplicación
run-docker.bat status    # Ver estado
run-docker.bat help      # Ver todos los comandos
```

### Windows (PowerShell)
```powershell
.\run-docker.ps1 build
.\run-docker.ps1 start
.\run-docker.ps1 logs
.\run-docker.ps1 stop
.\run-docker.ps1 status
.\run-docker.ps1 help
```

### Linux/macOS
```bash
./run-docker.sh build
./run-docker.sh start
./run-docker.sh logs
./run-docker.sh stop
./run-docker.sh status
./run-docker.sh help
```

## ⚡ Primera Ejecución

El script automáticamente:
1. ✅ Construye la imagen Docker (solo primera vez, ~5-10 min)
2. ✅ Instala todos los paquetes de R necesarios
3. ✅ Ejecuta el pipeline de análisis
4. ✅ Inicia la aplicación Shiny
5. ✅ Abre el puerto 3838

## 🎬 ¡Eso es Todo!

No necesitas instalar:
- ❌ R
- ❌ RStudio
- ❌ Paquetes de R
- ❌ Dependencias del sistema

**Solo Docker y ya está! 🚀**

---

**Proyecto**: Análisis IMDB Movies 2000-2020  
**Versión**: 3.0  
**Compatible**: Windows 10/11, Linux, macOS
