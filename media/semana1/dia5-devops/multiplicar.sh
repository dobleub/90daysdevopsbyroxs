#!/bin/bash

num1=$1
num2=$2
if [[ -z "$num1" || -z "$num2" ]]; then
  echo "Por favor, proporciona dos números como argumentos."
  exit 1
fi
if ! [[ "$num1" =~ ^-?[0-9]+$ ]] || ! [[ "$num2" =~ ^-?[0-9]+$ ]]; then
  echo "Los argumentos deben ser números enteros."
  exit 1
fi
result=$((num1 * num2))
echo "El resultado de multiplicar $num1 y $num2 es: $result"