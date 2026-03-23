#!/bin/bash

SRC="./mD8K_comentado.c"
RESULTS_DIR="./3_resultados_md8k"
BIN="./md8k_pal2"

echo "Compilando programa..."
cc -O3 -fopenmp $SRC -o $BIN

if [ $? -ne 0 ]; then
    echo "Error en compilacion"
    exit 1
fi
mkdir -p $RESULTS_DIR

echo "===== EJECUCIONES EN ORCA SECUENCIAL ====="
srun -p orca -c 1 time $BIN &> $RESULTS_DIR/SECUENCIAL

echo "Ejecucion completa"