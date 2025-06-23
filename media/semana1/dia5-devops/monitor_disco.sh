#!/bin/bash
ADMIN="omnius@pop-os.lan"
USO_RAIZ=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
TAMANO_HOME=$(du -sh /home | awk '{print $1}' | sed 's/G//g')

log_file="/var/log/monitor_disco.log"

# Verificar si el archivo de log existe, si no, crearlo
if [ ! -f "$log_file" ]; then
  touch "$log_file"
fi

function enviar_alerta() {
  local asunto="$1"
  local mensaje="$2"
  echo -e "$mensaje" | mail -s "$asunto" "$ADMIN"
}
function monitor_disco() {
  if [ "$USO_RAIZ" -gt 90 ]; then
    enviar_alerta "Alerta: Uso de disco en /" "El uso del disco en / ha superado el 90%: $USO_RAIZ%"
  fi

  if [ "$TAMANO_HOME" -gt 50 ]; then
    enviar_alerta "Alerta: Tamaño de /home" "El tamaño de /home ha superado los 50GB: $TAMANO_HOME GB"
  fi
}
function save_history() {
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "$timestamp - Uso de disco en /: $USO_RAIZ%, Tamaño de /home: $TAMANO_HOME GB" >> "$log_file"
}
function main() {
  monitor_disco
  save_history
}
main "$@"
