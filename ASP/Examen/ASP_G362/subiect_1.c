#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#define MASTER 0

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(size != 4) {
        if(rank == MASTER)
            fprintf(stderr, "Avem nevoie de exact 4 procese!\n");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }

    int total_values = 0;
    float *data = NULL;
    int *sendcounts = NULL, *displs = NULL;
    float *local_data;
    int local_count = 0;
    int local_positive = 0, total_positive = 0;

    if(rank == MASTER) {
        FILE *input_file = fopen("input.dat", "r");
        if (!input_file) {
            fprintf(stderr, "Nu se poate deschide input.dat\n");
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }

        float temp;
        int capacity = 1024;
        data = (float*)malloc(capacity * sizeof(float));
        if (!data) {
            fprintf(stderr, "Eroare la alocarea memoriei\n");
            fclose(input_file);
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
        while (fscanf(input_file, "%f", &temp) == 1) {
            if (total_values >= capacity) {
                capacity *= 2;
                float *new_data = (float*)realloc(data, capacity * sizeof(float));
                if (!new_data) {
                    fprintf(stderr, "Eroare la realocarea memoriei\n");
                    free(data);
                    fclose(input_file);
                    MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
                }
                data = new_data;
            }
            data[total_values++] = temp;
        }
        fclose(input_file);

        sendcounts = (int*)malloc(size * sizeof(int));
        displs = (int*)malloc(size * sizeof(int));
        int base = total_values / size;
        int rest = total_values % size;
        int offset = 0;
        for(int i = 0; i < size; i++) {
            sendcounts[i] = base + (i < rest ? 1 : 0);
            displs[i] = offset;
            offset += sendcounts[i];
        }
    }

    if(rank != MASTER) {
        sendcounts = (int*)malloc(size * sizeof(int));
    }
    MPI_Bcast(sendcounts, size, MPI_INT, MASTER, MPI_COMM_WORLD);

    local_count = sendcounts[rank];

    local_data = (float *)malloc(local_count * sizeof(float));

    MPI_Scatterv(data, sendcounts, displs, MPI_FLOAT,
                 local_data, local_count, MPI_FLOAT,
                 MASTER, MPI_COMM_WORLD);

    for(int i = 0; i < local_count; i++)
        if(local_data[i] >= 0)
            local_positive++;

    MPI_Reduce(&local_positive, &total_positive, 1, MPI_INT, MPI_SUM, MASTER, MPI_COMM_WORLD);

    if(rank == MASTER) {
        FILE *output_file = fopen("output.dat", "w");
        if (!output_file) {
            fprintf(stderr, "Nu se poate deschide fisierul output.dat\n");
            free(data);
            free(sendcounts);
            free(displs);
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
        fprintf(output_file, "Numar valori procesate:\t%d\n", total_values);
        fprintf(output_file, "Numar valori semipozitive procesate:\t%d\n", total_positive);
        fclose(output_file);
        free(data);
        free(sendcounts);
        free(displs);
    } else {
        free(sendcounts);
    }

    free(local_data);
    MPI_Finalize();
    return 0;
}