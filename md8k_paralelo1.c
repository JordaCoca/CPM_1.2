#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <strings.h>
#include <assert.h>
#include <omp.h>

#define N 8000L
#define ND N*N/100

typedef struct {
    int i,j,v;
} tmd;

int A[N][N],B[N][N],C[N][N],C1[N][N],C2[N][N];
int jBD[N+1];
tmd AD[ND],BD[ND],CD[N*N];

long long Suma;

int cmp_fil(const void *pa, const void *pb)
{
    tmd * a = (tmd*)pa;
    tmd * b = (tmd*)pb;

    if (a->i > b->i) return(1);
    else if (a->i < b->i) return (-1);
    else return (a->j - b->j);
}

int cmp_col(const void *pa, const void *pb)
{
    tmd * a = (tmd*)pa;
    tmd * b = (tmd*)pb;

    if (a->j > b->j) return(1);
    else if (a->j < b->j) return (-1);
    else return (a->i - b->i);
}

int main()
{
    int i,j,k,neleC;
    double t_b1=0, t_b2=0, t_b3=0, t_b4=0, t_b5=0, t_b6=0, t_b7=0, t_b8=0;

    bzero(C,sizeof(int)*(N*N));
    bzero(C1,sizeof(int)*(N*N));
    bzero(C2,sizeof(int)*(N*N));

    for(k=0;k<ND;k++)
    {
        AD[k].i=rand()%(N-1);
        AD[k].j=rand()%(N-1);
        AD[k].v=rand()%100+1;
        while (A[AD[k].i][AD[k].j]) {
            if(AD[k].i < AD[k].j)
                AD[k].i = (AD[k].i + 1)%N;
            else 
                AD[k].j = (AD[k].j + 1)%N;
        }
        A[AD[k].i][AD[k].j] = AD[k].v;
    }
    qsort(AD,ND,sizeof(tmd),cmp_fil);

    for(k=0;k<ND;k++)
    {
        BD[k].i=rand()%(N-1);
        BD[k].j=rand()%(N-1);
        BD[k].v=rand()%100+1;
        while (B[BD[k].i][BD[k].j]) {
            if(BD[k].i < BD[k].j)
                BD[k].i = (BD[k].i + 1)%N;
            else 
                BD[k].j = (BD[k].j + 1)%N;
        }
        B[BD[k].i][BD[k].j] = BD[k].v;
    }

    qsort(BD,ND,sizeof(tmd),cmp_col);

    /* ====== BUCLE 1 ====== */
    double t0 = omp_get_wtime();
    k=0;
    for (j=0; j<N+1; j++)
    {
        while (k < ND && j>BD[k].j) k++;
        jBD[j] = k;
    }
    t_b1 += omp_get_wtime() - t0;

    /* ====== BUCLE 2 ====== */
    t0 = omp_get_wtime();
    #pragma omp parallel for private(k)
    for(i=0;i<N;i++)
        for (k=0;k<ND;k++)
            C1[AD[k].i][i] += AD[k].v * B[AD[k].j][i];
    t_b2 += omp_get_wtime() - t0;

    /* ====== BUCLE 3 ====== */
    t0 = omp_get_wtime();
    // ya no necesario global
    t_b3 += omp_get_wtime() - t0;

    /* ====== BUCLE 4  este ====== */
    t0 = omp_get_wtime();
    #pragma omp parallel
    {
        int *VBcol = (int*)calloc(N, sizeof(int));  // privado por thread

        #pragma omp for
        for(i=0;i<N;i++)
        {
            for (k=jBD[i];k<jBD[i+1];k++)
                VBcol[BD[k].i] = BD[k].v;

            for (k=0;k<ND;k++)
                C2[AD[k].i][i] += AD[k].v * VBcol[AD[k].j];

            for (k=jBD[i];k<jBD[i+1];k++)  // limpiar SOLO lo usado
                VBcol[BD[k].i] = 0;
        }

        free(VBcol);
    }
    t_b4 += omp_get_wtime() - t0;

    /* ====== BUCLE 5 ====== */
    t0 = omp_get_wtime();
    neleC=0;
    t_b5 += omp_get_wtime() - t0;

    /* ====== BUCLE 6 est ====== */
    t0 = omp_get_wtime();
    #pragma omp parallel
    {
        int *VBcol = (int*)calloc(N, sizeof(int));
        int *VCcol = (int*)calloc(N, sizeof(int));

        int local_count;
        tmd *local_CD = (tmd*)malloc(sizeof(tmd)*N);

        #pragma omp for
        for(i=0;i<N;i++)
        {
            local_count = 0;

            for (k=jBD[i];k<jBD[i+1];k++)
                VBcol[BD[k].i] = BD[k].v;

            for (k=0;k<ND;k++)
                VCcol[AD[k].i] += AD[k].v * VBcol[AD[k].j];

            for (j=0;j<N;j++)
            {
                if (VCcol[j])
                {
                    local_CD[local_count].i = j;
                    local_CD[local_count].j = i;
                    local_CD[local_count].v = VCcol[j];
                    VCcol[j] = 0;
                    local_count++;
                }
            }

            for (k=jBD[i];k<jBD[i+1];k++)
                VBcol[BD[k].i] = 0;

            // merge sin critical grande
            int pos;
            #pragma omp atomic capture
            { pos = neleC; neleC += local_count; }

            for (k=0;k<local_count;k++)
                CD[pos+k] = local_CD[k];
        }

        free(VBcol);
        free(VCcol);
        free(local_CD);
    }
    t_b6 += omp_get_wtime() - t0;

    /* ====== BUCLE 7 ====== */
    t0 = omp_get_wtime();
    #pragma omp parallel for private(j)
    for (i=0;i<N;i++)
        for(j=0;j<N;j++)
            if (C2[i][j] != C1[i][j])
                printf("Diferencias C1 y C2 %d,%d\n",i,j);
    t_b7 += omp_get_wtime() - t0;

    /* ====== BUCLE 8 ====== */
    t0 = omp_get_wtime();
    Suma = 0;

    #pragma omp parallel for reduction(+:Suma)
    for(k=0;k<neleC;k++)
    {
        Suma += CD[k].v;
        if (CD[k].v != C1[CD[k].i][CD[k].j])
            printf("Error en CD\n");
    }
    t_b8 += omp_get_wtime() - t0;

    printf("Tiempo bucle1: %f\n", t_b1);
    printf("Tiempo bucle2: %f\n", t_b2);
    printf("Tiempo bucle3: %f\n", t_b3);
    printf("Tiempo bucle4: %f\n", t_b4);
    printf("Tiempo bucle5: %f\n", t_b5);
    printf("Tiempo bucle6: %f\n", t_b6);
    printf("Tiempo bucle7: %f\n", t_b7);
    printf("Tiempo bucle8: %f\n", t_b8);
    printf("Elementos C: %d\n", neleC);
    printf("Suma: %lld\n", Suma);

    return 0;
}