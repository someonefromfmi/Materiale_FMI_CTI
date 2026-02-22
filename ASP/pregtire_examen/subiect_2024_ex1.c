// ******** Integrarea numerica prin metoda trapezelor ********
//  Integrala functiei f(x) = log(1+x^2)*Gamma(x), pe [0.10,2.50]: 2.48826233

#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_sf_gamma.h>

#define N 10000

// Functia de integrat
double f(double x) {
    return log(1 + x * x) * gsl_sf_gamma(x);
}

// Functia care calculeaza efectiv integrala pe un subinterval
double int_T(double a, double b, long Nm) {
    double h = (b - a) / ((double) Nm);
    double Iab = 0.0; // Valoarea integralei
    long i;

    for (i = 0; i < Nm; i++) {
        double x1 = a + i * h; // Valoarea x_i
        double x2 = a + (i + 1) * h; // Valoarea x_(i+1)
        Iab += (f(x1) + f(x2));
    }

    Iab = Iab * h / 2.0;
    return Iab;
}

int main(int argc, char** argv) {
    double a = 0.1, b = 2.5;
    double IT, local_IT;
    int rank, size;

    // Initializare MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Calculam limitele locale de integrare pentru fiecare proces
    double local_a = a + rank * (b - a) / size;
    double local_b = a + (rank + 1) * (b - a) / size;
    long local_N = N / size;

    // Calculam integral pentru subintervalul local
    local_IT = int_T(local_a, local_b, local_N);

    // Agregam rezultatele din toate procesele folosind MPI_Reduce
    MPI_Reduce(&local_IT, &IT, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    // Procesul cu rangul 0 afiseaza rezultatul final
    if (rank == 0) {
        printf("******** Integrarea numerica prin metoda trapezelor ********\n");
        printf(" Integrala functiei f(x) = log(1+x^2)*Gamma(x), pe [%.2lf,%.2lf]: %.8lf\n\n", a, b, IT);
    }

    // Finalizare MPI
    MPI_Finalize();
    return 0;
}
