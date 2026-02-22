// /* programul calculeaza cu un algoritm dublu adaptativ integrala functiei
//  * log(x)/sqrt(x) pe intervalul [0,1] (singularitate logaritmica
//  * la limita inferioara)
//  */

// #include <stdio.h>
// #include <math.h>
// #include <gsl/gsl_integration.h>

// // functia de integrat
// double f (double x, void * params) 
// {
//     /* biblioteca GSL defineste pentru generalitate toate functiile
//      * de lucru astfel incat sa accepte parametri externi, definiti
//      * ca pointeri pe void; acestia trebuie redefiniti in corpul functiei
//      * pentru a asigura functionalitatea dorita.
//      * In cazul de fata, nu este nevoie de parametri
//      * suplimentari, astfel ca valoarea alpha va fi initializata cu 1
//      * la momentul apelului functiei.
//      */
//     double alpha = *(double *) params;
//     double y = log(alpha*x) / sqrt(x);
//     return y;
// }

// int main (void)
// {
//     // limitele intervalului de integrare
//     double a = 0., b = 1.;
//     // nr. evaluari functionale ale algoritmului gsl_integration_cquad
//     size_t nevals;
//     /*aloc spatiul RAM necesar dezvoltarii algoritmului - aici se aloca
//      * suficient spatiu RAM pentru 1000 subintervale (valori double), valorile
//      * integralelor si estimarilor de eroare corespunzatoare acestor subintervale
//      */
//     gsl_integration_cquad_workspace * w = gsl_integration_cquad_workspace_alloc (1000);
    
//     // rezultatul si eroarea estimata
//     double result, error;
//     /* aici nu includ nici un parametru suplimentar, functia de integrat
//      * este complet definita de valoarea argumentului x.
//      */
//     double alpha = 1.0;

//     //definitia obiectului gsl_function necesar aplicarii algoritmului
//     gsl_function F;
//     F.function = &f;
//     F.params = &alpha;

//     /* integrarea adaptativa cu algoritmul CQUAD;
//      * noile subintervale sunt concentrate in vecinatatea
//      * singularitatii. Subintervalele si rezultatele corespunzatoare
//      * sunt stocate in spatiul de lucru w, eroarea relativa asteptata 
//      * fiind 1e-7
//      */   
//     gsl_integration_cquad (&F, a, b, 0, 1e-7, w, &result, &error, &nevals);
//     printf ("rezultat = % .18f\n", result);
//     printf ("eroare estimata = % .18f\n", error);
//     printf ("intervale = %d\n", w->size);
    
//     gsl_integration_cquad_workspace_free (w);
//     return 0;
// }  
// programul de mai sus calculeaza secvential integrala de la 0 la 1 a functiei f definita

// cerinta: transforma programul de mai sus intr-un program MPI care 
// sa asigure urmatoarea functionalitate:
// - vor fi lansate in executie nproc procese, procesul cu rangul 0(master) definid valorile a si b
// distribuind initial o partitie uniforma a intervalului d eintegrare

// - o solutie posibila ar fi ca fiecare proces sa defineasca un sir double llims[2] in care
// sa receptioneze limitele intervalului de integrare de la procesul cu rang 0

// - partitia initiala va fi: procesul cu rangul 0 trateaza primul interval si asa mai departe

// - toate procesele vor defini suplimentar variabilele double local_result, local_error care vor stoca rezultatul
// si eroarea estimata pt calculul local

// - in partea secventiala va fi aplicat algoritmul de integrare exact ca in programul secvential, insa valorile calculate vor fi stocate in local_result si local_error

// - valorile locale vor fi acumulate de procesul cu rangul 0 in variabilele result si error(foloseste MPI_Reduce)

// - procesul cu rangul 0 scrie in fisier text rezultatul finalsi estimarea marginii superioare a erorii
 // codul mai jos:

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
#include <gsl/gsl_integration.h>

double f(double x, void *params) {
    double alpha = *(double *)params;
    return log(alpha * x) / sqrt(x);
}

void printResult(double result, double error) {
    printf("Result = %.18f\n", result);
    printf("Estimated error = %.18f\n", error);
}

void writeResultToFile(double result, double error) {
    FILE *file = fopen("data2.txt", "w");
    if (file == NULL) {
        perror("Error opening file");
        exit(EXIT_FAILURE);
    }
    fprintf(file, "Result = %.18f\n", result);
    fprintf(file, "Estimated error = %.18f\n", error);
    fclose(file);
}

int main(int argc, char *argv[]) {
    int rank, size;
    double a = 0.0, b = 1.0;
    size_t nevals;
    double alpha = 1.0;
    double result, error;

    gsl_integration_cquad_workspace *w = gsl_integration_cquad_workspace_alloc(1000);
    gsl_function F;
    F.function = &f;
    F.params = &alpha;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size < 2) {
        fprintf(stderr, "This program requires at least two processes.\n");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }

    double subinterval = (b - a) / size;
    double local_a = a + rank * subinterval;
    double local_b = local_a + subinterval;

    gsl_integration_cquad(&F, local_a, local_b, 0, 1e-7, w, &result, &error, &nevals);

    double local_result = result;
    double local_error = error;

    MPI_Reduce(&local_result, &result, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
    MPI_Reduce(&local_error, &error, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    gsl_integration_cquad_workspace_free(w);

    if (rank == 0) {
        printResult(result, error);
        writeResultToFile(result, error);
    }

    MPI_Finalize();
    return 0;
}