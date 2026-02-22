#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

//#ifndef N
#define N 200
//#ifndef MASTER
#define MASTER 0
int main(int argc, char** argv) {
    int nproc, my_rank, i;
    float *x, *y, *x_local, *y_local, ps, ps_local=0;
    MPI_Comm comm = MPI_COMM_WORLD;
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(comm, &nproc);
    MPI_Comm_rank(comm, &my_rank);
    double start_time = MPI_Wtime();

    x_local = (float*) malloc(N/nproc*sizeof(float));
    y_local = (float*) malloc(N/nproc*sizeof(float));
    ps_local = 0;

    if(my_rank == MASTER) {
        
        x = (float*)malloc(N*sizeof(float));
        y = (float*)malloc(N*sizeof(float));
        FILE* fp;
        fp = fopen("x.dat","r");
        for(i=0;i<N;i++) fscanf(fp, "%f\n", x+i);
        fclose(fp); fp = NULL;

        fp = fopen("y.dat","r");
        for(i=0;i<N;i++) fscanf(fp, "%f\n", y+i);
        fclose(fp); fp = NULL;
    } 
    MPI_Scatter(x, N/nproc, MPI_FLOAT, x_local, N/nproc, MPI_FLOAT, MASTER, comm);
    MPI_Scatter(y, N/nproc, MPI_FLOAT, y_local, N/nproc, MPI_FLOAT, MASTER, comm);

    for(i = 0; i < N/nproc; i++) ps_local += (*(x_local+i))*(*(y_local+i));

    MPI_Reduce(&ps_local, &ps, 1, MPI_FLOAT, MPI_SUM, MASTER, comm);
    if(my_rank == MASTER) {
        if(N % nproc) for(i = nproc * (N/nproc); i < N; i++) ps+=(*(x+i))*(*(y+i));
    }

    if(my_rank == MASTER) {
        FILE* fp;
        fp = fopen("res-point-to-point.dat", "w");
        fprintf(fp, "Produsul scalar x.y = %.8g, calculat cu %d procese cu comunicare globala.\nDurata: %.8g sec\n",
        ps, nproc, MPI_Wtime() - start_time);
        free(x); free(y);
    }
    free(x_local);
    free(y_local);
    MPI_Finalize();
    return MPI_SUCCESS;
} // end_of_main()