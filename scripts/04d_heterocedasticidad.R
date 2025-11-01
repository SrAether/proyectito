################################################################################
#           VERIFICACIÓN Y CORRECCIÓN DE HETEROCEDASTICIDAD                   #
#                       IMDB Movies 2000-2020                                  #
################################################################################

# Limpieza del entorno
rm(list = ls())
gc()

# Cargar librerías necesarias
suppressPackageStartupMessages({
  library(tidyverse)
  library(lmtest)      # Test de Breusch-Pagan y White
  library(sandwich)    # Errores estándar robustos
  library(car)         # Funciones adicionales
  library(stargazer)   # Tablas comparativas
})

# Definir rutas
ruta_modelo <- "resultados/modelo/modelo_regresion.rds"
ruta_datos <- "data/datos_limpios.csv"
ruta_graficos <- "resultados/graficos/"
ruta_tablas <- "resultados/tablas/"

cat("\n")
cat("===============================================================================\n")
cat("  VERIFICACIÓN Y CORRECCIÓN DE HETEROCEDASTICIDAD\n")
cat("===============================================================================\n\n")

################################################################################
# PASO 1: CARGAR MODELO Y DATOS
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 1: Cargando modelo y datos...\n")
cat("-------------------------------------------------------------------------------\n\n")

modelo <- readRDS(ruta_modelo)
datos <- read_csv(ruta_datos, show_col_types = FALSE)

# Preparar datos para el modelo
datos_modelo <- datos %>%
  select(ingresos_internacionales, presupuesto, idioma_ingles, 
         pais_fuerte, duracion_cuadrado) %>%
  filter(complete.cases(.)) %>%
  mutate(
    ingresos_int_mill = ingresos_internacionales / 1e6,
    presupuesto_mill = presupuesto / 1e6
  )

cat(sprintf("  ✓ Modelo cargado correctamente\n"))
cat(sprintf("  ✓ Datos cargados: %d observaciones\n\n", nrow(datos_modelo)))

################################################################################
# PASO 2: CONCEPTO DE HETEROCEDASTICIDAD
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 2: Concepto de Heterocedasticidad\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  ¿QUÉ ES LA HETEROCEDASTICIDAD?\n\n")
cat("  La heterocedasticidad ocurre cuando la varianza de los errores NO es\n")
cat("  constante a lo largo de las observaciones. Es decir: Var(εᵢ) ≠ σ²\n\n")

cat("  CONSECUENCIAS:\n")
cat("    • Los estimadores MCO siguen siendo INSESGADOS\n")
cat("    • Pero ya NO son eficientes (no tienen varianza mínima)\n")
cat("    • Los errores estándar están MAL calculados\n")
cat("    • Las pruebas t y F NO son válidas\n")
cat("    • Los intervalos de confianza son incorrectos\n\n")

cat("  SOLUCIONES:\n")
cat("    1. Si se CONOCE la forma de la heterocedasticidad:\n")
cat("       → Usar MCP (Mínimos Cuadrados Ponderados) - MELI\n\n")
cat("    2. Si NO se conoce la forma:\n")
cat("       → Usar errores estándar robustos de White\n")
cat("       → Asintóticamente válidos (muestras grandes)\n\n")

################################################################################
# PASO 3: PRUEBA DE BREUSCH-PAGAN
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 3: Prueba de Breusch-Pagan\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  La prueba de Breusch-Pagan detecta heterocedasticidad bajo la hipótesis:\n")
cat("    H₀: Homocedasticidad (varianza constante)\n")
cat("    H₁: Heterocedasticidad presente\n\n")

# Realizar prueba de Breusch-Pagan
bp_test <- bptest(modelo)

cat("  RESULTADOS DE LA PRUEBA:\n\n")
cat(sprintf("    Estadístico BP: %.4f\n", bp_test$statistic))
cat(sprintf("    Grados de libertad: %d\n", bp_test$parameter))
cat(sprintf("    Valor p: %.6f\n\n", bp_test$p.value))

if (bp_test$p.value < 0.05) {
  cat("  ✗ CONCLUSIÓN: Se RECHAZA H₀ (p < 0.05)\n")
  cat("    HAY evidencia de HETEROCEDASTICIDAD\n")
  cat("    Los errores estándar de MCO NO son confiables\n\n")
  hay_hetero_bp <- TRUE
} else {
  cat("  ✓ CONCLUSIÓN: NO se rechaza H₀ (p > 0.05)\n")
  cat("    NO hay evidencia suficiente de heterocedasticidad\n\n")
  hay_hetero_bp <- FALSE
}

################################################################################
# PASO 4: PRUEBA DE WHITE
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 4: Prueba de White (más robusta)\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  La prueba de White es más general y NO asume una forma específica\n")
cat("  de heterocedasticidad.\n\n")

# Crear variables auxiliares para la prueba de White
datos_white <- datos_modelo %>%
  mutate(
    presup_sq = presupuesto_mill^2,
    idioma_presup = idioma_ingles * presupuesto_mill,
    pais_presup = pais_fuerte * presupuesto_mill,
    duracion_presup = duracion_cuadrado * presupuesto_mill
  )

# Modelo auxiliar con residuos cuadrados
residuos_sq <- residuals(modelo)^2

modelo_white <- lm(residuos_sq ~ presupuesto_mill + idioma_ingles + 
                                 pais_fuerte + duracion_cuadrado +
                                 presup_sq + idioma_presup + 
                                 pais_presup + duracion_presup,
                   data = datos_white)

# Estadístico de White
n <- nrow(datos_modelo)
R2_white <- summary(modelo_white)$r.squared
LM_white <- n * R2_white
p_value_white <- 1 - pchisq(LM_white, df = modelo_white$rank - 1)

cat("  RESULTADOS DE LA PRUEBA:\n\n")
cat(sprintf("    R² del modelo auxiliar: %.6f\n", R2_white))
cat(sprintf("    Estadístico LM (n×R²): %.4f\n", LM_white))
cat(sprintf("    Grados de libertad: %d\n", modelo_white$rank - 1))
cat(sprintf("    Valor p: %.6f\n\n", p_value_white))

if (p_value_white < 0.05) {
  cat("  ✗ CONCLUSIÓN: Se RECHAZA H₀ (p < 0.05)\n")
  cat("    HAY evidencia de HETEROCEDASTICIDAD\n\n")
  hay_hetero_white <- TRUE
} else {
  cat("  ✓ CONCLUSIÓN: NO se rechaza H₀ (p > 0.05)\n")
  cat("    NO hay evidencia de heterocedasticidad\n\n")
  hay_hetero_white <- FALSE
}

# Guardar resultados de las pruebas
resultados_pruebas <- data.frame(
  Prueba = c("Breusch-Pagan", "White"),
  Estadistico = c(bp_test$statistic, LM_white),
  GL = c(bp_test$parameter, modelo_white$rank - 1),
  Valor_p = c(bp_test$p.value, p_value_white),
  Conclusion = c(
    ifelse(hay_hetero_bp, "Heterocedasticidad presente", "No se detecta"),
    ifelse(hay_hetero_white, "Heterocedasticidad presente", "No se detecta")
  )
)

write_csv(resultados_pruebas, paste0(ruta_tablas, "pruebas_heterocedasticidad.csv"))
cat("  ✓ Resultados de pruebas guardados\n\n")

################################################################################
# PASO 5: VISUALIZACIÓN DE HETEROCEDASTICIDAD
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 5: Visualización de heterocedasticidad...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Gráfico de residuos vs valores ajustados
valores_ajustados <- fitted(modelo)
residuos <- residuals(modelo)

p1 <- ggplot(data.frame(ajustados = valores_ajustados, residuos = residuos), 
             aes(x = ajustados, y = residuos)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed", linewidth = 1) +
  geom_smooth(method = "loess", color = "darkgreen", se = TRUE) +
  labs(
    title = "Diagnóstico de Heterocedasticidad",
    subtitle = "Residuos vs Valores Ajustados",
    x = "Valores Ajustados (millones USD)",
    y = "Residuos"
  ) +
  theme_minimal(base_size = 12)

ggsave(paste0(ruta_graficos, "10_hetero_residuos_vs_ajustados.png"),
       plot = p1, width = 10, height = 6, dpi = 300)
cat("  ✓ Gráfico guardado: 10_hetero_residuos_vs_ajustados.png\n")

# Gráfico de residuos cuadrados vs valores ajustados
p2 <- ggplot(data.frame(ajustados = valores_ajustados, residuos_sq = residuos_sq), 
             aes(x = ajustados, y = residuos_sq)) +
  geom_point(alpha = 0.4, color = "coral") +
  geom_smooth(method = "loess", color = "darkblue", se = TRUE) +
  labs(
    title = "Diagnóstico de Heterocedasticidad",
    subtitle = "Residuos Cuadrados vs Valores Ajustados",
    x = "Valores Ajustados (millones USD)",
    y = "Residuos Cuadrados"
  ) +
  theme_minimal(base_size = 12)

ggsave(paste0(ruta_graficos, "11_hetero_residuos_cuadrados.png"),
       plot = p2, width = 10, height = 6, dpi = 300)
cat("  ✓ Gráfico guardado: 11_hetero_residuos_cuadrados.png\n")

# Scale-Location plot
residuos_std <- sqrt(abs(rstandard(modelo)))
p3 <- ggplot(data.frame(ajustados = valores_ajustados, residuos_std = residuos_std), 
             aes(x = ajustados, y = residuos_std)) +
  geom_point(alpha = 0.4, color = "purple") +
  geom_smooth(method = "loess", color = "red", se = TRUE) +
  labs(
    title = "Scale-Location Plot",
    subtitle = "Verificación de homocedasticidad",
    x = "Valores Ajustados (millones USD)",
    y = "√|Residuos Estandarizados|"
  ) +
  theme_minimal(base_size = 12)

ggsave(paste0(ruta_graficos, "12_hetero_scale_location.png"),
       plot = p3, width = 10, height = 6, dpi = 300)
cat("  ✓ Gráfico guardado: 12_hetero_scale_location.png\n\n")

################################################################################
# PASO 6: CORRECCIÓN - ERRORES ESTÁNDAR ROBUSTOS DE WHITE
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 6: CORRECCIÓN - Errores Estándar Robustos de White\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  Cuando NO se conoce la forma de la heterocedasticidad:\n")
cat("  → Usamos errores estándar robustos (HC - Heteroskedasticity Consistent)\n\n")

cat("  Tipos de corrección disponibles:\n")
cat("    • HC0: Corrección básica de White\n")
cat("    • HC1: Corrección con factor de pequeñas muestras\n")
cat("    • HC2: Corrección que ajusta por leverage\n")
cat("    • HC3: Más robusta (recomendada)\n\n")

# Calcular errores estándar robustos (HC3)
vcov_robust_hc3 <- vcovHC(modelo, type = "HC3")
errores_robust_hc3 <- sqrt(diag(vcov_robust_hc3))

# Calcular errores estándar robustos (HC1)
vcov_robust_hc1 <- vcovHC(modelo, type = "HC1")
errores_robust_hc1 <- sqrt(diag(vcov_robust_hc1))

# Errores estándar originales (MCO)
errores_mco <- sqrt(diag(vcov(modelo)))

# Coeficientes
coeficientes <- coef(modelo)

# Crear tabla comparativa
comparacion <- data.frame(
  Variable = names(coeficientes),
  Coeficiente = coeficientes,
  EE_MCO = errores_mco,
  EE_HC1 = errores_robust_hc1,
  EE_HC3 = errores_robust_hc3,
  t_MCO = coeficientes / errores_mco,
  t_HC3 = coeficientes / errores_robust_hc3,
  p_MCO = 2 * pt(-abs(coeficientes / errores_mco), df = modelo$df.residual),
  p_HC3 = 2 * pt(-abs(coeficientes / errores_robust_hc3), df = modelo$df.residual)
)

cat("  COMPARACIÓN: MCO vs ERRORES ROBUSTOS\n\n")
print(comparacion %>% 
      select(Variable, Coeficiente, EE_MCO, EE_HC3, p_MCO, p_HC3) %>%
      mutate(across(where(is.numeric), ~round(., 5))))

write_csv(comparacion, paste0(ruta_tablas, "comparacion_errores_robustos.csv"))
cat("\n  ✓ Tabla de comparación guardada\n\n")

################################################################################
# PASO 7: PRUEBAS DE SIGNIFICANCIA CON ERRORES ROBUSTOS
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 7: Pruebas de significancia con errores robustos\n")
cat("-------------------------------------------------------------------------------\n\n")

# Test de coeficientes con errores robustos
coeftest_robust <- coeftest(modelo, vcov = vcov_robust_hc3)

cat("  RESULTADOS CON ERRORES ESTÁNDAR ROBUSTOS (HC3):\n\n")
print(coeftest_robust)
cat("\n")

# Intervalos de confianza robustos
ic_mco <- confint(modelo)
ic_robust <- coefci(modelo, vcov = vcov_robust_hc3)

comparacion_ic <- data.frame(
  Variable = names(coeficientes),
  Coef = coeficientes,
  IC_MCO_inf = ic_mco[, 1],
  IC_MCO_sup = ic_mco[, 2],
  IC_Robust_inf = ic_robust[, 1],
  IC_Robust_sup = ic_robust[, 2],
  Amplitud_MCO = ic_mco[, 2] - ic_mco[, 1],
  Amplitud_Robust = ic_robust[, 2] - ic_robust[, 1]
)

cat("  INTERVALOS DE CONFIANZA (95%):\n\n")
print(comparacion_ic %>% mutate(across(where(is.numeric), ~round(., 4))))

write_csv(comparacion_ic, paste0(ruta_tablas, "intervalos_confianza_comparacion.csv"))
cat("\n  ✓ Intervalos de confianza guardados\n\n")

################################################################################
# PASO 8: VISUALIZACIÓN DE COMPARACIÓN
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 8: Visualización de errores estándar...\n")
cat("-------------------------------------------------------------------------------\n\n")

# Gráfico de comparación de errores estándar
datos_grafico <- comparacion %>%
  select(Variable, EE_MCO, EE_HC3) %>%
  pivot_longer(cols = c(EE_MCO, EE_HC3), names_to = "Tipo", values_to = "Error_Estandar") %>%
  mutate(
    Tipo = factor(Tipo, levels = c("EE_MCO", "EE_HC3"), 
                  labels = c("MCO", "Robusto HC3")),
    Variable = factor(Variable, levels = names(coeficientes))
  )

p4 <- ggplot(datos_grafico, aes(x = Variable, y = Error_Estandar, fill = Tipo)) +
  geom_col(position = "dodge", alpha = 0.8) +
  scale_fill_manual(values = c("MCO" = "steelblue", "Robusto HC3" = "coral")) +
  labs(
    title = "Comparación de Errores Estándar",
    subtitle = "MCO vs Errores Robustos de White (HC3)",
    x = "Variable",
    y = "Error Estándar",
    fill = "Método"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

ggsave(paste0(ruta_graficos, "13_comparacion_errores_estandar.png"),
       plot = p4, width = 10, height = 6, dpi = 300)
cat("  ✓ Gráfico guardado: 13_comparacion_errores_estandar.png\n")

# Gráfico de intervalos de confianza
datos_ic_grafico <- comparacion_ic %>%
  filter(Variable != "(Intercept)") %>%
  mutate(Variable = factor(Variable))

p5 <- ggplot(datos_ic_grafico) +
  geom_point(aes(x = Variable, y = Coef), size = 3) +
  geom_errorbar(aes(x = Variable, ymin = IC_MCO_inf, ymax = IC_MCO_sup),
                width = 0.2, color = "steelblue", linewidth = 1, alpha = 0.6) +
  geom_errorbar(aes(x = Variable, ymin = IC_Robust_inf, ymax = IC_Robust_sup),
                width = 0.1, color = "coral", linewidth = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "Intervalos de Confianza 95%",
    subtitle = "Azul: MCO | Naranja: Robusto HC3",
    x = "Variable",
    y = "Coeficiente"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(paste0(ruta_graficos, "14_intervalos_confianza.png"),
       plot = p5, width = 10, height = 6, dpi = 300)
cat("  ✓ Gráfico guardado: 14_intervalos_confianza.png\n\n")

################################################################################
# PASO 9: INTERPRETACIÓN Y RECOMENDACIONES
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 9: Interpretación y Recomendaciones\n")
cat("-------------------------------------------------------------------------------\n\n")

cat("  CAMBIOS EN LA SIGNIFICANCIA:\n\n")

cambios_sig <- comparacion %>%
  mutate(
    sig_MCO = ifelse(p_MCO < 0.05, "Significativo", "No significativo"),
    sig_HC3 = ifelse(p_HC3 < 0.05, "Significativo", "No significativo"),
    cambio = sig_MCO != sig_HC3
  ) %>%
  select(Variable, sig_MCO, sig_HC3, cambio, p_MCO, p_HC3)

print(cambios_sig)

n_cambios <- sum(cambios_sig$cambio)
cat(sprintf("\n  Variables que cambiaron de significancia: %d\n\n", n_cambios))

if (n_cambios > 0) {
  cat("  ⚠ IMPORTANTE: Hay cambios en la significancia de variables\n")
  cat("    Usar los resultados con errores robustos para inferencia\n\n")
} else {
  cat("  ✓ Las conclusiones de significancia se mantienen\n\n")
}

cat("  RECOMENDACIONES:\n\n")
cat("  1. SIEMPRE reportar errores robustos cuando hay heterocedasticidad\n")
cat("  2. Los coeficientes NO cambian (siguen siendo insesgados)\n")
cat("  3. Los errores estándar robustos son MAYORES generalmente\n")
cat("  4. Las pruebas t y p-valores SON VÁLIDOS con errores robustos\n")
cat("  5. Los intervalos de confianza con errores robustos son más confiables\n\n")

################################################################################
# PASO 10: GUARDAR MODELO CORREGIDO
################################################################################

cat("-------------------------------------------------------------------------------\n")
cat("PASO 10: Guardar resultados corregidos\n")
cat("-------------------------------------------------------------------------------\n\n")

# Guardar matriz de varianzas-covarianzas robusta
saveRDS(vcov_robust_hc3, "resultados/modelo/vcov_robust_hc3.rds")
cat("  ✓ Matriz de varianzas-covarianzas robusta guardada\n")

# Guardar tabla de coeficientes robustos
coef_robust_table <- data.frame(
  Variable = rownames(coeftest_robust),
  Estimador = coeftest_robust[, "Estimate"],
  Error_Estandar = coeftest_robust[, "Std. Error"],
  t_valor = coeftest_robust[, "t value"],
  p_valor = coeftest_robust[, "Pr(>|t|)"]
)
write_csv(coef_robust_table, paste0(ruta_tablas, "coeficientes_robustos.csv"))
cat("  ✓ Tabla de coeficientes robustos guardada\n")

# Crear tabla comparativa con stargazer
sink(paste0(ruta_tablas, "tabla_comparativa_mco_robust.txt"))
stargazer(modelo, modelo,
          type = "text",
          title = "Comparación: MCO vs Errores Robustos",
          column.labels = c("MCO", "Robusto (HC3)"),
          se = list(NULL, errores_robust_hc3),
          dep.var.labels = "Ingresos Internacionales (millones USD)",
          covariate.labels = c("Presupuesto (mill)", "Idioma Inglés", 
                               "País Fuerte", "Duración²"),
          omit.stat = c("f", "ser"),
          notes = "Errores robustos a heterocedasticidad (White HC3)")
sink()
cat("  ✓ Tabla comparativa Stargazer guardada\n\n")

################################################################################
# RESUMEN FINAL
################################################################################

cat("===============================================================================\n")
cat("INFORME FINAL: HETEROCEDASTICIDAD\n")
cat("===============================================================================\n\n")

cat("SUPUESTO EVALUADO:\n")
cat("  Homocedasticidad: Var(εᵢ) = σ² (constante)\n\n")

cat("MÉTODOS UTILIZADOS:\n")
cat("  1. Prueba de Breusch-Pagan\n")
cat("  2. Prueba de White\n")
cat("  3. Inspección visual de residuos\n\n")

cat("RESULTADOS DE LAS PRUEBAS:\n")
cat(sprintf("  • Breusch-Pagan: p = %.6f ", bp_test$p.value))
if (hay_hetero_bp) cat("✗ Heterocedasticidad\n") else cat("✓ Homocedasticidad\n")
cat(sprintf("  • White: p = %.6f ", p_value_white))
if (hay_hetero_white) cat("✗ Heterocedasticidad\n\n") else cat("✓ Homocedasticidad\n\n")

if (hay_hetero_bp || hay_hetero_white) {
  cat("CONCLUSIÓN:\n")
  cat("  ✗ HAY EVIDENCIA DE HETEROCEDASTICIDAD\n\n")
  
  cat("CORRECCIÓN APLICADA:\n")
  cat("  ✓ Errores Estándar Robustos de White (HC3)\n")
  cat("  ✓ Los coeficientes NO cambian (siguen siendo insesgados)\n")
  cat("  ✓ Los errores estándar SÍ cambian (ahora son válidos)\n")
  cat("  ✓ Las pruebas de hipótesis ahora son confiables\n\n")
  
  cat("IMPACTO EN LOS RESULTADOS:\n")
  cat(sprintf("  • Variables con cambio en significancia: %d\n", n_cambios))
  cat("  • Los errores robustos son generalmente mayores\n")
  cat("  • Los intervalos de confianza son más amplios (más conservadores)\n\n")
} else {
  cat("CONCLUSIÓN:\n")
  cat("  ✓ NO HAY EVIDENCIA SIGNIFICATIVA DE HETEROCEDASTICIDAD\n")
  cat("  ✓ Los errores estándar de MCO son apropiados\n")
  cat("  ✓ No se requiere corrección\n\n")
  cat("NOTA:\n")
  cat("  Aunque no se detectó heterocedasticidad significativa,\n")
  cat("  se calcularon errores robustos como verificación adicional.\n\n")
}

cat("ARCHIVOS GENERADOS:\n")
cat("  1. resultados/tablas/pruebas_heterocedasticidad.csv\n")
cat("  2. resultados/tablas/comparacion_errores_robustos.csv\n")
cat("  3. resultados/tablas/intervalos_confianza_comparacion.csv\n")
cat("  4. resultados/tablas/coeficientes_robustos.csv\n")
cat("  5. resultados/tablas/tabla_comparativa_mco_robust.txt\n")
cat("  6. resultados/modelo/vcov_robust_hc3.rds\n")
cat("  7. resultados/graficos/10_hetero_residuos_vs_ajustados.png\n")
cat("  8. resultados/graficos/11_hetero_residuos_cuadrados.png\n")
cat("  9. resultados/graficos/12_hetero_scale_location.png\n")
cat("  10. resultados/graficos/13_comparacion_errores_estandar.png\n")
cat("  11. resultados/graficos/14_intervalos_confianza.png\n\n")

cat("===============================================================================\n")
cat("VERIFICACIÓN DE HETEROCEDASTICIDAD COMPLETADA\n")
cat(sprintf("Fecha y hora: %s\n", Sys.time()))
cat("===============================================================================\n\n")

cat("PRÓXIMO PASO:\n")
cat("  Usar los resultados con errores robustos para interpretación final\n\n")
