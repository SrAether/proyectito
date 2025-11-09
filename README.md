# Análisis de Ingresos Internacionales de Películas IMDB (2000-2020)

## � Inicio Rápido con Docker (Recomendado)

### Windows
```cmd
REM CMD
run-docker.bat

REM PowerShell
.\run-docker.ps1
```

### Linux/macOS
```bash
chmod +x run-docker.sh
./run-docker.sh
```

**📖 Guías detalladas:**
- 🪟 Windows: [`WINDOWS_README.md`](WINDOWS_README.md)
- 🐧 Linux/macOS: [`DOCKER_README.md`](DOCKER_README.md)

**🌐 Acceso:** http://localhost:3838/app

---

## �📋 Descripción del Proyecto

Este proyecto implementa un modelo de regresión lineal múltiple para analizar y predecir los ingresos internacionales de películas utilizando datos de IMDB del período 2000-2020. El análisis incluye limpieza de datos, análisis exploratorio, implementación del modelo, verificación de supuestos econométricos y una aplicación Shiny interactiva.

## 🎯 Objetivos

1. **Limpiar y preparar** el conjunto de datos de películas IMDB
2. **Implementar** un modelo de regresión lineal múltiple
3. **Verificar** el cumplimiento de los supuestos del modelo de regresión
4. **Desarrollar** una aplicación Shiny para visualización interactiva
5. **Documentar** todo el proceso metodológico

## 🔬 Modelo Propuesto

El modelo de regresión lineal múltiple relaciona los ingresos internacionales con las siguientes variables:

```
InternationalRevenue_i = β₀ + β₁·Budget_i + β₂·LanguageDummy_i + 
                         β₃·CountryDummy_i + β₄·Runtime_i² + ε_i
```

### Variables del Modelo:

- **Variable Dependiente:**
  - `InternationalRevenue`: Ingresos internacionales de la película

- **Variables Independientes:**
  - `Budget`: Presupuesto de la película
  - `LanguageDummy`: Variable dummy (1 = inglés, 0 = otro idioma)
  - `CountryDummy`: Variable dummy (1 = países con fuerte industria cinematográfica, 0 = otros)
  - `Runtime²`: Duración de la película al cuadrado (captura efectos no lineales)

## 🗂️ Estructura del Proyecto

```
proyecto/
│
├── README.md                           # Este archivo
├── DOCUMENTACION_TECNICA.md            # Documentación técnica detallada
├── requisitos.txt                      # Requisitos del proyecto (original)
│
├── data/                               # Datos
│   ├── IMDB Movies 2000 - 2020.csv    # Dataset original
│   └── datos_limpios.csv              # Dataset procesado
│
├── scripts/                            # Scripts de análisis
│   ├── setup.R                        # Configuración del entorno pruebasVal
│   ├── 01_limpieza_datos.R           # Limpieza y preparación de datos
│   ├── 02_analisis_exploratorio.R    # Análisis exploratorio de datos
│   ├── 03_modelo_regresion.R         # Implementación del modelo
│   ├── 04a_multicolinealidad.R       # Verificación de multicolinealidad
│   ├── 04b_endogeneidad.R            # Verificación de endogeneidad
│   ├── 04c_forma_funcional.R         # Verificación de forma funcional
│   ├── 04d_heterocedasticidad.R      # Verificación de heterocedasticidad
│   └── 04e_autocorrelacion.R         # Verificación de autocorrelación
│
├── resultados/                         # Outputs del análisis
│   ├── graficos/                      # Gráficos generados
│   ├── tablas/                        # Tablas de resultados
│   └── modelo/                        # Modelo guardado y resultados
│
└── shiny_app/                         # Aplicación Shiny
    ├── app.R                          # Aplicación principal
    ├── ui.R                           # Interfaz de usuario (opcional)
    ├── server.R                       # Lógica del servidor (opcional)
    └── www/                           # Recursos estáticos (CSS, imágenes)
```

## 🔧 Configuración del Entorno

### Prerrequisitos

- R (versión 4.0.0 o superior)
- RStudio (recomendado)
- Acceso a internet para instalar paquetes

### Instalación

1. **Clonar o descargar el proyecto:**
   ```bash
   cd /home/aether/Proyectos/Valeria/proyecto
   ```

2. **Configurar el entorno R "pruebasVal":**
   ```r
   source("scripts/setup.R")
   ```

   Este script:
   - Verifica la instalación de R
   - Instala todos los paquetes necesarios
   - Configura el entorno de trabajo
   - Crea las carpetas necesarias

### Paquetes Requeridos

El proyecto utiliza los siguientes paquetes de R:

#### Manipulación y Limpieza de Datos:
- `tidyverse` (incluye dplyr, ggplot2, tidyr, readr)
- `data.table`
- `lubridate`
- `stringr`

#### Modelado Estadístico:
- `car` (VIF, pruebas de diagnóstico)
- `lmtest` (pruebas de heterocedasticidad, autocorrelación)
- `sandwich` (errores estándar robustos)
- `AER` (variables instrumentales)
- `MASS`

#### Visualización:
- `ggplot2`
- `corrplot`
- `gridExtra`
- `plotly`

#### Aplicación Shiny:
- `shiny`
- `shinydashboard`
- `DT`
- `shinyWidgets`

#### Reportes y Tablas:
- `stargazer`
- `knitr`
- `kableExtra`

## 🚀 Guía de Uso

### Opción 1: Docker (Recomendado) 🐳

La forma más rápida y compatible con todos los sistemas operativos:

#### Windows:
```cmd
REM CMD (Command Prompt)
run-docker.bat build
run-docker.bat start

REM PowerShell
.\run-docker.ps1 build
.\run-docker.ps1 start

REM Git Bash/WSL
chmod +x run-docker.sh
./run-docker.sh
```

#### Linux/macOS:
```bash
chmod +x run-docker.sh
./run-docker.sh build
./run-docker.sh start
```

**📖 Ver guías completas:**
- [Guía Docker para Windows](WINDOWS_README.md) - Instrucciones específicas para Windows 10/11
- [Guía Docker General](DOCKER_README.md) - Linux, macOS y configuración avanzada

**Ventajas de usar Docker:**
- ✅ Funciona igual en Windows, Linux y macOS
- ✅ No necesitas instalar R ni paquetes manualmente
- ✅ Entorno reproducible y aislado
- ✅ Un solo comando para todo
- ✅ Actualización automática del pipeline

### Opción 2: Ejecución Manual con R

Si prefieres usar tu instalación local de R:

### Ejecución Paso a Paso

#### 1. Configuración Inicial
```r
# Configurar el entorno
source("scripts/setup.R")
```

#### 2. Limpieza de Datos
```r
# Ejecutar limpieza de datos
source("scripts/01_limpieza_datos.R")
```

Este script:
- Carga el dataset original
- Maneja valores faltantes
- Crea variables dummy
- Transforma variables
- Exporta datos limpios

#### 3. Análisis Exploratorio
```r
# Ejecutar análisis exploratorio
source("scripts/02_analisis_exploratorio.R")
```

Genera:
- Estadísticas descriptivas
- Histogramas y boxplots
- Matriz de correlación
- Gráficos de dispersión

#### 4. Implementación del Modelo
```r
# Ejecutar modelo de regresión
source("scripts/03_modelo_regresion.R")
```

Realiza:
- Estimación del modelo
- Resumen de resultados
- Interpretación de coeficientes
- Gráficos de diagnóstico

#### 5. Verificación de Supuestos

Ejecutar cada script de verificación:

```r
# Multicolinealidad
source("scripts/04a_multicolinealidad.R")

# Endogeneidad
source("scripts/04b_endogeneidad.R")

# Forma Funcional
source("scripts/04c_forma_funcional.R")

# Heterocedasticidad
source("scripts/04d_heterocedasticidad.R")

# Autocorrelación
source("scripts/04e_autocorrelacion.R")
```

#### 6. Ejecución de Todos los Scripts

Para ejecutar todo el análisis de una vez:

```r
# Ejecutar pipeline completo
source("scripts/setup.R")
source("scripts/01_limpieza_datos.R")
source("scripts/02_analisis_exploratorio.R")
source("scripts/03_modelo_regresion.R")
source("scripts/04a_multicolinealidad.R")
source("scripts/04b_endogeneidad.R")
source("scripts/04c_forma_funcional.R")
source("scripts/04d_heterocedasticidad.R")
source("scripts/04e_autocorrelacion.R")
```

### Lanzar la Aplicación Shiny

```r
# Opción 1: Desde RStudio
# Abrir shiny_app/app.R y hacer clic en "Run App"

# Opción 2: Desde consola R
library(shiny)
runApp("shiny_app")

# Opción 3: Con puerto específico
runApp("shiny_app", port = 8080)
```

## 📊 Características de la Aplicación Shiny

La aplicación Shiny incluye las siguientes pestañas:

### 1. **Inicio**
- Descripción del proyecto
- Objetivos del análisis
- Información del dataset

### 2. **Datos**
- Visualización de datos originales y limpios
- Estadísticas descriptivas
- Filtros interactivos
- Descarga de datos

### 3. **Limpieza de Datos**
- Descripción del proceso de limpieza
- Valores faltantes antes/después
- Transformaciones aplicadas
- Visualización comparativa

### 4. **Análisis Exploratorio**
- Distribución de variables
- Gráficos de correlación
- Análisis por categorías
- Gráficos interactivos con Plotly

### 5. **Modelo**
- Ecuación del modelo
- Tabla de coeficientes
- Interpretación de resultados
- Métricas de ajuste (R², RMSE, etc.)

### 6. **Supuestos**
- Resultados de pruebas estadísticas
- Gráficos de diagnóstico
- Interpretación de cada supuesto
- Soluciones implementadas

### 7. **Predicciones**
- Calculadora de predicciones
- Gráficos de residuos
- Intervalos de confianza
- Análisis de influencia

### 8. **Conclusiones**
- Resumen de hallazgos
- Limitaciones del modelo
- Recomendaciones
- Trabajo futuro

## 📈 Resultados Esperados

### Outputs Generados

1. **Datos Limpios:**
   - `data/datos_limpios.csv`

2. **Gráficos:**
   - `resultados/graficos/distribucion_variables.png`
   - `resultados/graficos/matriz_correlacion.png`
   - `resultados/graficos/residuos.png`
   - Y más...

3. **Tablas:**
   - `resultados/tablas/estadisticas_descriptivas.csv`
   - `resultados/tablas/coeficientes_modelo.csv`
   - `resultados/tablas/pruebas_supuestos.csv`

4. **Modelo:**
   - `resultados/modelo/modelo_regresion.rds`
   - `resultados/modelo/resumen_modelo.txt`

## 🔍 Supuestos Verificados

El proyecto verifica los siguientes supuestos del modelo de regresión lineal:

### 1. **Multicolinealidad**
- **Método:** VIF (Variance Inflation Factor)
- **Criterio:** VIF < 5
- **Solución:** Eliminar variables colineales si VIF > 10

### 2. **Endogeneidad**
- **Método:** Test de Hausman, Variables Instrumentales
- **Criterio:** Valor p > 0.05 (no hay endogeneidad)
- **Solución:** Usar 2SLS si hay endogeneidad

### 3. **Forma Funcional**
- **Método:** Test RESET de Ramsey
- **Criterio:** Valor p > 0.05 (forma correcta)
- **Solución:** Agregar términos cuadráticos/logarítmicos

### 4. **Heterocedasticidad**
- **Método:** Test de Breusch-Pagan, Test de White
- **Criterio:** Valor p > 0.05 (homocedasticidad)
- **Solución:** Errores estándar robustos (HC3)

### 5. **Autocorrelación**
- **Método:** Test de Breusch-Godfrey, Durbin-Watson
- **Criterio:** Valor p > 0.05 (no autocorrelación)
- **Solución:** Errores estándar de Newey-West

## 📚 Referencias

- **Dataset:** IMDB Movies 2000-2020
- **Metodología:** Regresión Lineal Múltiple con MCO
- **Software:** R (v4.0+), RStudio, Shiny

## 👥 Equipo

**Proyecto:** Análisis de Ingresos Internacionales de Películas  
**Entorno R:** pruebasVal  
**Fecha:** Noviembre 2025

## 📝 Notas Adicionales

### Consideraciones Importantes:

1. **Valores Faltantes:** Muchas películas no tienen datos de presupuesto o ingresos. El análisis se realiza con casos completos.

2. **Conversión Monetaria:** Todos los valores monetarios deben estar en la misma moneda (USD).

3. **Outliers:** Se identifican y analizan outliers que pueden afectar el modelo.

4. **Causalidad:** Este modelo establece asociaciones, no necesariamente causalidad.

### Limitaciones:

- El modelo no incluye variables de calidad (críticas, premios)
- No considera efectos temporales (tendencias, estacionalidad)
- No incluye variables de competencia o contexto del mercado
- El análisis se limita a películas del período 2000-2020

## 🆘 Solución de Problemas

### Problema: Paquetes no se instalan
```r
# Configurar repositorio CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Instalar manualmente
install.packages("nombre_paquete")
```

### Problema: Error al cargar datos
```r
# Verificar ruta del archivo
getwd()
list.files("data/")

# Cargar con ruta completa
datos <- read.csv("/ruta/completa/IMDB Movies 2000 - 2020.csv")
```

### Problema: Shiny app no se ejecuta
```r
# Verificar que los datos estén cargados
file.exists("data/datos_limpios.csv")

# Revisar consola de errores en RStudio
# Instalar paquetes faltantes
```

## 📞 Contacto y Soporte

Para preguntas o problemas:
1. Revisar la documentación técnica: `DOCUMENTACION_TECNICA.md`
2. Verificar los comentarios en cada script
3. Consultar la ayuda de R: `?funcion_nombre`

## 📄 Licencia

Este proyecto es con fines educativos y de investigación.

---

**¡Gracias por usar este proyecto de análisis de películas IMDB!** 🎬📊
