#!/bin/bash
read -p "¿Tenés sed? (sí/no): " RESPUESTA

if [ "$RESPUESTA" == "sí" ]; then
  echo "Andá por un cafecito ☕"
else
  echo "Seguimos con DevOps 🚀"
fi