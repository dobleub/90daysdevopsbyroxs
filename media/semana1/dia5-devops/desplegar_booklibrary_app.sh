#!/bin/bash

log_file="/var/log/deploy_booklibrary_app.log"

function install_dependencies() {
    echo "Instalando dependencias..."
    sudo apt update
    sudo apt install -yq python3 python3-pip python3-venv nginx git
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Dependencias instaladas." | tee -a "$log_file"
}

function clone_repository() {
    echo "Clonando el repositorio..."
    if [ ! -d "booklibrary" ]; then
        git clone -b booklibrary https://github.com/roxsross/devops-static-web.git booklibrary
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Repositorio clonado." | tee -a "$log_file"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [WARN] - El repositorio ya existe." | tee -a "$log_file"
    fi
}

function configure_venv() {
    echo "Configurando entorno virtual..."
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Entorno virtual creado y activado." | tee -a "$log_file"
    else
        source venv/bin/activate
        pip install --upgrade pip
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [WARN] - El entorno virtual ya existe." | tee -a "$log_file"
    fi
}

function install_requirements() {
    echo "Instalando dependencias..."
    pip install -r requirements.txt
    pip install gunicorn
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Dependencias instaladas." | tee -a "$log_file"
}

function configure_nginx() {
    echo "Configurando Nginx..."
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
    sudo tee /etc/nginx/sites-available/booklibrary <<EOF
upstream app_server {
  # for UNIX domain socket setups
  # server unix:/tmp/gunicorn.sock fail_timeout=0;

  # for a TCP configuration
  server localhost:8000 fail_timeout=0;
}

server {
  # use 'listen 80 deferred;' for Linux
  # use 'listen 80 accept_filter=httpready;' for FreeBSD
  listen 9000; # because of I have many apps running on different ports 
  client_max_body_size 4G;

  # set the correct host(s) for your site
  server_name localhost booklibrary.local; 

  keepalive_timeout 5;

  # path for static files
  root /static;

  location / {
    # checks for static file, if not found proxy to app
    try_files \$uri @proxy_to_app;
  }

  location @proxy_to_app {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_pass http://app_server;
  }

  error_page 500 502 503 504 /500.html;
  location = /500.html {
    root /;
  }

  access_log /var/log/nginx/booklibrary_access.log;
  error_log /var/log/nginx/booklibrary_error.log;
}
EOF
    sudo ln -s /etc/nginx/sites-available/booklibrary /etc/nginx/sites-enabled/
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [WARN] - Enlace simbólico de Nginx ya existe, reemplazando." | tee -a "$log_file"
        sudo rm /etc/nginx/sites-enabled/booklibrary
        sudo ln -s /etc/nginx/sites-available/booklibrary /etc/nginx/sites-enabled/
        if [ $? -ne 0 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - Fallo al crear el enlace simbólico de Nginx. $?" | tee -a "$log_file"
            exit 1
        fi
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Enlace simbólico de Nginx reemplazado." | tee -a "$log_file"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Enlace simbólico de Nginx creado." | tee -a "$log_file"
    fi
    sudo nginx -t
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - Fallo en la prueba de configuración de Nginx. $?" | tee -a "$log_file"
        exit 1
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Configuración de Nginx válida." | tee -a "$log_file"

    echo "Reiniciando Nginx..."
    sudo systemctl restart nginx
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - Fallo al reiniciar Nginx. $?" | tee -a "$log_file"
        exit 1
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Nginx configurado y reiniciado." | tee -a "$log_file"
}

function start_gunicorn() {
    cd booklibrary || { echo "No se pudo cambiar al directorio booklibrary." | tee -a "$log_file"; exit 1; }
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Cambiado al directorio booklibrary." | tee -a "$log_file"
    
    configure_venv
    install_requirements

    # check if gunicorn is already running
    if pgrep -f gunicorn > /dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [WARN] - Gunicorn ya está en ejecución." | tee -a "$log_file"
        echo "Deteniendo Gunicorn..."
        pkill -f gunicorn
        if [ $? -ne 0 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - Fallo al detener Gunicorn. $?" | tee -a "$log_file"
            exit 1
        fi
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Gunicorn detenido." | tee -a "$log_file"
    fi
    
    local isOK=0
    echo "Iniciando Gunicorn..."
    gunicorn -w 4 -b 127.0.0.1:8000 library_site:app --daemon 2>> "$log_file"
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - Fallo al iniciar Gunicorn. $?" | tee -a "$log_file"
        isOK=1
        exit 1
    fi
    sleep 5
    curl -s http://localhost:8000 > /dev/null
    if [ $? -ne 0 ]; then
        echo "Gunicorn no está respondiendo correctamente." | tee -a "$log_file"
        exit 1
    fi

    if [ $isOK -eq 0 ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Gunicorn iniciado." | tee -a "$log_file"
    fi
}

function verificar_servicios() {
  echo "Verificando servicios..."
  echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Verificando servicios." | tee -a "$log_file"
  
  # Verificar Nginx
  if systemctl is-active --quiet nginx; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - ✓ Nginx está activo." | tee -a "$log_file"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - ✗ Nginx no está activo." | tee -a "$log_file"
  fi
  
  # Verificar Gunicorn
  if pgrep -f "gunicorn.*library_site" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - ✓ Gunicorn está corriendo." | tee -a "$log_file"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - ✗ Gunicorn no está corriendo." | tee -a "$log_file"
  fi
  
  # Verificar puerto 8000
  if netstat -tlnp | grep -q ":8000"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - ✓ Puerto 8000 está en uso." | tee -a "$log_file"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - ✗ Puerto 8000 no está en uso." | tee -a "$log_file"
  fi
  
  # Probar conexión directa a Gunicorn
  if curl -s http://localhost:8000 > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - ✓ Gunicorn responde correctamente." | tee -a "$log_file"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - ✗ Gunicorn no responde." | tee -a "$log_file"
  fi

  # Probar conexión a través de Nginx
  if curl -s http://localhost:9000 > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - ✓ Nginx responde correctamente." | tee -a "$log_file"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] - ✗ Nginx no responde." | tee -a "$log_file"
  fi
}

function main() {
    echo "Desplegando BookLibrary App..."
    install_dependencies
    clone_repository
    start_gunicorn
    configure_nginx
    verificar_servicios
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] - Despliegue completado." | tee -a "$log_file"
}

main

echo "Revisar el log en $log_file para más detalles."
exit 0