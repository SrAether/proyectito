#!/usr/bin/env bash
set -e

echo "=========================================="
echo "   Proyecto IMDB Movies 2000-2020"
echo "   Versión 3.0 con Docker"
echo "=========================================="
echo ""

# Cambiar al directorio del proyecto
cd /home/proyecto

# Verificar existencia de archivos críticos
echo "✓ Verificando archivos del proyecto..."
if [ ! -f "IMDB Movies 2000 - 2020.csv" ]; then
    echo "⚠️  Advertencia: Dataset original no encontrado"
    echo "   Buscando dataset en data/..."
    if [ -f "data/IMDB Movies 2000 - 2020.csv" ]; then
        echo "✓ Dataset encontrado en data/"
    else
        echo "❌ Error: No se encuentra el dataset IMDB"
        exit 1
    fi
fi

# Ejecutar scripts de análisis si no existen los resultados
if [ ! -f "data/datos_limpios.csv" ]; then
    echo ""
    echo "=========================================="
    echo "   Ejecutando Pipeline de Análisis"
    echo "=========================================="
    echo ""
    
    echo "📊 Paso 1/6: Limpieza de datos..."
    Rscript scripts/01_limpieza_datos.R
    
    echo "📊 Paso 2/6: Análisis exploratorio..."
    Rscript scripts/02_analisis_exploratorio.R
    
    echo "📊 Paso 3/6: Modelo de regresión..."
    Rscript scripts/03_modelo_regresion.R
    
    echo "📊 Paso 4/6: Verificación de multicolinealidad..."
    Rscript scripts/04a_multicolinealidad.R
    
    echo "📊 Paso 5/6: Verificación de forma funcional..."
    Rscript scripts/04c_forma_funcional.R
    
    echo "📊 Paso 6/6: Corrección de heterocedasticidad..."
    Rscript scripts/04d_heterocedasticidad.R
    
    echo ""
    echo "✅ Pipeline de análisis completado!"
    echo ""
else
    echo "✓ Datos limpios ya existen. Omitiendo pipeline de análisis."
    echo "  Para re-ejecutar el análisis, elimine: data/datos_limpios.csv"
    echo ""
fi

# Mostrar información del sistema
echo "=========================================="
echo "   Información del Sistema"
echo "=========================================="
echo "R version: $(R --version | head -n1)"
echo "Directorio: $(pwd)"
echo "Archivos disponibles:"
ls -lh data/ 2>/dev/null | head -n 5 || echo "  (directorio data no accesible)"
echo ""

# Iniciar Shiny Server
echo "=========================================="
echo "   Iniciando Shiny Server"
echo "=========================================="
echo ""
echo "✅ La aplicación estará disponible en:"
echo "   http://localhost:3838/app"
echo ""
echo "📊 Paneles disponibles:"
echo "   - Inicio"
echo "   - Datos"
echo "   - Limpieza de Datos"
echo "   - Análisis Exploratorio"
echo "   - Modelo"
echo "   - Supuestos (con corrección de heterocedasticidad)"
echo "   - Predicciones"
echo "   - Conclusiones"
echo ""
echo "Para detener el contenedor:"
echo "   docker stop imdb-movies-app"
echo ""
echo "=========================================="

# Mantener el contenedor corriendo y mostrar logs
exec shiny-server 2>&1
