#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <time.h>

#define N 100

void timestamp(void);

int main(int argc, char *argv[]) {
    MPI_Comm comm1, comm2;
    MPI_Group world_group, group1, group2;

    int i, rank, nproc, newrank;

    double mean, sigma, local_sum, *data, *local_data;
    int *ranks1, *ranks2;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);

    if (nproc < 2) {
        fprintf(stderr, "This program requires at least two processes.\n");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }

    if(rank == 0) {
        printf("\n");
        printf("Data si ora la inceputul executiei programului: ");
        timestamp ( );
        printf ( "\nCreare de comunicatori MPI - procesul master este cel cu rangul %d\n", rank);
        printf ( "\nNumarul de procese lansate in executie este %d.\n", nproc );
        printf ( "\n" );
    }

    MPI_Comm_group(MPI_COMM_WORLD, &world_group);

    ranks1 = (int *)malloc((nproc / 2) * sizeof(int));
    ranks2 = (int *)malloc((nproc / 2) * sizeof(int));

    int kpar = 0, kimpar = 0;
    for (i = 0; i < nproc; i++) {
        if (i % 2 == 0) {
            ranks1[kpar++] = i;
        } else {
            ranks2[kimpar++] = i;
        }
    }

    MPI_Group_incl(world_group, nproc / 2, ranks1, &group1);
    MPI_Group_incl(world_group, nproc / 2, ranks2, &group2);

    MPI_Comm_create(MPI_COMM_WORLD, group1, &comm1);
    MPI_Comm_create(MPI_COMM_WORLD, group2, &comm2);

    if(rank % 2 == 0) {
        MPI_Comm_rank(comm1, &newrank);
    } else {
        MPI_Comm_rank(comm2, &newrank);
    }

    if(newrank == 0) {
        data = (double *)malloc(N * sizeof(double));
    }

    local_data = (double *)malloc((N/(nproc/2)) * sizeof(double));

    if(newrank == 0) {
        FILE* f = fopen("input_vec.dat", "r");
        for(int i = 0; i < N; i++) {
            fscanf(f, "%lf", &data[i]);
        }
        fclose(f);
    }

    // --- MODIFICARE SINCRONIZARE ---
    if(rank % 2 == 0) {
        MPI_Scatter(data, N/(nproc/2), MPI_DOUBLE, local_data, N/(nproc/2), MPI_DOUBLE, 0, comm1);
        local_sum = 0.0;
        for(i = 0; i < N/(nproc/2); i++) {
            local_sum += local_data[i];
        }
        MPI_Reduce(&local_sum, &mean, 1, MPI_DOUBLE, MPI_SUM, 0, comm1);

        if(newrank == 0) {
            mean /= N;
            // Trimite media catre procesul 1 din MPI_COMM_WORLD
            MPI_Send(&mean, 1, MPI_DOUBLE, 1, 0, MPI_COMM_WORLD);
            MPI_Bcast(&mean, 1, MPI_DOUBLE, 0, comm1);
            printf("\n Media este: %lf", mean);
        }
    } else {
        if(newrank == 0) {
            // Primeste media de la procesul 0 din MPI_COMM_WORLD
            MPI_Recv(&mean, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }
        MPI_Bcast(&mean, 1, MPI_DOUBLE, 0, comm2);
        MPI_Scatter(data, N/(nproc/2), MPI_DOUBLE, local_data, N/(nproc/2), MPI_DOUBLE, 0, comm2);
        local_sum = 0.0;
        for(i = 0; i < N/(nproc/2); i++) {
            local_sum += (local_data[i] - mean) * (local_data[i] - mean);
        }
        MPI_Reduce(&local_sum, &sigma, 1, MPI_DOUBLE, MPI_SUM, 0, comm2);
        if(newrank == 0) {
            sigma = sigma / (N - 1);
            printf("\n Varianta este: %lf\n", sigma);
        }
    }
    // --- FINAL MODIFICARE ---

    if(newrank == 0) {
        free(data);
    }
    free(local_data);
    free(ranks1);
    free(ranks2);

    if (rank == 0){
        printf("\n");
        printf("****** Programul a iesit in conditii normale ******\n");
        printf("\n");
        printf("Data si ora la final: ");
        timestamp();
        printf("\n");
    }

    MPI_Finalize();
    return 0;
}

void timestamp(void) {
    #define TIME_SIZE 40
    static char time_buffer[TIME_SIZE];
    const struct tm *tm;
    size_t len;
    time_t now;

    now = time(NULL);
    tm = localtime(&now);

    len = strftime(time_buffer, TIME_SIZE, "%d %B %Y %I:%M:%S %p", tm);
    fprintf(stdout, "%s\n", time_buffer);
    return;
    #undef TIME_SIZE
}