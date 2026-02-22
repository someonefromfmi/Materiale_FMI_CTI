#include <mpi.h>
#include "pgm_IO.h"
#include "pgm_IO.c"

#define MASTER 0

int main(int argc, char* argv[]) {
    int myrank, nproc;
    int i, j;
    int NX, NY;
    int dims[NDIM];
    int GSIZE = XSIZE * YSIZE;
    int reorder = 0;
    int periods[NDIM] = {TRUE, TRUE};
    int dX, dY, localSize;
    int coords[NDIM];
    int up, down, left, right;
    int nvec;
    char* fname;

    float *masterdata, *data, *data_next;

    MPI_Comm wcomm = MPI_COMM_WORLD, comm_2D;
    MPI_Comm comm = MPI_COMM_WORLD;
    MPI_Status status;
    MPI_Datatype blockType;
    MPI_Datatype colType;
    MPI_Datatype lineType;
    MPI_Datatype recvBlockType;
    MPI_Datatype sendBlockType;
    int niter;
    niter = 20;
    for (i=0; i<NDIM; i++) dims[i] = 0; 

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

    MPI_Dims_create(nproc, NDIM, dims);
    MPI_Cart_create(wcomm, NDIM, dims, periods, reorder, &comm_2D);
    MPI_Cart_coords(comm_2D, myrank, NDIM, coords);

    NX = dims[0]; NY = dims[1];
    dX = (XSIZE / NX) + 2;
    dY = (YSIZE / NY) + 2;
    
    if (myrank == MASTER) {
        masterdata = (float*)malloc(XSIZE * YSIZE * sizeof(float));
        for (i=0; i<XSIZE*YSIZE; i++) *(masterdata+i) = 0.75 * CONTRAST;
    }

    data = (float*)malloc(dX * dY * sizeof(float));
    data_next = (float*)malloc(dX * dY * sizeof(float));
    for (i=0; i<dX*dY; i++) *(data+i) = 0.75 * CONTRAST;

    int x = coords[0], y = coords[1];

    if ((x+y+1)%2 == 1) for (i=0; i<dX*dY; i++) *(data+i) = 0;
    else for (i=0; i<dX*dY; i++) *(data+i) = CONTRAST;

    MPI_Type_vector(dX - 2, dY - 2, YSIZE, MPI_FLOAT, &recvBlockType);
    MPI_Type_commit(&recvBlockType);

    MPI_Type_vector(dX - 2, dY - 2, YSIZE, MPI_FLOAT, &sendBlockType);
    MPI_Type_commit(&sendBlockType);

    MPI_Type_vector(dY, dX, XSIZE, MPI_FLOAT, &blockType);
    MPI_Type_commit(&blockType);
    
    MPI_Type_vector(dY, 1, dX, MPI_FLOAT, &colType);
    MPI_Type_commit(&colType);
    MPI_Type_vector(1, dX, 1, MPI_FLOAT, &lineType);
    MPI_Type_commit(&lineType);

    MPI_Cart_shift(comm_2D, 0, 1, &up, &down);
    MPI_Cart_shift(comm_2D, 1, 1, &left, &right);

    // MPI_Sendrecv(data + dX + 1, 1, lineType, up, 123, data + dX * (dY - 1) + 1, 1, lineType, down, 123, comm_2D, &status);
    // MPI_Sendrecv(data + dX*(dY-2) + 1, 1, lineType, down, 123, data + 1, 1, lineType, up, 123, comm_2D, &status);
    // MPI_Sendrecv(data + dX - 1, 1, colType, right, 123, data, 1, colType, left, 123, comm_2D, &status);
    // MPI_Sendrecv(data + 1, 1, colType, left, 123, data + dX - 1, 1, colType, right, 123, comm_2D, &status);

    if(coords[0] == NX/2) {
        for(i=0;i<dX; i++)
            for(j=0;j<dY;j++)
                if(i == dX/2)
                    *(data + i * dY + j) = *(data_next + i * dY +j ) = 0;
                else 
                    *(data + i *dY + j) = *(data_next + i * dY + j) = CONTRAST;
    } else {
        if (coords[1] = NY/2) {
            for(i = 0; i<dX; i++) 
                for(j=0;j<dY;j++)
                    if(j==dY/2)
                        *(data + i * dY + j) = *(data_next + i*dY + j) = 0;
                    else 
                        *(data + i * dY + j) = *(data_next + i * dY + j) = CONTRAST;
        } else {
            for(i=0;i<dX;i++) 
                for(j=0; j<dY; j++) 
                    *(data + i * dY + j) = *(data_next + i * dY + j) = CONTRAST;
        }
    }

    // if (myrank == MASTER) {
    //     for (i=0; i<dY; i++) {
    //         for (j=0; j<dX; j++) {
    //             *(masterdata+i*XSIZE+j) = *(data+i*dX+j);
    //         }
    //     }
    // }

    for(int crs=1; crs<=niter; crs++) {
        MPI_Sendrecv(data + dX + 1, 1, lineType, up, 123, data + dX * (dY - 1) + 1, 1, lineType, down, 123, comm_2D, &status);
        MPI_Sendrecv(data + dX*(dY-2) + 1, 1, lineType, down, 123, data + 1, 1, lineType, up, 123, comm_2D, &status);
        MPI_Sendrecv(data + dX - 1, 1, colType, right, 123, data, 1, colType, left, 123, comm_2D, &status);
        MPI_Sendrecv(data + 1, 1, colType, left, 123, data + dX - 1, 1, colType, right, 123, comm_2D, &status);
        
        for(int i = 1; i < dY + 1; i++) {
            for(int j = 1; j < dX + 1; j++) {
                nvec = 0;
                if(*(data + (i-1)*dX + (j-1)) == 0) nvec++;
                if(*(data + (i-1)*dX + j) == 0) nvec++;
                if(*(data + (i-1)*dX + j + 1) == 0) nvec++;
                if(*(data + i*dX + j - 1) == 0) nvec++;
                if(*(data + i*dX + j + 1) == 0) nvec++;
                if(*(data + (i+1)*dX + j-1) == 0) nvec++;
                if(*(data + (i+1)*dX + j) == 0) nvec++;
                if(*(data + (i+1)*dX + j+1) == 0) nvec++;
            }
        }
        
        if(nvec < 2 && data[i] == 0)
            data_next[i] = 255;
        else if(nvec == 2) 
            data_next[i] = data[i];
        else if(nvec >= 3 && nvec <= 7 && data[i] == 0)
            data_next[i] = 0;
        else if(nvec > 7 && data[i] == 255)
            data_next[i] = 0;

        for(int i = 1; i < dY + 1; i++) 
            for(int j = 1; j < dX + 1; j++)
                *(data + i*dX + j) = *(data_next + i*dX + j);

        if((crs + 1) % 2) {
            if(myrank == 0) {
                sprintf(fname, "%s_%d_iter.txt", "poza", crs);
                //strcpy(fname, )
            }
            }
        }
    }

    if (myrank != MASTER) { // not master
        MPI_Send(data, dX*dY, MPI_FLOAT, MASTER, 1, comm_2D);
    } else { // master
        for (i=1; i<nproc; i++) {
            MPI_Cart_coords(comm_2D, i, NDIM, coords);
            x = coords[0];
            y = coords[1];
            MPI_Recv((masterdata + x * (dX-2) + y * (dY-2) * XSIZE), 1, blockType, i, 1, comm_2D, &status);
        }   
        pgm_write("output.pgm", masterdata, XSIZE, YSIZE);
        free(masterdata);
    }

    

    free(data);
    free(data_next);
    MPI_Finalize();
    return MPI_SUCCESS;

}