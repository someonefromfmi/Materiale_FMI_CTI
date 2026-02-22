/* 
 * Programul integreaza f(x) = log(1+x*x )*Gamma(x) pe intervalul [a,b] prin metoda trapezelor. 
 * Intervalul [a,b] se imparte in N subintervale (x_i,x_(i+1)), de lungime h=(b-a)/N.
 * Valoarea aproximativa a integralei este:
 *             /            
 *         I = | f(x)dx = sum_i {( f(x_i)+f(x_(i+1)) ) * h/2} 
 *             /          
 *  
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_sf_gamma.h>


#define N 10000


// functia de integrat
double f(double x)
{
  return log(1+x*x) * gsl_sf_gamma(x);
}

// functia care calculeaza efectiv integrala
double int_T(double a, double b, long Nm)
{
  double h=(b-a)/((double) Nm),				
         Iab = 0.;                     /* valoarea integralei */
  long i;	     		
  
  for(i=0; i < Nm+1; i++)
  {
    double x1 = a + i*h,		/* valoarea x_i */
           x2 = a + (i+1)*h;		/* valoarea x_(i+1) */
    Iab += (f(x1) + f(x2));
  }//end-of-for(i<Nm)
  
  Iab = Iab * h/2.;
  return Iab;
} //end-of-int_T()


int main ()
{
  double a, b;			/* limitele domeniului de integrare */
  
  double IT;
  
  // initializare
  a = 0.1; b = 2.5; 		/* domeniul de integrare si limita superioara a */

  IT = int_T(a,b,N);
  printf("******** Integrarea numerica prin metoda trapezelor ********\n");
  printf(" Integrala functiei f(x) = log(1+x^2)*Gamma(x), pe [%.2lf,%.2lf]: %.8lf\n\n",a,b,IT);
  return 0;
} //end-of-main()

