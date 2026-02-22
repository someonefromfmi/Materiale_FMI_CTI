#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

void pgm_size (char *filename, int *nx, int *ny);
void pgm_read (char *filename, void *vx, int nx, int ny);
void pgm_write(char *filename, void *vx, int nx, int ny);
