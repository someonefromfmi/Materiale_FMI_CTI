#include <stdio.h>
#include <math.h>
#include <time.h>
#include <omp.h>

#define N 100000
#define NUM_THREADS 8

double sinc(double x) {
    if(fabs(x) < 1e-50) {
        return 1.0;
    } else return sin(x)/x;
}

int main() {
    double res = 0., h = 2 * M_PI / (double)N, start = omp_get_wtime();
    omp_set_num_threads(NUM_THREADS);


    #pragma omp parallel for default(none) shared(h)/*Solutia 3*/ reduction(+:res)
    for(long i = 0; i < N; i++) {
        double x1 = - M_PI + i * h;
        double x2 = x1 + h;

        /*Solutia 1*///#pragma omp atomic
        /*Solutia 1*///#pragma omp critical
        res += (sinc(x1) + sinc(x2)) * h/2; // problema aici daca nu protejam resursa comuna

    }

    fprintf(stdout, "\n pi \n | sin(x)/x dx = %.8lf \n / \n -pi. \n\n Rezultatul calculat cu %d fire de executie in %.8f sec. \n\n",
            res, NUM_THREADS,omp_get_wtime()-start);
}