# GUÍA RÁPIDA DE EJECUCIÓN
## Proyecto: Análisis de Ingresos Internacionales IMDB (2000-2020)

**Entorno R:** pruebasVal  
**Última actualización:** Noviembre 2025  
**Versión:** 2.0 (con corrección de heterocedasticidad)

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
source("scripts/02_analisis_exploratorio.R")
source("scripts/03_modelo_regresion.R")
source("scripts/04a_multicolinealidad.R")
source("scripts/04d_heterocedasticidad.R")

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

# Paso 3: Análisis exploratorio (opcional pero recomendado)
source("scripts/02_analisis_exploratorio.R")
# ⏱ Tiempo estimado: 1-2 minutos
# 📁 Genera: 12 gráficos exploratorios

# Paso 4: Estimar modelo
source("scripts/03_modelo_regresion.R")
# ⏱ Tiempo estimado: 1-2 minutos
# 📁 Genera: resultados/modelo/modelo_regresion.rds y gráficos

# Paso 5: Verificar multicolinealidad
source("scripts/04a_multicolinealidad.R")
# ⏱ Tiempo estimado: 30 segundos
# 📁 Genera: VIF, matrices de correlación

# Paso 6: Verificar y corregir heterocedasticidad (IMPORTANTE)
source("scripts/04d_heterocedasticidad.R")
# ⏱ Tiempo estimado: 45 segundos
# 📁 Genera: Errores robustos HC3, comparaciones MCO vs Robust

# Paso 7: Lanzar Shiny App
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
│   │   ├── 09_vif_barplot.png
│   │   ├── 10_hetero_residuos_vs_ajustados.png    [Nuevo v2.0]
│   │   ├── 11_hetero_residuos_cuadrados.png       [Nuevo v2.0]
│   │   ├── 12_hetero_scale_location.png           [Nuevo v2.0]
│   │   ├── 13_comparacion_errores_estandar.png    [Nuevo v2.0]
│   │   ├── 14_intervalos_confianza.png            [Nuevo v2.0]
│   │   └── eda_01 a eda_12 (análisis exploratorio)
│   │
│   ├── tablas/
│   │   ├── valores_faltantes_originales.csv
│   │   ├── estadisticas_descriptivas.csv
│   │   ├── coeficientes_modelo.csv
│   │   ├── metricas_ajuste.csv
│   │   ├── matriz_correlacion.csv
│   │   ├── vif_valores.csv
│   │   ├── pruebas_heterocedasticidad.csv         [Nuevo v2.0]
│   │   ├── comparacion_errores_robustos.csv       [Nuevo v2.0]
│   │   ├── intervalos_confianza_comparacion.csv   [Nuevo v2.0]
│   │   ├── coeficientes_robustos.csv              [Nuevo v2.0]
│   │   └── tabla_comparativa_mco_robust.txt       [Nuevo v2.0]
│   │
│   └── modelo/
│       ├── modelo_regresion.rds
│       ├── resumen_modelo.txt
│       ├── tabla_stargazer.txt
│       └── vcov_robust_hc3.rds                     [Nuevo v2.0]
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

### Problema 6: "¿Qué son los errores robustos y por qué los necesito?"

**Explicación:**
La heterocedasticidad hace que los errores estándar de MCO sean incorrectos, lo que invalida las pruebas t y los intervalos de confianza.

**Solución:**
Los errores robustos de White (HC3) corrigen este problema:
```r
# El script 04d_heterocedasticidad.R hace esto automáticamente
source("scripts/04d_heterocedasticidad.R")

# Para usar errores robustos manualmente:
library(sandwich)
library(lmtest)
coeftest(modelo, vcov = vcovHC(modelo, type = "HC3"))
```

**Impacto:**
- Los coeficientes NO cambian (siguen siendo válidos)
- Los errores estándar SÍ cambian (ahora son correctos)
- Las pruebas de significancia son ahora confiables
- Los intervalos de confianza son más amplios pero correctos

---

## 💡 CONSEJOS Y MEJORES PRÁCTICAS

### 1. Orden de Ejecución

**SIEMPRE ejecuta en este orden:**
```
setup.R → 01_limpieza_datos.R → 02_analisis_exploratorio.R → 
03_modelo_regresion.R → 04a_multicolinealidad.R → 04d_heterocedasticidad.R
```

**IMPORTANTE:** El script `04d_heterocedasticidad.R` debe ejecutarse después del modelo para obtener errores estándar robustos válidos.

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

**R² = 0.5606**
- El modelo explica el 56.06% de la variabilidad en ingresos internacionales
- ✓ Aceptable para ciencias sociales (típicamente R² > 0.5 es bueno)

**RMSE = 92.70 millones USD**
- Error promedio de predicción
- Significa que las predicciones se desvían ±92.7 millones en promedio

**VIF < 5** (VIF máximo = 1.21)
- ✓ No hay multicolinealidad problemática
- Variables independientes no están correlacionadas entre sí

**p-valor < 0.05**
- ✓ Variable es estadísticamente significativa
- Rechazamos que el coeficiente sea cero
- **IMPORTANTE:** Usar p-valores de errores robustos (HC3)

**Coeficiente de Presupuesto = 2.18**
- Por cada millón USD más de presupuesto
- Los ingresos internacionales aumentan 2.18 millones USD
- ROI implícito: 218% (muy rentable)

### Interpretando la Heterocedasticidad

**Test de Breusch-Pagan: p < 0.001**
- ✗ HAY heterocedasticidad presente
- Los errores estándar de MCO NO son confiables

**Test de White: p < 0.001**
- ✗ Confirma heterocedasticidad
- Necesitamos usar errores robustos

**Errores Robustos (HC3)**
- ✓ Corrigen el problema de heterocedasticidad
- Los coeficientes siguen siendo válidos
- Los errores estándar ahora son correctos
- **Usar SIEMPRE estos para inferencia**

**Cambios en Significancia:**
- Intercepto: Pierde significancia (p = 0.030 → 0.099)
- Presupuesto: Mantiene alta significancia (p < 0.001)
- Idioma Inglés: Mantiene significancia (p < 0.001)
- País Fuerte: Sigue no significativo (p = 0.639 → 0.655)
- Duración²: Mantiene significancia (p < 0.001 → 0.017)

---

## 🎓 RECURSOS DE APRENDIZAJE

### Conceptos Básicos

- **Regresión Lineal**: [StatQuest Video](https://www.youtube.com/watch?v=nk2CQITm_eo)
- **R para Principiantes**: [R for Data Science](https://r4ds.had.co.nz/)
- **Interpretación de R²**: [Khan Academy](https://www.khanacademy.org/math/statistics-probability)

### Conceptos Avanzados

- **Multicolinealidad**: Ver `DOCUMENTACION_TECNICA.md` Sección 8.2
- **Heterocedasticidad**: Ver `DOCUMENTACION_TECNICA.md` Sección 8.4
- **Errores Estándar Robustos**: [Robust Standard Errors Explained](https://www.stata.com/support/faqs/statistics/robust-standard-errors/)
- **Test de Breusch-Pagan**: Ver script `04d_heterocedasticidad.R` comentado
- **Test de White**: Prueba más robusta de heterocedasticidad

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

**P: ¿Qué es la heterocedasticidad y por qué debo preocuparme?**  
R: Es cuando la varianza de los errores no es constante. Hace que los errores estándar sean incorrectos, por eso usamos errores robustos de White (HC3) que corrigen este problema.

**P: ¿Debo usar los resultados de MCO o los robustos?**  
R: SIEMPRE usa los resultados con errores robustos (HC3) para inferencia estadística. Los coeficientes son los mismos, pero los p-valores y los IC son más confiables.

**P: ¿Por qué algunos resultados cambian con errores robustos?**  
R: Los errores estándar robustos son generalmente mayores, lo que hace que algunas variables pierdan significancia. Esto es correcto - los resultados de MCO eran demasiado optimistas.

**P: ¿Puedo publicar un paper con estos resultados?**  
R: Los métodos son estándar y válidos. Asegúrate de: 1) Reportar ambos (MCO y robustos), 2) Basar conclusiones en errores robustos, 3) Discutir limitaciones (variables omitidas).

---

## 📝 CHECKLIST DE FINALIZACIÓN

Marca cuando completes cada paso:

- [ ] Entorno `pruebasVal` configurado (`setup.R`)
- [ ] Datos limpios generados (`01_limpieza_datos.R`)
- [ ] Análisis exploratorio completado (`02_analisis_exploratorio.R`)
- [ ] Modelo estimado (`03_modelo_regresion.R`)
- [ ] Multicolinealidad verificada (`04a_multicolinealidad.R`)
- [ ] Heterocedasticidad corregida (`04d_heterocedasticidad.R`) ⭐ IMPORTANTE
- [ ] Gráficos generados (en `resultados/graficos/`)
- [ ] Errores robustos calculados y revisados
- [ ] Shiny App funciona correctamente
- [ ] Resultados revisados e interpretados con errores robustos
- [ ] Documentación leída (`DOCUMENTACION_TECNICA.md`)

---

## 🎉 ¡FELICIDADES!

Si completaste todos los pasos, ahora tienes:

✅ Un modelo de regresión lineal múltiple robusto  
✅ Análisis completo de supuestos (incluida corrección de heterocedasticidad)  
✅ Errores estándar robustos de White (HC3) - estadísticamente válidos  
✅ Visualizaciones profesionales (23+ gráficos)  
✅ Aplicación interactiva Shiny  
✅ Documentación técnica detallada  
✅ Inferencias estadísticas confiables  

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
| 02_analisis_exploratorio.R | Análisis exploratorio (EDA) | scripts/ |
| 03_modelo_regresion.R | Estimación del modelo | scripts/ |
| 04a_multicolinealidad.R | Verificación VIF | scripts/ |
| 04d_heterocedasticidad.R | Corrección de heterocedasticidad | scripts/ |
| app.R | Aplicación Shiny | shiny_app/ |

---

**Última actualización:** Noviembre 2025  
**Entorno:** pruebasVal  
**Versión:** 2.0 - Con corrección de heterocedasticidad mediante errores robustos HC3

*Para soporte adicional, revisa los comentarios dentro de cada script R.*
