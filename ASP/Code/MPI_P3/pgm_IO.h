#ifndef _PGMIO_H_
#define _PGMIO_H_

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

/* pentru localizarea definitiilor de periodicitate a topologiei carteziene virtuale */
#define TRUE 1
#define FALSE 0

/* numarul de dimensiuni al retelei virtuale asociate proceselor lansate in executie */
#define NDIM 2

/* procesul master este procesul de rang 0 */
#define MASTER 0

/************************************************************************************************ 
 * dimensiunea blocului de construit este XSIZE x YSIZE                                         *
 * ATENTIE: numarul de procesoare pe fiecare directie trebuie sa fie divizor al XSIZE si YSIZE! *
 ************************************************************************************************/ 
 
#define XSIZE 128
#define YSIZE 128

/* valoarea maxima a contrastului
 * 0 - pixelul este negru
 * CONTRAST - pixelul este alb
 * valoare intermediara - pixelul este gri
 */
#define CONTRAST 255

/* structura utilizata pentru a defini tipul de date derivat
 * corespunzator valorilor din regiunile halo
 */
typedef struct _VTYPE_ {
  int X;
  int Y;
} VType;

/* functii de acces al datelor din fisiere grafice PGM */
void pgm_size (char *filename, int *nx, int *ny);
void pgm_read (char *filename, void *vx, int nx, int ny);
void pgm_write(char *filename, void *vx, int nx, int ny);

/* nu se adauga nimic sub aceasta linie */
#endif
