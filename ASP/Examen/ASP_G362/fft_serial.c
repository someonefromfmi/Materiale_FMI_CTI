/*
 * Definitia TF directe:
 * x_j = sum_0^(n-1) (z_k exp(-2*pi*i*j*k/n))
 * si inverse:
 * z_j = 1/n * sum_0^(n-1) (x_k exp(2*pi*i*j*k/n))
 * nproc trebuie sa fe divizor al lui N
 */
#include <stdio.h>
#include <math.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_fft_real.h>
#include <gsl/gsl_fft_halfcomplex.h>

#define N 256
#define FILTER 80

int main (void)
{
int i;
double data[N], dummy;

//fisierele de lucru; in varianta MPI doar procesul 0 face
//operatii I/O
char *input_file = "input_data.dat";
char *output_file = "filtered_data_serial.dat";
FILE *fp;

gsl_fft_real_wavetable * real;
gsl_fft_halfcomplex_wavetable * hc;
gsl_fft_real_workspace * work;

fp = fopen (input_file, "r");

  for (i = 0; i < N; i++)
   {
     fscanf (fp, "%lg\t%lg", &dummy,&data[i]);
   }
   fclose (fp); fp = NULL;
  

//transformata Fourier directa
work = gsl_fft_real_workspace_alloc (N);
real = gsl_fft_real_wavetable_alloc (N);
gsl_fft_real_transform (data, 1, N, real, work);
gsl_fft_real_wavetable_free (real);

//filtrez componentele Fourier de frecvență mai mare decât FILTER
for (i = FILTER; i < N; i++)
{
    data[i] = 0;
}

//transformata inversa
hc = gsl_fft_halfcomplex_wavetable_alloc (N);
gsl_fft_halfcomplex_inverse (data, 1, N, hc, work);
gsl_fft_halfcomplex_wavetable_free (hc);

fp = fopen(output_file,"w");
for (i = 0; i < N; i++)
{
    fprintf (fp,"%d\t%e\n", i, data[i]);
}
fclose(fp); fp = NULL;

gsl_fft_real_workspace_free (work);
return 0;
}
