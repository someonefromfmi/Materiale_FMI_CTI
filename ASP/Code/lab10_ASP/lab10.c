#include <stdio.h>
#include <stdlib.h>
#include "pgm_IO.h"
#include "pgm_IO.c"
#include <fftw3-mpi.h>

// mpicc -o lab10 lab10.c -lfftw3f-mpi -lfftw3f -lm

#define MASTER 0
#define REAL 0
#define IMAG 1

// z = x + iy = re^iteta
// r = sqrt(x^2 + y^2)
// teta = arctan(y/x)
// x = rcos teta
// y = rsin teta

int main(int argc, char** argv) {
    int L, M; // dimens pozei in pixeli
    float *data, *local_data;
    fftwf_complex *data_in, *data_out;
    fftwf_plan plan;
    int myrank, nproc;
    ptrdiff_t alloc_local, local_n0, local_0_start, i, j;
    MPI_Comm comm = MPI_COMM_WORLD;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(comm ,&nproc);
    MPI_Comm_rank(comm ,&myrank);

    pgm_size("cat.pgm", &L, &M);

    if(myrank == MASTER) {
        data = (float*) malloc(L*M*sizeof(float));
        pgm_read("cat.pgm", data, L, M);
    }

    fftwf_mpi_init();
    
    alloc_local = fftwf_mpi_local_size_2d(L, M, comm, &local_n0, &local_0_start);
    data_in = fftwf_alloc_complex(alloc_local);
    data_out = fftwf_alloc_complex(alloc_local);

    local_data = (float*) malloc(local_n0*M*sizeof(float));

    plan = fftwf_mpi_plan_dft_2d(L, M, data_in, data_out, comm, FFTW_FORWARD, FFTW_ESTIMATE);

    MPI_Scatter(data, local_n0*M, MPI_FLOAT, local_data, local_n0*M,MPI_FLOAT, 0, comm);

    for(i = 0; i < local_n0; i++)
        for(j = 0; j < M; j++) {
            data_in[i*M+j][REAL] = local_data[i*M+j];
            data_in[i*M+j][IMAG] = 0;
        }

    fftwf_execute(plan);

    // low pass
    // for(j = alloc_local - 1000; j < alloc_local; j++) {
    //     data_out[j][REAL] = 0;
    //     data_out[j][IMAG] = 0;
    // }

    // high pass
    for(j = 0; j < 1000; j++) {
        data_out[j][REAL] = 0;
        data_out[j][IMAG] = 0;
    }

    plan = fftwf_mpi_plan_dft_2d(L, M, data_out, data_in, comm, FFTW_BACKWARD, FFTW_ESTIMATE);
    fftwf_execute(plan);
   
    for(i = 0; i < local_n0; i++)
        for(j = 0; j < M ; j++) {
            local_data[i*M+j] = data_in[i*M+j][REAL];
        }

    MPI_Gather(local_data, local_n0*M, MPI_FLOAT, data, local_n0*M, MPI_FLOAT, MASTER, comm);

    if(myrank == MASTER) {
        pgm_write("cat_high.pgm", data, L, M);
        free(data);
    }

    free(local_data);
    fftwf_destroy_plan(plan);
    MPI_Finalize();

    return MPI_SUCCESS;
}