#ifndef CALC
#define CALC
#include <mpi.h>

/*******************************************************
 * Nume functie: numerator()
 * Rol: Calculeaza numaratorul formulei cu ajutorul unui grup
 * Intrare: A - matricea
 *          x,y - vectorii
 *          size - lungimea vectorilor
 *          comm - comunicatorul folosit
 * Iesire: numaratorul fractiei
 ********************************************************/
float numerator(float** A, float* x, float* y, int size, MPI_Comm comm);

/*******************************************************
 * Nume functie: denominator()
 * Rol: Calculeaza numitorul formulei cu ajutorul unui grup
 * Intrare: A - matricea
 *          x,y - vectorii
 *          size - lungimea vectorilor
 *          comm - comunicatorul folosit
 * Iesire: numitorul fractiei
 ********************************************************/
float denominator(float* x, float* y, int size, MPI_Comm comm);

#endif