#include <stdlib.h>
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // nr de proc din com
    int numprocs;
    // rangul procesului
    int rank;
    MPI_Status status;
    MPI_Request request;
    int data;

    // initializare MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    request = MPI_REQUEST_NULL;

    // program
    if(rank==0) {
        data = 13;
        MPI_Isend(&data, 1, MPI_INT, 1, 0, MPI_COMM_WORLD,
                    &request);

        // Operatii de calcul
        printf("inainte de MPI_Wait: Nodul %i a trimis %i\n",
                rank, data);
    }

    if(rank==1) {
        MPI_Irecv(&data, 1, MPI_INT, 0, 0, MPI_COMM_WORLD,
                    &request);
    }

    MPI_Wait(&request, &status);

    if(rank==0) {
        printf("dupa MPI_Wait: Nodul %i a trimis %i\n",
                rank, data);
    }

    if(rank==1) {
        printf("dupa MPI_Wait: Nodul %i a primit %i\n",
                rank, data);
    }

    // Finalizare MPI
    MPI_Finalize();

    return 0;
}