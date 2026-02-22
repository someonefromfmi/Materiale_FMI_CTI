/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
Programul demonstreaza scrierea in paralel intr - un fisier , cu
ajutorul functiilor MPI .
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mpi.h"

#define DATASIZE 25

int main(int argc, char** argv) {
    int myRank;
    int i;

    float* data;
    char fname[32];
    MPI_File fh;
    MPI_Offset offset;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

    strcpy(fname, "datafile.dat");

    data = (float*) malloc(DATASIZE*sizeof(float));
    for(i=0; i< DATASIZE; i++) {
        *(data + i) = ((float)(myRank + 1))/DATASIZE + i;
    }

    
}