#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#define MASTER 0

int main(int argc, char *argv[]) {
    int rank, nproc;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);

    if (nproc < 2) {
        fprintf(stderr, "This program requires at least two processes.\n");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }

    int senddata[10];
    int recvdata[10];

    senddata[0] = rank;
    recvdata[0] = 0;

    for(int i = 1; i < 10; i++) {
        senddata[i] = senddata[i - 1] + 1;
        recvdata[i] = 0;
    }

    if (rank == MASTER) {
        MPI_Sendrecv(
            senddata, 10, MPI_INT, 
            rank + 1, 0,
            recvdata, 10, MPI_INT, 
            nproc - 1, 0,
            MPI_COMM_WORLD, MPI_STATUS_IGNORE
        );
    } else if (rank == nproc - 1) {
        MPI_Sendrecv(
            senddata, 10, MPI_INT, 
            MASTER, 0,
            recvdata, 10, MPI_INT, 
            rank - 1, 0,
            MPI_COMM_WORLD, MPI_STATUS_IGNORE
        );
    } else {
        MPI_Sendrecv(
            senddata, 10, MPI_INT, 
            rank + 1, 0,
            recvdata, 10, MPI_INT, 
            rank - 1, 0,
            MPI_COMM_WORLD, MPI_STATUS_IGNORE
        );
    }

    if(rank == MASTER) {
        printf("Send data\n");
        for(int i = 0; i < 10; i++) {
            printf("%d ", senddata[i]);
        }
        printf("\n");
        printf("Recv data\n");
        for(int i = 0; i < 10; i++) {
            printf("%d ", recvdata[i]);
        }
        printf("\n");
    }   

    MPI_Finalize();
    return 0;
}