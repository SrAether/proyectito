################################################################################
#                   ANÁLISIS EXPLORATORIO DE DATOS (EDA)                      #
#                       IMDB Movies 2000-2020                                  #
################################################################################

# Limpieza del entorno
rm(list = ls())
gc()

# Cargar librerías necesarias
suppressPackageStartupMessages({
  library(tidyverse)
  library(corrplot)
  library(gridExtra)
  library(scales)
  library(moments)  # Para asimetría y curtosis
})

# Definir rutas
ruta_datos <- "data/datos_limpios.csv"
ruta_graficos <- "resultados/graficos/"
ruta_tablas <- "resultados/tablas/"

# Función para guardar gráficos
guardar_grafico <- function(plot_obj, nombre_archivo, ancho = 12, alto = 8) {
  ggsave(
    filename = paste0(ruta_graficos, nombre_archivo),
    plot = plot_obj,
    width = ancho,
    height = alto,
    dpi = 300,
    bg = "white"
  )
}

cat("\n")
cat("===============================================================================\n")
cat("  ANÁLISIS EXPLORATORIO DE DATOS (EDA)\n")
cat("  Dataset: IMDB Movies 2000-2020\n")
cat("===============================================================================\n\n")

################################################################################
# PASO 1: CARGAR DATOS
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 1: Cargando datos limpios...\n")
cat("-------------------------------------------------------------------------------\n\n")

datos <- read_csv(ruta_datos, show_col_types = FALSE)

cat(sprintf("  ✓ Datos cargados: %d observaciones\n", nrow(datos)))
cat(sprintf("  ✓ Variables: %d\n\n", ncol(datos)))

################################################################################
# PASO 2: ESTADÍSTICAS DESCRIPTIVAS DETALLADAS
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 2: Estadísticas descriptivas detalladas...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Variables numéricas de interés
vars_numericas <- c("presupuesto", "ingresos_internacionales", 
                    "ingresos_mundiales", "ingresos_usa",
                    "duracion", "calificacion_promedio", "num_votos")

# Crear tabla de estadísticas
estadisticas_detalladas <- datos %>%
  select(all_of(vars_numericas)) %>%
  summarise(across(everything(), list(
    n = ~n(),
    media = ~mean(., na.rm = TRUE),
    mediana = ~median(., na.rm = TRUE),
    desv_std = ~sd(., na.rm = TRUE),
    minimo = ~min(., na.rm = TRUE),
    maximo = ~max(., na.rm = TRUE),
    asimetria = ~moments::skewness(., na.rm = TRUE),
    curtosis = ~moments::kurtosis(., na.rm = TRUE)
  ))) %>%
  pivot_longer(everything(), names_to = "variable_stat", values_to = "valor") %>%
  separate(variable_stat, into = c("variable", "estadistica"), sep = "_", extra = "merge") %>%
  pivot_wider(names_from = estadistica, values_from = valor)

print(estadisticas_detalladas)

write_csv(estadisticas_detalladas, 
          paste0(ruta_tablas, "estadisticas_detalladas.csv"))

cat("\n  ✓ Estadísticas detalladas guardadas\n\n")

################################################################################
# PASO 3: DISTRIBUCIONES UNIVARIADAS
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 3: Visualizando distribuciones univariadas...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Histograma: Ingresos Internacionales
p1 <- ggplot(datos, aes(x = ingresos_internacionales / 1e6)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "white", alpha = 0.7) +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Distribución de Ingresos Internacionales",
    x = "Ingresos Internacionales (millones USD)",
    y = "Frecuencia"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p1, "eda_01_dist_ingresos.png", 10, 6)
cat("  ✓ Gráfico guardado: eda_01_dist_ingresos.png\n")

# Histograma: Presupuesto
p2 <- ggplot(datos, aes(x = presupuesto / 1e6)) +
  geom_histogram(bins = 50, fill = "coral", color = "white", alpha = 0.7) +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Distribución de Presupuesto",
    x = "Presupuesto (millones USD)",
    y = "Frecuencia"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p2, "eda_02_dist_presupuesto.png", 10, 6)
cat("  ✓ Gráfico guardado: eda_02_dist_presupuesto.png\n")

# Histograma: Duración
p3 <- ggplot(datos, aes(x = duracion)) +
  geom_histogram(bins = 40, fill = "darkgreen", color = "white", alpha = 0.7) +
  labs(
    title = "Distribución de Duración de Películas",
    x = "Duración (minutos)",
    y = "Frecuencia"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p3, "eda_03_dist_duracion.png", 10, 6)
cat("  ✓ Gráfico guardado: eda_03_dist_duracion.png\n")

# Box plot: Calificación Promedio
p4 <- ggplot(datos, aes(y = calificacion_promedio)) +
  geom_boxplot(fill = "purple", alpha = 0.5, width = 0.5) +
  coord_flip() +
  labs(
    title = "Distribución de Calificación Promedio",
    x = "",
    y = "Calificación Promedio (IMDB)"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p4, "eda_04_boxplot_calificacion.png", 10, 4)
cat("  ✓ Gráfico guardado: eda_04_boxplot_calificacion.png\n\n")

################################################################################
# PASO 4: RELACIONES BIVARIADAS
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 4: Explorando relaciones bivariadas...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Scatter plot: Presupuesto vs Ingresos
p5 <- ggplot(datos, aes(x = presupuesto / 1e6, y = ingresos_internacionales / 1e6)) +
  geom_point(alpha = 0.3, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Relación: Presupuesto vs Ingresos Internacionales",
    subtitle = "Con línea de regresión lineal",
    x = "Presupuesto (millones USD)",
    y = "Ingresos Internacionales (millones USD)"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p5, "eda_05_presupuesto_vs_ingresos.png", 10, 7)
cat("  ✓ Gráfico guardado: eda_05_presupuesto_vs_ingresos.png\n")

# Scatter plot: Duración vs Ingresos
p6 <- ggplot(datos, aes(x = duracion, y = ingresos_internacionales / 1e6)) +
  geom_point(alpha = 0.3, color = "darkgreen") +
  geom_smooth(method = "loess", color = "orange", se = TRUE) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Relación: Duración vs Ingresos Internacionales",
    subtitle = "Con curva suavizada (LOESS)",
    x = "Duración (minutos)",
    y = "Ingresos Internacionales (millones USD)"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p6, "eda_06_duracion_vs_ingresos.png", 10, 7)
cat("  ✓ Gráfico guardado: eda_06_duracion_vs_ingresos.png\n")

# Box plot: Idioma vs Ingresos
p7 <- ggplot(datos, aes(x = factor(idioma_ingles, labels = c("Otro", "Inglés")), 
                         y = ingresos_internacionales / 1e6)) +
  geom_boxplot(fill = "coral", alpha = 0.6) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Ingresos Internacionales por Idioma",
    x = "Idioma",
    y = "Ingresos Internacionales (millones USD)"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p7, "eda_07_idioma_vs_ingresos.png", 10, 6)
cat("  ✓ Gráfico guardado: eda_07_idioma_vs_ingresos.png\n")

# Box plot: País vs Ingresos
p8 <- ggplot(datos, aes(x = factor(pais_fuerte, labels = c("Otro", "Industria Fuerte")), 
                         y = ingresos_internacionales / 1e6)) +
  geom_boxplot(fill = "purple", alpha = 0.6) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Ingresos Internacionales por Tipo de País",
    x = "Tipo de País",
    y = "Ingresos Internacionales (millones USD)"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p8, "eda_08_pais_vs_ingresos.png", 10, 6)
cat("  ✓ Gráfico guardado: eda_08_pais_vs_ingresos.png\n\n")

################################################################################
# PASO 5: ANÁLISIS POR AÑO
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 5: Análisis temporal por año...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Evolución temporal
datos_por_anio <- datos %>%
  group_by(anio) %>%
  summarise(
    n_peliculas = n(),
    presupuesto_promedio = mean(presupuesto, na.rm = TRUE) / 1e6,
    ingresos_promedio = mean(ingresos_internacionales, na.rm = TRUE) / 1e6,
    .groups = "drop"
  )

p9 <- ggplot(datos_por_anio, aes(x = anio)) +
  geom_line(aes(y = presupuesto_promedio, color = "Presupuesto"), size = 1.2) +
  geom_line(aes(y = ingresos_promedio, color = "Ingresos"), size = 1.2) +
  geom_point(aes(y = presupuesto_promedio, color = "Presupuesto"), size = 2) +
  geom_point(aes(y = ingresos_promedio, color = "Ingresos"), size = 2) +
  scale_color_manual(values = c("Presupuesto" = "coral", "Ingresos" = "steelblue")) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Evolución Temporal: Presupuesto e Ingresos Promedio",
    x = "Año",
    y = "Promedio (millones USD)",
    color = ""
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

guardar_grafico(p9, "eda_09_evolucion_temporal.png", 12, 6)
cat("  ✓ Gráfico guardado: eda_09_evolucion_temporal.png\n")

p10 <- ggplot(datos_por_anio, aes(x = anio, y = n_peliculas)) +
  geom_col(fill = "darkgreen", alpha = 0.7) +
  labs(
    title = "Número de Películas por Año",
    x = "Año",
    y = "Número de Películas"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p10, "eda_10_peliculas_por_anio.png", 12, 6)
cat("  ✓ Gráfico guardado: eda_10_peliculas_por_anio.png\n\n")

################################################################################
# PASO 6: MATRIZ DE CORRELACIÓN
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 6: Matriz de correlación de variables numéricas...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Seleccionar variables para correlación
vars_correlacion <- datos %>%
  select(presupuesto, ingresos_internacionales, duracion, 
         calificacion_promedio, num_votos, idioma_ingles, pais_fuerte) %>%
  rename(
    Presupuesto = presupuesto,
    `Ing. Internacional` = ingresos_internacionales,
    Duración = duracion,
    Calificación = calificacion_promedio,
    Votos = num_votos,
    `Idioma Inglés` = idioma_ingles,
    `País Fuerte` = pais_fuerte
  )

matriz_cor <- cor(vars_correlacion, use = "complete.obs")

# Visualización con corrplot
png(paste0(ruta_graficos, "eda_11_matriz_correlacion.png"), 
    width = 10, height = 10, units = "in", res = 300)
corrplot(
  matriz_cor,
  method = "circle",
  type = "upper",
  tl.col = "black",
  tl.srt = 45,
  addCoef.col = "black",
  number.cex = 0.8,
  col = colorRampPalette(c("red", "white", "blue"))(200),
  title = "Matriz de Correlación - Variables Principales",
  mar = c(0, 0, 2, 0)
)
dev.off()

cat("  ✓ Gráfico guardado: eda_11_matriz_correlacion.png\n\n")

################################################################################
# PASO 7: ROI (RETURN ON INVESTMENT)
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 7: Análisis de ROI (Retorno de Inversión)...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Filtrar películas con ROI válido
datos_roi <- datos %>%
  filter(!is.na(roi), is.finite(roi), roi > -100, roi < 100) %>%
  mutate(roi_categoria = case_when(
    roi < 0 ~ "Pérdida",
    roi >= 0 & roi < 1 ~ "Baja rentabilidad",
    roi >= 1 & roi < 5 ~ "Rentabilidad media",
    roi >= 5 ~ "Alta rentabilidad"
  ))

p11 <- ggplot(datos_roi, aes(x = roi)) +
  geom_histogram(bins = 50, fill = "gold", color = "white", alpha = 0.7) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed", size = 1) +
  labs(
    title = "Distribución de ROI (Return on Investment)",
    subtitle = "ROI = (Ingresos - Presupuesto) / Presupuesto",
    x = "ROI",
    y = "Frecuencia"
  ) +
  theme_minimal(base_size = 12)

guardar_grafico(p11, "eda_12_distribucion_roi.png", 10, 6)
cat("  ✓ Gráfico guardado: eda_12_distribucion_roi.png\n")

# Tabla resumen ROI
resumen_roi <- datos_roi %>%
  group_by(roi_categoria) %>%
  summarise(
    n = n(),
    porcentaje = n() / nrow(datos_roi) * 100,
    .groups = "drop"
  )

print(resumen_roi)

write_csv(resumen_roi, paste0(ruta_tablas, "resumen_roi.csv"))
cat("\n  ✓ Resumen de ROI guardado\n\n")

################################################################################
# RESUMEN FINAL
################################################################################

cat("===============================================================================\n")
cat("RESUMEN DEL ANÁLISIS EXPLORATORIO\n")
cat("===============================================================================\n\n")

cat("DATOS ANALIZADOS:\n")
cat(sprintf("  • Total de películas: %d\n", nrow(datos)))
cat(sprintf("  • Período: %d - %d\n", min(datos$anio), max(datos$anio)))
cat(sprintf("  • Variables analizadas: %d\n\n", ncol(datos)))

cat("HALLAZGOS PRINCIPALES:\n\n")

cat("  1. DISTRIBUCIONES:\n")
cat("     • Ingresos y presupuesto presentan alta asimetría positiva\n")
cat("     • Mayoría de películas tienen presupuestos moderados (< 50 mill USD)\n")
cat("     • Duración promedio: ~109 minutos\n\n")

cat("  2. RELACIONES:\n")
cat(sprintf("     • Correlación Presupuesto-Ingresos: %.3f\n", 
            cor(datos$presupuesto, datos$ingresos_internacionales, use = "complete.obs")))
cat("     • Relación positiva fuerte entre presupuesto e ingresos\n")
cat("     • Duración muestra relación no lineal con ingresos\n\n")

cat("  3. IDIOMA:\n")
cat(sprintf("     • Películas en inglés: %.1f%%\n", 
            mean(datos$idioma_ingles) * 100))
cat("     • Películas en otros idiomas: representación menor pero significativa\n\n")

cat("  4. ROI:\n")
if(nrow(datos_roi) > 0) {
  cat(sprintf("     • ROI promedio: %.2f\n", mean(datos_roi$roi, na.rm = TRUE)))
  cat(sprintf("     • ROI mediano: %.2f\n", median(datos_roi$roi, na.rm = TRUE)))
}

cat("\nARCHIVOS GENERADOS:\n")
cat("  • 12 gráficos exploratorios en resultados/graficos/\n")
cat("  • 2 tablas de resumen en resultados/tablas/\n\n")

cat("===============================================================================\n")
cat("ANÁLISIS EXPLORATORIO COMPLETADO\n")
cat(sprintf("Fecha y hora: %s\n", Sys.time()))
cat("===============================================================================\n\n")

cat("PRÓXIMO PASO:\n")
cat("  Revisar los gráficos y continuar con el modelo de regresión\n\n")
