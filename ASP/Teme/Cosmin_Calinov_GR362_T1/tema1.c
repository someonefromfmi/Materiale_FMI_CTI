#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "filecom.h"
#include "calc.h"

#define N 200

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int world_rank, nproc;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);

    // verificare daca numarul de procese este par
    if (nproc % 2 != 0) {
        if (world_rank == MASTER) {
            fprintf(stderr, "Eroare: numarul de procese trebuie sa fie par.\n");
        }
        MPI_Finalize();
        return EXIT_FAILURE;
    }

    MPI_Group world_group, low_group, high_group; // crearea grupurilor
    MPI_Comm_group(MPI_COMM_WORLD, &world_group); // crearea comunicatorilor

    const int half = nproc / 2; // punctul in care se separa low si high
    int* low_ranks = (int*)malloc(half * sizeof(int));
    int* high_ranks = (int*)malloc((nproc - half) * sizeof(int));

    for (int i = 0; i < half; i++) low_ranks[i] = i;
    for (int i = 0; i < nproc - half; i++) high_ranks[i] = half + i;

    MPI_Group_incl(world_group, half, low_ranks, &low_group);
    MPI_Group_incl(world_group, nproc - half, high_ranks, &high_group);

    MPI_Comm low_comm, high_comm;
    MPI_Comm_create(MPI_COMM_WORLD, low_group, &low_comm);
    MPI_Comm_create(MPI_COMM_WORLD, high_group, &high_comm);

    float* x = NULL;
    float* y = NULL;
    float** A = NULL;

    // root-ul unui grup citeste datele separat pentru a evita un IO bottleneck la master-ul global
    if (world_rank < half) {
        if (low_comm != MPI_COMM_NULL) {
            x = readVector("x.dat", N, low_comm);
            y = readVector("y.dat", N, low_comm);
        }
    } else {
        if (high_comm != MPI_COMM_NULL) {
            x = readVector("x.dat", N, high_comm);
            y = readVector("y.dat", N, high_comm);
            A = readMatrix("mat.dat", N, high_comm);
        }
    }

    // calcul propriu-zis
    float loc_res = 0.0;
    int send_flag = 0;
    float computation_result = 0.0;

    if (world_rank < half && low_comm != MPI_COMM_NULL) {
        int low_rank;
        computation_result = denominator(x, y, N, low_comm);
        MPI_Comm_rank(low_comm, &low_rank);
        send_flag = (low_rank == 0); // root-ul unui grup trimite date 
    } else if (high_comm != MPI_COMM_NULL) {
        computation_result = numerator(A, x, y, N, high_comm);
        int high_rank;
        MPI_Comm_rank(high_comm, &high_rank);
        send_flag = (high_rank == 0); // analog mai sus
    }

    if (send_flag) {
        if (world_rank == MASTER) {
            loc_res = computation_result; // calculele se salveaza in master
        } else {
            // trimitere catre master
            int tag = (world_rank < half) ? 0 : 1;
            MPI_Send(&computation_result, 1, MPI_FLOAT, 0, tag, MPI_COMM_WORLD);
        }
    }

    // gestionarea datelor este facuta de catre master
    if (world_rank == MASTER) {
        float numerator = 0.0, denominator = 0.0;
        
        // low
        if (world_rank < half) { 
            denominator = loc_res;
            MPI_Recv(&numerator, 1, MPI_FLOAT, half, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        // high
        } else { 
            numerator = loc_res;
            MPI_Recv(&denominator, 1, MPI_FLOAT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }

        // rezultatul final
        float final_result = (denominator != 0.0) ? (numerator / denominator) : 0.0;
        writeResult("out.txt", final_result, MPI_COMM_WORLD);
        printf("Rezultat: %f\n", final_result);
    }

    // dezalocarea resurselor
    if (x) free(x);
    if (y) free(y);
    if (A) {
        for (int i = 0; i < N; i++) free(A[i]);
    }
    free(A); A = NULL;

    if (low_comm != MPI_COMM_NULL) MPI_Comm_free(&low_comm);
    if (high_comm != MPI_COMM_NULL) MPI_Comm_free(&high_comm);

    MPI_Group_free(&low_group);
    MPI_Group_free(&high_group);

    free(low_ranks);
    free(high_ranks);

    MPI_Finalize();
    return MPI_SUCCESS;
}