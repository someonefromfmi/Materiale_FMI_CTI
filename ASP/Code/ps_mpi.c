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
    if(!(N%nproc)) {

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
        
        for(i=1;i<nproc;i++) {
            MPI_Send(x+i*N/nproc, N/nproc, MPI_FLOAT,i,123,comm);
            MPI_Send(y+i*N/nproc, N/nproc, MPI_FLOAT,i,234,comm);
        }

        for(i=0;i<N/nproc;i++) ps += (*(x + i))*(*(y + i));

        for(i=1;i<nproc;i++) {
            MPI_Recv(&ps_local, 1, MPI_FLOAT,i,345,comm, &status);
            ps += ps_local;
        }
        fp = fopen("res-point-to-point.dat", "w");
        fprintf(fp, "Produsul scalar x.y = %.8g, calculat cu %dprocese cu comunicare 1-la-1.\n Durata: %.8g\n sec",
        ps, nproc, MPI_Wtime() - start_time);
        free(x); free(y);
    } else { /* end_of_if(MASTER) */
        // procese worker
        MPI_Recv(x_local, N/nproc, MPI_FLOAT, MASTER, 123, comm, MPI_STATUS_IGNORE);
        MPI_Recv(y_local, N/nproc, MPI_FLOAT, MASTER, 234, comm, &status);
        for(i=0;i<N/nproc;i++) ps_local += (*(x_local+i))*(*(y_local+i));
        MPI_Send(&ps_local, 1, MPI_FLOAT, MASTER, 345, comm);
    }

    free(x_local);
    free(y_local);
    MPI_Finalize();
    return MPI_SUCCESS;
}
} // end_of_main()