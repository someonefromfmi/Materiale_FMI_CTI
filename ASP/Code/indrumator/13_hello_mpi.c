#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char** argv) {
    // nr de proc din comunicator
    int numprocs;
    // rangul procesului
    int myrank;

    // init MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

    // program
    printf("Eu sunt nodul %i\n", myrank);

    // finalizare MPI
    MPI_Finalize();
    return 0;
}