#!/bin/bash

SRC="./paralelo_2.c"
RESULTS_DIR="./resultados_paralelos"
BIN="./md8k_pal2"

echo "Compilando programa..."
gcc -O3 -fopenmp $SRC -o $BIN

if [ $? -ne 0 ]; then
    echo "Error en compilacion"
    exit 1
fi
mkdir -p $RESULTS_DIR


echo "===== EJECUCIONES EN TEEN ====="

for t in 1 2 4 8 16 32 64 128
do
    echo "Configuracion: $t threads"
    {
        echo "Programa: paralelo2"
        echo "Maquina: teen"
        echo "Threads: $t"
        echo "Run: $i"
        echo "----------------------"

        export OMP_NUM_THREADS=$t
        srun -c 1 -n 1 -p teen time $BIN
    } &> $RESULTS_DIR/teen_${t}
done


echo "Ejecuciones completadas"