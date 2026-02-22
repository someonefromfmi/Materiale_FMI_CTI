#include <stdio.h>
#include <math.h>
#include <time.h>

#define N 100000

double sinc(double x) {
    if(fabs(x) < 1e-50) {
        return 1.0;
    } else return sin(x)/x;
}

int main() {
    long i;
    double res = 0., h = 2 * M_PI / (double)N;
    clock_t start = clock();

    for(i = 0; i < N; i++) {
        double x1 = - M_PI + i * h;
        double x2 = x1 + h;
        res += (sinc(x1) + sinc(x2)) * h/2;
    }

    fprintf(stdout, "\n pi \n | sin(x)/x dx = %.8lf \n / \n -pi. \n\n Rezultatul calculat secvential in %.8f sec. \n\n",
            res, (clock()-start/CLOCKS_PER_SEC));
}