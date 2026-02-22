#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pgm_IO.h"
#include "pgm_IO.c"
#include <mpi.h>

#define MASTER 0

int main(int argc, char** argv) {
    int M, N;
    int nproc, myrank;
    int niter = 1000;
    int i, j, it;
    float *data, *pold, *pnew, *plim, *masterdata;
    MPI_Status status;

    // Initializare MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

    // citire dimensiuni imagini
    if(myrank == MASTER)
        pgm_size("image_640x480.pgm", &M, &N);

    // trimite dimensiunile de la master catre celelalte
    // procese
    MPI_Bcast(&M, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(&N, 1, MPI_INT, 0, MPI_COMM_WORLD);

    // divizarea imaginii intre porcese de-a lungul
    // liniilor de pixeli
    int MP = M / nproc;
    int NP = N;

    // Alocare memorie
    data = (float*)malloc(MP * NP * sizeof(float));
    pold = (float*)malloc((MP + 2) * (NP + 2) * sizeof(float));
    pnew = (float*)malloc((MP + 2) * (NP + 2) * sizeof(float));
    plim = (float*)malloc((MP + 2) * (NP + 2) * sizeof(float));

    for(i = 0; i < (MP + 2) * (NP + 2); i++) {
        *(pold + i) = 255;
        *(pnew + i) = 255;
        *(plim + i) = 255;
    }

    // citirea datelor din imagine in masterdata
    if(myrank == MASTER) {
        masterdata = (float*) malloc(M * N * sizeof(float));
        pgm_read("image_640x480.pgm", (void*)masterdata, M, N);
    }

    // distribuirea segmentelor de date MP * NP din
    // masterdata catre toate procesele
    MPI_Scatter(masterdata, MP * NP, MPI_FLOAT, data, MP * NP, MPI_FLOAT, 0, MPI_COMM_WORLD);

    // Copiere date in plim
    for(i = 1; i <= MP; i++)
        for(j = 1; j <= NP; j++)
            *(plim + i * (NP + 2) + j) = *(data + (i - 1) * NP + (j - 1));
 
    for(it = 0; it < niter; it++) {
        if(myrank != MASTER) {
            // receptioneaza NP elemente de la procesul cu rank - 1
            // trimite NP elemente catre procesul cu rank - 1
            MPI_Sendrecv(pold + (NP + 2) + 1, NP, MPI_FLOAT, myrank - 1, 0,
                         pold + 1, NP, MPI_FLOAT, myrank - 1, 1, MPI_COMM_WORLD, 
                         &status);
        }
        
        if(myrank != nproc - 1) {
            // trimite NP elemente catre procesul cu rank + 1
            // receptioneaza NP elemente de la procesul cu rank + 1
            MPI_Sendrecv(pold + (MP * (NP + 2) + 1), NP, MPI_FLOAT, myrank + 1, 1,
                         pold + ((MP + 1) * (NP + 2) + 1), NP, MPI_FLOAT, myrank + 1, 0,
                         MPI_COMM_WORLD, &status);
        }

        // reconstructie
        for(i = 1; i <= MP; i++) 
            for(j = 1; j <= NP; j++)
                *(pnew + i * (NP + 2) + j) = 0.25 * (
                    *(pold + (i - 1) * (NP + 2) + j) +
                    *(pold + (i + 1) * (NP + 2) + j) +
                    *(pold + i * (NP + 2) + (j - 1)) +
                    *(pold + i * (NP + 2) + (j + 1)) -
                    *(plim + i * (NP + 2) + j));

        for(i = 1; i < MP + 2; i++)
            for(j = 1; j < NP + 2; j++)
                *(pold + i * (NP + 2) + j) = *(pnew + i * (NP + 2) + j);
    }

    // Copiere in data fara halouri
    for(i = 0; i < MP; i++)
        for(j = 0; j < NP; j++)
            *(data + i * NP + j) = *(pold + (i + 1) * (NP + 2) + (j + 1));

    // adunarea matricilor locale in masterdata
    MPI_Gather(data, MP * NP, MPI_FLOAT, masterdata, MP * NP, MPI_FLOAT, 0, MPI_COMM_WORLD);

    // scrierea datelor din masterdata in fisierul grafic
    if(myrank == MASTER) {
        pgm_write("rez_paralel.pgm", masterdata, M, N);
        // Eliberare masterdata
        free(masterdata);
    }

    // Eliberare memorie
    free(pold);
    free(pnew);
    free(plim);
    free(data);

    // Finalizare MPI
    MPI_Finalize();

    return 0;
}
