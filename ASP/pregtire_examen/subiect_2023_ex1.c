/**
 * scrieti un program C MPI care sa poate fi rulat cu 4 procese
 * si sa asigure urmatoarea functionalitate:
 * - toate procesele isi stocheaza rangul in variabila my_rank si declara un sir double data[10]
   pe care il initializeaza cu valori generate aleator in intervalul (0,1) (puteti folosi functii din GSL, precum gsl_rng_uniform())
   - procesul 0 colecteaza toate datele/sirurile si le stocheaza intr-un fisier text data.out sub forma:
   rank: data[0], data[1], ..., data[9], unde rank este rangul procesului care a generat sirul respectiv    
   - functii sugerate: MPI_Init(), MPI_Comm_size(), MPI_Comm_rank(), MPI_Send(), MPI_Recv(), MPI_Finalize(), MPI_Send(), MPI_Recv()
 */

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <gsl/gsl_rng.h>

#define ARRAY_SIZE 10

int main(int argc, char *argv[]) {
    int my_rank, size;
    double data[ARRAY_SIZE];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size != 4) {
        if (my_rank == 0)
            fprintf(stderr, "This program must be run with exactly 4 processes.\n");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }

    // Initialize random number generator
    gsl_rng *rng = gsl_rng_alloc(gsl_rng_default);
    gsl_rng_set(rng, my_rank + 1234); // Different seed for each rank

    for (int i = 0; i < ARRAY_SIZE; i++) {
        data[i] = gsl_rng_uniform(rng);
    }

    if (my_rank == 0) {
        FILE *fp = fopen("data.out", "w");
        if (fp == NULL) {
            fprintf(stderr, "Error opening file for writing.\n");
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }

        // Write own data
        fprintf(fp, "%d:", my_rank);
        for (int i = 0; i < ARRAY_SIZE; i++) {
            fprintf(fp, " %f", data[i]);
            if (i < ARRAY_SIZE - 1) fprintf(fp, ",");
        }
        fprintf(fp, "\n");

        // Receive and write data from other processes
        double recv_data[ARRAY_SIZE];
        for (int src = 1; src < size; src++) {
            MPI_Recv(recv_data, ARRAY_SIZE, MPI_DOUBLE, src, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            fprintf(fp, "%d:", src);
            for (int i = 0; i < ARRAY_SIZE; i++) {
                fprintf(fp, " %f", recv_data[i]);
                if (i < ARRAY_SIZE - 1) fprintf(fp, ",");
            }
            fprintf(fp, "\n");
        }
        fclose(fp);
    } else {
        MPI_Send(data, ARRAY_SIZE, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
    }

    gsl_rng_free(rng);
    MPI_Finalize();
    return 0;
}