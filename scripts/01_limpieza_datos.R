################################################################################
# SCRIPT 01: LIMPIEZA Y PREPARACIÓN DE DATOS
################################################################################
#
# Proyecto: Análisis de Ingresos Internacionales de Películas IMDB
# Entorno: pruebasVal
# Script: 01_limpieza_datos.R
# 
# Propósito:
#   - Cargar el dataset de películas IMDB (2000-2020)
#   - Limpiar y preparar los datos para el análisis
#   - Crear variables dummy necesarias para el modelo
#   - Transformar variables (ej. Runtime²)
#   - Exportar dataset limpio
#
# Autor: Proyecto Valeria
# Fecha: Noviembre 2025
#
################################################################################

# ==============================================================================
# CONFIGURACIÓN INICIAL
# ==============================================================================

cat("\n")
cat("===============================================================================\n")
cat("  SCRIPT 01: LIMPIEZA Y PREPARACIÓN DE DATOS\n")
cat("  Dataset: IMDB Movies 2000-2020\n")
cat("===============================================================================\n\n")

# Cargar librerías necesarias
suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(janitor)
  library(skimr)
})

cat("✓ Librerías cargadas correctamente\n\n")

# ==============================================================================
# PASO 1: CARGAR DATOS ORIGINALES
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 1: Cargando datos originales...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Intentar cargar desde diferentes ubicaciones
rutas_posibles <- c(
  "IMDB Movies 2000 - 2020.csv",
  "data/IMDB Movies 2000 - 2020.csv",
  "../IMDB Movies 2000 - 2020.csv"
)

datos_originales <- NULL
for (ruta in rutas_posibles) {
  if (file.exists(ruta)) {
    cat(sprintf("  Cargando desde: %s\n", ruta))
    datos_originales <- read.csv(ruta, stringsAsFactors = FALSE)
    break
  }
}

if (is.null(datos_originales)) {
  stop("ERROR: No se encontró el archivo de datos. Por favor verifica la ubicación.")
}

cat(sprintf("  ✓ Datos cargados exitosamente\n"))
cat(sprintf("  ✓ Dimensiones: %d filas × %d columnas\n", 
            nrow(datos_originales), ncol(datos_originales)))
cat(sprintf("  ✓ Período: %d - %d\n", 
            min(datos_originales$year, na.rm = TRUE),
            max(datos_originales$year, na.rm = TRUE)))

# Mostrar las primeras columnas
cat("\n  Columnas del dataset:\n")
cat(paste("   ", names(datos_originales), collapse = "\n"))
cat("\n\n")

# ==============================================================================
# PASO 2: ANÁLISIS INICIAL DE VALORES FALTANTES
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 2: Análisis de valores faltantes...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Calcular porcentaje de valores faltantes por columna
valores_faltantes <- data.frame(
  Variable = names(datos_originales),
  NA_Count = sapply(datos_originales, function(x) sum(is.na(x))),
  NA_Percent = sapply(datos_originales, function(x) 
    round(100 * sum(is.na(x)) / length(x), 2))
) %>%
  arrange(desc(NA_Percent))

cat("  Valores faltantes por variable (top 10):\n\n")
print(head(valores_faltantes, 10))

# Guardar análisis completo
write.csv(valores_faltantes, 
          "resultados/tablas/valores_faltantes_originales.csv", 
          row.names = FALSE)

cat("\n  ✓ Análisis de valores faltantes guardado\n\n")

# ==============================================================================
# PASO 3: SELECCIÓN Y RENOMBRADO DE VARIABLES RELEVANTES
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 3: Seleccionando y renombrando variables relevantes...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Seleccionar variables necesarias para el modelo
# InternationalRevenue = Budget + LanguageDummy + CountryDummy + Runtime²

datos_trabajo <- datos_originales %>%
  select(
    imdb_title_id,
    title,
    year,
    country,
    language_1,
    duration,
    budget,
    worlwide_gross_income,
    usa_gross_income,
    avg_vote,
    votes,
    genre
  ) %>%
  # Renombrar columnas para mayor claridad
  rename(
    id = imdb_title_id,
    titulo = title,
    anio = year,
    pais = country,
    idioma = language_1,
    duracion = duration,
    presupuesto = budget,
    ingresos_mundiales = worlwide_gross_income,
    ingresos_usa = usa_gross_income,
    calificacion_promedio = avg_vote,
    num_votos = votes,
    genero = genre
  )

cat(sprintf("  ✓ Variables seleccionadas: %d\n", ncol(datos_trabajo)))
cat("  Variables en el dataset de trabajo:\n")
cat(paste("   ", names(datos_trabajo), collapse = "\n"))
cat("\n\n")

# ==============================================================================
# PASO 4: LIMPIEZA DE VARIABLES MONETARIAS
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 4: Limpiando variables monetarias...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Función para limpiar variables monetarias (remover $, símbolos de moneda)
limpiar_monetario <- function(x) {
  # Convertir a character si no lo es
  x <- as.character(x)
  
  # Remover símbolos de moneda y espacios
  x <- gsub("[$€£¥]", "", x)
  x <- gsub(" ", "", x)
  x <- gsub(",", "", x)
  
  # Convertir a numérico
  x <- as.numeric(x)
  
  return(x)
}

# Aplicar limpieza a variables monetarias
datos_trabajo <- datos_trabajo %>%
  mutate(
    presupuesto = limpiar_monetario(presupuesto),
    ingresos_mundiales = limpiar_monetario(ingresos_mundiales),
    ingresos_usa = limpiar_monetario(ingresos_usa)
  )

cat("  ✓ Variables monetarias limpiadas (presupuesto, ingresos)\n\n")

# ==============================================================================
# PASO 5: CALCULAR INGRESOS INTERNACIONALES
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 5: Calculando ingresos internacionales...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Ingresos Internacionales = Ingresos Mundiales - Ingresos USA
datos_trabajo <- datos_trabajo %>%
  mutate(
    ingresos_internacionales = case_when(
      !is.na(ingresos_mundiales) & !is.na(ingresos_usa) ~ 
        ingresos_mundiales - ingresos_usa,
      !is.na(ingresos_mundiales) & is.na(ingresos_usa) ~ 
        ingresos_mundiales * 0.6,  # Aproximación: 60% internacional
      TRUE ~ NA_real_
    )
  )

cat(sprintf("  ✓ Ingresos internacionales calculados\n"))
cat(sprintf("  ✓ Películas con ingresos internacionales: %d (%.1f%%)\n",
            sum(!is.na(datos_trabajo$ingresos_internacionales)),
            100 * sum(!is.na(datos_trabajo$ingresos_internacionales)) / 
              nrow(datos_trabajo)))
cat("\n")

# ==============================================================================
# PASO 6: CREAR VARIABLE DUMMY DE IDIOMA
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 6: Creando variable dummy de idioma...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Analizar distribución de idiomas
idiomas_top <- datos_trabajo %>%
  count(idioma, sort = TRUE) %>%
  head(10)

cat("  Top 10 idiomas en el dataset:\n\n")
print(idiomas_top)
cat("\n")

# Crear variable dummy: 1 = Inglés, 0 = Otro idioma
datos_trabajo <- datos_trabajo %>%
  mutate(
    idioma_ingles = case_when(
      is.na(idioma) ~ NA_real_,
      idioma == "English" ~ 1,
      TRUE ~ 0
    )
  )

cat(sprintf("  ✓ Variable dummy 'idioma_ingles' creada\n"))
cat(sprintf("    - Películas en inglés: %d (%.1f%%)\n",
            sum(datos_trabajo$idioma_ingles == 1, na.rm = TRUE),
            100 * sum(datos_trabajo$idioma_ingles == 1, na.rm = TRUE) / 
              sum(!is.na(datos_trabajo$idioma_ingles))))
cat(sprintf("    - Películas en otros idiomas: %d (%.1f%%)\n",
            sum(datos_trabajo$idioma_ingles == 0, na.rm = TRUE),
            100 * sum(datos_trabajo$idioma_ingles == 0, na.rm = TRUE) / 
              sum(!is.na(datos_trabajo$idioma_ingles))))
cat("\n")

# ==============================================================================
# PASO 7: CREAR VARIABLE DUMMY DE PAÍS
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 7: Creando variable dummy de país...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Analizar distribución de países
paises_top <- datos_trabajo %>%
  count(pais, sort = TRUE) %>%
  head(15)

cat("  Top 15 países en el dataset:\n\n")
print(paises_top)
cat("\n")

# Definir países con fuerte industria cinematográfica
paises_fuertes <- c(
  "USA", "UK", "France", "India", "Germany", "Japan", 
  "China", "Italy", "South Korea", "Spain", "Canada",
  "Australia", "Hong Kong"
)

# Crear variable dummy: 1 = País con fuerte industria, 0 = Otro
datos_trabajo <- datos_trabajo %>%
  mutate(
    pais_fuerte = case_when(
      is.na(pais) ~ NA_real_,
      pais %in% paises_fuertes ~ 1,
      TRUE ~ 0
    )
  )

cat(sprintf("  ✓ Variable dummy 'pais_fuerte' creada\n"))
cat(sprintf("    - Países fuertes considerados: %d\n", length(paises_fuertes)))
cat(sprintf("    - Películas de países fuertes: %d (%.1f%%)\n",
            sum(datos_trabajo$pais_fuerte == 1, na.rm = TRUE),
            100 * sum(datos_trabajo$pais_fuerte == 1, na.rm = TRUE) / 
              sum(!is.na(datos_trabajo$pais_fuerte))))
cat("\n")

# ==============================================================================
# PASO 8: TRANSFORMAR VARIABLE DE DURACIÓN
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 8: Transformando variable de duración...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Crear variable Runtime²
datos_trabajo <- datos_trabajo %>%
  mutate(
    duracion_cuadrado = duracion^2
  )

# Estadísticas de duración
cat("  Estadísticas de duración (minutos):\n")
cat(sprintf("    - Media: %.2f\n", mean(datos_trabajo$duracion, na.rm = TRUE)))
cat(sprintf("    - Mediana: %.2f\n", median(datos_trabajo$duracion, na.rm = TRUE)))
cat(sprintf("    - Mínimo: %.0f\n", min(datos_trabajo$duracion, na.rm = TRUE)))
cat(sprintf("    - Máximo: %.0f\n", max(datos_trabajo$duracion, na.rm = TRUE)))
cat(sprintf("  ✓ Variable 'duracion_cuadrado' creada\n"))
cat("\n")

# ==============================================================================
# PASO 9: FILTRAR CASOS COMPLETOS
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 9: Filtrando casos completos para el modelo...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Variables necesarias para el modelo
variables_modelo <- c(
  "ingresos_internacionales",
  "presupuesto",
  "idioma_ingles",
  "pais_fuerte",
  "duracion",
  "duracion_cuadrado"
)

cat("  Variables requeridas para el modelo:\n")
cat(paste("   ", variables_modelo, collapse = "\n"))
cat("\n\n")

# Contar casos antes del filtrado
n_antes <- nrow(datos_trabajo)

# Filtrar casos completos
datos_limpios <- datos_trabajo %>%
  filter(
    !is.na(ingresos_internacionales),
    !is.na(presupuesto),
    !is.na(idioma_ingles),
    !is.na(pais_fuerte),
    !is.na(duracion),
    presupuesto > 0,
    ingresos_internacionales > 0,
    duracion > 0
  )

n_despues <- nrow(datos_limpios)

cat(sprintf("  Casos antes del filtrado: %d\n", n_antes))
cat(sprintf("  Casos después del filtrado: %d\n", n_despues))
cat(sprintf("  Casos eliminados: %d (%.1f%%)\n", 
            n_antes - n_despues,
            100 * (n_antes - n_despues) / n_antes))
cat("\n")

# ==============================================================================
# PASO 10: DETECCIÓN Y TRATAMIENTO DE OUTLIERS
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 10: Analizando outliers...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Función para detectar outliers usando IQR
detectar_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  limite_inf <- q1 - 3 * iqr
  limite_sup <- q3 + 3 * iqr
  return(x < limite_inf | x > limite_sup)
}

# Identificar outliers en variables numéricas clave
datos_limpios <- datos_limpios %>%
  mutate(
    outlier_presupuesto = detectar_outliers(presupuesto),
    outlier_ingresos = detectar_outliers(ingresos_internacionales),
    outlier_duracion = detectar_outliers(duracion)
  )

cat("  Outliers detectados (método IQR con factor 3):\n")
cat(sprintf("    - Presupuesto: %d (%.1f%%)\n",
            sum(datos_limpios$outlier_presupuesto),
            100 * sum(datos_limpios$outlier_presupuesto) / nrow(datos_limpios)))
cat(sprintf("    - Ingresos: %d (%.1f%%)\n",
            sum(datos_limpios$outlier_ingresos),
            100 * sum(datos_limpios$outlier_ingresos) / nrow(datos_limpios)))
cat(sprintf("    - Duración: %d (%.1f%%)\n",
            sum(datos_limpios$outlier_duracion),
            100 * sum(datos_limpios$outlier_duracion) / nrow(datos_limpios)))
cat("\n  NOTA: Los outliers se conservan para el análisis\n")
cat("        pero se marcan para revisión posterior\n\n")

# ==============================================================================
# PASO 11: CREAR VARIABLES ADICIONALES
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 11: Creando variables adicionales...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Crear variables transformadas y derivadas
datos_limpios <- datos_limpios %>%
  mutate(
    # Variables logarítmicas (útiles para análisis)
    log_presupuesto = log(presupuesto + 1),
    log_ingresos_int = log(ingresos_internacionales + 1),
    
    # ROI (Return on Investment)
    roi = (ingresos_internacionales - presupuesto) / presupuesto,
    
    # Ratio de eficiencia
    ratio_ingreso_presupuesto = ingresos_internacionales / presupuesto,
    
    # Categorización de presupuesto
    categoria_presupuesto = case_when(
      presupuesto < 10000000 ~ "Bajo",
      presupuesto < 50000000 ~ "Medio",
      presupuesto < 100000000 ~ "Alto",
      TRUE ~ "Muy Alto"
    ),
    
    # Década
    decada = paste0(floor(anio / 10) * 10, "s")
  )

cat("  ✓ Variables adicionales creadas:\n")
cat("    - log_presupuesto\n")
cat("    - log_ingresos_int\n")
cat("    - roi (Return on Investment)\n")
cat("    - ratio_ingreso_presupuesto\n")
cat("    - categoria_presupuesto\n")
cat("    - decada\n")
cat("\n")

# ==============================================================================
# PASO 12: RESUMEN ESTADÍSTICO FINAL
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 12: Generando resumen estadístico final...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Estadísticas descriptivas de variables del modelo
estadisticas <- datos_limpios %>%
  select(all_of(variables_modelo)) %>%
  summary()

cat("  Estadísticas descriptivas de variables del modelo:\n\n")
print(estadisticas)
cat("\n")

# Guardar estadísticas detalladas
estadisticas_detalladas <- datos_limpios %>%
  select(all_of(variables_modelo)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Valor") %>%
  group_by(Variable) %>%
  summarise(
    N = n(),
    Media = mean(Valor, na.rm = TRUE),
    Mediana = median(Valor, na.rm = TRUE),
    SD = sd(Valor, na.rm = TRUE),
    Min = min(Valor, na.rm = TRUE),
    Max = max(Valor, na.rm = TRUE),
    Q1 = quantile(Valor, 0.25, na.rm = TRUE),
    Q3 = quantile(Valor, 0.75, na.rm = TRUE)
  )

write.csv(estadisticas_detalladas, 
          "resultados/tablas/estadisticas_descriptivas.csv",
          row.names = FALSE)

cat("  ✓ Estadísticas descriptivas guardadas\n\n")

# ==============================================================================
# PASO 13: EXPORTAR DATOS LIMPIOS
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 13: Exportando datos limpios...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Guardar dataset limpio completo
write.csv(datos_limpios, "data/datos_limpios.csv", row.names = FALSE)
cat("  ✓ Dataset completo guardado: data/datos_limpios.csv\n")

# Guardar solo variables del modelo
datos_modelo <- datos_limpios %>%
  select(id, titulo, anio, all_of(variables_modelo), 
         categoria_presupuesto, decada)

write.csv(datos_modelo, "data/datos_modelo.csv", row.names = FALSE)
cat("  ✓ Variables del modelo guardadas: data/datos_modelo.csv\n\n")

# ==============================================================================
# PASO 14: INFORME FINAL DE LIMPIEZA
# ==============================================================================

cat("===============================================================================\n")
cat("INFORME FINAL DE LIMPIEZA DE DATOS\n")
cat("===============================================================================\n\n")

cat("RESUMEN DEL PROCESO:\n\n")
cat(sprintf("  1. Dataset original: %d películas\n", nrow(datos_originales)))
cat(sprintf("  2. Después de selección de variables: %d películas\n", nrow(datos_trabajo)))
cat(sprintf("  3. Después de filtrar casos completos: %d películas\n", nrow(datos_limpios)))
cat(sprintf("  4. Tasa de retención: %.1f%%\n", 
            100 * nrow(datos_limpios) / nrow(datos_originales)))
cat("\n")

cat("VARIABLES CREADAS:\n\n")
cat("  Variables Dummy:\n")
cat("    - idioma_ingles: 1 = Inglés, 0 = Otro\n")
cat("    - pais_fuerte: 1 = País con industria fuerte, 0 = Otro\n")
cat("\n")
cat("  Variables Transformadas:\n")
cat("    - duracion_cuadrado: Duración al cuadrado\n")
cat("    - ingresos_internacionales: Ingresos mundiales - USA\n")
cat("\n")
cat("  Variables Adicionales:\n")
cat("    - log_presupuesto, log_ingresos_int\n")
cat("    - roi, ratio_ingreso_presupuesto\n")
cat("    - categoria_presupuesto, decada\n")
cat("\n")

cat("DISTRIBUCIÓN DE VARIABLES DUMMY:\n\n")
cat(sprintf("  Idioma Inglés:\n"))
cat(sprintf("    - Sí (1): %d películas (%.1f%%)\n",
            sum(datos_limpios$idioma_ingles == 1),
            100 * sum(datos_limpios$idioma_ingles == 1) / nrow(datos_limpios)))
cat(sprintf("    - No (0): %d películas (%.1f%%)\n",
            sum(datos_limpios$idioma_ingles == 0),
            100 * sum(datos_limpios$idioma_ingles == 0) / nrow(datos_limpios)))
cat("\n")
cat(sprintf("  País con Industria Fuerte:\n"))
cat(sprintf("    - Sí (1): %d películas (%.1f%%)\n",
            sum(datos_limpios$pais_fuerte == 1),
            100 * sum(datos_limpios$pais_fuerte == 1) / nrow(datos_limpios)))
cat(sprintf("    - No (0): %d películas (%.1f%%)\n",
            sum(datos_limpios$pais_fuerte == 0),
            100 * sum(datos_limpios$pais_fuerte == 0) / nrow(datos_limpios)))
cat("\n")

cat("ARCHIVOS GENERADOS:\n\n")
cat("  1. data/datos_limpios.csv - Dataset completo limpio\n")
cat("  2. data/datos_modelo.csv - Solo variables del modelo\n")
cat("  3. resultados/tablas/valores_faltantes_originales.csv\n")
cat("  4. resultados/tablas/estadisticas_descriptivas.csv\n")
cat("\n")

cat("===============================================================================\n")
cat("LIMPIEZA DE DATOS COMPLETADA EXITOSAMENTE\n")
cat(sprintf("Fecha y hora: %s\n", Sys.time()))
cat("===============================================================================\n\n")

cat("PRÓXIMO PASO:\n")
cat("  Ejecutar análisis exploratorio: source('scripts/02_analisis_exploratorio.R')\n\n")

# ==============================================================================
# FIN DEL SCRIPT
# ==============================================================================
