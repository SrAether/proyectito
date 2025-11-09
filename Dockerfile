# Dockerfile para Proyecto de Análisis IMDB Movies
# Basado en imagen oficial de R con Shiny Server

FROM rocker/shiny:4.3.2

# Metadata
LABEL maintainer="Proyecto IMDB Movies"
LABEL description="Análisis de Ingresos Internacionales de Películas IMDB 2000-2020"
LABEL version="3.0"

# Configurar variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV R_REPOS=https://cloud.r-project.org

# Actualizar sistema e instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgit2-dev \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /home/proyecto

# Copiar archivos de dependencias primero (para aprovechar cache de Docker)
COPY .gitignore .gitignore

# Instalar paquetes de R necesarios
RUN R -e "install.packages(c( \
    'tidyverse', \
    'data.table', \
    'lubridate', \
    'stringr', \
    'car', \
    'lmtest', \
    'sandwich', \
    'AER', \
    'MASS', \
    'ggplot2', \
    'corrplot', \
    'gridExtra', \
    'plotly', \
    'shiny', \
    'shinydashboard', \
    'DT', \
    'shinyWidgets', \
    'stargazer', \
    'knitr', \
    'kableExtra', \
    'ggcorrplot', \
    'moments' \
    ), repos='https://cloud.r-project.org')"

# Copiar todos los archivos del proyecto
COPY . /home/proyecto/

# Crear directorios necesarios si no existen
RUN mkdir -p data resultados/graficos resultados/tablas resultados/modelo

# Dar permisos de lectura/escritura
RUN chmod -R 755 /home/proyecto

# Configurar Shiny Server
RUN rm -rf /srv/shiny-server/*
RUN ln -s /home/proyecto/shiny_app /srv/shiny-server/app

# Exponer puerto 3838 (Shiny Server) y 8080 (alternativo)
EXPOSE 3838 8080

# Script de inicio
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Comando por defecto
CMD ["/usr/local/bin/docker-entrypoint.sh"]
