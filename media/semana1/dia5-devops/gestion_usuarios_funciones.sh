#!/bin/bash

log_file="/var/log/gestion_usuarios.log"

function crear_usuario() {
    local usuario=$1
    local password=$2
    local grupo=$3

    if [ -z $grupo ] || [ -z $usuario ] || [ -z $password ]; then
        echo "Error: Debes proporcionar un nombre de usuario, una contraseña y un grupo."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Faltan parámetros para crear el usuario." >> "$log_file"
        return 1
    fi

    if ! getent group "$grupo" &>/dev/null; then
        echo "El grupo '$grupo' no existe. Creando el grupo..."
        groupadd "$grupo"
        if [ $? -ne 0 ]; then
            echo "Error al crear el grupo '$grupo'."
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Error al crear el grupo '$grupo'." >> "$log_file"
            return 1
        fi
    fi

    if id "$usuario" &>/dev/null; then  # Comprobar si el usuario ya existe en silencio
        echo "El usuario '$usuario' ya existe."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - El usuario '$usuario' ya existe." >> "$log_file"
        return 1
    fi

    useradd -m -s /bin/bash -p "$(openssl passwd -6 "$password")" -G "$grupo" "$usuario"
    if [ $? -eq 0 ]; then
        echo "Usuario '$usuario' creado exitosamente."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Usuario '$usuario' creado exitosamente." >> "$log_file"
        return 0
    else
        echo "Error al crear el usuario '$usuario'."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error al crear el usuario '$usuario'." >> "$log_file"
        return 1
    fi
}