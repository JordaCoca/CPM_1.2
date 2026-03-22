#!/bin/bash

SRC="./version3.c"
RESULTS_DIR="./3_resultados_md8k"
BIN="./md8k_pal2"

echo "Compilando programa..."
cc -O3 -fopenmp $SRC -o $BIN

if [ $? -ne 0 ]; then
    echo "Error en compilacion"
    exit 1
fi
mkdir -p $RESULTS_DIR

echo "===== EJECUCIONES EN ORCA ====="

for t in 1 2 4 8 16 32 64 128
do
    echo "Configuracion: $t threads"
    {
        echo "Programa: paralelo1"
        echo "Maquina: orca"
        echo "Threads: $t"
        echo "Run: $i"
        echo "----------------------"

        srun -p orca -c $t time $BIN
    } &> $RESULTS_DIR/orca_${t}
done

echo "Ejecuciones completadas"