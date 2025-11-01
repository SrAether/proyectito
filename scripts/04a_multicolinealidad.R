################################################################################
# SCRIPT 04a: VERIFICACIÓN DE MULTICOLINEALIDAD
################################################################################
#
# Proyecto: Análisis de Ingresos Internacionales de Películas IMDB
# Entorno: pruebasVal
# Script: 04a_multicolinealidad.R
#
# Propósito: Verificar el supuesto de no multicolinealidad perfecta
#            usando VIF (Variance Inflation Factor) y matriz de correlación
#
# Supuesto: Las variables independientes no deben estar perfectamente
#           correlacionadas entre sí
#
# Criterio: VIF < 5 (aceptable), VIF > 10 (problemático)
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
cat("  VERIFICACIÓN DE SUPUESTO: MULTICOLINEALIDAD\n")
cat("===============================================================================\n\n")

# Cargar librerías
suppressPackageStartupMessages({
  library(tidyverse)
  library(car)
  library(corrplot)
  library(ggcorrplot)
})

cat("✓ Librerías cargadas correctamente\n\n")

# ==============================================================================
# PASO 1: CARGAR MODELO Y DATOS
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 1: Cargando modelo y datos...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Cargar modelo
if (!file.exists("resultados/modelo/modelo_regresion.rds")) {
  stop("ERROR: El modelo no existe.\n",
       "       Ejecuta primero: source('scripts/03_modelo_regresion.R')")
}

modelo <- readRDS("resultados/modelo/modelo_regresion.rds")
cat("  ✓ Modelo cargado correctamente\n")

# Cargar datos
datos <- read.csv("data/datos_limpios.csv")
datos <- datos %>%
  mutate(
    presupuesto_mill = presupuesto / 1000000,
    ingresos_int_mill = ingresos_internacionales / 1000000
  )

cat(sprintf("  ✓ Datos cargados: %d observaciones\n\n", nrow(datos)))

# ==============================================================================
# PASO 2: TEORÍA DE MULTICOLINEALIDAD
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 2: Concepto de Multicolinealidad\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  ¿QUÉ ES LA MULTICOLINEALIDAD?\n\n")
cat("  La multicolinealidad ocurre cuando dos o más variables independientes\n")
cat("  están altamente correlacionadas entre sí. Esto puede causar:\n\n")
cat("    • Estimadores inestables (varianzas infladas)\n")
cat("    • Coeficientes con signos inesperados\n")
cat("    • Dificultad para determinar el efecto individual de cada variable\n")
cat("    • Intervalos de confianza muy amplios\n\n")

cat("  MÉTODOS DE DETECCIÓN:\n\n")
cat("    1. Matriz de Correlación: Correlaciones > 0.8 son problemáticas\n")
cat("    2. VIF (Variance Inflation Factor):\n")
cat("       - VIF < 5: No hay problema de multicolinealidad\n")
cat("       - 5 ≤ VIF < 10: Multicolinealidad moderada\n")
cat("       - VIF ≥ 10: Multicolinealidad severa (requiere corrección)\n\n")

cat("  SOLUCIONES:\n\n")
cat("    • Eliminar una de las variables correlacionadas\n")
cat("    • Combinar variables correlacionadas\n")
cat("    • Usar regresión de componentes principales (PCA)\n")
cat("    • Aumentar el tamaño de la muestra\n\n")

# ==============================================================================
# PASO 3: MATRIZ DE CORRELACIÓN
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 3: Matriz de Correlación\n")
cat("-------------------------------------------------------------------------------\n\n")

# Seleccionar variables independientes del modelo
variables_indep <- c("presupuesto_mill", "idioma_ingles", 
                     "pais_fuerte", "duracion_cuadrado")

# Calcular matriz de correlación
matriz_cor <- cor(datos[, variables_indep], use = "complete.obs")

cat("  MATRIZ DE CORRELACIÓN:\n\n")
print(round(matriz_cor, 4))
cat("\n")

# Identificar correlaciones altas
correlaciones_altas <- which(abs(matriz_cor) > 0.8 & matriz_cor != 1, 
                             arr.ind = TRUE)

if (nrow(correlaciones_altas) > 0) {
  cat("  ⚠ CORRELACIONES ALTAS DETECTADAS (|r| > 0.8):\n\n")
  for (i in 1:nrow(correlaciones_altas)) {
    row_idx <- correlaciones_altas[i, 1]
    col_idx <- correlaciones_altas[i, 2]
    if (row_idx < col_idx) {  # Evitar duplicados
      cat(sprintf("    • %s ↔ %s: r = %.4f\n",
                  rownames(matriz_cor)[row_idx],
                  colnames(matriz_cor)[col_idx],
                  matriz_cor[row_idx, col_idx]))
    }
  }
  cat("\n")
} else {
  cat("  ✓ No se detectaron correlaciones altas (|r| > 0.8)\n\n")
}

# Guardar matriz
write.csv(matriz_cor, 
          "resultados/tablas/matriz_correlacion.csv")
cat("  ✓ Matriz de correlación guardada\n\n")

# ==============================================================================
# PASO 4: VISUALIZACIÓN DE LA MATRIZ DE CORRELACIÓN
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 4: Visualización de la Matriz de Correlación\n")
cat("-------------------------------------------------------------------------------\n\n")

# Gráfico 1: corrplot clásico
png("resultados/graficos/07_matriz_correlacion_corrplot.png",
    width = 800, height = 800)
corrplot(matriz_cor, 
         method = "color",
         type = "upper",
         tl.col = "black",
         tl.srt = 45,
         addCoef.col = "black",
         number.cex = 0.8,
         col = colorRampPalette(c("#6D9EC1", "white", "#E46726"))(200),
         title = "Matriz de Correlación - Variables del Modelo",
         mar = c(0, 0, 2, 0))
dev.off()
cat("  ✓ Gráfico guardado: 07_matriz_correlacion_corrplot.png\n")

# Gráfico 2: ggcorrplot
p_cor <- ggcorrplot(matriz_cor,
                    hc.order = TRUE,
                    type = "lower",
                    lab = TRUE,
                    lab_size = 4,
                    colors = c("#6D9EC1", "white", "#E46726"),
                    title = "Matriz de Correlación - Variables Independientes",
                    ggtheme = theme_minimal())

ggsave("resultados/graficos/08_matriz_correlacion_ggplot.png", p_cor,
       width = 10, height = 8, dpi = 300)
cat("  ✓ Gráfico guardado: 08_matriz_correlacion_ggplot.png\n\n")

# ==============================================================================
# PASO 5: CÁLCULO DEL VIF
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 5: Cálculo del VIF (Variance Inflation Factor)\n")
cat("-------------------------------------------------------------------------------\n\n")

# Calcular VIF
vif_valores <- vif(modelo)

# Crear tabla de resultados
tabla_vif <- data.frame(
  Variable = names(vif_valores),
  VIF = vif_valores,
  Interpretacion = case_when(
    vif_valores < 5 ~ "Sin problema",
    vif_valores < 10 ~ "Multicolinealidad moderada",
    TRUE ~ "Multicolinealidad severa"
  ),
  Tolerancia = 1 / vif_valores
)

rownames(tabla_vif) <- NULL

cat("  VALORES DE VIF:\n\n")
print(tabla_vif)
cat("\n")

# Interpretación
cat("  INTERPRETACIÓN:\n\n")
cat("    VIF mide cuánto se infla la varianza de un coeficiente estimado\n")
cat("    debido a la multicolinealidad. Se calcula como: VIF = 1 / (1 - R²_j)\n")
cat("    donde R²_j es el R² de la regresión de X_j sobre las otras X's.\n\n")

# Diagnóstico
variables_problema <- tabla_vif$Variable[tabla_vif$VIF >= 10]

if (length(variables_problema) > 0) {
  cat("  ⚠ VARIABLES CON MULTICOLINEALIDAD SEVERA (VIF ≥ 10):\n\n")
  for (var in variables_problema) {
    vif_val <- tabla_vif$VIF[tabla_vif$Variable == var]
    cat(sprintf("    • %s: VIF = %.2f\n", var, vif_val))
  }
  cat("\n")
  cat("  RECOMENDACIÓN: Considerar eliminar o combinar estas variables.\n\n")
} else if (any(tabla_vif$VIF >= 5)) {
  cat("  ⚠ MULTICOLINEALIDAD MODERADA DETECTADA (5 ≤ VIF < 10):\n\n")
  vars_moderadas <- tabla_vif$Variable[tabla_vif$VIF >= 5 & tabla_vif$VIF < 10]
  for (var in vars_moderadas) {
    vif_val <- tabla_vif$VIF[tabla_vif$Variable == var]
    cat(sprintf("    • %s: VIF = %.2f\n", var, vif_val))
  }
  cat("\n")
  cat("  RECOMENDACIÓN: Monitorear estas variables, pero no es crítico.\n\n")
} else {
  cat("  ✓ NO HAY PROBLEMAS DE MULTICOLINEALIDAD\n\n")
  cat("    Todos los valores de VIF son menores a 5.\n")
  cat("    Las variables independientes no están altamente correlacionadas.\n\n")
}

# Guardar tabla
write.csv(tabla_vif, 
          "resultados/tablas/vif_valores.csv",
          row.names = FALSE)
cat("  ✓ Tabla de VIF guardada\n\n")

# ==============================================================================
# PASO 6: GRÁFICO DE VIF
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 6: Visualización de VIF\n")
cat("-------------------------------------------------------------------------------\n\n")

# Gráfico de barras de VIF
p_vif <- ggplot(tabla_vif, aes(x = reorder(Variable, VIF), y = VIF)) +
  geom_col(aes(fill = VIF), show.legend = FALSE) +
  geom_hline(yintercept = 5, color = "orange", linetype = "dashed", 
             size = 1.5, alpha = 0.7) +
  geom_hline(yintercept = 10, color = "red", linetype = "dashed", 
             size = 1.5, alpha = 0.7) +
  geom_text(aes(label = round(VIF, 2)), hjust = -0.2, size = 4) +
  scale_fill_gradient(low = "steelblue", high = "darkred") +
  annotate("text", x = 0.5, y = 5.3, label = "VIF = 5 (umbral moderado)", 
           color = "orange", hjust = 0, size = 3.5) +
  annotate("text", x = 0.5, y = 10.3, label = "VIF = 10 (umbral severo)", 
           color = "red", hjust = 0, size = 3.5) +
  coord_flip() +
  labs(title = "VIF (Variance Inflation Factor) por Variable",
       subtitle = "Valores menores a 5 indican ausencia de multicolinealidad",
       x = "Variable",
       y = "VIF") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5),
        axis.text = element_text(size = 10))

ggsave("resultados/graficos/09_vif_barplot.png", p_vif,
       width = 10, height = 6, dpi = 300)
cat("  ✓ Gráfico guardado: 09_vif_barplot.png\n\n")

# ==============================================================================
# PASO 7: ANÁLISIS DE TOLERANCIA
# ==============================================================================

cat("-------------------------------------------------------------------------------\n")
cat("PASO 7: Análisis de Tolerancia\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  TOLERANCIA = 1 / VIF\n\n")
cat("  La tolerancia mide la proporción de varianza en cada variable\n")
cat("  independiente que NO es explicada por las otras variables.\n\n")
cat("  Criterio:\n")
cat("    • Tolerancia > 0.2: Aceptable\n")
cat("    • Tolerancia < 0.2: Problemático\n")
cat("    • Tolerancia < 0.1: Muy problemático\n\n")

# Identificar variables con baja tolerancia
vars_baja_tolerancia <- tabla_vif$Variable[tabla_vif$Tolerancia < 0.2]

if (length(vars_baja_tolerancia) > 0) {
  cat("  ⚠ VARIABLES CON BAJA TOLERANCIA:\n\n")
  for (var in vars_baja_tolerancia) {
    tol_val <- tabla_vif$Tolerancia[tabla_vif$Variable == var]
    cat(sprintf("    • %s: Tolerancia = %.4f\n", var, tol_val))
  }
  cat("\n")
} else {
  cat("  ✓ Todas las variables tienen tolerancia aceptable (> 0.2)\n\n")
}

# ==============================================================================
# INFORME FINAL
# ==============================================================================

cat("===============================================================================\n")
cat("INFORME FINAL: MULTICOLINEALIDAD\n")
cat("===============================================================================\n\n")

cat("SUPUESTO EVALUADO:\n")
cat("  No multicolinealidad perfecta entre variables independientes\n\n")

cat("MÉTODOS UTILIZADOS:\n")
cat("  1. Matriz de Correlación de Pearson\n")
cat("  2. VIF (Variance Inflation Factor)\n")
cat("  3. Análisis de Tolerancia\n\n")

cat("RESULTADOS:\n\n")

# Resumen de correlaciones
max_cor <- max(abs(matriz_cor[matriz_cor != 1]))
cat(sprintf("  Correlación máxima (absoluta): %.4f\n", max_cor))
if (max_cor > 0.8) {
  cat("  ⚠ Hay correlaciones altas entre variables\n\n")
} else {
  cat("  ✓ No hay correlaciones problemáticas\n\n")
}

# Resumen de VIF
max_vif <- max(tabla_vif$VIF)
cat(sprintf("  VIF máximo: %.4f\n", max_vif))
if (max_vif >= 10) {
  cat("  ⚠ Multicolinealidad severa detectada\n\n")
} else if (max_vif >= 5) {
  cat("  ⚠ Multicolinealidad moderada detectada\n\n")
} else {
  cat("  ✓ No hay problemas de multicolinealidad\n\n")
}

# Conclusión final
cat("CONCLUSIÓN:\n\n")
if (max_vif < 5 && max_cor < 0.8) {
  cat("  ✓ EL SUPUESTO DE NO MULTICOLINEALIDAD SE CUMPLE\n\n")
  cat("  Las variables independientes del modelo no presentan\n")
  cat("  correlaciones problemáticas entre sí. Los coeficientes\n")
  cat("  estimados son estables y confiables.\n\n")
} else if (max_vif < 10) {
  cat("  ⚠ MULTICOLINEALIDAD MODERADA\n\n")
  cat("  Hay cierta correlación entre variables, pero no es severa.\n")
  cat("  El modelo puede usarse con precaución. Se recomienda:\n")
  cat("    • Interpretar los coeficientes con cuidado\n")
  cat("    • No eliminar variables solo por multicolinealidad moderada\n")
  cat("    • Verificar la estabilidad de los coeficientes\n\n")
} else {
  cat("  ✗ MULTICOLINEALIDAD SEVERA\n\n")
  cat("  Los coeficientes pueden ser inestables. Se recomienda:\n")
  cat("    • Eliminar una de las variables correlacionadas\n")
  cat("    • Combinar variables correlacionadas en un índice\n")
  cat("    • Usar técnicas de regularización (Ridge, Lasso)\n")
  cat("    • Reestimar el modelo sin las variables problemáticas\n\n")
}

cat("ARCHIVOS GENERADOS:\n")
cat("  1. resultados/tablas/matriz_correlacion.csv\n")
cat("  2. resultados/tablas/vif_valores.csv\n")
cat("  3. resultados/graficos/07_matriz_correlacion_corrplot.png\n")
cat("  4. resultados/graficos/08_matriz_correlacion_ggplot.png\n")
cat("  5. resultados/graficos/09_vif_barplot.png\n")
cat("\n")

cat("===============================================================================\n")
cat("VERIFICACIÓN DE MULTICOLINEALIDAD COMPLETADA\n")
cat(sprintf("Fecha y hora: %s\n", Sys.time()))
cat("===============================================================================\n\n")

cat("PRÓXIMO PASO:\n")
cat("  Verificar endogeneidad: source('scripts/04b_endogeneidad.R')\n\n")

# ==============================================================================
# FIN DEL SCRIPT
# ==============================================================================
