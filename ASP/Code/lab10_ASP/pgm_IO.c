/*
 * Acest fisier contine functiile C pentru exercitiul MPI de prelucrare a imaginilor in format PGM.
 *
 * "pgm_read" citeste intr-un buffer continutul imaginii PGM si poate fi apelata astfel:
 *
 *    float data[M][N];
 *    pgm_read("image_edge.pgm", data, M, N);
 *
 * "pgm_write" scrie continutul unei matrici M x N intr-un fisier in format PGM si poate fi apelata astfel:
 *
 *    float data[M][N];
 *    pgm_write("picture.pgm", data, M, N);
 *
 * "pgm_size" intoarce dimensiunea (Nx,Ny) a unei imagini in format PGM si poate fi apelata astfel:
 *
 *    int nx, ny;
 *    pgm_size("edge.pgm", &nx, &ny);
 *
 *  Pentru a accesa aceste functii, programul trebuie sa contina clauza:
 *
 *    #include "pgm_IO.h"
 *
 *  Nota: la compilare programul trebuie legat cu biblioteca matematica  (-lm) pentru a utiliza fabs etc.
 */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define MAXLINE 128

/*
 *  Functia de extragere a dimensiunii unui fisier imagine in format PGM 
 *
 *  Se presupune existenta unei singure linii de comentarii si nici un caracter de tip spatiu suplimentar.
 */

void pgm_size(char *filename, int *nx, int *ny)
{ 
  FILE *fp;

  char *cret;		// pentru a absorbi liniile din fisier care contin info nerelevant
  int iret;		// valori de intoarcere ale functiilor apelate

  char dummy[MAXLINE];	// pentru stocarea continutului liniilor din fiser nerelevante 
  int n = MAXLINE;	// lungimea maxima a unei linii din fisier

  if (NULL == (fp = fopen(filename,"r")))
  {
    fprintf(stderr, "pgm_size: nu pot deschide <%s> pentru citire\n", filename);
    exit(-1);
  }

  // sarim peste primele doua linii (formatul si comentariul)
  cret = fgets(dummy, n, fp);
  cret = fgets(dummy, n, fp);
  
  // citim dimensiunea (Nx,Ny) a imaginii PGM
  iret = fscanf(fp,"%d %d", nx, ny);
      
  fclose(fp);
}


/*
 *  Functia de citire a datelor din fisierul PGM intr-o matrice float 
 *  x[nx][ny]. Pentru generalitatea codului si gestionarea corecta a
 *  felului in care C defineste array-uri multi-dimensionale, transmitem 
 *  argumentul ca pointer pe void.
 *
 *  Se presupune existenta unei singure linii de comentarii si nici un caracter de tip spatiu suplimentar.
 */

void pgm_read(char *filename, void *vx, int nx, int ny)
{ 
  FILE *fp;

  int nxt, nyt, i, j, t;
  char dummy[MAXLINE];
  int n = MAXLINE;

  char *cret;
  int iret;

  float *x = (float *) vx;

  if (NULL == (fp = fopen(filename,"r")))
  {
    fprintf(stderr, "pgm_read: nu pot deschide <%s> pentru citire. Ies...\n", filename);
    exit(-1);
  }

  cret = fgets(dummy, n, fp);
  cret = fgets(dummy, n, fp);

  iret = fscanf(fp,"%d %d",&nxt,&nyt);

  if (nx != nxt || ny != nyt)
  {
    fprintf(stderr,
            "pgm_read: diferenta intre dimensiunea fisierului PGM si cea asteptata! Valori actuale: (nx,ny) = (%d,%d), valori asteptate (%d,%d)\n",
            nxt, nyt, nx, ny);
    exit(-1);
  }

  iret = fscanf(fp,"%d",&i);

  /*
   *  Ordinea de stocare a datelor in fisierul imagine nu este cea  
   *  tipica pentru stocarea unei matrici in C; este necesara o operatie aritmetica
   *  cu pointeri pentru a accesa x[i][j].
   */

  for (j=0; j<ny; j++)
  {
    for (i=0; i<nx; i++)
    {
      iret = fscanf(fp,"%d", &t);
      x[(ny-j-1)+ny*i] = t;		// adaptarea continutului fisierului PGM la stilul de stocare C 
    }
  }

  fclose(fp);
}


/*
 *  Functia scrie un fisier imagine PGM plecand de la o matrice 2D 
 *  de valori float x[nx][ny]. Pointerulpe void este transmis pentru a asigura 
 *  generalitatea si felul in care se trateaza in C array-urile multidimensionale.
 */

void pgm_write(char *filename, void *vx, int nx, int ny)
{
  FILE *fp;

  int i, j, k, grey;

  float xmin, xmax, tmp, fval;
  float thresh = 255.0;

  float *x = (float *) vx;

  if (NULL == (fp = fopen(filename,"w")))
  {
    fprintf(stderr, "pgm_write: nu pot crea fisierul PGM <%s>. Ies...\n", filename);
    exit(-1);
  }

  printf("Se scrie imaginea %d x %d in fisierul: %s\n", nx, ny, filename);

  /*
   *  Valorile maxima si minima din matrice
   */

  xmin = fabs(x[0]);
  xmax = fabs(x[0]);

  for (i=0; i < nx*ny; i++)
  {
    if (fabs(x[i]) < xmin) xmin = fabs(x[i]);
    if (fabs(x[i]) > xmax) xmax = fabs(x[i]);
  }

  if (xmin == xmax) xmin = xmax-1.0;

  fprintf(fp, "P2\n");					// numarul magic: format PGM plain
  fprintf(fp, "# Fisier creat de pgm_write()\n");	// comentariu
  fprintf(fp, "%d %d\n", nx, ny);			// dimensiunea imaginii PGM
  fprintf(fp, "%d\n", (int) thresh);			// contrastul

  k = 0;						// pentru aranjarea liniilor in fisierul PGM

  for (j=ny-1; j >=0 ; j--)
  {
    for (i=0; i < nx; i++)
    {
      /*
       *  Accesez valoarea x[i][j]
       */

      tmp = x[j+ny*i];

      /*
       *  Scalez valoarea citita a.i. sa fie in intervalul [0,thresh]
       */

      fval = thresh*((fabs(tmp)-xmin)/(xmax-xmin))+0.5;
      grey = (int) fval;

      fprintf(fp, "%3d ", grey);

      if (0 == (k+1)%16) fprintf(fp, "\n");		// 16 valori pe o linie, pentru usurinta citirii 

      k++;
    }
  }

  if (0 != k%16) fprintf(fp, "\n");
  fclose(fp);
}
