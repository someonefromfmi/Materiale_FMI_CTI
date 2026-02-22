#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>

int main ( void )
{
// Argumentele pentru exec .
char * args [4] = { " / bin / ls " , " -l " , " . " , NULL } ;
pid_t my_pid ;
int status ;
// Pornirea procesului copil .
my_pid = fork () ;
// Conditie valabila in cazul procesului copil .
if ( my_pid == 0)
{
// Executa comanda indicata in lista de argumente args .
execv ( args [0] , args ) ;
// Iar in cazul folosirii functiei execl () :
// execl ("/ bin / ls " ,"/ bin / ls " , " - l " , "." , NULL ) ;
// In momentul apelului exec , procesul curent este inlocuit
// de noul proces . Daca ajunge in acest punct inseamna ca
// a avut loc o eroare .
perror ( " Execve error " ) ;
}
// Conditie valabila in cazul procesului parinte .
else if ( my_pid > 0)
{
if ( ( my_pid = wait (& status ) ) < 0)
{
    perror ( " Wait error " ) ;
    exit (1) ;
    }
    }
    else
    {
    perror ( " Fork error " ) ;
    _exit (1) ;
    }
    return 0;
    } 