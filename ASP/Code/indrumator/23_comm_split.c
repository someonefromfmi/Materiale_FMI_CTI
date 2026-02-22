/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *
Programul demonstreaza modul de creare a unui set de n
comunicatori cu utilizarea functiei MPI_Comm_split () .
Forma actuala presupune ca numarul de procese lansate in
executie este np = n * n . Dupa crearea noilor comunicatori
se executa o operatie colectiva de transmitere de date .
Cod adaptat dupa P . Pacheco , " Parallel Programming with
MPI " np = n * n procese distribuite pe un grid de n x n
noduri
* Exemplu (n = 2):
* ---------
* linia 0 | 0 | 1 |
* ---------
* linia 1 | 2 | 3 |
* ---------
Se defineste un comunicator pentru fiecare linie , adica
pentru procesele {0 ,1} si {2 ,3} , pentru a facilita
comunicarea directa intre ele .
* * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <stdio.h>
#include <math.h>
#include <string.h>
#include "mpi.h"

int main(int argc, char** argv) {
    int nProc, myRank;
    MPI_Comm my_row_comm; // comunicatorul coresp unei
    // linii in topografia nodurilor de calcul

    int my_row, my_rank_in_row; // linia si rangul unui
    // proces intr-o linie

    int n; // variabila interna; n*n = nProc
    char test[32]; // variab interan, pt op colective

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nProc);
    MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

    // programul presupune o topologie 2 D n x n a nodurilor
    // de calcul pe care sunt distribuite cele nProc
    // procese lansate in executie determinam numarul de
    // linii n
    n = (int) sqrt((double)nProc);
    
    // nr liniei corespunzatoare procesului curent este
    // stocat in my_row
    my_row = myRank/n;

    MPI_Comm_split(MPI_COMM_WORLD, my_row, myRank,
                    &my_row_comm);

    // si testam noii comunicatori; mai intai, aflam 
    // noile ranguri ale proceselor
    MPI_Comm_rank(my_row_comm, &my_rank_in_row);

    // procesele cu rang 0 in fiecare linie definesc
    // stringul test
    if(my_rank_in_row == 0) strcpy(test, "Test reusit!");
    
    // si il transmitem colectiv tuturor proceselor din
    // noii comunicatori
    MPI_Bcast(test, 32, MPI_CHAR, 0, my_row_comm);

    // si verif rezultatul (cu scop exclusiv demonstrativ!)
    printf("Procesul cu rangul initial %d: linia = %d, noul\
            rang = %d, stringul test = %s\n", myRank, my_row,
            my_rank_in_row, test);

    MPI_Finalize(); // terminam sesiunea MPI

    return 0;
}