#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "pgm_IO.h"
#include "pgm_IO_mod.c"
#include <omp.h>
#include <string.h>

#define MY_SUCCESS 0

void correlate(int ny, int nx, const float* data, float* corr_res) {
    int i,j,k;
    float sum_x, sum_y, sum_xy, sum_sqx, sum_sqy; 
    for(i = 0; i < ny; i++) {
        for(j = i; j < ny; j++) {
            sum_x = sum_y = sum_xy = sum_sqx = sum_sqy = 0;
            // cmpxchg
            # pragma omp parallel for reduction(+: sum_x, sum_y, sum_xy, sum_sqx, sum_sqy)
            for(k = 0; k < nx; k++) {
                // # pragma omp critical
                sum_x += *(data + i * nx + k);
                // # pragma omp critical
                sum_y += *(data + j * nx + k);
                // # pragma omp critical
                sum_xy += (*(data + i * nx + k)) * (*(data + j * nx + k));
                // # pragma omp critical
                sum_sqx += (*(data + i * nx + k)) * (*(data + i * nx + k));
                // # pragma omp critical
                sum_sqy += (*(data + j * nx + k)) * (*(data + j * nx + k));
            }
           *(corr_res + j * ny + i) = *(corr_res + i * ny + j) = (nx * sum_xy - sum_x * sum_y) 
                                    / sqrt((nx * sum_sqx - sum_x * sum_x)
                                    * (nx * sum_sqy - sum_y*sum_y));

        }
    }
    return;
}

int main(int argc, char** argv) {
    if(argc != 2) {
        printf("Utilizare: %s nume_fisier.pgm\n\n", argv[0]);
        exit(1);
    }
    int nx, ny;
    float* data;
    float* corr_res;

    double start = omp_get_wtime();

    pgm_size(argv[1], &nx, &ny);


    data = (float*) malloc(nx * ny * sizeof(float));
    corr_res = (float*) malloc(ny * ny * sizeof(float));

    pgm_read(argv[1], data, nx, ny);

    correlate(ny, nx, data, corr_res);

    char fname[64];
    char* token = strtok(argv[1], ".");
    sprintf(fname, "%s_res_sec.pgm", token);

    pgm_write(fname, corr_res, ny, ny);

    free(data); free(corr_res); 

    printf("Durata: %.11lf sec. \n", omp_get_wtime()-start);

    return MY_SUCCESS;
}