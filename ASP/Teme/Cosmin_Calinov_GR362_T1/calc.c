#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "calc.h"

float numerator(float** A, float* x, float* y, int size, MPI_Comm comm) {
    int rank, nproc;
    MPI_Comm_size(comm, &nproc); // setare numar de procese care lucreaza in paralel
    MPI_Comm_rank(comm, &rank); // setarea rangului procesului curent
    
    // calculul numarului de date procesate local
    int local_N = size / nproc; // cate date asignam fiecarui proces
    int rest = size % nproc; // rest in cazul in care dimenisunea nu se divide cu
    // numarul de procese
    
    // distribuirea datelor pentru fiecare proces
    int start = rank * local_N + (rank < rest ? rank : rest);
    int end = start + local_N + (rank < rest ? 1 : 0);
    
    float local_sum = 0.0; // suma locala fiecarui proces
    for (int i = start; i < end; i++) {
        for (int j = 0; j < size; j++) {
            local_sum += x[i] * A[i][j] * y[j];
        }
    }
    
    float global_sum; // suma globala
    MPI_Reduce(&local_sum, &global_sum, 1, MPI_FLOAT, MPI_SUM, 0, comm);
    
    return global_sum;
}

float denominator(float* x, float* y, int size, MPI_Comm comm) {
    int rank, nproc;
    MPI_Comm_rank(comm, &rank); 
    MPI_Comm_size(comm, &nproc);
    
    // calculul numarului de date procesate local
    int local_N = size / nproc; // cate date asignam fiecarui proces
    int rest = size % nproc; // rest in cazul in care dimenisunea nu se divide cu
    // numarul de procese
    
    // distribuirea datelor pentru fiecare proces
    int start = rank * local_N + (rank < rest ? rank : rest);
    int end = start + local_N + (rank < rest ? 1 : 0);
    

    float local_sum = 0.0; // suma locala fiecarui proces
    for (int i = start; i < end; i++) {
        local_sum += x[i] * y[i];
    }
    
    float global_sum; // suma globala
    MPI_Reduce(&local_sum, &global_sum, 1, MPI_FLOAT, MPI_SUM, 0, comm);
    
    return global_sum;
}