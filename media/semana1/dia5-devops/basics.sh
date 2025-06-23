#!/bin/bash

# Comentario
echo "Hola Mundo"

# Variables
NOMBRE="Edd"
echo "Hola $NOMBRE"

# Condicionales
if [ "$NOMBRE" == "Edd" ]; then
    echo "¡Heeeeyyy!"
else
    echo "¿Hu?"
fi

# Bucle
for i in {1..3}; do
    echo "Iteración $i"
done
