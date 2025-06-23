#!/bin/bash

function buscar_palabra() {
  local palabra="$1"
  local archivo="$2"

  if [ -z "$palabra" ] || [ -z "$archivo" ]; then
    echo "Uso: buscar_palabra <palabra> <archivo>"
    return 1
  fi

  if [ ! -f "$archivo" ]; then
    echo "El archivo $archivo no existe."
    return 1
  fi

  grep -i "$palabra" "$archivo"
}

function main() {
  if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <palabra> <archivo>"
    exit 1
  fi

  buscar_palabra "$1" "$2"
}

main "$@"