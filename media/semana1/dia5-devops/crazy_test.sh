#!/bin/bash

# Crazy test script

read -p "¿Cuál es tu nombre? " NOMBRE
read -p "¿Cuál es tu edad? " EDAD
read -p "¿Cuál es tu color favorito? " COLOR
read -p "¿Cuál es tu comida favorita? " COMIDA
read -p "¿Cuál es tu hobby favorito? " HOBBY

if [ -z "$NOMBRE" ] || [ -z "$EDAD" ] || [ -z "$COLOR" ] || [ -z "$COMIDA" ] || [ -z "$HOBBY" ]; then
  echo "Por favor, completa todos los campos."
  exit 1
fi

edadString=""
case $EDAD in
  # Edad menor a 0
  -[0-9]*)
    edadString="¿$EDAD años? ¿Cómo es eso posible? ¿Eres un viajero del tiempo?"
    ;;
  # Edad entre 0 y 1
  [0-1])
    edadString="Qué eres?, un bebé?"
    ;;
  [2-9])
    edadString="tienes $EDAD años?, casi no te creo pero ¡qué joven!"
    ;;
  # Edad entre 10 y 19
  1[0-9])
    edadString="tienes $EDAD años?, ve a jugar o a estudiar! No quieras hacer locuras con Bash."
    ;;
  # Edad entre 20 y 29
  2[0-9])
    edadString="tienes $EDAD años, ya estás en la adultez, ¡a trabajar!"
    ;;
  # Edad entre 30 y 39
  3[0-9])
    edadString="con $EDAD años, ya estás rozando la vejez, ¡pero aún puedes aprender Bash!"
    ;;
  # Edad entre 40 y 49
  [4-9][0-9])
    edadString="con $EDAD años, ya estas viejito, aprende Bash antes de que se te olvide todo!"
    ;;
  *)
    edadString="¿$EDAD años? ¿Estás seguro? ¿Eres un vampiro?"
    ;;
esac

colorString=""
case $COLOR in
  # Colores comunes
  rojo|red)
    colorString="El rojo es el color de la pasión, ¡como tu amor por Bash!"
    ;;
  azul|blue)
    colorString="El azul es el color del cielo, ¡y de los errores en Bash!"
    ;;
  verde|green)
    colorString="El verde es el color de la naturaleza, ¡y de los scripts bien hechos!"
    ;;
  amarillo|yellow)
    colorString="El amarillo es el color del sol, ¡y de los scripts que iluminan tu día!"
    ;;
  negro|black)
    colorString="Negro es el color del misterio, ¡como los secretos de Bash!"
    ;;
  *)
    colorString="¡$COLOR es un color interesante! ¿Por qué no lo usas en tus scripts?"
    ;;
esac

echo "Hola $NOMBRE, $edadString"
echo "$colorString"
