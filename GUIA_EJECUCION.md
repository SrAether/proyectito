# GUÍA RÁPIDA DE EJECUCIÓN
## Proyecto: Análisis de Ingresos Internacionales IMDB (2000-2020)

**Entorno R:** pruebasVal  
**Última actualización:** Noviembre 2025

---

## 📋 LISTA DE VERIFICACIÓN PRE-EJECUCIÓN

Antes de comenzar, asegúrate de tener:

- [ ] R instalado (versión 4.0 o superior)
- [ ] RStudio instalado (recomendado)
- [ ] Archivo "IMDB Movies 2000 - 2020.csv" en el directorio del proyecto
- [ ] Conexión a internet (para instalar paquetes)
- [ ] Al menos 2 GB de espacio libre en disco

---

## 🚀 INICIO RÁPIDO (3 PASOS)

### Opción A: Ejecución Completa Automatizada

```r
# 1. Configurar entorno
source("scripts/setup.R")

# 2. Ejecutar pipeline completo
source("scripts/01_limpieza_datos.R")
source("scripts/03_modelo_regresion.R")
source("scripts/04a_multicolinealidad.R")

# 3. Lanzar aplicación Shiny
library(shiny)
runApp("shiny_app")
```

### Opción B: Ejecución Paso a Paso

Si prefieres ejecutar cada paso y revisar los resultados:

```r
# Paso 1: Configurar entorno (OBLIGATORIO - solo una vez)
source("scripts/setup.R")
# ⏱ Tiempo estimado: 5-10 minutos (instalación de paquetes)

# Paso 2: Limpiar datos
source("scripts/01_limpieza_datos.R")
# ⏱ Tiempo estimado: 2-3 minutos
# 📁 Genera: data/datos_limpios.csv

# Paso 3: Estimar modelo
source("scripts/03_modelo_regresion.R")
# ⏱ Tiempo estimado: 1-2 minutos
# 📁 Genera: resultados/modelo/modelo_regresion.rds y gráficos

# Paso 4: Verificar supuestos (opcional pero recomendado)
source("scripts/04a_multicolinealidad.R")
# ⏱ Tiempo estimado: 30 segundos

# Paso 5: Lanzar Shiny App
library(shiny)
runApp("shiny_app")
# 🌐 Se abrirá en tu navegador
```

---

## 📂 ESTRUCTURA DE ARCHIVOS GENERADOS

Después de ejecutar los scripts, tendrás:

```
proyecto/
│
├── data/
│   ├── IMDB Movies 2000 - 2020.csv     [Original]
│   ├── datos_limpios.csv                [Generado]
│   └── datos_modelo.csv                 [Generado]
│
├── resultados/
│   ├── graficos/
│   │   ├── 01_residuos_vs_ajustados.png
│   │   ├── 02_qq_plot.png
│   │   ├── 03_scale_location.png
│   │   ├── 04_residuos_leverage.png
│   │   ├── 05_residuos_ggplot.png
│   │   ├── 06_reales_vs_predichos.png
│   │   ├── 07_matriz_correlacion_corrplot.png
│   │   ├── 08_matriz_correlacion_ggplot.png
│   │   └── 09_vif_barplot.png
│   │
│   ├── tablas/
│   │   ├── valores_faltantes_originales.csv
│   │   ├── estadisticas_descriptivas.csv
│   │   ├── coeficientes_modelo.csv
│   │   ├── metricas_ajuste.csv
│   │   ├── matriz_correlacion.csv
│   │   └── vif_valores.csv
│   │
│   └── modelo/
│       ├── modelo_regresion.rds
│       ├── resumen_modelo.txt
│       └── tabla_stargazer.txt
```

---

## 🔧 SOLUCIÓN DE PROBLEMAS COMUNES

### Problema 1: "Error: No se encontró el archivo de datos"

**Solución:**
```r
# Verificar ubicación del archivo
file.exists("IMDB Movies 2000 - 2020.csv")

# Si está en otro lugar, especificar ruta completa
# O mover el archivo al directorio del proyecto
```

### Problema 2: "Error al instalar paquete X"

**Solución:**
```r
# Configurar repositorio CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Instalar manualmente el paquete problemático
install.packages("nombre_del_paquete", dependencies = TRUE)

# Actualizar todos los paquetes
update.packages(ask = FALSE)
```

### Problema 3: "Error: objeto 'modelo' no encontrado"

**Causa:** No has ejecutado el script de modelado.

**Solución:**
```r
# Ejecutar primero
source("scripts/03_modelo_regresion.R")

# Verificar que el modelo existe
file.exists("resultados/modelo/modelo_regresion.rds")
```

### Problema 4: Shiny App no carga datos

**Solución:**
```r
# Verificar que los datos limpios existen
file.exists("data/datos_limpios.csv")

# Si no existen, ejecutar limpieza primero
source("scripts/01_limpieza_datos.R")

# Luego relanzar Shiny
runApp("shiny_app")
```

### Problema 5: Error de memoria en R

**Solución:**
```r
# Limpiar ambiente
rm(list = ls())
gc()  # Garbage collection

# Si persiste, aumentar límite de memoria (Windows)
memory.limit(size = 8000)  # 8 GB
```

---

## 💡 CONSEJOS Y MEJORES PRÁCTICAS

### 1. Orden de Ejecución

**SIEMPRE ejecuta en este orden:**
```
setup.R → 01_limpieza_datos.R → 03_modelo_regresion.R → 04a_multicolinealidad.R
```

### 2. Revisar Salidas

Después de cada script, revisa:
- Mensajes en la consola (✓ o ⚠)
- Archivos generados en `resultados/`
- Estadísticas reportadas

### 3. Guardar Workspace

Para no repetir cálculos:
```r
# Al finalizar
save.image("workspace_analisis.RData")

# Para cargar después
load("workspace_analisis.RData")
```

### 4. Modificar Parámetros

Si quieres experimentar con el modelo:

```r
# Cargar datos limpios
datos <- read.csv("data/datos_limpios.csv")

# Agregar transformaciones
datos <- datos %>%
  mutate(
    presupuesto_mill = presupuesto / 1000000,
    ingresos_int_mill = ingresos_internacionales / 1000000
  )

# Estimar modelo alternativo (ejemplo: sin duración²)
modelo_alt <- lm(ingresos_int_mill ~ presupuesto_mill + 
                 idioma_ingles + pais_fuerte, 
                 data = datos)

# Comparar modelos
AIC(modelo, modelo_alt)
BIC(modelo, modelo_alt)
```

### 5. Exportar Resultados

Para compartir resultados:

```r
# Exportar tabla de coeficientes a Excel
library(writexl)
write_xlsx(tabla_coef, "resultados/coeficientes.xlsx")

# Crear reporte HTML
library(rmarkdown)
render("informe.Rmd", output_file = "informe_final.html")
```

---

## 📊 INTERPRETACIÓN RÁPIDA DE RESULTADOS

### ¿Qué significa cada métrica?

**R² = 0.68** (ejemplo)
- El modelo explica el 68% de la variabilidad en ingresos
- ✓ Bueno si > 0.6 en ciencias sociales

**RMSE = 48 millones USD**
- Error promedio de predicción
- Comparar con media de ingresos para relativizar

**VIF < 5**
- ✓ No hay multicolinealidad problemática
- Variables independientes no están muy correlacionadas

**p-valor < 0.05**
- ✓ Variable es estadísticamente significativa
- Rechazamos que el coeficiente sea cero

**Coeficiente de Presupuesto = 1.25**
- Por cada millón USD más de presupuesto
- Los ingresos aumentan 1.25 millones USD

---

## 🎓 RECURSOS DE APRENDIZAJE

### Conceptos Básicos

- **Regresión Lineal**: [StatQuest Video](https://www.youtube.com/watch?v=nk2CQITm_eo)
- **R para Principiantes**: [R for Data Science](https://r4ds.had.co.nz/)
- **Interpretación de R²**: [Khan Academy](https://www.khanacademy.org/math/statistics-probability)

### Conceptos Avanzados

- **Multicolinealidad**: Ver `DOCUMENTACION_TECNICA.md` Sección 8.2
- **Heterocedasticidad**: Ver `DOCUMENTACION_TECNICA.md` Sección 8.4
- **Errores Estándar Robustos**: [Robust Standard Errors](https://www.stata.com/support/faqs/statistics/robust-standard-errors/)

### Tutoriales de R

```r
# Tutoriales interactivos
install.packages("swirl")
library(swirl)
swirl()  # Elegir curso de regresión

# Ayuda en R
?lm           # Ayuda de regresión lineal
?summary.lm   # Ayuda del resumen
help.search("regression")
```

---

## 📧 CONTACTO Y SOPORTE

### Problemas Técnicos

1. **Revisar Documentación**: `README.md` y `DOCUMENTACION_TECNICA.md`
2. **Revisar Comentarios**: Cada script tiene documentación detallada
3. **Logs**: Revisar mensajes de error en la consola de R

### Preguntas Frecuentes

**P: ¿Cuánto tiempo toma ejecutar todo?**  
R: Primera vez (con instalación): ~15-20 min. Ejecuciones posteriores: ~5 min.

**P: ¿Necesito experiencia en R?**  
R: No para ejecutar. Sí para modificar o interpretar a profundidad.

**P: ¿Puedo usar estos scripts con otros datos?**  
R: Sí, pero deberás adaptar nombres de variables y transformaciones.

**P: ¿Los resultados son reproducibles?**  
R: Sí, la semilla aleatoria está fijada en `setup.R` (seed = 123).

**P: ¿Puedo publicar un paper con estos resultados?**  
R: Los métodos son estándar y válidos, pero complementa con análisis robustez.

---

## 📝 CHECKLIST DE FINALIZACIÓN

Marca cuando completes cada paso:

- [ ] Entorno `pruebasVal` configurado (`setup.R`)
- [ ] Datos limpios generados (`01_limpieza_datos.R`)
- [ ] Modelo estimado (`03_modelo_regresion.R`)
- [ ] Supuestos verificados (`04a_multicolinealidad.R`)
- [ ] Gráficos generados (en `resultados/graficos/`)
- [ ] Shiny App funciona correctamente
- [ ] Resultados revisados e interpretados
- [ ] Documentación leída (`DOCUMENTACION_TECNICA.md`)

---

## 🎉 ¡FELICIDADES!

Si completaste todos los pasos, ahora tienes:

✅ Un modelo de regresión lineal múltiple robusto  
✅ Análisis completo de supuestos  
✅ Visualizaciones profesionales  
✅ Aplicación interactiva Shiny  
✅ Documentación técnica detallada  

**Próximos pasos sugeridos:**

1. Experimenta con el modelo (agregar variables, interacciones)
2. Prueba modelos alternativos (log-lineal, polinomial)
3. Segmenta el análisis por género de película
4. Compara con técnicas de machine learning
5. Publica tu análisis (blog, GitHub, paper)

---

## 📚 REFERENCIAS RÁPIDAS

| Documento | Descripción | Ubicación |
|-----------|-------------|-----------|
| README.md | Guía completa del proyecto | Raíz del proyecto |
| DOCUMENTACION_TECNICA.md | Análisis detallado y metodología | Raíz del proyecto |
| setup.R | Configuración del entorno | scripts/ |
| 01_limpieza_datos.R | Limpieza de datos | scripts/ |
| 03_modelo_regresion.R | Estimación del modelo | scripts/ |
| app.R | Aplicación Shiny | shiny_app/ |

---

**Última actualización:** Noviembre 2025  
**Entorno:** pruebasVal  
**Versión:** 1.0

*Para soporte adicional, revisa los comentarios dentro de cada script R.*
