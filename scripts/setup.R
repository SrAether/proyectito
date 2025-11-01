################################################################################
# CONFIGURACIÓN DEL ENTORNO R: pruebasVal
################################################################################
#
# Nombre del Entorno: pruebasVal
# Proyecto: Análisis de Ingresos Internacionales de Películas IMDB
# Propósito: Configurar el entorno R con todos los paquetes necesarios
#           y crear la estructura de directorios del proyecto
#
# Autor: Proyecto Valeria
# Fecha: Noviembre 2025
# Versión: 1.0
#
################################################################################

# ==============================================================================
# SECCIÓN 1: INFORMACIÓN DEL SISTEMA
# ==============================================================================

cat("\n")
cat("===============================================================================\n")
cat("   CONFIGURACIÓN DEL ENTORNO R: pruebasVal\n")
cat("   Proyecto: Análisis de Películas IMDB (2000-2020)\n")
cat("===============================================================================\n\n")

# Mostrar información del sistema
cat("Información del Sistema:\n")
cat(sprintf("  - Sistema Operativo: %s\n", Sys.info()["sysname"]))
cat(sprintf("  - Versión de R: %s\n", R.version.string))
cat(sprintf("  - Directorio de trabajo: %s\n", getwd()))
cat(sprintf("  - Usuario: %s\n", Sys.info()["user"]))
cat("\n")

# ==============================================================================
# SECCIÓN 2: CONFIGURACIÓN DE OPCIONES GLOBALES
# ==============================================================================

cat("Configurando opciones globales de R...\n")

# Configurar repositorio CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Opciones de visualización
options(scipen = 999)          # Desactivar notación científica
options(digits = 4)            # Número de dígitos a mostrar
options(max.print = 100)       # Máximo de líneas a imprimir

# Configuración de encoding
options(encoding = "UTF-8")

# Configuración para gráficos
options(device = "png")

cat("  ✓ Opciones globales configuradas\n\n")

# ==============================================================================
# SECCIÓN 3: LISTA DE PAQUETES REQUERIDOS
# ==============================================================================

cat("Preparando lista de paquetes necesarios...\n\n")

# Lista completa de paquetes requeridos por categoría
paquetes <- list(
  
  # Manipulación y limpieza de datos
  data_manipulation = c(
    "tidyverse",      # Suite completa (dplyr, ggplot2, tidyr, readr, etc.)
    "data.table",     # Manipulación eficiente de grandes datasets
    "lubridate",      # Manejo de fechas
    "stringr"         # Manipulación de strings
  ),
  
  # Modelado estadístico y econométrico
  statistical_modeling = c(
    "car",            # VIF y pruebas de diagnóstico
    "lmtest",         # Pruebas de heterocedasticidad y autocorrelación
    "sandwich",       # Errores estándar robustos
    "AER",            # Variables instrumentales y datos econométricos
    "MASS"            # Funciones estadísticas adicionales
  ),
  
  # Visualización
  visualization = c(
    "ggplot2",        # Ya incluido en tidyverse, pero explícito
    "corrplot",       # Matrices de correlación
    "ggcorrplot",     # Gráficos de correlación con ggplot2
    "gridExtra",      # Organizar múltiples gráficos
    "plotly",         # Gráficos interactivos
    "scales"          # Escalas para gráficos
  ),
  
  # Aplicación Shiny
  shiny_apps = c(
    "shiny",          # Framework para aplicaciones web
    "shinydashboard", # Dashboard para Shiny
    "DT",             # Tablas interactivas
    "shinyWidgets",   # Widgets adicionales para Shiny
    "shinythemes"     # Temas para Shiny
  ),
  
  # Reportes y tablas
  reporting = c(
    "stargazer",      # Tablas de regresión
    "knitr",          # Reportes dinámicos
    "kableExtra"      # Tablas elegantes
  ),
  
  # Utilidades adicionales
  utilities = c(
    "here",           # Manejo de rutas de archivos
    "janitor",        # Limpieza de nombres de columnas
    "skimr",          # Resúmenes de datos
    "moments"         # Asimetría y curtosis
  )
)

# Crear vector único de todos los paquetes
todos_paquetes <- unique(unlist(paquetes))

cat("Paquetes a instalar/verificar:\n")
for (categoria in names(paquetes)) {
  cat(sprintf("\n  %s:\n", gsub("_", " ", categoria)))
  for (pkg in paquetes[[categoria]]) {
    cat(sprintf("    - %s\n", pkg))
  }
}
cat("\n")

# ==============================================================================
# SECCIÓN 4: INSTALACIÓN DE PAQUETES
# ==============================================================================

cat("===============================================================================\n")
cat("Verificando e instalando paquetes...\n")
cat("===============================================================================\n\n")

# Función para instalar paquetes si no están instalados
instalar_si_necesario <- function(paquete) {
  if (!require(paquete, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("  Instalando '%s'...\n", paquete))
    tryCatch({
      install.packages(paquete, dependencies = TRUE, quiet = TRUE)
      library(paquete, character.only = TRUE)
      cat(sprintf("    ✓ '%s' instalado correctamente\n", paquete))
      return(TRUE)
    }, error = function(e) {
      cat(sprintf("    ✗ Error al instalar '%s': %s\n", paquete, e$message))
      return(FALSE)
    })
  } else {
    cat(sprintf("  ✓ '%s' ya está instalado\n", paquete))
    return(TRUE)
  }
}

# Instalar todos los paquetes
paquetes_instalados <- sapply(todos_paquetes, instalar_si_necesario)

# Resumen de instalación
cat("\n")
cat("-------------------------------------------------------------------------------\n")
cat("Resumen de instalación:\n")
cat(sprintf("  Total de paquetes: %d\n", length(paquetes_instalados)))
cat(sprintf("  Instalados correctamente: %d\n", sum(paquetes_instalados)))
cat(sprintf("  Fallos: %d\n", sum(!paquetes_instalados)))

if (any(!paquetes_instalados)) {
  cat("\nPaquetes con problemas:\n")
  cat(paste("  -", names(paquetes_instalados[!paquetes_instalados]), collapse = "\n"))
  cat("\n")
}
cat("-------------------------------------------------------------------------------\n\n")

# ==============================================================================
# SECCIÓN 5: CARGAR PAQUETES PRINCIPALES
# ==============================================================================

cat("Cargando paquetes principales...\n")

paquetes_principales <- c("tidyverse", "car", "lmtest", "sandwich", 
                          "corrplot", "stargazer", "here")

for (pkg in paquetes_principales) {
  suppressPackageStartupMessages(
    library(pkg, character.only = TRUE, quietly = TRUE)
  )
  cat(sprintf("  ✓ %s cargado\n", pkg))
}

cat("\n")

# ==============================================================================
# SECCIÓN 6: CREAR ESTRUCTURA DE DIRECTORIOS
# ==============================================================================

cat("===============================================================================\n")
cat("Creando estructura de directorios del proyecto...\n")
cat("===============================================================================\n\n")

# Definir estructura de directorios
directorios <- c(
  "data",
  "scripts",
  "resultados",
  "resultados/graficos",
  "resultados/tablas",
  "resultados/modelo",
  "shiny_app",
  "shiny_app/www",
  "documentacion"
)

# Crear directorios si no existen
for (dir in directorios) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat(sprintf("  ✓ Creado: %s/\n", dir))
  } else {
    cat(sprintf("  ✓ Ya existe: %s/\n", dir))
  }
}

cat("\n")

# ==============================================================================
# SECCIÓN 7: VERIFICAR ARCHIVO DE DATOS
# ==============================================================================

cat("===============================================================================\n")
cat("Verificando archivo de datos...\n")
cat("===============================================================================\n\n")

# Buscar el archivo de datos
archivo_datos <- "IMDB Movies 2000 - 2020.csv"
rutas_posibles <- c(
  archivo_datos,
  file.path("data", archivo_datos),
  file.path("..", archivo_datos)
)

archivo_encontrado <- FALSE
for (ruta in rutas_posibles) {
  if (file.exists(ruta)) {
    cat(sprintf("  ✓ Archivo de datos encontrado: %s\n", ruta))
    archivo_encontrado <- TRUE
    
    # Intentar leer el archivo para verificar
    tryCatch({
      datos_test <- read.csv(ruta, nrows = 5)
      cat(sprintf("  ✓ Archivo legible (dimensiones: %d filas × %d columnas)\n", 
                  5, ncol(datos_test)))
      cat(sprintf("  ✓ Columnas detectadas: %d\n", ncol(datos_test)))
      
      # Si el archivo no está en data/, copiarlo
      if (ruta != file.path("data", archivo_datos) && 
          !file.exists(file.path("data", archivo_datos))) {
        file.copy(ruta, file.path("data", archivo_datos))
        cat(sprintf("  ✓ Archivo copiado a: data/%s\n", archivo_datos))
      }
      
    }, error = function(e) {
      cat(sprintf("  ⚠ Advertencia: Error al leer el archivo: %s\n", e$message))
    })
    
    break
  }
}

if (!archivo_encontrado) {
  cat("  ⚠ ADVERTENCIA: No se encontró el archivo de datos\n")
  cat("    Por favor, asegúrate de que 'IMDB Movies 2000 - 2020.csv'\n")
  cat("    esté en el directorio del proyecto o en la carpeta 'data/'\n")
}

cat("\n")

# ==============================================================================
# SECCIÓN 8: CONFIGURACIONES ESPECÍFICAS DEL PROYECTO
# ==============================================================================

cat("===============================================================================\n")
cat("Configuraciones específicas del proyecto pruebasVal...\n")
cat("===============================================================================\n\n")

# Variables globales del proyecto
PROYECTO_NOMBRE <- "Análisis de Ingresos Internacionales IMDB"
ENTORNO_NOMBRE <- "pruebasVal"
FECHA_INICIO <- Sys.Date()

# Guardar configuración en el entorno global
assign("PROYECTO_NOMBRE", PROYECTO_NOMBRE, envir = .GlobalEnv)
assign("ENTORNO_NOMBRE", ENTORNO_NOMBRE, envir = .GlobalEnv)
assign("FECHA_INICIO", FECHA_INICIO, envir = .GlobalEnv)

cat(sprintf("  Nombre del Proyecto: %s\n", PROYECTO_NOMBRE))
cat(sprintf("  Nombre del Entorno: %s\n", ENTORNO_NOMBRE))
cat(sprintf("  Fecha de Inicio: %s\n", FECHA_INICIO))
cat("\n")

# Configurar semilla aleatoria para reproducibilidad
set.seed(123)
cat("  ✓ Semilla aleatoria establecida: 123 (para reproducibilidad)\n")

# Configuración de tema para ggplot2
theme_set(theme_minimal() + 
          theme(plot.title = element_text(hjust = 0.5, face = "bold"),
                plot.subtitle = element_text(hjust = 0.5),
                legend.position = "bottom"))
cat("  ✓ Tema de ggplot2 configurado\n")

cat("\n")

# ==============================================================================
# SECCIÓN 9: FUNCIONES AUXILIARES DEL PROYECTO
# ==============================================================================

cat("===============================================================================\n")
cat("Definiendo funciones auxiliares del proyecto...\n")
cat("===============================================================================\n\n")

# Función para guardar gráficos
guardar_grafico <- function(nombre_archivo, plot = last_plot(), 
                           ancho = 10, alto = 6, dpi = 300) {
  ruta <- file.path("resultados", "graficos", nombre_archivo)
  ggsave(ruta, plot = plot, width = ancho, height = alto, dpi = dpi)
  cat(sprintf("  ✓ Gráfico guardado: %s\n", ruta))
}

# Función para guardar tablas
guardar_tabla <- function(tabla, nombre_archivo) {
  ruta <- file.path("resultados", "tablas", nombre_archivo)
  write.csv(tabla, ruta, row.names = FALSE)
  cat(sprintf("  ✓ Tabla guardada: %s\n", ruta))
}

# Función para cargar datos limpios
cargar_datos_limpios <- function() {
  ruta <- file.path("data", "datos_limpios.csv")
  if (file.exists(ruta)) {
    datos <- read.csv(ruta)
    cat(sprintf("  ✓ Datos limpios cargados: %d filas × %d columnas\n", 
                nrow(datos), ncol(datos)))
    return(datos)
  } else {
    cat("  ⚠ Archivo de datos limpios no encontrado\n")
    cat("    Ejecuta primero: source('scripts/01_limpieza_datos.R')\n")
    return(NULL)
  }
}

# Función para mostrar estadísticas descriptivas
mostrar_resumen <- function(datos) {
  cat("\nResumen de los datos:\n")
  cat(sprintf("  - Número de filas: %d\n", nrow(datos)))
  cat(sprintf("  - Número de columnas: %d\n", ncol(datos)))
  cat(sprintf("  - Variables numéricas: %d\n", 
              sum(sapply(datos, is.numeric))))
  cat(sprintf("  - Variables categóricas: %d\n", 
              sum(sapply(datos, function(x) is.character(x) | is.factor(x)))))
  cat(sprintf("  - Valores faltantes totales: %d (%.2f%%)\n", 
              sum(is.na(datos)), 
              100 * sum(is.na(datos)) / (nrow(datos) * ncol(datos))))
}

# Registrar funciones en el entorno global
assign("guardar_grafico", guardar_grafico, envir = .GlobalEnv)
assign("guardar_tabla", guardar_tabla, envir = .GlobalEnv)
assign("cargar_datos_limpios", cargar_datos_limpios, envir = .GlobalEnv)
assign("mostrar_resumen", mostrar_resumen, envir = .GlobalEnv)

cat("  ✓ Funciones auxiliares definidas:\n")
cat("    - guardar_grafico()\n")
cat("    - guardar_tabla()\n")
cat("    - cargar_datos_limpios()\n")
cat("    - mostrar_resumen()\n")
cat("\n")

# ==============================================================================
# SECCIÓN 10: VERIFICACIÓN FINAL Y RESUMEN
# ==============================================================================

cat("===============================================================================\n")
cat("VERIFICACIÓN FINAL DEL ENTORNO\n")
cat("===============================================================================\n\n")

# Verificar componentes críticos
verificaciones <- list(
  "R versión ≥ 4.0" = as.numeric(R.version$major) >= 4,
  "Paquetes core instalados" = all(c("tidyverse", "car", "lmtest") %in% 
                                    installed.packages()[, "Package"]),
  "Directorio data/ existe" = dir.exists("data"),
  "Directorio resultados/ existe" = dir.exists("resultados"),
  "Directorio scripts/ existe" = dir.exists("scripts")
)

cat("Estado de los componentes:\n")
for (nombre in names(verificaciones)) {
  estado <- if (verificaciones[[nombre]]) "✓" else "✗"
  cat(sprintf("  %s %s\n", estado, nombre))
}

cat("\n")
cat("===============================================================================\n")
cat("CONFIGURACIÓN COMPLETADA - ENTORNO: pruebasVal\n")
cat("===============================================================================\n\n")

# Mensaje de éxito
if (all(unlist(verificaciones))) {
  cat("✓ ¡Entorno configurado correctamente!\n\n")
  cat("Próximos pasos:\n")
  cat("  1. Ejecutar limpieza de datos: source('scripts/01_limpieza_datos.R')\n")
  cat("  2. Ejecutar análisis exploratorio: source('scripts/02_analisis_exploratorio.R')\n")
  cat("  3. Ejecutar modelo: source('scripts/03_modelo_regresion.R')\n")
  cat("  4. Verificar supuestos: source('scripts/04a_multicolinealidad.R') [y demás]\n")
  cat("  5. Lanzar Shiny App: runApp('shiny_app')\n\n")
} else {
  cat("⚠ Algunas verificaciones fallaron. Revisa los mensajes anteriores.\n\n")
}

cat("===============================================================================\n")
cat(sprintf("Fecha y hora de configuración: %s\n", Sys.time()))
cat("===============================================================================\n\n")

# ==============================================================================
# FIN DEL SCRIPT
# ==============================================================================
