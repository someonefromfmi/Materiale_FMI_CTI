#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_fft_real.h>
#include <gsl/gsl_fft_halfcomplex.h>
#include <mpi.h>

#define MASTER 0
#define FILTER 80

int read_lines_number(char* file_name) {
    FILE *fp = fopen(file_name, "r");
    if (!fp) {
        fprintf(stderr, "Could not open file %s\n", file_name);
        return -1;
    }
    int count = 0;
    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        count++;
    }
    fclose(fp);
    return count;
}

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int N = 0;
    if (rank == MASTER) {
        N = read_lines_number("input_data.dat");
        if (N <= 0) {
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
    }
    MPI_Bcast(&N, 1, MPI_INT, MASTER, MPI_COMM_WORLD);

    if (N % size != 0) {
        if (rank == MASTER)
            fprintf(stderr, "N (%d) nu este divizibil cu numarul de procese (%d)!\n", N, size);
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }

    int local_size = N / size;
    double *local_data = (double *)malloc(local_size * sizeof(double));
    if (!local_data) {
        fprintf(stderr, "Memory allocation failed for local_data\n");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }

    double *data = NULL;
    if (rank == MASTER) {
        data = (double *)malloc(N * sizeof(double));
        if (!data) {
            fprintf(stderr, "Memory allocation failed for data\n");
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
        FILE *fp = fopen("input_data.dat", "r");
        if (!fp) {
            fprintf(stderr, "Nu se poate deschide input_data.dat\n");
            free(data);
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
        for (int i = 0; i < N; i++) {
            fscanf(fp, "%*d %lf", &data[i]);
        }
        fclose(fp);

        gsl_fft_real_workspace *work = gsl_fft_real_workspace_alloc(N);
        gsl_fft_real_wavetable *real = gsl_fft_real_wavetable_alloc(N);
        gsl_fft_real_transform(data, 1, N, real, work);
        gsl_fft_real_wavetable_free(real);

        for (int i = FILTER; i < N; i++) {
            data[i] = 0;
        }

        gsl_fft_halfcomplex_wavetable *hc = gsl_fft_halfcomplex_wavetable_alloc(N);
        gsl_fft_halfcomplex_inverse(data, 1, N, hc, work);
        gsl_fft_halfcomplex_wavetable_free(hc);
        gsl_fft_real_workspace_free(work);
    }

    MPI_Scatter(data, local_size, MPI_DOUBLE, local_data, local_size, MPI_DOUBLE, MASTER, MPI_COMM_WORLD);

    double *result_data = NULL;
    if (rank == MASTER) {
        result_data = (double *)malloc(N * sizeof(double));
        if (!result_data) {
            fprintf(stderr, "Memory allocation failed for result_data\n");
            free(data);
            free(local_data);
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
    }

    MPI_Gather(local_data, local_size, MPI_DOUBLE, result_data, local_size, MPI_DOUBLE, MASTER, MPI_COMM_WORLD);

    if (rank == MASTER) {
        FILE *fp = fopen("filtered_data.dat", "w");
        if (!fp) {
            fprintf(stderr, "Nu se poate deschide fisierul filtered_data.dat\n");
            free(result_data);
            free(data);
            free(local_data);
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
        for (int i = 0; i < N; i++) {
            fprintf(fp, "%d\t%e\n", i, result_data[i]);
        }
        fclose(fp);
        free(result_data);
        free(data);
    }

    free(local_data);
    MPI_Finalize();
    return 0;
}