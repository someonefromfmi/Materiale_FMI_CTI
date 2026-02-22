#include <stdio.h>
#include <math.h>
#include <time.h>
#include <omp.h>
#include <mpi.h>
#include <stdlib.h>

#define N 100000
#define NUM_THREADS 8
#define MASTER 0

double sinc(double x) {
    if(fabs(x) < 1e-50) {
        return 1.0;
    } else return sin(x)/x;
}

int main(int argc, char** argv) {
    double local_res = 0. ,res = 0., h, start = omp_get_wtime();
    int nproc, myrank, available_threading;
    MPI_Comm comm = MPI_COMM_WORLD;

    MPI_Init_thread(&argc, &argv, MPI_THREAD_MULTIPLE, &available_threading);
    if(available_threading != MPI_THREAD_MULTIPLE) {
        perror("Nivel de threading nesurportat de biblioteca MPI. Ies...\n\n");
        exit(1);
    }
    MPI_Comm_size(comm, &nproc);
    MPI_Comm_rank(comm, &myrank);
    omp_set_num_threads(NUM_THREADS);

    double lower_limit = -M_PI + myrank * 2 * M_PI/nproc;
    double upper_limit = lower_limit + 2 * M_PI/nproc;
    h = (upper_limit - lower_limit)/(double)N;

    #pragma omp parallel for default(none) shared(h, lower_limit)/*Solutia 3*/ reduction(+:local_res)
    for(long i = 0; i < N; i++) {
        double x1 = lower_limit + i * h;
        double x2 = x1 + h;

        /*Solutia 1*///#pragma omp atomic
        /*Solutia 1*///#pragma omp critical
        local_res += (sinc(x1) + sinc(x2)) * h/2; // problema aici daca nu protejam resursa comuna
    }

    MPI_Reduce(&local_res, &res, 1, MPI_DOUBLE, MPI_SUM, MASTER, comm);

    if(myrank == MASTER)
        fprintf(stdout, "\n pi \n | sin(x)/x dx = %.8lf \n / \n -pi. \n\n Rezultatul calculat cu %d fire de executie in %.8f sec. \n\n",
                res, NUM_THREADS,omp_get_wtime()-start);

    MPI_Finalize();
    return 0;
}