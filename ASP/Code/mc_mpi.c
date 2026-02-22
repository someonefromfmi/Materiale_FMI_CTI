// MPI
#include <stdio.h>
#include <stdlib.h>
#include <gsl/gsl_rng.h>
#include <math.h>
#include <mpi.h>

#include "func.c"
#include "mc.c"

#define N 1000000
#define MASTER 0

// cat /proc/cpuinfo -> cpucores: 8 (max 8 procese: 1 proces/core)
// noi vom folosi 4 procese (0,1,2,3)
// 0 - master: coord, op in/out, sinc, distrib datelor init catre workers
// 1,2,3 - worker: munca p zisa

int main(int argc, char** argv) {
    int nproc, // nr proc i  ||
        my_rank, // rangul proc
        cnt; // counter nr procese
    double *params, // param care definesc dom de integrare
            recv_val; // buffer send_recv
    MPI_Comm comm = MPI_COMM_WORLD;
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(comm, &nproc); // setare nr de proc care ruleaza in ||
    MPI_Comm_rank(comm, &my_rank);  // setare rang proc curr
    params = (double*) malloc(4*sizeof(double));
    if(my_rank == MASTER) {
        // Master
        FILE* fp;
        double start = MPI_Wtime(), stop;
        fp = fopen("rezultat_mc.out", "w");
        // mai elegant luam din fisier de intrare
        *(params) = M_PI; // a
        *(params+1) = M_PI; // b
        *(params+2) = M_PI; // c
        *(params+3) = 1.0; // fmax
        double val = 0;
        for(cnt=1; cnt < nproc; cnt++) {
            MPI_Send(params, 4, MPI_DOUBLE, cnt, 123, comm);
        }
        for(cnt=1; cnt < nproc; cnt++) {
            MPI_Recv(&recv_val, 1, MPI_DOUBLE, cnt, 321, comm, &status);
            val += recv_val;
        }
        fprintf(fp, "Valoarea integralei: %.8e, calculate cu %d procese\n", val/(nproc-1), nproc);
        fprintf(fp, "Calculul a durat %.8e sec.\n\n", MPI_Wtime()-start);
        fclose(fp); fp = NULL;
    } /*end_of_if (MASTER) */else {
        // Worker
        MPI_Recv(params, 4, MPI_DOUBLE, MASTER, 123, comm, &status);
        recv_val = mc(N, params);
        MPI_Send(&recv_val, 1, MPI_DOUBLE, MASTER, 321, comm);
    } // end_of_else(WORKER)
    free(params);
    MPI_Finalize();
    return MPI_SUCCESS;
} // end_of_main()

// mpicc -o mc_mpi mc_mpi.c -lgsl -lgslcblas -lm
// mpirun -np 4 ./mc_mpi