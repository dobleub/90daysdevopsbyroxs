#!/bin/bash

# Variables
username="admin"  # Default username
filename=$3 # 3rd argument passed to the script

# Input
read -p "Enter your username (default: $username): " input_username
echo "Username: ${input_username:-$username}"

# If conditional
if [ -z "$input_username" ]; then
  echo "No username provided, using default: $username"
else
  username=$input_username
  echo "Username set to: $username"
fi

if [ -z "$filename" ]; then
  echo "No filename provided, exiting."
  exit 1
else
  echo "Filename provided: $filename"
fi

if [ "$EUID" -ne 0 ]; then
  echo "You are not root."
else
  echo "You are root."
fi

# For loop
for i in {1..5}; do
  echo "Iteration $i"
done

# While loop
count=1
while [ $count -le 5 ]; do
  echo "Count is $count"
  ((count++))
done

# Case statement
case $1 in
  start)
    echo "Starting the service..."
    ;;
  stop)
    echo "Stopping the service..."
    ;;
  restart)
    echo "Restarting the service..."
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac

# Function definition
function greet() {
  local name=$1
  echo "Hello, $name!"
}
# Function call
greet "$username"

# Arguments
echo "Script name: $0"
echo "Total number of arguments: $#"
echo "All arguments: $@"

# Output redirection
cat 404file.txt 2> /dev/null
echo "Error messages redirected to /dev/null: $?"
echo "This is a test message." > output.txt

# Indexed array
declare -a fruits=("apple" "banana" "cherry")
echo "Fruits array: ${fruits[@]}"
echo "First fruit: ${fruits[0]}"

# Associative array
declare -A colors
colors=( ["red"]="#FF0000" ["green"]="#00FF00" ["blue"]="#0000FF" )
colors["yellow"]="#FFFF00"
echo "Colors array: ${colors[@]}"
echo "Red color code: ${colors[red]}"

# String manipulation
string="Hello, World!"
echo "Original string: $string"
echo "Uppercase: ${string^^}"
echo "Lowercase: ${string,,}"
echo "Substring (1-5): ${string:0:5}"
echo "Length of string: ${#string}"

# Arithmetic operations
num1=10
num2=5
sum=$((num1 + num2))
diff=$((num1 - num2))
prod=$((num1 * num2))
quot=$((num1 / num2))
mod=$((num1 % num2))
echo "Sum: $sum"
echo "Difference: $diff"
echo "Product: $prod"
echo "Quotient: $quot"
echo "Modulus: $mod"

# Parameter expansion
echo "Parameter expansion example: ${username:-default_user}"
SRC="/path/to/source.txt"
FILENAME="${SRC##*/}"
echo "Filename of source path: $FILENAME"
BASE="${SRC%/*}"
echo "Directory name of source path: $BASE"

# Command substitution
current_date=$(date)
echo "Current date: $current_date"

# System signals
trap 'echo "Script interrupted"; exit' INT TERM

: '
#  End of script
'
