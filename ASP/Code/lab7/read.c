#include <stdio.h>
#include <stdlib.h>

int readmatrix(size_t nrows, size_t ncols, float *m, const char* fname) {
    FILE* fp;
    int i,j;
    fp = fopen(fname, "r");
    if(fp == NULL) return -1;
    for(i=0;i<nrows;i++)
        for(j=0;j<ncols;j++)
            fscanf(fp, "%f", m+i*ncols+j);
    fclose(fp);
    return 0;
}

int readvec(size_t n, float* v, const char* fname) {
    FILE* fp;
    int i;
    fp = fopen(fname, "r");
    if (fp == NULL) return -1;
    for(i=0;i<n;i++) fscanf(fp, "%f", *(v+i));
    fclose(fp);
    return 0;
}