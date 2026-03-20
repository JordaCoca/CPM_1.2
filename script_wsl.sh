#!/bin/bash

SRC=md8k_paralelo1.c
BIN=program
OUTDIR=resultados_wsl

THREADS=(1 2 4 8 16 32 64 128)

echo "Compilando $SRC..."
cc -O3 -fopenmp $SRC -o $BIN

if [ $? -ne 0 ]; then
    echo "Error de compilación"
    exit 1
fi

# Crear carpeta de resultados
mkdir -p $OUTDIR

echo "Iniciando ejecuciones..."

for t in "${THREADS[@]}"
do
    echo "Ejecutando con $t threads..."

    export OMP_NUM_THREADS=$t
    export OMP_PROC_BIND=true
    export OMP_PLACES=cores

    time ./$BIN &> "$OUTDIR/output_${t}_threads.txt"
done

echo "Todas las ejecuciones completadas."