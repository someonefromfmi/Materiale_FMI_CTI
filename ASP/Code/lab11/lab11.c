#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <sys/types.h>
#define MASTER 0

double f(double t, int x, int y) {
    return pow(t, x - 1) * pow(1 - t, y - 1);
}

int main(int argc, char** argv) {
    int nproc, my_rank, i, xyn[3];
    double val, xi, dx;
    MPI_Comm comm = MPI_COMM_WORLD;
    MPI_Win val_win, in_data_win;
    FILE* fp;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(comm, &my_rank);
    MPI_Comm_size(comm, &nproc);

    if(my_rank == MASTER) {
        fp = fopen("data.in","r");
        char* line;
        size_t len, count = 1;
        ssize_t read;
        while((read = getline(&line, &len, fp)) != -1) {
            if(count == 1)
                sscanf(line, "%d %d", xyn, xyn + 1);
            else 
                sscanf(line, "%d", xyn + 2);
            count++;
        }
        fclose(fp); fp = NULL;
       
        MPI_Win_create(xyn, 3 * sizeof(int), sizeof(int), MPI_INFO_NULL, comm, &in_data_win);
        MPI_Win_create(&val, sizeof(double), sizeof(double), MPI_INFO_NULL, comm, &val_win);
    } else { // not master
        MPI_Win_create(MPI_BOTTOM, 0, 1, MPI_INFO_NULL, comm, &in_data_win);
        MPI_Win_create(MPI_BOTTOM, 0, 1, MPI_INFO_NULL, comm, &val_win);
    }

    MPI_Win_fence(0, in_data_win); // sincronizare globala, incep sesiunea RMA
    MPI_Get(xyn, 3, MPI_INT, MASTER, 0, 3, MPI_INT, in_data_win);
    MPI_Win_fence(0, in_data_win); // termin sesiunea RMA la xyn pe master
    dx = 1. /(double) xyn[2];
    val = 0;
    for(i = my_rank; i < xyn[2]; i+=nproc) {
        xi = dx * ((double)i + 0.5);
        val += f(xi, xyn[0], xyn[1]);
    }

    MPI_Win_fence(0, val_win);
    MPI_Accumulate(&val, 1, MPI_DOUBLE, MASTER, 0, 1, MPI_DOUBLE, MPI_SUM, val_win);
    MPI_Win_fence(0, val_win);

    if(my_rank == MASTER) {
        val = val * dx;
        fp=fopen("data.out", "w");
        fprintf(fp, "B(2, 3) = %.8lf\n\n", val);
        fclose(fp); fp = NULL;
    }

    MPI_Win_free(&in_data_win);
    MPI_Win_free(&val_win);
    MPI_Finalize();

    return MPI_SUCCESS;
}