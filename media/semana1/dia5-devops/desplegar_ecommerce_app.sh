#!/bin/bash

project_folder="ecommerce"

function log_message() {
    local message="$1"
    local type="$2"
    local log_file="/var/log/deploy_ecommerce_app.log"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [ "$type" = "" ]; then
        type="INFO"
    fi

    echo "${timestamp} - [${type}] - ${message}" | tee -a "$log_file"
}

function install_dependencies() {
    echo "Instalando dependencias..."
    sudo apt update
    sudo apt install -yq git curl build-essential nginx

    # Download and install nvm:
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    # in lieu of restarting the shell
    \. "$HOME/.nvm/nvm.sh"
    # Download and install Node.js:
    nvm install --lts
    # Verify the Node.js version:
    node -v # Should print "v22.16.0".
    nvm current # Should print "v22.16.0".
    # Verify npm version:
    npm -v # Should print "10.9.2".

    log_message "Dependencias instaladas." "INFO"
}

function clone_repository() {
    echo "Clonando el repositorio..."
    if [ ! -d "${project_folder}" ]; then
        git clone -b ecommerce-ms https://github.com/roxsross/devops-static-web.git "${project_folder}"
        log_message "Repositorio clonado." "INFO"
    else
        log_message "El repositorio ya existe." "WARN"
    fi
}

function install_npm_dependencies() {
    echo "Instalando dependencias de npm..."

    for dir in frontend merchandise products shopping-cart; do
        if [ -d "${dir}" ]; then
            cd "${dir}" || continue
            if [ -f "package.json" ]; then
                echo "Instalando dependencias en ${dir}..."
                npm install # --legacy-peer-deps
                log_message "Dependencias de npm instaladas en ${dir}." "INFO"
                cd .. || exit
            else
                log_message "No se encontró package.json en ${dir}." "WARN"
            fi
        fi
    done

    cd .. || exit
    
    log_message "Todas las dependencias de npm instaladas." "INFO"
}

function config_pm2() {
    echo "Configurando PM2..."
    npm install -g pm2
    
    # cd "${project_folder}" || exit
    pm2 init simple
    tee ecosystem.config.js <<EOF
module.exports = {
  apps : [
    {
      name   : "frontend",
      script : "./frontend/server.js",
      watch  : true,
      env_production: {
       NODE_ENV: "production"
      },
      env_development: {
        NODE_ENV: "development"
      }
    },
    {
      name   : "merchandise",
      script : "./merchandise/server.js",
      watch  : true,
      env_production: {
        NODE_ENV: "production"
      },
      env_development: {
        NODE_ENV: "development"
      }
    },
    {
      name   : "products",
      script : "./products/server.js",
      watch  : true,
      env_production: {
        NODE_ENV: "production"
      },
      env_development: {
        NODE_ENV: "development"
      }
    },
    {
      name   : "shopping-cart",
      script : "./shopping-cart/server.js",
      watch  : true,
      env_production: {
        NODE_ENV: "production"
      },
      env_development: {
        NODE_ENV: "development"
      }
    }
  ]
}
EOF
    sudo env PATH=$PATH:/home/omnius/.nvm/versions/node/v22.16.0/bin /home/omnius/.nvm/versions/node/v22.16.0/lib/node_modules/pm2/bin/pm2 startup systemd -u omnius --hp /home/omnius
    pm2 link 2obs1wpmv3dlipq odm8s5y4vydgphl
    pm2 start ecosystem.config.js --env development
    pm2 save
    pm2 startup
    if [ $? -ne 0 ]; then
        log_message "Fallo al configurar PM2. $?" "ERROR"
        exit 1
    fi

    log_message "PM2 configurado." "INFO"
}

function configure_nginx() {
    echo "Configurando Nginx..."
    sudo tee /etc/nginx/sites-available/ecommerce <<EOF
upstream frontend_server {
  # for UNIX domain socket setups
  # server unix:/tmp/gunicorn.sock fail_timeout=0;

  # for a TCP configuration
  server localhost:3004 fail_timeout=0;
}
upstream products_server {
  # for a TCP configuration
  server localhost:3001 fail_timeout=0;
}
upstream shopping_cart_server {
  # for a TCP configuration
  server localhost:3002 fail_timeout=0;
}
upstream merchandise_server {
  # for a TCP configuration
  server localhost:3003 fail_timeout=0;
}

server {
  # use 'listen 80 deferred;' for Linux
  # use 'listen 80 accept_filter=httpready;' for FreeBSD
  listen 4004; # because of I have many apps running on different ports 
  client_max_body_size 4G;

  # set the correct host(s) for your site
  server_name localhost ecommerce.local; 

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
    proxy_pass http://frontend_server;
  }

  error_page 500 502 503 504 /500.html;
  location = /500.html {
    root /;
  }

  access_log /var/log/nginx/ecommerce_access.log;
  error_log /var/log/nginx/ecommerce_error.log;
}

server {
  listen 4001;
  server_name localhost products.local;

  location / {
    proxy_pass http://products_server;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}

server {
  listen 4002;
  server_name localhost shopping-cart.local;

  location / {
    proxy_pass http://shopping_cart_server;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}

server {
  listen 4003;
  server_name localhost merchandise.local;

  location / {
    proxy_pass http://merchandise_server;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF

    sudo ln -s /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
    if [ $? -ne 0 ]; then
        log_message "Enlace simbólico de Nginx ya existe, reemplazando." "WARN"
        sudo rm /etc/nginx/sites-enabled/ecommerce
        sudo ln -s /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
        if [ $? -ne 0 ]; then
            log_message "Fallo al crear el enlace simbólico de Nginx. $?" "ERROR"
            exit 1
        fi
        log_message "Enlace simbólico de Nginx reemplazado." "INFO"
    fi

    sudo systemctl restart nginx
    if [ $? -ne 0 ]; then
        log_message "Fallo al reiniciar Nginx. $?" "ERROR"
        exit 1
    fi

    log_message "Nginx configurado." "INFO"
}

function main() {
    log_message "Iniciando despliegue de la aplicación eCommerce." "INFO"
    
    install_dependencies
    clone_repository

    cd "${project_folder}" || exit

    install_npm_dependencies
    config_pm2
    configure_nginx

    log_message "Despliegue de la aplicación eCommerce completado." "INFO"
}

main "$@"
