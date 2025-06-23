#!/bin/bash

source ./gestion_usuarios_funciones.sh

function main() {
    if [ "$#" -ne 3 ]; then
        echo "Uso: $0 <usuario> <contraseña> <grupo>"
        exit 1
    fi

    local usuario="$1"
    local password="$2"
    local grupo="$3"

    crear_usuario "$usuario" "$password" "$grupo"
}

main "$@"
