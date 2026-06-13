#!/bin/bash

SRC="./paralelo_mD8K.c"
RESULTS_DIR="./resultados_3"
BIN="./md8k_pal3"

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
        export OMP_PLACES=cores
        export OMP_PROC_BIND=spread

        srun -p teen \
            --nodes=1 \
            --ntasks=1 \
            --cpus-per-task=$t \
            time $BIN
    } &> $RESULTS_DIR/teen_${t}
done


echo "Ejecuciones completadas"