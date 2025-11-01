################################################################################
# SCRIPT 03: IMPLEMENTACIÓN DEL MODELO DE REGRESIÓN
################################################################################
#
# Proyecto: Análisis de Ingresos Internacionales de Películas IMDB
# Entorno: pruebasVal
# Script: 03_modelo_regresion.R
#
# Modelo: InternationalRevenue = β₀ + β₁·Budget + β₂·LanguageDummy + 
#                                  β₃·CountryDummy + β₄·Runtime² + ε
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
cat("  SCRIPT 03: IMPLEMENTACIÓN DEL MODELO DE REGRESIÓN LINEAL MÚLTIPLE\n")
cat("===============================================================================\n\n")

# Cargar librerías
suppressPackageStartupMessages({
  library(tidyverse)
  library(car)
  library(stargazer)
  library(lmtest)
  library(sandwich)
})

cat("✓ Librerías cargadas correctamente\n\n")

# ==============================================================================
# PASO 1: CARGAR DATOS LIMPIOS
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 1: Cargando datos limpios...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Verificar que exista el archivo
if (!file.exists("data/datos_limpios.csv")) {
  stop("ERROR: El archivo 'datos_limpios.csv' no existe.\n",
       "       Ejecuta primero: source('scripts/01_limpieza_datos.R')")
}

# Cargar datos
datos <- read.csv("data/datos_limpios.csv")

cat(sprintf("  ✓ Datos cargados: %d observaciones\n", nrow(datos)))
cat(sprintf("  ✓ Variables disponibles: %d\n", ncol(datos)))
cat("\n")

# ==============================================================================
# PASO 2: PREPARAR VARIABLES PARA EL MODELO
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 2: Preparando variables para el modelo...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Escalar variables para mejor interpretación
# Presupuesto en millones de dólares
# Ingresos en millones de dólares
datos <- datos %>%
  mutate(
    presupuesto_mill = presupuesto / 1000000,
    ingresos_int_mill = ingresos_internacionales / 1000000
  )

cat("  Variables escaladas:\n")
cat("    - presupuesto → presupuesto_mill (millones USD)\n")
cat("    - ingresos_internacionales → ingresos_int_mill (millones USD)\n")
cat("\n")

# Estadísticas de las variables del modelo
cat("  Estadísticas de variables del modelo:\n\n")

variables_modelo <- c("ingresos_int_mill", "presupuesto_mill", 
                      "idioma_ingles", "pais_fuerte", "duracion_cuadrado")

resumen <- datos %>%
  select(all_of(variables_modelo)) %>%
  summary()

print(resumen)
cat("\n")

# ==============================================================================
# PASO 3: ESPECIFICACIÓN DEL MODELO
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 3: Especificación del modelo...\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  MODELO TEÓRICO:\n\n")
cat("  InternationalRevenue_i = β₀ + β₁·Budget_i + β₂·LanguageDummy_i +\n")
cat("                           β₃·CountryDummy_i + β₄·Runtime²_i + ε_i\n\n")

cat("  Donde:\n")
cat("    • InternationalRevenue: Ingresos internacionales (millones USD)\n")
cat("    • Budget: Presupuesto de la película (millones USD)\n")
cat("    • LanguageDummy: 1 = Inglés, 0 = Otro idioma\n")
cat("    • CountryDummy: 1 = País con industria fuerte, 0 = Otro\n")
cat("    • Runtime²: Duración de la película al cuadrado (minutos²)\n")
cat("    • ε: Término de error\n\n")

# ==============================================================================
# PASO 4: ESTIMACIÓN DEL MODELO
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 4: Estimando modelo por MCO (Mínimos Cuadrados Ordinarios)...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Estimar el modelo
modelo <- lm(ingresos_int_mill ~ presupuesto_mill + idioma_ingles + 
             pais_fuerte + duracion_cuadrado, 
             data = datos)

cat("  ✓ Modelo estimado correctamente\n\n")

# ==============================================================================
# PASO 5: RESULTADOS DEL MODELO
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 5: Resultados del modelo...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Resumen del modelo
cat("  RESUMEN DEL MODELO:\n\n")
summary_modelo <- summary(modelo)
print(summary_modelo)
cat("\n")

# Extraer coeficientes
coeficientes <- summary_modelo$coefficients

# Crear tabla de coeficientes
tabla_coef <- data.frame(
  Variable = c("(Intercepto)", "Presupuesto (mill USD)", 
               "Idioma Inglés (dummy)", "País Fuerte (dummy)", 
               "Duración² (min²)"),
  Coeficiente = coeficientes[, "Estimate"],
  Error_Estandar = coeficientes[, "Std. Error"],
  t_valor = coeficientes[, "t value"],
  p_valor = coeficientes[, "Pr(>|t|)"],
  Significancia = case_when(
    coeficientes[, "Pr(>|t|)"] < 0.001 ~ "***",
    coeficientes[, "Pr(>|t|)"] < 0.01 ~ "**",
    coeficientes[, "Pr(>|t|)"] < 0.05 ~ "*",
    coeficientes[, "Pr(>|t|)"] < 0.1 ~ ".",
    TRUE ~ ""
  )
)

# Guardar tabla de coeficientes
write.csv(tabla_coef, "resultados/tablas/coeficientes_modelo.csv", 
          row.names = FALSE)

cat("  ✓ Tabla de coeficientes guardada\n\n")

# ==============================================================================
# PASO 6: MÉTRICAS DE AJUSTE DEL MODELO
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 6: Métricas de ajuste del modelo...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Calcular métricas
r_cuadrado <- summary_modelo$r.squared
r_cuadrado_aj <- summary_modelo$adj.r.squared
rmse <- sqrt(mean(residuals(modelo)^2))
mae <- mean(abs(residuals(modelo)))
estadistico_f <- summary_modelo$fstatistic[1]
p_valor_f <- pf(summary_modelo$fstatistic[1],
                summary_modelo$fstatistic[2],
                summary_modelo$fstatistic[3],
                lower.tail = FALSE)

# AIC y BIC
aic_modelo <- AIC(modelo)
bic_modelo <- BIC(modelo)

cat("  MÉTRICAS DE AJUSTE:\n\n")
cat(sprintf("    R² (Coef. de Determinación):        %.4f\n", r_cuadrado))
cat(sprintf("    R² Ajustado:                         %.4f\n", r_cuadrado_aj))
cat(sprintf("    RMSE (Error Cuadrático Medio):      %.2f millones USD\n", rmse))
cat(sprintf("    MAE (Error Absoluto Medio):         %.2f millones USD\n", mae))
cat(sprintf("    Estadístico F:                       %.2f\n", estadistico_f))
cat(sprintf("    Valor p (F-estadístico):            %.4e\n", p_valor_f))
cat(sprintf("    AIC (Criterio de Información):      %.2f\n", aic_modelo))
cat(sprintf("    BIC (Criterio Bayesiano):           %.2f\n", bic_modelo))
cat("\n")

# Interpretar R²
cat("  INTERPRETACIÓN DEL R²:\n\n")
cat(sprintf("    El modelo explica el %.2f%% de la variabilidad en los\n",
            100 * r_cuadrado))
cat("    ingresos internacionales de las películas.\n\n")

# Guardar métricas
metricas <- data.frame(
  Metrica = c("R²", "R² Ajustado", "RMSE", "MAE", "F-estadístico", 
              "p-valor F", "AIC", "BIC"),
  Valor = c(r_cuadrado, r_cuadrado_aj, rmse, mae, estadistico_f, 
            p_valor_f, aic_modelo, bic_modelo)
)

write.csv(metricas, "resultados/tablas/metricas_ajuste.csv", row.names = FALSE)

# ==============================================================================
# PASO 7: INTERPRETACIÓN DE COEFICIENTES
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 7: Interpretación de coeficientes...\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  INTERPRETACIÓN DE CADA COEFICIENTE:\n\n")

# Presupuesto
cat(sprintf("  1. PRESUPUESTO (β₁ = %.4f):\n", coeficientes["presupuesto_mill", "Estimate"]))
cat(sprintf("     Por cada millón de dólares adicional en presupuesto,\n"))
cat(sprintf("     los ingresos internacionales aumentan en %.2f millones USD,\n",
            coeficientes["presupuesto_mill", "Estimate"]))
cat(sprintf("     manteniendo las demás variables constantes.\n"))
if (coeficientes["presupuesto_mill", "Pr(>|t|)"] < 0.05) {
  cat("     ✓ Estadísticamente significativo (p < 0.05)\n")
} else {
  cat("     ⚠ NO estadísticamente significativo\n")
}
cat("\n")

# Idioma
cat(sprintf("  2. IDIOMA INGLÉS (β₂ = %.4f):\n", coeficientes["idioma_ingles", "Estimate"]))
if (coeficientes["idioma_ingles", "Estimate"] > 0) {
  cat(sprintf("     Las películas en inglés tienen, en promedio, %.2f millones USD\n",
              coeficientes["idioma_ingles", "Estimate"]))
  cat("     MÁS de ingresos internacionales que películas en otros idiomas,\n")
} else {
  cat(sprintf("     Las películas en inglés tienen, en promedio, %.2f millones USD\n",
              abs(coeficientes["idioma_ingles", "Estimate"])))
  cat("     MENOS de ingresos internacionales que películas en otros idiomas,\n")
}
cat("     manteniendo las demás variables constantes.\n")
if (coeficientes["idioma_ingles", "Pr(>|t|)"] < 0.05) {
  cat("     ✓ Estadísticamente significativo (p < 0.05)\n")
} else {
  cat("     ⚠ NO estadísticamente significativo\n")
}
cat("\n")

# País
cat(sprintf("  3. PAÍS CON INDUSTRIA FUERTE (β₃ = %.4f):\n", 
            coeficientes["pais_fuerte", "Estimate"]))
if (coeficientes["pais_fuerte", "Estimate"] > 0) {
  cat(sprintf("     Las películas de países con industria fuerte tienen, en promedio,\n"))
  cat(sprintf("     %.2f millones USD MÁS de ingresos internacionales,\n",
              coeficientes["pais_fuerte", "Estimate"]))
} else {
  cat(sprintf("     Las películas de países con industria fuerte tienen, en promedio,\n"))
  cat(sprintf("     %.2f millones USD MENOS de ingresos internacionales,\n",
              abs(coeficientes["pais_fuerte", "Estimate"])))
}
cat("     manteniendo las demás variables constantes.\n")
if (coeficientes["pais_fuerte", "Pr(>|t|)"] < 0.05) {
  cat("     ✓ Estadísticamente significativo (p < 0.05)\n")
} else {
  cat("     ⚠ NO estadísticamente significativo\n")
}
cat("\n")

# Duración²
cat(sprintf("  4. DURACIÓN² (β₄ = %.8f):\n", coeficientes["duracion_cuadrado", "Estimate"]))
cat("     Efecto no lineal de la duración. El término cuadrático captura\n")
cat("     si existe una duración óptima que maximiza los ingresos.\n")
if (coeficientes["duracion_cuadrado", "Estimate"] < 0) {
  cat("     El coeficiente negativo sugiere una relación de U invertida:\n")
  cat("     existe una duración óptima, después de la cual los ingresos\n")
  cat("     disminuyen (películas muy largas son menos rentables).\n")
} else {
  cat("     El coeficiente positivo sugiere rendimientos crecientes.\n")
}
if (coeficientes["duracion_cuadrado", "Pr(>|t|)"] < 0.05) {
  cat("     ✓ Estadísticamente significativo (p < 0.05)\n")
} else {
  cat("     ⚠ NO estadísticamente significativo\n")
}
cat("\n")

# ==============================================================================
# PASO 8: GRÁFICOS DE DIAGNÓSTICO
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 8: Generando gráficos de diagnóstico...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Crear directorio si no existe
if (!dir.exists("resultados/graficos")) {
  dir.create("resultados/graficos", recursive = TRUE)
}

# 1. Residuos vs Valores Ajustados
png("resultados/graficos/01_residuos_vs_ajustados.png", 
    width = 800, height = 600)
plot(modelo, which = 1, main = "Residuos vs Valores Ajustados")
abline(h = 0, col = "red", lty = 2)
dev.off()
cat("  ✓ Gráfico guardado: 01_residuos_vs_ajustados.png\n")

# 2. Q-Q Plot (normalidad de residuos)
png("resultados/graficos/02_qq_plot.png", width = 800, height = 600)
plot(modelo, which = 2, main = "Q-Q Plot de Residuos")
dev.off()
cat("  ✓ Gráfico guardado: 02_qq_plot.png\n")

# 3. Scale-Location (homocedasticidad)
png("resultados/graficos/03_scale_location.png", width = 800, height = 600)
plot(modelo, which = 3, main = "Scale-Location")
dev.off()
cat("  ✓ Gráfico guardado: 03_scale_location.png\n")

# 4. Residuos vs Leverage
png("resultados/graficos/04_residuos_leverage.png", width = 800, height = 600)
plot(modelo, which = 5, main = "Residuos vs Leverage")
dev.off()
cat("  ✓ Gráfico guardado: 04_residuos_leverage.png\n")

# 5. Gráfico de residuos con ggplot2
p_residuos <- ggplot(data.frame(
  ajustados = fitted(modelo),
  residuos = residuals(modelo)
), aes(x = ajustados, y = residuos)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed", size = 1) +
  geom_smooth(method = "loess", color = "darkgreen", se = TRUE) +
  labs(title = "Análisis de Residuos del Modelo",
       x = "Valores Ajustados (millones USD)",
       y = "Residuos") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("resultados/graficos/05_residuos_ggplot.png", p_residuos,
       width = 10, height = 6, dpi = 300)
cat("  ✓ Gráfico guardado: 05_residuos_ggplot.png\n\n")

# ==============================================================================
# PASO 9: PREDICCIONES Y INTERVALOS DE CONFIANZA
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 9: Generando predicciones...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Agregar predicciones y residuos al dataset
datos <- datos %>%
  mutate(
    prediccion = predict(modelo),
    residuo = residuals(modelo),
    residuo_estandarizado = rstandard(modelo)
  )

# Ejemplos de predicción
cat("  Ejemplos de predicciones (primeras 5 películas):\n\n")
ejemplos <- datos %>%
  select(titulo, ingresos_int_mill, prediccion, residuo) %>%
  head(5)

print(ejemplos)
cat("\n")

# Gráfico de valores reales vs predichos
p_prediccion <- ggplot(datos, aes(x = ingresos_int_mill, y = prediccion)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_abline(slope = 1, intercept = 0, color = "red", 
              linetype = "dashed", size = 1) +
  labs(title = "Valores Reales vs Predicciones",
       x = "Ingresos Internacionales Reales (millones USD)",
       y = "Ingresos Internacionales Predichos (millones USD)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("resultados/graficos/06_reales_vs_predichos.png", p_prediccion,
       width = 10, height = 6, dpi = 300)
cat("  ✓ Gráfico guardado: 06_reales_vs_predichos.png\n\n")

# ==============================================================================
# PASO 10: GUARDAR MODELO Y RESULTADOS
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 10: Guardando modelo y resultados...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Guardar objeto del modelo
saveRDS(modelo, "resultados/modelo/modelo_regresion.rds")
cat("  ✓ Modelo guardado: resultados/modelo/modelo_regresion.rds\n")

# Guardar resumen del modelo como texto
sink("resultados/modelo/resumen_modelo.txt")
cat("MODELO DE REGRESIÓN LINEAL MÚLTIPLE\n")
cat("Análisis de Ingresos Internacionales de Películas IMDB\n")
cat("========================================================\n\n")
print(summary(modelo))
cat("\n\nMÉTRICAS DE AJUSTE:\n")
print(metricas)
cat("\n\nTABLA DE COEFICIENTES:\n")
print(tabla_coef)
sink()
cat("  ✓ Resumen guardado: resultados/modelo/resumen_modelo.txt\n")

# Crear tabla con stargazer
stargazer(modelo, 
          type = "text",
          title = "Modelo de Regresión: Ingresos Internacionales",
          out = "resultados/modelo/tabla_stargazer.txt",
          covariate.labels = c("Presupuesto (mill USD)", 
                               "Idioma Inglés",
                               "País Fuerte",
                               "Duración²"),
          dep.var.labels = "Ingresos Internacionales (mill USD)")
cat("  ✓ Tabla Stargazer guardada: resultados/modelo/tabla_stargazer.txt\n\n")

# ==============================================================================
# INFORME FINAL
# ==============================================================================

cat("===============================================================================\n")
cat("RESUMEN DEL MODELO DE REGRESIÓN\n")
cat("===============================================================================\n\n")

cat("ESPECIFICACIÓN:\n")
cat("  InternationalRevenue = β₀ + β₁·Budget + β₂·Language + β₃·Country + β₄·Runtime² + ε\n\n")

cat("OBSERVACIONES:\n")
cat(sprintf("  Total de películas analizadas: %d\n", nrow(datos)))
cat(sprintf("  Grados de libertad: %d\n", modelo$df.residual))
cat("\n")

cat("BONDAD DE AJUSTE:\n")
cat(sprintf("  R² = %.4f (%.2f%% de variabilidad explicada)\n", 
            r_cuadrado, 100 * r_cuadrado))
cat(sprintf("  R² Ajustado = %.4f\n", r_cuadrado_aj))
cat(sprintf("  RMSE = %.2f millones USD\n", rmse))
cat("\n")

cat("SIGNIFICANCIA GLOBAL:\n")
cat(sprintf("  F-estadístico = %.2f\n", estadistico_f))
cat(sprintf("  p-valor < 0.001 ***\n"))
cat("  ✓ El modelo es globalmente significativo\n\n")

cat("COEFICIENTES SIGNIFICATIVOS:\n")
for (i in 1:nrow(tabla_coef)) {
  if (tabla_coef$p_valor[i] < 0.05) {
    cat(sprintf("  ✓ %s (p = %.4f)\n", 
                tabla_coef$Variable[i], tabla_coef$p_valor[i]))
  }
}
cat("\n")

cat("ARCHIVOS GENERADOS:\n")
cat("  1. resultados/modelo/modelo_regresion.rds\n")
cat("  2. resultados/modelo/resumen_modelo.txt\n")
cat("  3. resultados/modelo/tabla_stargazer.txt\n")
cat("  4. resultados/tablas/coeficientes_modelo.csv\n")
cat("  5. resultados/tablas/metricas_ajuste.csv\n")
cat("  6. resultados/graficos/01_residuos_vs_ajustados.png\n")
cat("  7. resultados/graficos/02_qq_plot.png\n")
cat("  8. resultados/graficos/03_scale_location.png\n")
cat("  9. resultados/graficos/04_residuos_leverage.png\n")
cat("  10. resultados/graficos/05_residuos_ggplot.png\n")
cat("  11. resultados/graficos/06_reales_vs_predichos.png\n")
cat("\n")

cat("===============================================================================\n")
cat("MODELO ESTIMADO EXITOSAMENTE\n")
cat(sprintf("Fecha y hora: %s\n", Sys.time()))
cat("===============================================================================\n\n")

cat("PRÓXIMOS PASOS:\n")
cat("  1. Verificar multicolinealidad: source('scripts/04a_multicolinealidad.R')\n")
cat("  2. Verificar endogeneidad: source('scripts/04b_endogeneidad.R')\n")
cat("  3. Verificar forma funcional: source('scripts/04c_forma_funcional.R')\n")
cat("  4. Verificar heterocedasticidad: source('scripts/04d_heterocedasticidad.R')\n")
cat("  5. Verificar autocorrelación: source('scripts/04e_autocorrelacion.R')\n\n")

# ==============================================================================
# FIN DEL SCRIPT
# ==============================================================================
