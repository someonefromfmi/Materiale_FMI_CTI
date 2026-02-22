/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Programul demonstreaza operatia de citire paralela ,
cu un numar arbitrar de procese
* * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

int main(int argc, char** argv) {
    int myRank, nProc;
    int dataSize, dataElements; // variab interne
    float* data; // adresa RAM unde sunt stocate datele

    MPI_File fh; // descriptorul  de fisier
    MPI_Status status; // pt starea operatiei

    MPI_Offset fileSize; // pastreaza dimensiunea fisierului
    char fname[32]; // pastreaza numele fisierului

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &myRank);
    MPI_Comm_size(MPI_COMM_WORLD, &nProc);

    strcpy(fname, "ftest1.dat");

    MPI_File_open(MPI_COMM_WORLD, fname, MPI_MODE_RDONLY,
                    MPI_INFO_NULL, &fh);

    MPI_File_get_size(fh, &fileSize);

    // nr total de valori float de citit, pt fiecare
    // proces
    dataSize = fileSize / sizeof(float) / nProc + 1;

    // alocam spatiul necesar in memorie libera, pt
    // cele dataSize valori float

    data = (float*) malloc(dataSize*sizeof(float));

    // pozitionam in locul corect pointerii de fisier
    // individuali
    MPI_File_set_view(fh, myRank*dataSize*sizeof(float),
                        MPI_FLOAT, MPI_FLOAT, "native",
                         MPI_INFO_NULL);

    // ...si citim datele, in numar de dataSize
    MPI_File_read(fh, data, dataSize, MPI_FLOAT, &status);

    // aflam nr de elem primit de fiecare proces
    MPI_Get_count(&status, MPI_FLOAT, &dataElements);

    printf("Procseul %a citit %d valori reale, prima fiind: %.2f\n",
            myRank, dataElements, *data);

    MPI_File_close(&fh);
    MPI_Finalize();

    free(data);
    data = NULL;

    return 0;
}