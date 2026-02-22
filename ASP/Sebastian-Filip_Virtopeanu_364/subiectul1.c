#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_sf_gamma.h>

#define N 10000

// functia de integrat
double f(double x) {
    return log(1 + x * x) * gsl_sf_gamma(x);
}

double int_T(double a, double b, long Nm) {
    double h = (b - a) / ((double) Nm);
    double Iab = 0.0;  
    for (long i = 0; i < Nm; i++) {
        double x1 = a + i * h; 
        double x2 = a + (i + 1) * h;  
        Iab += (f(x1) + f(x2));
    }
    Iab = Iab * h / 2.0;
    return Iab;
}

// initializarea MPI si setarea parametrilor
void initialize_MPI(int argc, char** argv, int* rank, int* size) {
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, rank);
    MPI_Comm_size(MPI_COMM_WORLD, size);
}

// calculatrea limitelor locale de integrare pentru fiecare proces
void calculate_local_limits(double a, double b, int rank, int size, double* local_a, double* local_b, long* local_N) {
    *local_a = a + rank * (b - a) / size;
    *local_b = a + (rank + 1) * (b - a) / size;
    *local_N = N / size;
}

// reunirea rezultatelor partiale folosind MPI_Reduce
void gather_results(double local_IT, double* IT) {
    MPI_Reduce(&local_IT, IT, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
}

// afisarea rezultatului final
void display_result(double a, double b, double IT, int rank) {
    FILE *file;
    file = fopen("subiectul1Output.txt", "a");  

    if (file == NULL) {
        printf("Eroare la deschiderea fișierului!\n");
        return;
    }

    if (rank == 0) {
        fprintf(file, "******** Integrarea numerica prin metoda trapezelor ********\n");
        fprintf(file, " Integrala functiei f(x) = log(1+x^2)*Gamma(x), pe [%.2lf,%.2lf]: %.8lf\n\n", a, b, IT);
        
        printf("******** Integrarea numerica prin metoda trapezelor ********\n");
        printf(" Integrala functiei f(x) = log(1+x^2)*Gamma(x), pe [%.2lf,%.2lf]: %.8lf\n\n", a, b, IT);
    }

    fclose(file); 
}

int main(int argc, char** argv) {
    double a = 0.1, b = 2.5;
    double IT, local_IT;
    int rank, size;
    double local_a, local_b;
    long local_N;

    double start_time, end_time, computation_time, total_time;

    initialize_MPI(argc, argv, &rank, &size);

    start_time = MPI_Wtime();
    calculate_local_limits(a, b, rank, size, &local_a, &local_b, &local_N);
    local_IT = int_T(local_a, local_b, local_N);
    computation_time = MPI_Wtime();

    gather_results(local_IT, &IT);
    end_time = MPI_Wtime();

    if (rank == 0) {
        printf("Timp calcul (secunde): %f\n", computation_time - start_time);
        printf("Timp total (secunde): %f\n", end_time - start_time);
    }

    display_result(a, b, IT, rank);
    MPI_Finalize();

    return 0;
}
