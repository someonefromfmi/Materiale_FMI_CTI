#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "filecom.h"

float* readVector(const char* filename, int N, MPI_Comm comm) {
    int rank;
    float* vector;
    MPI_Comm_rank(comm, &rank);
    
    if (rank == MASTER) {
        FILE* file = fopen(filename, "r");
        if (!file) {
            perror("Eroare la deschiderea fisierului cu vector");
            MPI_Abort(comm, EXIT_FAILURE);
        }
        
        vector = (float*)malloc(N * sizeof(float));
        for (int i = 0; i < N; i++) {
            if (fscanf(file, "%f", &vector[i]) != 1) {
                perror("Eroare la citirea datelor");
                MPI_Abort(comm, EXIT_FAILURE);
            }
        }
        fclose(file);
    }
    
    // trimiterea vectorului tuturor proceselor
    if (rank == MASTER) {
        MPI_Bcast(vector, N, MPI_FLOAT, 0, comm);
    } else {
        vector = (float*)malloc(N * sizeof(float));
        MPI_Bcast(vector, N, MPI_FLOAT, 0, comm);
    }
    
    return vector;
}

float** readMatrix(const char* filename, int size, MPI_Comm comm) {
    int rank;
    MPI_Comm_rank(comm, &rank);
    
    float** matrix = NULL;
    
    if (rank == MASTER) {
        FILE* file = fopen(filename, "r");
        if (!file) {
            perror("Error la deschiderea fisierului cu matrice");
            MPI_Abort(comm, EXIT_FAILURE);
        }
        
        matrix = (float**)malloc(size * sizeof(float*));
        for (int i = 0; i < size; i++) {
            matrix[i] = (float*)malloc(size * sizeof(float));
            for (int j = 0; j < size; j++) {
                if (fscanf(file, "%f", &matrix[i][j]) != 1) {
                    perror("Eroare la citirea datelor din matrice");
                    MPI_Abort(comm, EXIT_FAILURE);
                }
            }
        }
        fclose(file);
    }
    
    // trimiterea randurilor matricii fiecarui rand
    for (int i = 0; i < size; i++) {
        if (rank == MASTER) {
            MPI_Bcast(matrix[i], size, MPI_FLOAT, 0, comm);
        } else {
            if (i == 0) {
                matrix = (float**)malloc(size * sizeof(float*));
            }
            matrix[i] = (float*)malloc(size * sizeof(float));
            MPI_Bcast(matrix[i], size, MPI_FLOAT, 0, comm);
    }
}
    
    return matrix;
}

void writeResult(const char* filename, float res, MPI_Comm comm) {
    int rank;
    MPI_Comm_rank(comm, &rank);
    
    if (rank == MASTER) {
        FILE* file = fopen(filename, "w");
        if (!file) {
            perror("Eroare la deschiderea fisierului out");
            MPI_Abort(comm, EXIT_FAILURE);
        }
        fprintf(file, "AVG = %f\n", res);
        fclose(file);
    }
}
