// in cadrul acestui program
// trimit numarul de randuri citite cu broadcast catre celelalte procesd
// impart datele citite de ROOT cu scatter 
// aplic transformata fourier pe segmentul procesului de date 
// ! dupa cum am discutat în cadrul examenului, pot aparea 
// diferente mici în rezultatele finale datorita împartirii semnalului în secțiuni mai mici si efectului de halo
// comparand outputul cu serial si cel paralel se pot observa mici diferente

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_fft_real.h>
#include <gsl/gsl_fft_halfcomplex.h>
#include <mpi.h>

#define FILTER 80

int read_lines_number(char *file_name);
void perform_fft_operations(double* local_data, size_t local_N);

int main(int argc, char *argv[])
{
    int rank, size, N, i;
    double *data, dummy;
    FILE *fp;
    gsl_fft_real_wavetable *real;
    gsl_fft_halfcomplex_wavetable *hc;
    gsl_fft_real_workspace *work;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    char *input_file = "input_data.dat";
    char *output_file = "filtered_data.dat";

    if (rank == 0) {
        N = read_lines_number(input_file);
    }

    MPI_Bcast(&N, 1, MPI_INT, 0, MPI_COMM_WORLD);

    data = (double*)malloc(N * sizeof(double));

    // procesul 0 citeste datele din fisier
    if (rank == 0) {
        fp = fopen(input_file, "r");
        for (i = 0; i < N; i++) {
            fscanf(fp, "%lg\t%lg", &dummy, &data[i]);
        }
        fclose(fp); fp = NULL;
    }

    // distribuirea datelor
    int local_N = N / size;
    int remainder = N % size;

    if (rank < remainder) {
        local_N++;
    }

    double *local_data = (double*)malloc(local_N * sizeof(double));

    int *sendcounts = (int*)malloc(size * sizeof(int));
    int *displs = (int*)malloc(size * sizeof(int));

    int offset = 0;
    for (i = 0; i < size; i++) {
        sendcounts[i] = N / size;
        if (i < remainder) {
            sendcounts[i]++;
        }
        displs[i] = offset;
        offset += sendcounts[i];
    }

    MPI_Scatterv(data, sendcounts, displs, MPI_DOUBLE, local_data, local_N, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    // // verificare distribuire date
    // printf("Rank %d: received data:\n", rank);
    // for (i = 0; i < local_N; i++) {
    //     printf("%d\t%e\n", i + displs[rank], local_data[i]);
    // }

    // transformata Fourier directa pe datele locale
   perform_fft_operations(local_data, local_N);

    // verificare date filtrate
    // printf("Rank %d: filtered data:\n", rank);
    // for (i = 0; i < local_N; i++) {
    //     printf("%d\t%e\n", i + displs[rank], local_data[i]);
    // }

    MPI_Gatherv(local_data, local_N, MPI_DOUBLE, data, sendcounts, displs, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    // scrierea datelor procesate de catre procesul 0
    if (rank == 0) {
        fp = fopen(output_file, "w");
        for (i = 0; i < N; i++) {
            fprintf(fp, "%d\t%e\n", i, data[i]);
        }
        fclose(fp); fp = NULL;
        free(data);
    }

    // eliberare memorie
    free(local_data);
    free(sendcounts);
    free(displs);

    MPI_Finalize();
    return 0;
}

int read_lines_number(char *file_name) {
    FILE *file = fopen(file_name, "r");
    if (file == NULL) {
        perror("Failed to open file");
        return -1;
    }

    int lines = 0;
    char buffer[1024];

    while (fgets(buffer, sizeof(buffer), file) != NULL) {
        lines++;
    }

    fclose(file);
    return lines;
}

void perform_fft_operations(double* local_data, size_t local_N) {
    gsl_fft_real_workspace *work = gsl_fft_real_workspace_alloc(local_N);
    gsl_fft_real_wavetable *real = gsl_fft_real_wavetable_alloc(local_N);

    // Transformare FFT
    gsl_fft_real_transform(local_data, 1, local_N, real, work);
    gsl_fft_real_wavetable_free(real);

    // Filtrare
    for (size_t i = FILTER; i < local_N; i++) {
        local_data[i] = 0;
    }

    // transformare inversa
    gsl_fft_halfcomplex_wavetable *hc = gsl_fft_halfcomplex_wavetable_alloc(local_N);
    gsl_fft_halfcomplex_inverse(local_data, 1, local_N, hc, work);
    gsl_fft_halfcomplex_wavetable_free(hc);

    gsl_fft_real_workspace_free(work);
}