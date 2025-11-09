# 🪟 Guía de Docker para Windows

## ✅ Compatibilidad Total con Windows

Sí, el proyecto funciona **perfectamente en Windows**. Tienes 3 opciones para ejecutarlo:

### 📦 Scripts Disponibles

| Script | Uso | Recomendado para |
|--------|-----|------------------|
| `run-docker.bat` | CMD/Command Prompt | Usuarios básicos de Windows |
| `run-docker.ps1` | PowerShell | Usuarios avanzados de Windows |
| `run-docker.sh` | Git Bash/WSL | Desarrolladores con experiencia Unix |

## 🚀 Inicio Rápido en Windows

### Opción 1: CMD (Command Prompt) - Más Simple

```cmd
REM Abrir CMD como Administrador (opcional pero recomendado)
cd C:\ruta\a\tu\proyecto

REM Construir y arrancar
run-docker.bat

REM O paso a paso:
run-docker.bat build
run-docker.bat start
```

### Opción 2: PowerShell - Recomendado

```powershell
# Abrir PowerShell como Administrador
cd C:\ruta\a\tu\proyecto

# Permitir ejecución de scripts (solo primera vez)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Construir y arrancar
.\run-docker.ps1

# O paso a paso:
.\run-docker.ps1 build
.\run-docker.ps1 start
```

### Opción 3: Git Bash / WSL

```bash
cd /c/ruta/a/tu/proyecto
chmod +x run-docker.sh
./run-docker.sh
```

## 📋 Requisitos Previos en Windows

### 1. Docker Desktop para Windows

**Instalación:**
1. Descarga Docker Desktop: https://www.docker.com/products/docker-desktop
2. Ejecuta el instalador
3. Reinicia tu PC cuando se te solicite
4. Abre Docker Desktop y acepta los términos

**Verificar instalación:**
```cmd
docker --version
docker compose version
```

**Requisitos del sistema:**
- Windows 10 64-bit: Pro, Enterprise o Education (Build 19041 o superior)
- Windows 11 64-bit
- WSL 2 habilitado (Docker Desktop lo instala automáticamente)
- Virtualización habilitada en BIOS
- Mínimo 4GB RAM (recomendado 8GB)

### 2. Habilitar WSL 2 (si no está habilitado)

Docker Desktop lo hace automáticamente, pero si tienes problemas:

```powershell
# PowerShell como Administrador
wsl --install
wsl --set-default-version 2

# Reiniciar PC
```

## 🎯 Comandos para Windows

### CMD (run-docker.bat)

```cmd
REM Ver todos los comandos
run-docker.bat help

REM Construir imagen (primera vez)
run-docker.bat build

REM Iniciar aplicación
run-docker.bat start

REM Ver logs
run-docker.bat logs

REM Ver estado
run-docker.bat status

REM Detener
run-docker.bat stop

REM Reiniciar
run-docker.bat restart

REM Acceder al contenedor
run-docker.bat shell

REM Ejecutar análisis completo
run-docker.bat analysis

REM Limpiar todo
run-docker.bat clean
```

### PowerShell (run-docker.ps1)

```powershell
# Ver todos los comandos
.\run-docker.ps1 help

# Construir imagen (primera vez)
.\run-docker.ps1 build

# Iniciar aplicación
.\run-docker.ps1 start

# Ver logs
.\run-docker.ps1 logs

# Ver estado
.\run-docker.ps1 status

# Detener
.\run-docker.ps1 stop

# Reiniciar
.\run-docker.ps1 restart

# Acceder al contenedor
.\run-docker.ps1 shell

# Ejecutar análisis completo
.\run-docker.ps1 analysis

# Limpiar todo
.\run-docker.ps1 clean
```

## 🐛 Problemas Comunes en Windows

### Problema 1: "Docker no está instalado"

**Causa:** Docker Desktop no está corriendo o no está instalado.

**Solución:**
1. Abre Docker Desktop desde el menú Inicio
2. Espera a que el icono de Docker en la bandeja del sistema muestre "Running"
3. Intenta nuevamente

### Problema 2: "WSL 2 installation is incomplete"

**Solución:**
```powershell
# PowerShell como Administrador
wsl --install
wsl --update

# Reiniciar PC
```

### Problema 3: "PowerShell cannot run scripts"

**Causa:** Política de ejecución restrictiva.

**Solución:**
```powershell
# PowerShell como Administrador
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Confirmar con "Y"
```

### Problema 4: "Hardware assisted virtualization is not enabled"

**Causa:** Virtualización deshabilitada en BIOS.

**Solución:**
1. Reinicia el PC y entra al BIOS (usualmente F2, F10, o Del)
2. Busca "Virtualization Technology" o "Intel VT-x" o "AMD-V"
3. Habilítalo
4. Guarda y reinicia

### Problema 5: Rutas con espacios

**Problema:**
```cmd
cd C:\Users\Mi Usuario\Proyectos\proyecto
```

**Solución:**
```cmd
REM Usar comillas
cd "C:\Users\Mi Usuario\Proyectos\proyecto"

REM O mejor, evitar espacios en nombres de carpetas
```

### Problema 6: Puerto 3838 ocupado

**Causa:** Otro proceso usa el puerto 3838.

**Solución:**
```cmd
REM Ver qué proceso usa el puerto
netstat -ano | findstr :3838

REM Matar el proceso (reemplaza PID con el número que viste)
taskkill /PID <PID> /F

REM O cambiar el puerto en docker-compose.yml
```

### Problema 7: Lentitud en Docker Desktop

**Causa:** Configuración de recursos insuficiente.

**Solución:**
1. Abre Docker Desktop
2. Settings → Resources
3. Ajusta:
   - CPUs: 2-4
   - Memory: 4-8 GB
   - Swap: 1-2 GB
4. Apply & Restart

## 📂 Rutas en Windows

### Estructura de Directorios

Cuando ejecutes los scripts, los volúmenes se montarán automáticamente:

```
C:\ruta\a\tu\proyecto\
├── data\              → Montado en el contenedor
├── resultados\        → Montado en el contenedor
├── shiny_app\         → Montado en el contenedor
├── scripts\           → Montado como solo lectura
├── run-docker.bat     ← Usa este en CMD
├── run-docker.ps1     ← Usa este en PowerShell
└── run-docker.sh      ← Usa este en Git Bash/WSL
```

### Acceso desde WSL

Si usas WSL, tus archivos de Windows están en:
```bash
cd /mnt/c/Users/TuUsuario/Proyectos/proyecto
```

## 🌐 Acceso a la Aplicación

Una vez iniciado el contenedor, abre tu navegador favorito:

### 🔗 http://localhost:3838/app

Funciona en:
- ✅ Chrome
- ✅ Firefox
- ✅ Edge
- ✅ Opera
- ✅ Brave

## 🔧 Configuración Avanzada para Windows

### Docker Compose con Rutas de Windows

El archivo `docker-compose.yml` funciona automáticamente en Windows. Docker Desktop convierte las rutas:

```yaml
volumes:
  - ./data:/home/proyecto/data              # Funciona en Windows
  - ./resultados:/home/proyecto/resultados  # Docker Desktop lo maneja
```

### Variables de Entorno en Windows

Para configurar variables personalizadas:

**CMD:**
```cmd
set SHINY_PORT=8080
run-docker.bat start
```

**PowerShell:**
```powershell
$env:SHINY_PORT = "8080"
.\run-docker.ps1 start
```

### Compartir con Docker Desktop

Docker Desktop comparte automáticamente:
- `C:\` - Toda la unidad C
- Otras unidades se pueden agregar en: Settings → Resources → File Sharing

## 📊 Verificación de Instalación

Script de verificación para PowerShell:

```powershell
Write-Host "Verificando requisitos..." -ForegroundColor Cyan

# Docker
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no instalado" -ForegroundColor Red
}

# Docker Compose
try {
    $composeVersion = docker compose version
    Write-Host "✅ Docker Compose: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose no disponible" -ForegroundColor Red
}

# WSL 2
try {
    $wslVersion = wsl --status
    Write-Host "✅ WSL 2 disponible" -ForegroundColor Green
} catch {
    Write-Host "⚠️  WSL 2 no configurado" -ForegroundColor Yellow
}

Write-Host "`n¡Todo listo!" -ForegroundColor Green
```

Guarda como `verificar.ps1` y ejecuta:
```powershell
.\verificar.ps1
```

## 🎨 Integración con VS Code

Para editar el proyecto con Visual Studio Code:

1. Instala la extensión "Remote - Containers"
2. Abre la carpeta del proyecto en VS Code
3. Click en el icono azul de abajo izquierda
4. Selecciona "Reopen in Container"

Ahora puedes editar archivos directamente en el contenedor.

## 🔄 Actualizar el Proyecto

```cmd
REM Detener contenedor
run-docker.bat stop

REM Actualizar código (git pull, copiar archivos, etc.)
git pull

REM Reconstruir imagen con cambios
run-docker.bat build

REM Reiniciar
run-docker.bat start
```

## 📱 Acceso desde Otros Dispositivos

Para acceder desde tu celular o tablet en la misma red:

1. Obtén tu IP local:
   ```cmd
   ipconfig
   REM Busca "IPv4 Address" (ejemplo: 192.168.1.100)
   ```

2. Configura el firewall:
   ```powershell
   # PowerShell como Administrador
   New-NetFirewallRule -DisplayName "Shiny Server" -Direction Inbound -LocalPort 3838 -Protocol TCP -Action Allow
   ```

3. Accede desde otro dispositivo:
   ```
   http://192.168.1.100:3838/app
   ```

## 💾 Backup de Datos en Windows

Script para backup automático (PowerShell):

```powershell
# backup.ps1
$fecha = Get-Date -Format "yyyy-MM-dd_HHmmss"
$destino = ".\backups\backup_$fecha"

New-Item -ItemType Directory -Path $destino -Force

Copy-Item -Path ".\data" -Destination "$destino\data" -Recurse
Copy-Item -Path ".\resultados" -Destination "$destino\resultados" -Recurse

Write-Host "Backup creado: $destino" -ForegroundColor Green

# Comprimir
Compress-Archive -Path $destino -DestinationPath "$destino.zip"
Remove-Item -Path $destino -Recurse
```

## 🆘 Soporte Adicional

### Logs Detallados

```cmd
REM Ver logs completos
docker compose logs --tail=500 > logs.txt
notepad logs.txt
```

### Reinicio Limpio

```cmd
REM Detener todo
run-docker.bat stop

REM Limpiar Docker
docker system prune -a

REM Reiniciar Docker Desktop
REM (desde la bandeja del sistema)

REM Reconstruir desde cero
run-docker.bat build
run-docker.bat start
```

## 📚 Referencias Windows

- [Docker Desktop para Windows](https://docs.docker.com/desktop/install/windows-install/)
- [WSL 2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)

---

## 🎬 ¡Todo Listo para Windows!

El proyecto está completamente optimizado para Windows. Elige el script que prefieras:

- 🟦 **Principiante**: `run-docker.bat` (CMD)
- 🔷 **Intermedio**: `run-docker.ps1` (PowerShell)
- 🐧 **Avanzado**: `run-docker.sh` (Git Bash/WSL)

**¡Disfruta tu análisis de películas IMDB!** 🎥📊

---

**Versión**: 3.0  
**Compatible con**: Windows 10/11, WSL2, Docker Desktop  
**Actualizado**: Noviembre 2025
