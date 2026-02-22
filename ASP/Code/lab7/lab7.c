// yi = sum de la j=1 la 200 Aij xj
// MPI_Type_vec
// MPI_Init(), MPI_Comm_size(), MPI_Comm_rank(), MPI_Type_vector(), MPI_Type_commit(),
// MPI_Type_Send(), MPI_Send_Recv(), MPI_Gather(), MPI_Finalize()

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "read.h"
#include "read.c"

#ifndef N
#define N 200
#ifndef MASTER
#define MASTER 0

int main(int argc, char** argv) {
    int my_rank, nproc;
    int i,j;
    FILE* fp;
    float* mat, *local_mat, *vec, *local_vec;
    MPI_Datatype my_block;

    MPI_Comm comm = MPI_COMM_WORLD;
    MPI_Status status;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_size(comm, &nproc);
    MPI_Comm_rank(comm, &my_rank);
    MPI_Type_vector(N/nproc,N, 1, MPI_FLOAT, &my_block);
    MPI_Type_commit(&my_block);

    local_mat = (float*)calloc(N*(N/nproc),sizeof(float));
    local_vec = (float*)calloc(N/nproc, sizeof(float));
    vec = (float*)calloc(N, sizeof(float));

    if(my_rank == MASTER) {
        mat = (float*)calloc(N*N,sizeof(float)); 
        readmatrix(N,N, mat, "mat.dat");
        readvec(N, vec, "x.dat");
        fclose(fp); fp = NULL;
        MPI_Bcast(vec, N, MPI_FLOAT, MASTER, comm);
        for(i=1;i<nproc;i++) MPI_Send(mat + i * N * (N/nproc), 1, my_block, i, 123, comm);
        for(i=0;i<N/nproc;i++)
            for(j=0;j<N;j++) 
                *(local_mat + i * N + j) = *(mat + i * N + j);
    } /*end_of_if(MASTER)*/ else {
        // worker, my_rank != 0
        MPI_Bcast(vec, N, MPI_FLOAT, MASTER, comm);
        MPI_Recv(local_mat, 1, my_block, MASTER, 123, comm, &status);
    }
    for(i=0;i<N/nproc;i++)
        for(j=0;j<N/nproc;j++)
            *(local_vec + i) += (*(local_mat + i * N + j) * (*vec+j));

    MPI_Gather(local_vec, N/nproc, MPI_FLOAT, vec, N/nproc, MPI_FLOAT, MASTER, comm);

    if(my_rank == MASTER) {
        fp = fopen("res_vec.dat", "w");
        for(int i = 0; i < N; i++)
            fprintf(fp, "%f\n", vec[i]);  
        free(mat);
    }
    free(local_mat); free(vec); free(local_vec);
    MPI_Finalize();

    return MPI_SUCCESS;
}

#endif
#endif