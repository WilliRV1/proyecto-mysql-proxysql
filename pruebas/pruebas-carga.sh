#!/bin/bash
echo "--- 🧪 PRUEBA DE CARGA (SYSBENCH) ---"

# --- 0. Instalación de Sysbench ---
# Verificamos si sysbench está instalado
if ! command -v sysbench &> /dev/null
then
    echo "--- Instalando sysbench... ---"
    sudo apt-get update
    sudo apt-get install -y sysbench
else
    echo "--- Sysbench ya está instalado. ---"
fi

# --- Variables de Conexión ---
# Apuntamos a ProxySQL
DB="mydb"
USER="root"
PASS="root"
HOST="127.0.0.1"
PORT="6033"

# --- Parámetros de la Prueba ---
TABLES=10
TABLE_SIZE=100000
THREADS=8
TIME=60

echo "--- 1. Preparando tablas (en Master)... ---"
sysbench oltp_read_write \
    --tables=$TABLES \
    --table-size=$TABLE_SIZE \
    --mysql-db=$DB \
    --mysql-user=$USER \
    --mysql-password=$PASS \
    --mysql-host=$HOST \
    --mysql-port=$PORT \
    prepare

echo "--- 2. Ejecutando prueba de carga ($TIME seg, $THREADS hilos)... ---"
sysbench oltp_read_write \
    --tables=$TABLES \
    --table-size=$TABLE_SIZE \
    --time=$TIME \
    --threads=$THREADS \
    --report-interval=10 \
    --mysql-db=$DB \
    --mysql-user=$USER \
    --mysql-password=$PASS \
    --mysql-host=$HOST \
    --mysql-port=$PORT \
    run

echo "--- 3. Limpiando tablas (en Master)... ---"
sysbench oltp_read_write \
    --tables=$TABLES \
    --mysql-db=$DB \
    --mysql-user=$USER \
    --mysql-password=$PASS \
    --mysql-host=$HOST \
    --mysql-port=$PORT \
    cleanup

echo "--- ✅ Prueba de carga completada ---"