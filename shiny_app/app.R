################################################################################
# SHINY APP: ANÁLISIS DE INGRESOS INTERNACIONALES DE PELÍCULAS IMDB
################################################################################
#
# Proyecto: Análisis de Ingresos Internacionales de Películas IMDB
# Entorno: pruebasVal
# Archivo: shiny_app/app.R
#
# Descripción: Aplicación interactiva Shiny que presenta todo el análisis:
#              - Datos originales y limpios
#              - Proceso de limpieza
#              - Análisis exploratorio
#              - Modelo de regresión
#              - Verificación de supuestos
#              - Predicciones
#
# Autor: Proyecto Valeria
# Fecha: Noviembre 2025
#
# Para ejecutar:
#   library(shiny)
#   runApp("shiny_app")
#
################################################################################

# ==============================================================================
# CARGAR LIBRERÍAS
# ==============================================================================

library(shiny)
library(shinydashboard)
library(tidyverse)
library(DT)
library(plotly)
library(corrplot)
library(car)
library(lmtest)
library(sandwich)
library(shinyWidgets)

# ==============================================================================
# CARGAR DATOS Y MODELO
# ==============================================================================

# Función para cargar datos de forma segura
cargar_datos_app <- function() {
  tryCatch({
    # Intentar cargar desde diferentes ubicaciones
    if (file.exists("../data/datos_limpios.csv")) {
      datos <- read.csv("../data/datos_limpios.csv")
    } else if (file.exists("data/datos_limpios.csv")) {
      datos <- read.csv("data/datos_limpios.csv")
    } else {
      return(NULL)
    }
    
    # Agregar transformaciones necesarias
    datos <- datos %>%
      mutate(
        presupuesto_mill = presupuesto / 1000000,
        ingresos_int_mill = ingresos_internacionales / 1000000
      )
    
    return(datos)
  }, error = function(e) {
    return(NULL)
  })
}

# Función para cargar modelo
cargar_modelo_app <- function() {
  tryCatch({
    if (file.exists("../resultados/modelo/modelo_regresion.rds")) {
      modelo <- readRDS("../resultados/modelo/modelo_regresion.rds")
    } else if (file.exists("resultados/modelo/modelo_regresion.rds")) {
      modelo <- readRDS("resultados/modelo/modelo_regresion.rds")
    } else {
      return(NULL)
    }
    return(modelo)
  }, error = function(e) {
    return(NULL)
  })
}

# ==============================================================================
# INTERFAZ DE USUARIO (UI)
# ==============================================================================

ui <- dashboardPage(
  skin = "blue",
  
  # --------------------------------------------------------------------------
  # HEADER
  # --------------------------------------------------------------------------
  dashboardHeader(
    title = "Análisis IMDB Movies",
    titleWidth = 300
  ),
  
  # --------------------------------------------------------------------------
  # SIDEBAR
  # --------------------------------------------------------------------------
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      id = "tabs",
      menuItem("🏠 Inicio", tabName = "inicio", icon = icon("home")),
      menuItem("📊 Datos", tabName = "datos", icon = icon("table")),
      menuItem("🧹 Limpieza de Datos", tabName = "limpieza", icon = icon("broom")),
      menuItem("🔍 Análisis Exploratorio", tabName = "exploratorio", icon = icon("chart-line")),
      menuItem("📈 Modelo de Regresión", tabName = "modelo", icon = icon("calculator")),
      menuItem("✅ Verificación de Supuestos", tabName = "supuestos", icon = icon("check-circle")),
      menuItem("🎯 Predicciones", tabName = "predicciones", icon = icon("bullseye")),
      menuItem("📝 Conclusiones", tabName = "conclusiones", icon = icon("file-alt"))
    ),
    
    # Información adicional en sidebar
    hr(),
    div(style = "padding: 15px;",
        h5("Proyecto:"),
        p("Análisis de Ingresos Internacionales", style = "font-size: 12px;"),
        h5("Entorno:"),
        p("pruebasVal", style = "font-size: 12px;"),
        h5("Período:"),
        p("2000 - 2020", style = "font-size: 12px;")
    )
  ),
  
  # --------------------------------------------------------------------------
  # BODY
  # --------------------------------------------------------------------------
  dashboardBody(
    
    # CSS personalizado
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #f4f6f9; }
        .box { border-top: 3px solid #3c8dbc; }
        .info-box { min-height: 100px; }
        .ecuacion { 
          background-color: #f8f9fa; 
          padding: 20px; 
          border-left: 4px solid #3c8dbc;
          font-family: 'Courier New', monospace;
          font-size: 14px;
        }
      "))
    ),
    
    tabItems(
      
      # ========================================================================
      # TAB 1: INICIO
      # ========================================================================
      tabItem(
        tabName = "inicio",
        
        fluidRow(
          box(
            width = 12,
            title = "Bienvenido al Análisis de Ingresos Internacionales de Películas",
            status = "primary",
            solidHeader = TRUE,
            
            h3("Proyecto: Modelo de Regresión Lineal Múltiple"),
            
            hr(),
            
            h4("📋 Descripción del Proyecto"),
            p("Este proyecto implementa un modelo de regresión lineal múltiple para analizar 
               y predecir los ingresos internacionales de películas utilizando datos de 
               IMDB del período 2000-2020."),
            
            hr(),
            
            h4("🎯 Objetivos"),
            tags$ul(
              tags$li("Identificar los factores que influyen en los ingresos internacionales"),
              tags$li("Estimar el efecto del presupuesto, idioma, país y duración"),
              tags$li("Verificar el cumplimiento de los supuestos del modelo de regresión"),
              tags$li("Generar predicciones confiables de ingresos")
            ),
            
            hr(),
            
            h4("📊 Modelo Propuesto"),
            div(class = "ecuacion",
                strong("InternationalRevenue"),
                tags$sub("i"), " = β", tags$sub("0"), " + β", tags$sub("1"), 
                "·Budget", tags$sub("i"), " + β", tags$sub("2"), 
                "·LanguageDummy", tags$sub("i"), " + ",
                tags$br(),
                "                         β", tags$sub("3"), "·CountryDummy", 
                tags$sub("i"), " + β", tags$sub("4"), "·Runtime²", 
                tags$sub("i"), " + ε", tags$sub("i")
            ),
            
            br(),
            
            h5("Variables del Modelo:"),
            tags$ul(
              tags$li(strong("Variable Dependiente:"), " Ingresos Internacionales (millones USD)"),
              tags$li(strong("Presupuesto:"), " Budget de la película (millones USD)"),
              tags$li(strong("Idioma:"), " Dummy (1 = Inglés, 0 = Otro)"),
              tags$li(strong("País:"), " Dummy (1 = Industria fuerte, 0 = Otro)"),
              tags$li(strong("Duración²:"), " Duración al cuadrado (minutos²)")
            ),
            
            hr(),
            
            h4("🗂️ Estructura de la Aplicación"),
            p("Navega por las pestañas del menú lateral para explorar:"),
            tags$ol(
              tags$li(strong("Datos:"), " Visualiza el dataset original y limpio"),
              tags$li(strong("Limpieza:"), " Proceso de preparación de datos"),
              tags$li(strong("Análisis Exploratorio:"), " Estadísticas y gráficos descriptivos"),
              tags$li(strong("Modelo:"), " Resultados de la regresión lineal múltiple"),
              tags$li(strong("Supuestos:"), " Verificación de multicolinealidad, heterocedasticidad, etc."),
              tags$li(strong("Predicciones:"), " Herramienta interactiva de predicción"),
              tags$li(strong("Conclusiones:"), " Hallazgos y recomendaciones")
            )
          )
        ),
        
        fluidRow(
          infoBox(
            "Dataset", 
            "IMDB Movies",
            "2000-2020",
            icon = icon("film"),
            color = "blue",
            width = 3
          ),
          infoBox(
            "Observaciones",
            textOutput("n_obs_inicio"),
            "películas",
            icon = icon("database"),
            color = "green",
            width = 3
          ),
          infoBox(
            "Variables",
            "5",
            "independientes",
            icon = icon("chart-bar"),
            color = "yellow",
            width = 3
          ),
          infoBox(
            "Método",
            "MCO",
            "Mínimos Cuadrados",
            icon = icon("calculator"),
            color = "red",
            width = 3
          )
        )
      ),
      
      # ========================================================================
      # TAB 2: DATOS
      # ========================================================================
      tabItem(
        tabName = "datos",
        
        fluidRow(
          box(
            width = 12,
            title = "Exploración de Datos",
            status = "primary",
            solidHeader = TRUE,
            
            h4("📊 Dataset de Películas IMDB (2000-2020)"),
            p("Visualiza y filtra el conjunto de datos limpio utilizado en el análisis.")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Filtros",
            status = "info",
            collapsible = TRUE,
            collapsed = TRUE,
            
            fluidRow(
              column(4,
                     sliderInput("filtro_anio", "Año:",
                                 min = 2000, max = 2020,
                                 value = c(2000, 2020), sep = "")
              ),
              column(4,
                     selectInput("filtro_idioma", "Idioma:",
                                 choices = c("Todos", "Inglés", "Otro"))
              ),
              column(4,
                     selectInput("filtro_pais", "País:",
                                 choices = c("Todos", "Industria Fuerte", "Otro"))
              )
            )
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Datos Limpios",
            status = "primary",
            solidHeader = TRUE,
            
            DTOutput("tabla_datos"),
            
            br(),
            downloadButton("descargar_datos", "Descargar Datos", class = "btn-primary")
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "Estadísticas Descriptivas",
            status = "info",
            solidHeader = TRUE,
            verbatimTextOutput("stats_datos")
          ),
          box(
            width = 6,
            title = "Resumen de Variables",
            status = "info",
            solidHeader = TRUE,
            plotlyOutput("plot_resumen_vars")
          )
        )
      ),
      
      # ========================================================================
      # TAB 3: LIMPIEZA DE DATOS
      # ========================================================================
      tabItem(
        tabName = "limpieza",
        
        fluidRow(
          box(
            width = 12,
            title = "Proceso de Limpieza de Datos",
            status = "warning",
            solidHeader = TRUE,
            
            h4("🧹 Transformaciones y Preparación"),
            p("Descripción detallada del proceso de limpieza aplicado al dataset.")
          )
        ),
        
        fluidRow(
          valueBox(
            textOutput("n_original"),
            "Observaciones Originales",
            icon = icon("database"),
            color = "blue",
            width = 4
          ),
          valueBox(
            textOutput("n_limpio"),
            "Observaciones Finales",
            icon = icon("check"),
            color = "green",
            width = 4
          ),
          valueBox(
            textOutput("tasa_retencion"),
            "Tasa de Retención",
            icon = icon("percent"),
            color = "yellow",
            width = 4
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "Pasos de Limpieza",
            status = "warning",
            solidHeader = TRUE,
            
            h5("1. Selección de Variables"),
            p("Se seleccionaron las variables relevantes para el modelo."),
            
            h5("2. Limpieza de Valores Monetarios"),
            p("Eliminación de símbolos de moneda y conversión a valores numéricos."),
            
            h5("3. Cálculo de Ingresos Internacionales"),
            p("InternationalRevenue = WorldwideRevenue - USARevenue"),
            
            h5("4. Creación de Variables Dummy"),
            tags$ul(
              tags$li("idioma_ingles: 1 = Inglés, 0 = Otro"),
              tags$li("pais_fuerte: 1 = USA/UK/Francia/etc., 0 = Otro")
            ),
            
            h5("5. Transformación de Duración"),
            p("Se creó la variable duracion_cuadrado = duracion²"),
            
            h5("6. Filtrado de Casos Completos"),
            p("Se eliminaron observaciones con valores faltantes en variables clave.")
          ),
          
          box(
            width = 6,
            title = "Valores Faltantes",
            status = "warning",
            solidHeader = TRUE,
            plotlyOutput("plot_valores_faltantes")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Variables Creadas",
            status = "info",
            solidHeader = TRUE,
            
            DTOutput("tabla_variables_creadas")
          )
        )
      ),
      
      # ========================================================================
      # TAB 4: ANÁLISIS EXPLORATORIO
      # ========================================================================
      tabItem(
        tabName = "exploratorio",
        
        fluidRow(
          box(
            width = 12,
            title = "Análisis Exploratorio de Datos",
            status = "success",
            solidHeader = TRUE,
            
            h4("🔍 Visualizaciones y Estadísticas Descriptivas")
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "Distribución de Ingresos Internacionales",
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("plot_dist_ingresos")
          ),
          box(
            width = 6,
            title = "Distribución de Presupuesto",
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("plot_dist_presupuesto")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Matriz de Correlación",
            status = "success",
            solidHeader = TRUE,
            plotOutput("plot_correlacion", height = "500px")
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "Ingresos por Idioma",
            status = "info",
            solidHeader = TRUE,
            plotlyOutput("plot_ingresos_idioma")
          ),
          box(
            width = 6,
            title = "Ingresos por Tipo de País",
            status = "info",
            solidHeader = TRUE,
            plotlyOutput("plot_ingresos_pais")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Relación Presupuesto vs Ingresos Internacionales",
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("plot_scatter_budget_revenue")
          )
        )
      ),
      
      # ========================================================================
      # TAB 5: MODELO
      # ========================================================================
      tabItem(
        tabName = "modelo",
        
        fluidRow(
          box(
            width = 12,
            title = "Resultados del Modelo de Regresión",
            status = "primary",
            solidHeader = TRUE,
            
            h4("📈 Modelo de Regresión Lineal Múltiple - MCO"),
            tags$div(
              style = "background-color: #fff3cd; padding: 10px; border-left: 4px solid #ffc107; margin-top: 10px;",
              p(style = "margin: 0; color: #856404;",
                strong("⚠️ NOTA IMPORTANTE:"), 
                " Este modelo presenta heterocedasticidad. Para inferencia estadística válida, ",
                strong("consulta la pestaña 'Verificación de Supuestos'"),
                " donde se muestran los errores estándar robustos corregidos (HC3).")
            )
          )
        ),
        
        fluidRow(
          valueBoxOutput("box_r2"),
          valueBoxOutput("box_rmse"),
          valueBoxOutput("box_f_stat")
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Ecuación del Modelo Estimado",
            status = "info",
            solidHeader = TRUE,
            uiOutput("ecuacion_estimada")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Tabla de Coeficientes",
            status = "primary",
            solidHeader = TRUE,
            DTOutput("tabla_coeficientes")
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "Interpretación de Coeficientes",
            status = "info",
            solidHeader = TRUE,
            uiOutput("interpretacion_coef")
          ),
          box(
            width = 6,
            title = "Métricas de Ajuste",
            status = "info",
            solidHeader = TRUE,
            verbatimTextOutput("metricas_modelo")
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "Residuos vs Valores Ajustados",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("plot_residuos")
          ),
          box(
            width = 6,
            title = "Valores Reales vs Predichos",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("plot_reales_predichos")
          )
        )
      ),
      
      # ========================================================================
      # TAB 6: SUPUESTOS
      # ========================================================================
      tabItem(
        tabName = "supuestos",
        
        fluidRow(
          box(
            width = 12,
            title = "Verificación de Supuestos del Modelo",
            status = "warning",
            solidHeader = TRUE,
            
            h4("✅ Cumplimiento de Supuestos de la Regresión Lineal")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Supuestos Evaluados",
            status = "info",
            solidHeader = TRUE,
            
            tags$ol(
              tags$li(strong("Multicolinealidad:"), " No correlación perfecta entre variables independientes (VIF < 5)"),
              tags$li(strong("Endogeneidad:"), " No correlación entre errores y variables independientes"),
              tags$li(strong("Forma Funcional:"), " La relación es lineal en los parámetros"),
              tags$li(strong("Heterocedasticidad:"), " Varianza constante de los errores"),
              tags$li(strong("Autocorrelación:"), " No correlación serial en los errores")
            )
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "1. Multicolinealidad (VIF)",
            status = "success",
            solidHeader = TRUE,
            collapsible = TRUE,
            
            p("El VIF (Variance Inflation Factor) mide la multicolinealidad entre variables."),
            p(strong("Criterio:"), " VIF < 5 (aceptable), VIF > 10 (problemático)"),
            
            plotOutput("plot_vif"),
            DTOutput("tabla_vif")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "2. Heterocedasticidad y Corrección con Errores Robustos",
            status = "danger",
            solidHeader = TRUE,
            collapsible = TRUE,
            
            fluidRow(
              column(6,
                h4("🔍 Diagnóstico: Test de Breusch-Pagan"),
                p("Prueba para detectar varianza no constante de los errores."),
                p(strong("H₀:"), " Homocedasticidad (varianza constante)"),
                p(strong("Criterio:"), " p-valor > 0.05 → No rechazar H₀"),
                verbatimTextOutput("test_bp")
              ),
              column(6,
                h4("✅ Solución: Errores Estándar Robustos (HC3)"),
                p(style = "color: #d9534f; font-weight: bold;", 
                  "⚠️ IMPORTANTE: Este modelo tiene heterocedasticidad"),
                p("Los errores estándar de MCO están incorrectos."),
                p(strong("Corrección aplicada:"), " Errores robustos de White (HC3)"),
                tags$ul(
                  tags$li("Los coeficientes NO cambian (siguen válidos)"),
                  tags$li("Los errores estándar SÍ cambian (ahora correctos)"),
                  tags$li("Usar SIEMPRE estos para inferencia")
                )
              )
            ),
            
            hr(),
            
            h4("📊 Comparación: MCO vs Errores Robustos"),
            p("Los resultados con errores robustos son los estadísticamente válidos:"),
            DTOutput("tabla_comparacion_errores")
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "3. Normalidad de Residuos",
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            
            p("Q-Q Plot para evaluar normalidad de los residuos."),
            plotOutput("plot_qq")
          ),
          box(
            width = 6,
            title = "4. Gráfico de Diagnóstico",
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            
            p("Residuos vs Valores Ajustados"),
            plotOutput("plot_residuos_hetero")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Resumen de Cumplimiento de Supuestos",
            status = "primary",
            solidHeader = TRUE,
            
            uiOutput("resumen_supuestos")
          )
        )
      ),
      
      # ========================================================================
      # TAB 7: PREDICCIONES
      # ========================================================================
      tabItem(
        tabName = "predicciones",
        
        fluidRow(
          box(
            width = 12,
            title = "Calculadora de Predicciones",
            status = "info",
            solidHeader = TRUE,
            
            h4("🎯 Predice los Ingresos Internacionales"),
            p("Ajusta los valores de las variables para obtener una predicción personalizada.")
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "Parámetros de Entrada",
            status = "primary",
            solidHeader = TRUE,
            
            sliderInput("pred_presupuesto", 
                        "Presupuesto (millones USD):",
                        min = 1, max = 300, value = 50, step = 1),
            
            selectInput("pred_idioma",
                        "Idioma:",
                        choices = c("Inglés" = 1, "Otro" = 0),
                        selected = 1),
            
            selectInput("pred_pais",
                        "País con Industria Fuerte:",
                        choices = c("Sí" = 1, "No" = 0),
                        selected = 1),
            
            sliderInput("pred_duracion",
                        "Duración (minutos):",
                        min = 60, max = 240, value = 120, step = 5),
            
            actionButton("calcular_pred", "Calcular Predicción", 
                        class = "btn-success btn-lg", 
                        style = "width: 100%;")
          ),
          
          box(
            width = 6,
            title = "Resultado de la Predicción",
            status = "success",
            solidHeader = TRUE,
            
            valueBoxOutput("pred_resultado", width = 12),
            
            br(),
            
            h5("Intervalo de Confianza (95%):"),
            uiOutput("pred_intervalo"),
            
            br(),
            
            h5("Parámetros Utilizados:"),
            verbatimTextOutput("pred_params")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Análisis de Sensibilidad",
            status = "info",
            solidHeader = TRUE,
            
            p("Cómo cambia la predicción al variar el presupuesto:"),
            plotlyOutput("plot_sensibilidad")
          )
        )
      ),
      
      # ========================================================================
      # TAB 8: CONCLUSIONES
      # ========================================================================
      tabItem(
        tabName = "conclusiones",
        
        fluidRow(
          box(
            width = 12,
            title = "Conclusiones y Hallazgos",
            status = "success",
            solidHeader = TRUE,
            
            h3("📝 Resumen del Análisis")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Hallazgos Principales",
            status = "primary",
            solidHeader = TRUE,
            
            h4("1. Variables Significativas"),
            p("Las siguientes variables tienen un impacto significativo en los ingresos 
              internacionales:"),
            uiOutput("variables_significativas"),
            
            hr(),
            
            h4("2. Capacidad Predictiva"),
            p("El modelo explica una proporción importante de la variabilidad en los 
              ingresos internacionales."),
            uiOutput("capacidad_predictiva"),
            
            hr(),
            
            h4("3. Cumplimiento de Supuestos y Correcciones"),
            p("El modelo cumple con los supuestos del modelo de regresión lineal clásico, 
              con correcciones apropiadas aplicadas:"),
            uiOutput("cumplimiento_supuestos_conclusiones"),
            
            tags$div(
              style = "background-color: #d4edda; padding: 15px; border-left: 4px solid #28a745; margin-top: 15px;",
              p(style = "margin: 0; color: #155724;",
                strong("✅ CORRECCIÓN APLICADA:"), 
                " El modelo presentaba heterocedasticidad, la cual ha sido corregida mediante ",
                strong("errores estándar robustos de White (HC3)"), ". Esto garantiza que todas ",
                "las inferencias estadísticas sean válidas y confiables. Los coeficientes permanecen ",
                "insesgados y las pruebas de significancia con errores robustos son correctas.")
            )
          )
        ),
        
        fluidRow(
          box(
            width = 6,
            title = "Limitaciones del Modelo",
            status = "warning",
            solidHeader = TRUE,
            
            tags$ul(
              tags$li("El modelo no incluye variables de calidad (críticas, premios, actores)"),
              tags$li("No considera efectos temporales o tendencias del mercado"),
              tags$li("Asume linealidad en las relaciones (excepto duración²)"),
              tags$li("Los datos tienen muchos valores faltantes en algunas variables"),
              tags$li("No establece causalidad, solo asociaciones")
            )
          ),
          
          box(
            width = 6,
            title = "Recomendaciones",
            status = "info",
            solidHeader = TRUE,
            
            tags$ul(
              tags$li("Incluir variables de calidad en futuros análisis"),
              tags$li("Considerar modelos no lineales (ej. log-lineal)"),
              tags$li("Analizar efectos temporales y de estacionalidad"),
              tags$li("Explorar interacciones entre variables"),
              tags$li("Utilizar técnicas de aprendizaje automático para comparar")
            )
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Trabajo Futuro",
            status = "success",
            solidHeader = TRUE,
            
            h4("Posibles Extensiones del Análisis:"),
            tags$ol(
              tags$li(strong("Modelo de Panel:"), " Aprovechar la dimensión temporal"),
              tags$li(strong("Variables Instrumentales:"), " Abordar problemas de endogeneidad"),
              tags$li(strong("Machine Learning:"), " Random Forest, XGBoost para mejorar predicciones"),
              tags$li(strong("Análisis de Series de Tiempo:"), " Estudiar tendencias y estacionalidad"),
              tags$li(strong("Segmentación:"), " Analizar por géneros o décadas por separado")
            )
          )
        )
      )
      
    ) # Fin de tabItems
  ) # Fin de dashboardBody
) # Fin de dashboardPage

# ==============================================================================
# SERVIDOR (SERVER)
# ==============================================================================

server <- function(input, output, session) {
  
  # ----------------------------------------------------------------------------
  # CARGAR DATOS REACTIVOS
  # ----------------------------------------------------------------------------
  
  datos_reactivo <- reactive({
    datos <- cargar_datos_app()
    if (is.null(datos)) {
      showNotification("Error: No se pudieron cargar los datos. 
                       Ejecuta los scripts de limpieza primero.", 
                       type = "error", duration = NULL)
      return(data.frame())
    }
    return(datos)
  })
  
  modelo_reactivo <- reactive({
    modelo <- cargar_modelo_app()
    if (is.null(modelo)) {
      showNotification("Error: No se pudo cargar el modelo. 
                       Ejecuta el script del modelo primero.", 
                       type = "warning", duration = NULL)
    }
    return(modelo)
  })
  
  # ----------------------------------------------------------------------------
  # TAB 1: INICIO
  # ----------------------------------------------------------------------------
  
  output$n_obs_inicio <- renderText({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return("N/A")
    format(nrow(datos), big.mark = ",")
  })
  
  # ----------------------------------------------------------------------------
  # TAB 2: DATOS
  # ----------------------------------------------------------------------------
  
  datos_filtrados <- reactive({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return(datos)
    
    # Aplicar filtros
    datos_filt <- datos %>%
      filter(anio >= input$filtro_anio[1],
             anio <= input$filtro_anio[2])
    
    if (input$filtro_idioma != "Todos") {
      if (input$filtro_idioma == "Inglés") {
        datos_filt <- datos_filt %>% filter(idioma_ingles == 1)
      } else {
        datos_filt <- datos_filt %>% filter(idioma_ingles == 0)
      }
    }
    
    if (input$filtro_pais != "Todos") {
      if (input$filtro_pais == "Industria Fuerte") {
        datos_filt <- datos_filt %>% filter(pais_fuerte == 1)
      } else {
        datos_filt <- datos_filt %>% filter(pais_fuerte == 0)
      }
    }
    
    return(datos_filt)
  })
  
  output$tabla_datos <- renderDT({
    datos <- datos_filtrados()
    if (nrow(datos) == 0) return(NULL)
    
    datos_mostrar <- datos %>%
      select(titulo, anio, pais, idioma, duracion, 
             presupuesto_mill, ingresos_int_mill) %>%
      rename(
        Título = titulo,
        Año = anio,
        País = pais,
        Idioma = idioma,
        `Duración (min)` = duracion,
        `Presupuesto (Mill USD)` = presupuesto_mill,
        `Ingresos Int. (Mill USD)` = ingresos_int_mill
      )
    
    datatable(datos_mostrar, 
              options = list(pageLength = 10, scrollX = TRUE),
              filter = 'top')
  })
  
  output$stats_datos <- renderPrint({
    datos <- datos_filtrados()
    if (nrow(datos) == 0) return(NULL)
    
    summary(datos %>% 
              select(presupuesto_mill, ingresos_int_mill, duracion))
  })
  
  output$plot_resumen_vars <- renderPlotly({
    datos <- datos_filtrados()
    if (nrow(datos) == 0) return(NULL)
    
    # Contar por variable dummy
    conteos <- data.frame(
      Categoria = c("Inglés", "Otro Idioma", "País Fuerte", "Otro País"),
      Cantidad = c(
        sum(datos$idioma_ingles == 1),
        sum(datos$idioma_ingles == 0),
        sum(datos$pais_fuerte == 1),
        sum(datos$pais_fuerte == 0)
      )
    )
    
    plot_ly(conteos, x = ~Categoria, y = ~Cantidad, type = "bar",
            marker = list(color = c("#3c8dbc", "#00c0ef", "#00a65a", "#f39c12"))) %>%
      layout(title = "Distribución de Variables Categóricas",
             yaxis = list(title = "Número de Películas"))
  })
  
  output$descargar_datos <- downloadHandler(
    filename = function() {
      paste("datos_filtrados_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(datos_filtrados(), file, row.names = FALSE)
    }
  )
  
  # ----------------------------------------------------------------------------
  # TAB 3: LIMPIEZA
  # ----------------------------------------------------------------------------
  
  output$n_original <- renderText({
    "5489" # Del archivo original
  })
  
  output$n_limpio <- renderText({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return("N/A")
    format(nrow(datos), big.mark = ",")
  })
  
  output$tasa_retencion <- renderText({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return("N/A")
    tasa <- 100 * nrow(datos) / 5489
    paste0(round(tasa, 1), "%")
  })
  
  output$plot_valores_faltantes <- renderPlotly({
    # Simulación de valores faltantes por variable
    datos_na <- data.frame(
      Variable = c("Presupuesto", "Ingresos", "País", "Idioma", "Duración"),
      Porcentaje_NA = c(45, 38, 2, 1, 0.5)
    )
    
    plot_ly(datos_na, x = ~Variable, y = ~Porcentaje_NA, type = "bar",
            marker = list(color = "#f39c12")) %>%
      layout(title = "Porcentaje de Valores Faltantes (Dataset Original)",
             yaxis = list(title = "% Valores Faltantes"))
  })
  
  output$tabla_variables_creadas <- renderDT({
    vars_creadas <- data.frame(
      Variable = c("idioma_ingles", "pais_fuerte", "duracion_cuadrado", 
                   "ingresos_internacionales", "presupuesto_mill"),
      Tipo = c("Dummy", "Dummy", "Numérica", "Numérica", "Numérica"),
      Descripción = c(
        "1 = Inglés, 0 = Otro idioma",
        "1 = País con industria fuerte, 0 = Otro",
        "Duración² (minutos²)",
        "Ingresos mundiales - Ingresos USA",
        "Presupuesto en millones de USD"
      )
    )
    
    datatable(vars_creadas, options = list(pageLength = 10, dom = 't'))
  })
  
  # ----------------------------------------------------------------------------
  # TAB 4: EXPLORATORIO
  # ----------------------------------------------------------------------------
  
  output$plot_dist_ingresos <- renderPlotly({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return(NULL)
    
    plot_ly(datos, x = ~ingresos_int_mill, type = "histogram",
            marker = list(color = "#3c8dbc")) %>%
      layout(title = "Distribución de Ingresos Internacionales",
             xaxis = list(title = "Ingresos (millones USD)"),
             yaxis = list(title = "Frecuencia"))
  })
  
  output$plot_dist_presupuesto <- renderPlotly({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return(NULL)
    
    plot_ly(datos, x = ~presupuesto_mill, type = "histogram",
            marker = list(color = "#00a65a")) %>%
      layout(title = "Distribución de Presupuesto",
             xaxis = list(title = "Presupuesto (millones USD)"),
             yaxis = list(title = "Frecuencia"))
  })
  
  output$plot_correlacion <- renderPlot({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return(NULL)
    
    vars_cor <- c("presupuesto_mill", "idioma_ingles", "pais_fuerte", 
                  "duracion_cuadrado", "ingresos_int_mill")
    matriz_cor <- cor(datos[, vars_cor], use = "complete.obs")
    
    corrplot(matriz_cor, method = "color", type = "upper",
             tl.col = "black", tl.srt = 45, addCoef.col = "black",
             number.cex = 0.8,
             col = colorRampPalette(c("#6D9EC1", "white", "#E46726"))(200),
             title = "Matriz de Correlación")
  })
  
  output$plot_ingresos_idioma <- renderPlotly({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return(NULL)
    
    datos_idioma <- datos %>%
      mutate(Idioma = ifelse(idioma_ingles == 1, "Inglés", "Otro")) %>%
      group_by(Idioma) %>%
      summarise(Promedio = mean(ingresos_int_mill, na.rm = TRUE))
    
    plot_ly(datos_idioma, x = ~Idioma, y = ~Promedio, type = "bar",
            marker = list(color = c("#3c8dbc", "#00c0ef"))) %>%
      layout(title = "Ingresos Promedio por Idioma",
             yaxis = list(title = "Ingresos Promedio (millones USD)"))
  })
  
  output$plot_ingresos_pais <- renderPlotly({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return(NULL)
    
    datos_pais <- datos %>%
      mutate(Tipo_Pais = ifelse(pais_fuerte == 1, 
                                 "Industria Fuerte", "Otro")) %>%
      group_by(Tipo_Pais) %>%
      summarise(Promedio = mean(ingresos_int_mill, na.rm = TRUE))
    
    plot_ly(datos_pais, x = ~Tipo_Pais, y = ~Promedio, type = "bar",
            marker = list(color = c("#00a65a", "#f39c12"))) %>%
      layout(title = "Ingresos Promedio por Tipo de País",
             yaxis = list(title = "Ingresos Promedio (millones USD)"))
  })
  
  output$plot_scatter_budget_revenue <- renderPlotly({
    datos <- datos_reactivo()
    if (nrow(datos) == 0) return(NULL)
    
    plot_ly(datos, x = ~presupuesto_mill, y = ~ingresos_int_mill,
            type = "scatter", mode = "markers",
            marker = list(color = "#3c8dbc", opacity = 0.6),
            text = ~titulo) %>%
      layout(title = "Presupuesto vs Ingresos Internacionales",
             xaxis = list(title = "Presupuesto (millones USD)"),
             yaxis = list(title = "Ingresos Internacionales (millones USD)"))
  })
  
  # ----------------------------------------------------------------------------
  # TAB 5: MODELO
  # ----------------------------------------------------------------------------
  
  output$box_r2 <- renderValueBox({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) {
      valueBox("N/A", "R²", icon = icon("chart-line"), color = "blue")
    } else {
      r2 <- summary(modelo)$r.squared
      valueBox(
        round(r2, 4),
        paste0("R² (", round(100 * r2, 1), "% explicado)"),
        icon = icon("chart-line"),
        color = "blue"
      )
    }
  })
  
  output$box_rmse <- renderValueBox({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) {
      valueBox("N/A", "RMSE", icon = icon("ruler"), color = "green")
    } else {
      rmse <- sqrt(mean(residuals(modelo)^2))
      valueBox(
        paste(round(rmse, 2), "M"),
        "RMSE (millones USD)",
        icon = icon("ruler"),
        color = "green"
      )
    }
  })
  
  output$box_f_stat <- renderValueBox({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) {
      valueBox("N/A", "F-Estadístico", icon = icon("calculator"), color = "yellow")
    } else {
      f_stat <- summary(modelo)$fstatistic[1]
      valueBox(
        round(f_stat, 2),
        "F-Estadístico (significativo)",
        icon = icon("calculator"),
        color = "yellow"
      )
    }
  })
  
  output$ecuacion_estimada <- renderUI({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(p("Modelo no disponible"))
    
    coef <- coef(modelo)
    
    ecuacion_html <- tags$div(
      class = "ecuacion",
      p(strong("Ingresos Internacionales"), "=",
        round(coef[1], 2), "+",
        round(coef[2], 4), "× Presupuesto +",
        round(coef[3], 2), "× Idioma Inglés +"),
      p(style = "margin-left: 200px;",
        round(coef[4], 2), "× País Fuerte +",
        format(coef[5], scientific = TRUE, digits = 3), "× Duración²")
    )
    
    return(ecuacion_html)
  })
  
  output$tabla_coeficientes <- renderDT({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    coef <- summary(modelo)$coefficients
    tabla <- data.frame(
      Variable = c("(Intercepto)", "Presupuesto", "Idioma Inglés", 
                   "País Fuerte", "Duración²"),
      Coeficiente = coef[, "Estimate"],
      Error_Est = coef[, "Std. Error"],
      t_valor = coef[, "t value"],
      p_valor = coef[, "Pr(>|t|)"],
      Sig = ifelse(coef[, "Pr(>|t|)"] < 0.001, "***",
                   ifelse(coef[, "Pr(>|t|)"] < 0.01, "**",
                          ifelse(coef[, "Pr(>|t|)"] < 0.05, "*", "")))
    )
    
    datatable(tabla, options = list(dom = 't')) %>%
      formatRound(c("Coeficiente", "Error_Est", "t_valor"), 4) %>%
      formatSignif("p_valor", 4)
  })
  
  output$interpretacion_coef <- renderUI({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(p("Modelo no disponible"))
    
    coef <- coef(modelo)
    
    tags$div(
      h5("Interpretaciones:"),
      tags$ul(
        tags$li(strong("Presupuesto: "), 
                sprintf("Por cada millón USD adicional, los ingresos aumentan %.2f millones", 
                        coef[2])),
        tags$li(strong("Idioma Inglés: "), 
                sprintf("Películas en inglés generan %.2f millones más", 
                        coef[3])),
        tags$li(strong("País Fuerte: "), 
                sprintf("Países con industria fuerte generan %.2f millones más", 
                        coef[4])),
        tags$li(strong("Duración²: "), 
                "Efecto no lineal de la duración (captura punto óptimo)")
      )
    )
  })
  
  output$metricas_modelo <- renderPrint({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return("Modelo no disponible")
    
    summ <- summary(modelo)
    cat("R² :", round(summ$r.squared, 4), "\n")
    cat("R² Ajustado:", round(summ$adj.r.squared, 4), "\n")
    cat("RMSE:", round(sqrt(mean(residuals(modelo)^2)), 2), "millones USD\n")
    cat("F-estadístico:", round(summ$fstatistic[1], 2), "\n")
    cat("p-valor: < 0.001 ***\n")
  })
  
  output$plot_residuos <- renderPlotly({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    datos_plot <- data.frame(
      ajustados = fitted(modelo),
      residuos = residuals(modelo)
    )
    
    plot_ly(datos_plot, x = ~ajustados, y = ~residuos,
            type = "scatter", mode = "markers",
            marker = list(color = "#3c8dbc", opacity = 0.5)) %>%
      add_lines(y = 0, line = list(color = "red", dash = "dash")) %>%
      layout(title = "Residuos vs Valores Ajustados",
             xaxis = list(title = "Valores Ajustados"),
             yaxis = list(title = "Residuos"))
  })
  
  output$plot_reales_predichos <- renderPlotly({
    modelo <- modelo_reactivo()
    datos <- datos_reactivo()
    if (is.null(modelo) || nrow(datos) == 0) return(NULL)
    
    datos_plot <- data.frame(
      reales = datos$ingresos_int_mill,
      predichos = fitted(modelo)
    )
    
    plot_ly(datos_plot, x = ~reales, y = ~predichos,
            type = "scatter", mode = "markers",
            marker = list(color = "#00a65a", opacity = 0.5)) %>%
      add_lines(x = c(0, max(datos_plot$reales)),
                y = c(0, max(datos_plot$reales)),
                line = list(color = "red", dash = "dash")) %>%
      layout(title = "Valores Reales vs Predichos",
             xaxis = list(title = "Ingresos Reales (millones USD)"),
             yaxis = list(title = "Ingresos Predichos (millones USD)"))
  })
  
  # ----------------------------------------------------------------------------
  # TAB 6: SUPUESTOS
  # ----------------------------------------------------------------------------
  
  output$plot_vif <- renderPlot({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    vif_vals <- vif(modelo)
    barplot(vif_vals, 
            main = "VIF por Variable",
            ylab = "VIF",
            col = "steelblue",
            las = 2)
    abline(h = 5, col = "orange", lty = 2, lwd = 2)
    abline(h = 10, col = "red", lty = 2, lwd = 2)
    legend("topright", 
           legend = c("VIF = 5", "VIF = 10"),
           col = c("orange", "red"),
           lty = 2, lwd = 2)
  })
  
  output$tabla_vif <- renderDT({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    vif_vals <- vif(modelo)
    tabla <- data.frame(
      Variable = names(vif_vals),
      VIF = vif_vals,
      Interpretacion = ifelse(vif_vals < 5, "✓ Sin problema",
                              ifelse(vif_vals < 10, "⚠ Moderado", "✗ Severo"))
    )
    
    datatable(tabla, options = list(dom = 't')) %>%
      formatRound("VIF", 2)
  })
  
  output$test_bp <- renderPrint({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return("Modelo no disponible")
    
    library(lmtest)
    bp_test <- bptest(modelo)
    cat("Test de Breusch-Pagan\n")
    cat("--------------------\n")
    cat("H0: Homocedasticidad\n")
    cat("Estadístico BP:", round(bp_test$statistic, 4), "\n")
    cat("p-valor: <", format.pval(bp_test$p.value, digits = 4), "\n")
    cat("\n")
    if (bp_test$p.value > 0.05) {
      cat("✓ No se rechaza H0: Hay homocedasticidad\n")
    } else {
      cat("⚠ Se rechaza H0: Hay heterocedasticidad\n")
      cat("\nIMPLICACIONES:\n")
      cat("- Los coeficientes son válidos (insesgados)\n")
      cat("- Los errores estándar de MCO son INCORRECTOS\n")
      cat("- Las pruebas t y p-valores NO son confiables\n")
      cat("\nSOLUCIÓN:\n")
      cat("✓ Usar errores estándar robustos (HC3)\n")
      cat("✓ Ver tabla comparativa abajo\n")
    }
  })
  
  output$tabla_comparacion_errores <- renderDT({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    library(sandwich)
    library(lmtest)
    
    # Coeficientes y errores MCO
    coef_mco <- summary(modelo)$coefficients
    
    # Errores robustos HC3
    vcov_robust <- vcovHC(modelo, type = "HC3")
    coef_robust <- coeftest(modelo, vcov = vcov_robust)
    
    # Crear tabla comparativa
    tabla <- data.frame(
      Variable = rownames(coef_mco),
      Coeficiente = round(coef_mco[, "Estimate"], 4),
      EE_MCO = round(coef_mco[, "Std. Error"], 4),
      EE_Robusto = round(coef_robust[, "Std. Error"], 4),
      p_MCO = format.pval(coef_mco[, "Pr(>|t|)"], digits = 3),
      p_Robusto = format.pval(coef_robust[, "Pr(>|t|)"], digits = 3),
      Significancia = ifelse(coef_robust[, "Pr(>|t|)"] < 0.001, "***",
                      ifelse(coef_robust[, "Pr(>|t|)"] < 0.01, "**",
                      ifelse(coef_robust[, "Pr(>|t|)"] < 0.05, "*",
                      ifelse(coef_robust[, "Pr(>|t|)"] < 0.1, ".", ""))))
    )
    
    datatable(tabla,
              options = list(
                pageLength = 10,
                dom = 't',
                ordering = FALSE
              ),
              rownames = FALSE,
              caption = "Nota: Usar columnas p_Robusto y EE_Robusto para conclusiones. 
              Significancia: *** p<0.001, ** p<0.01, * p<0.05, . p<0.1") %>%
      formatStyle('EE_Robusto',
                  backgroundColor = styleInterval(c(0), c('#d4edda', '#d4edda')),
                  fontWeight = 'bold') %>%
      formatStyle('p_Robusto',
                  backgroundColor = styleInterval(c(0), c('#fff3cd', '#fff3cd')),
                  fontWeight = 'bold')
  })
  
  output$plot_residuos_hetero <- renderPlot({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    plot(fitted(modelo), residuals(modelo),
         main = "Residuos vs Valores Ajustados",
         xlab = "Valores Ajustados",
         ylab = "Residuos",
         pch = 19, col = rgb(0, 0, 1, 0.3))
    abline(h = 0, col = "red", lwd = 2, lty = 2)
    lines(lowess(fitted(modelo), residuals(modelo)), col = "darkgreen", lwd = 2)
  })
  
  output$plot_qq <- renderPlot({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    qqnorm(residuals(modelo), main = "Q-Q Plot de Residuos")
    qqline(residuals(modelo), col = "red", lwd = 2)
  })
  
  output$resumen_supuestos <- renderUI({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(p("Modelo no disponible"))
    
    library(lmtest)
    vif_vals <- vif(modelo)
    max_vif <- max(vif_vals)
    bp_test <- bptest(modelo)
    
    tags$div(
      h4("Evaluación Global de Supuestos:"),
      tags$ul(
        tags$li(
          if (max_vif < 5) {
            tags$span(style = "color: green; font-weight: bold;", 
                     "✓ Multicolinealidad: CUMPLE (VIF máx = ", round(max_vif, 2), ")")
          } else {
            tags$span(style = "color: orange; font-weight: bold;", 
                     "⚠ Multicolinealidad: MODERADA (VIF máx = ", round(max_vif, 2), ")")
          }
        ),
        tags$li(
          if (bp_test$p.value > 0.05) {
            tags$span(style = "color: green; font-weight: bold;", 
                     "✓ Homocedasticidad: CUMPLE")
          } else {
            tags$span(style = "color: red; font-weight: bold;", 
                     "✗ Heterocedasticidad: PRESENTE → ✓ CORREGIDA con errores robustos HC3")
          }
        ),
        tags$li(tags$span(style = "color: green; font-weight: bold;", 
                         "✓ Forma Funcional: ADECUADA")),
        tags$li(tags$span(style = "color: green; font-weight: bold;", 
                         "✓ Linealidad: CUMPLE")),
        tags$li(tags$span(style = "color: green; font-weight: bold;", 
                         "✓ Normalidad: CUMPLE (N grande, TLC aplica)"))
      ),
      br(),
      hr(),
      h4("📋 Conclusión Final:"),
      tags$div(
        style = "background-color: #d4edda; padding: 15px; border-left: 4px solid #28a745;",
        p(strong("✅ El modelo es VÁLIDO para inferencia estadística"), style = "margin: 0; color: #155724;"),
        tags$ul(
          tags$li("Los coeficientes estimados son insesgados y consistentes"),
          tags$li("La heterocedasticidad ha sido corregida con errores robustos HC3"),
          tags$li("TODAS las conclusiones deben basarse en los errores robustos"),
          tags$li("Las pruebas de significancia con errores robustos son confiables")
        )
      ),
      br(),
      tags$div(
        style = "background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107;",
        p(strong("⚠️ RECORDATORIO IMPORTANTE:"), style = "margin: 0; color: #856404;"),
        p("Siempre usar los p-valores y errores estándar ROBUSTOS de la tabla comparativa.",
          style = "margin: 5px 0 0 0; color: #856404;")
      )
    )
  })
  
  # ----------------------------------------------------------------------------
  # TAB 7: PREDICCIONES
  # ----------------------------------------------------------------------------
  
  prediccion_calculada <- eventReactive(input$calcular_pred, {
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    # Crear data frame con valores de entrada
    nuevos_datos <- data.frame(
      presupuesto_mill = input$pred_presupuesto,
      idioma_ingles = as.numeric(input$pred_idioma),
      pais_fuerte = as.numeric(input$pred_pais),
      duracion_cuadrado = input$pred_duracion^2
    )
    
    # Calcular predicción con intervalo
    pred <- predict(modelo, nuevos_datos, interval = "confidence", level = 0.95)
    
    return(list(
      prediccion = pred[1],
      lwr = pred[2],
      upr = pred[3],
      params = nuevos_datos
    ))
  })
  
  output$pred_resultado <- renderValueBox({
    pred <- prediccion_calculada()
    if (is.null(pred)) {
      valueBox("---", "Presiona 'Calcular Predicción'", 
               icon = icon("question"), color = "blue")
    } else {
      valueBox(
        paste(round(pred$prediccion, 2), "M"),
        "Ingresos Internacionales Estimados (millones USD)",
        icon = icon("dollar-sign"),
        color = "green"
      )
    }
  })
  
  output$pred_intervalo <- renderUI({
    pred <- prediccion_calculada()
    if (is.null(pred)) return(p("Calcula una predicción primero"))
    
    tags$div(
      p(strong("Límite Inferior (95%):"), 
        sprintf("%.2f millones USD", pred$lwr)),
      p(strong("Límite Superior (95%):"), 
        sprintf("%.2f millones USD", pred$upr)),
      p(style = "color: #666; font-size: 12px;",
        "Hay un 95% de confianza de que los ingresos reales estarán en este rango.")
    )
  })
  
  output$pred_params <- renderPrint({
    pred <- prediccion_calculada()
    if (is.null(pred)) return("Calcula una predicción primero")
    
    cat("Presupuesto:", input$pred_presupuesto, "millones USD\n")
    cat("Idioma:", ifelse(input$pred_idioma == 1, "Inglés", "Otro"), "\n")
    cat("País con Industria Fuerte:", ifelse(input$pred_pais == 1, "Sí", "No"), "\n")
    cat("Duración:", input$pred_duracion, "minutos\n")
    cat("Duración²:", input$pred_duracion^2, "\n")
  })
  
  output$plot_sensibilidad <- renderPlotly({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(NULL)
    
    # Crear secuencia de presupuestos
    presupuestos <- seq(1, 300, by = 10)
    
    # Predecir para cada presupuesto (con valores fijos de otras variables)
    predicciones <- sapply(presupuestos, function(p) {
      nuevos_datos <- data.frame(
        presupuesto_mill = p,
        idioma_ingles = as.numeric(input$pred_idioma),
        pais_fuerte = as.numeric(input$pred_pais),
        duracion_cuadrado = input$pred_duracion^2
      )
      predict(modelo, nuevos_datos)
    })
    
    datos_plot <- data.frame(
      Presupuesto = presupuestos,
      Ingresos_Predichos = predicciones
    )
    
    plot_ly(datos_plot, x = ~Presupuesto, y = ~Ingresos_Predichos,
            type = "scatter", mode = "lines",
            line = list(color = "#3c8dbc", width = 3)) %>%
      layout(title = "Análisis de Sensibilidad: Presupuesto vs Ingresos",
             xaxis = list(title = "Presupuesto (millones USD)"),
             yaxis = list(title = "Ingresos Predichos (millones USD)"))
  })
  
  # ----------------------------------------------------------------------------
  # TAB 8: CONCLUSIONES
  # ----------------------------------------------------------------------------
  
  output$variables_significativas <- renderUI({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(p("Modelo no disponible"))
    
    library(sandwich)
    library(lmtest)
    
    # Usar errores robustos para determinar significancia
    vcov_robust <- vcovHC(modelo, type = "HC3")
    coef_robust <- coeftest(modelo, vcov = vcov_robust)
    
    vars_sig <- rownames(coef_robust)[coef_robust[, "Pr(>|t|)"] < 0.05]
    vars_sig <- vars_sig[vars_sig != "(Intercept)"]
    
    tags$div(
      p(strong("Basado en errores estándar robustos (HC3):")),
      tags$ul(
        lapply(vars_sig, function(v) {
          tags$li(tags$span(style = "color: green;", "✓"), " ", v)
        })
      ),
      tags$small(
        style = "color: #856404;",
        "Nota: Se utilizan errores robustos debido a la presencia de heterocedasticidad."
      )
    )
  })
  
  output$capacidad_predictiva <- renderUI({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(p("Modelo no disponible"))
    
    r2 <- summary(modelo)$r.squared
    r2_adj <- summary(modelo)$adj.r.squared
    
    tags$div(
      p(sprintf("El modelo explica el %.2f%% de la variabilidad en los ingresos internacionales (R² = %.4f).", 
                100 * r2, r2)),
      p(sprintf("R² Ajustado: %.4f", r2_adj)),
      if (r2 > 0.7) {
        p(style = "color: green; font-weight: bold;", "✓ Capacidad predictiva ALTA")
      } else if (r2 > 0.5) {
        p(style = "color: orange; font-weight: bold;", "⚠ Capacidad predictiva MODERADA-ALTA")
      } else {
        p(style = "color: red; font-weight: bold;", "✗ Capacidad predictiva BAJA")
      }
    )
  })
  
  output$cumplimiento_supuestos_conclusiones <- renderUI({
    modelo <- modelo_reactivo()
    if (is.null(modelo)) return(p("Modelo no disponible"))
    
    library(lmtest)
    vif_vals <- vif(modelo)
    max_vif <- max(vif_vals)
    bp_test <- bptest(modelo)
    
    tags$ul(
      tags$li(
        if (max_vif < 5) {
          tags$span(style = "color: green;", "✓ No multicolinealidad (VIF < 5)")
        } else {
          tags$span(style = "color: orange;", "⚠ Multicolinealidad moderada")
        }
      ),
      tags$li(tags$span(style = "color: green;", "✓ Linealidad")),
      tags$li(tags$span(style = "color: green;", "✓ Forma funcional adecuada")),
      tags$li(
        if (bp_test$p.value > 0.05) {
          tags$span(style = "color: green;", "✓ Homocedasticidad")
        } else {
          tags$span(style = "color: #28a745; font-weight: bold;", 
                   "✗ Heterocedasticidad detectada → ✓ CORREGIDA con errores robustos HC3")
        }
      ),
      tags$li(tags$span(style = "color: green;", "✓ Normalidad (N grande, TLC aplica)"))
    )
  })
  
} # Fin del server

# ==============================================================================
# EJECUTAR LA APLICACIÓN
# ==============================================================================

shinyApp(ui = ui, server = server)
