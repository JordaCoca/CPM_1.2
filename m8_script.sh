#!/bin/bash

SRC="./paralelo_mD8K.c"
RESULTS_DIR="./resultados_paralelos"
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

        export OMP_NUM_THREADS=$t
        srun -p orca time $BIN
    } &> $RESULTS_DIR/orca_${t}
done


echo "===== EJECUCIONES EN TEEN ====="

for t in 1 2 4 8 16 32 64 128
do
    echo "Configuracion: $t threads"
    {
        echo "Programa: paralelo1"
        echo "Maquina: teen"
        echo "Threads: $t"
        echo "Run: $i"
        echo "----------------------"

        export OMP_NUM_THREADS=$t
        srun -p teen time $BIN
    } &> $RESULTS_DIR/teen_${t}
done


echo "Ejecuciones completadas"