#!/bin/bash

function check_service_status {
    SERVICE_NAME=$1
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "El servicio $SERVICE_NAME está activo."
    else
        echo "El servicio $SERVICE_NAME no está activo."
    fi
}
function main {
    # check_service_status "$1" # Uncomment this line to check a specific service passed as an argument
    local services=("nginx" "mysql" "ssh" "docker")
    for service in "${services[@]}"; do
        echo "Comprobando el estado del servicio: $service"
        check_service_status "$service"
    done
}
main "$@"