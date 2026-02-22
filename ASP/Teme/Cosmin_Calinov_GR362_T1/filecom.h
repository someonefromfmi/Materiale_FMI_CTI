#include <mpi.h>
#ifndef MASTER
#define MASTER 0

/*******************************************************
 * Nume functie: readVector()
 * Rol: Citeste datele vectorului din fisier
 * Intrare: filename - numele fisierului din care se va citi
 *          size - dimensiunea vectorului
 *          comm - comunicatorul folosit
 * Iesire: Vectorul de valori float parsat din fisier
 ********************************************************/
float* readVector(const char* filename, int size, MPI_Comm comm);

/*******************************************************
 * Nume functie: readMatrix()
 * Rol: Citeste datele matricii din fisier
 * Intrare: filename - numele fisierului din care se va citi
 *          size - dimensiunea matricii
 *          comm - comunicatorul folosit
 * Iesire: Matricea de valori float parsata din fisier
 ********************************************************/
float** readMatrix(const char* filename, int size, MPI_Comm comm);

/*******************************************************
 * Nume functie: writeResult()
 * Rol: Citeste datele matricii din fisier
 * Intrare: filename - numele fisierului in care se va scrie
 *          res - rezultatul scris in fisier
 *          comm - comunicatorul folosit
 * Iesire: -
 ********************************************************/
void writeResult(const char* filename, float res, MPI_Comm comm);

#endif