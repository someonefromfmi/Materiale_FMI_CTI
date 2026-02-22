#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>
#include "gpctrl.h"


float f(float x);
// de facut: -10|----------------|10
// delta = 20 / N  N/nproc  N/nproc
//                  0          1
// |------00000000000000|
// |000000-------0000000|

#define N 1000
int main(int argc, char** argv) {
    int i, nproc, my_rank, source, dest;
    float* data, start_time, xi, delta;
    MPI_Comm comm = MPI_COMM_WORLD;
    MPI_Status status;
    delta = 20.0 / (float)N;
    data = (float*)calloc(N, sizeof(float));
    
    MPI_Init(&argc, &argv);
    MPI_Comm_size(comm, &nproc);
    MPI_Comm_rank(comm, &my_rank);

    start_time = MPI_Wtime();

    for(i = 0; i < N/nproc; i++) {
        xi = -10 + (i + my_rank * N / nproc) * delta;
        *(data + i + my_rank * N / nproc) = f(xi);
    }

    source = (my_rank + nproc - 1) % nproc;
    dest = (my_rank + 1) % nproc;

    MPI_Sendrecv(data + my_rank * N/nproc, N/nproc, MPI_FLOAT, dest, 123, 
        data + source * N/nproc, N/nproc, MPI_FLOAT, source, 123, comm, &status
    );
    MPI_Barrier(comm);
    if(my_rank == 2) MPI_Send(data + N/nproc, 2 * N/nproc, MPI_FLOAT, 0, 234, comm);
    if(my_rank == 0) MPI_Recv(data + N/nproc, 2 * N/nproc, MPI_FLOAT, 2, 234, comm, &status);
    if(my_rank == 0) {
        FILE* fp = fopen("data.dat", "w");
        fprintf(fp, "# Date procesate pe un inel cu %d procese, durata de executie %.8f\n", nproc, MPI_Wtime() - start_time);
        for(i = 0; i < N; i++) {
            xi = -10. + i*delta;
            fprintf(fp, "%.8f\t%.8f\n", xi, *(data+i));
        }
        fclose(fp);  fp = NULL;
    gp_ctrl* h = gp_init();
    gp_set_xlabel(h, "x[div]");
    gp_set_ylabel(h, "f(x)");

    gp_send_cmd(h, "plot '%s' using 1:2", "data.dat");
    fprintf(stdout, "Apasa tasta q+ENTER pt a continua...\n");
    while(1) {
        char ch;
        if((ch=getchar()) == 'q') break;
    }
    gp_finalize(h);
    }
    
    free(data); data = NULL;
    MPI_Finalize();
    return MPI_SUCCESS;
}
// de luat o bucata mare de text, impartim textul in procese(de ex liniile) si numaram de cate ori se afla un cuvant
// moodle.unibuc.ro