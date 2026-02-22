#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pgm_IO.h"
#include "pgm_IO.c"

int main(int argc, char** argv) {
    int M, N;
    int niter = 1000;
    int i, j, it;
    float *data, *pold, *pnew, *plim;

    // Pas 1 - Dimensiuni imagine
    pgm_size("image_640x480.pgm", &M, &N);

    // Alocare memorie
    data = (float*)malloc(M * N * sizeof(float));
    pold = (float*)malloc((M + 2) * (N + 2) * sizeof(float));
    pnew = (float*)malloc((M + 2) * (N + 2) * sizeof(float));
    plim = (float*)malloc((M + 2) * (N + 2) * sizeof(float));

    // Pas 2 - Citire imagine
    pgm_read("image_640x480.pgm", (void*)data, M, N);

    // Pas 3 - Copiere date in plim
    for(i = 1; i <= M; i++)
        for(j = 1; j <= N; j++)
            *(plim + i * (N + 2) + j) = *(data + (i - 1) * N + (j - 1));

    // Pas 4 - Halouri
    for(i = 0; i < (M + 2) * (N + 2); i++) {
        *(pold + i) = 255;
        *(pnew + i) = 255;
        // *(plim + i) = 255;
    }

    // Pas 5
    for(it = 0; it < niter; it++) {
        for(i = 1; i <= M; i++) 
            for(j = 1; j <= N; j++)
                *(pnew + i * (N + 2) + j) = 0.25 * (
                    *(pold + (i - 1) * (N + 2) + j) +
                    *(pold + (i + 1) * (N + 2) + j) +
                    *(pold + i * (N + 2) + (j - 1)) +
                    *(pold + i * (N + 2) + (j + 1)) -
                    *(plim + i * (N + 2) + j));

        // copiaza matricea pnew in pold, 
        // fara copierea valorilor de halo
        for(i = 1; i <= M; i++)
            for(j = 1; j <= N; j++)
                *(pold + i * (N + 2) + j) = *(pnew + i * (N + 2) + j);
    }

    // Pas 7 - Copiere in data fara halouri
    for(i = 0; i < M; i++)
        for(j = 0; j < N; j++)
            *(data + i * N + j) = *(pold + (i + 1) * (N + 2) + (j + 1));

    // Pas 8 - Scriere imagine
    pgm_write("rez_secv.pgm", data, M, N);

    // Eliberare memorie
    free(pold);
    free(pnew);
    free(plim);
    free(data);

    return 0;
}
