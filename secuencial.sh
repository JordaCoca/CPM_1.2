#!/bin/bash

SRC="./mD8K_comentado.c"
RESULTS_DIR="./resultados_secuenciales"
BIN="./md8k_pal2"

echo "Compilando programa..."
cc -O3 -fopenmp $SRC -o $BIN

if [ $? -ne 0 ]; then
    echo "Error en compilacion"
    exit 1
fi
mkdir -p $RESULTS_DIR

echo "===== EJECUCIONES EN ORCA SECUENCIAL ====="
srun -p orca -c 1 time $BIN &> $RESULTS_DIR/SECUENCIAL_ORCA
srun -p teen -c 1 time $BIN &> $RESULTS_DIR/SECUENCIAL_ORCA

echo "Ejecucion completa"