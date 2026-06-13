RESULTS_DIR="./testeo"
mkdir -p $RESULTS_DIR

for t in 1 2 4
do 
    echo "=== ORCA $t ==="
    export OMP_NUM_THREADS=$t
    export OMP_PLACES=cores
    export OMP_PROC_BIND=spread
    export OMP_DYNAMIC=FALSE

    srun -p orca \
        --nodes=1 \
        --ntasks=1 \
        --cpus-per-task=$t \
        --hint=nomultithread \
        bash -c 'echo Cpus_allowed_list: $(grep Cpus_allowed_list /proc/self/status); tasket -pc $$; ./md8k_pal4'  &> $RESULTS_DIR/orca_${t}
done

for t in 1 2 4
do 
    echo "=== TEEN $t ==="
    export OMP_NUM_THREADS=$t
    export OMP_PLACES=cores
    export OMP_PROC_BIND=spread
    export OMP_DYNAMIC=FALSE

    srun -p orca \
        --nodes=1 \
        --ntasks=1 \
        --cpus-per-task=$t \
        --hint=nomultithread \
        bash -c 'echo Cpus_allowed_list: $(grep Cpus_allowed_list /proc/self/status); tasket -pc $$; ./md8k_pal4'  &> $RESULTS_DIR/teen_${t}
done
