#!/bin/bash
TIEMPO=$(date "+%Y-%m-%d %H:%M:%S")
echo -e "Hora\t\t\tMemoria\t\tDisco (root)\tCPU"
segundos="3600"
fin=$((SECONDS+segundos))
log_file="/var/log/alertas_cpu.log"

# Verificar si el archivo de log existe, si no, crearlo
if [ ! -f "$log_file" ]; then
    touch "$log_file"
fi

count=0
while [ $SECONDS -lt $fin ]; do
    if [ $count -ge 3 ]; then
        echo "Se han generado 3 alertas de CPU. Finalizando script..."
        echo "Finalizando script a las $TIEMPO" >> $log_file
        break
    fi

    MEMORIA=$(free -m | awk 'NR==2{printf "%.f%%\t\t", $3*100/$2 }')
    DISCO=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
    # HOME=$(du -sh /home | awk '{print $1}' | sed 's/G//g')
    CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | awk '{printf "%.f", $1}')

    echo -e "$TIEMPO\t$MEMORIA\t$DISCO%\t$CPU%"

    if [ "$CPU" -gt 85 ]; then
        echo "Alerta: Uso de CPU alto: $CPU%" >> $log_file
        count=$((count + 1))
    fi

    TIEMPO=$(date "+%Y-%m-%d %H:%M:%S")
    sleep 3
done