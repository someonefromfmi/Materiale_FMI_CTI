#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>


int main(void) {
    int i, status;
    // PID-ul unui proc copil va fi 0 iar val '1' este
    // folosita pt a indica proc parinte.
    pid_t my_pid = 1;

    // Bucla pt initializarea a 3 proc copil
    for(i = 0; i < 3; i++) {
        // Proc parinte va fi singurul cu var 
        // my_pid nenula.
        if(my_pid != 0) {
            // In caz de succes functia fork() va
            // intoarce val PID a proc nou creat
            // (proc copil). Daca fc fork intoarce
            // val -1, acest lucru indica o err
            // aparuta la pornirea noului proc.
            if((my_pid = fork()) < 0) {
                perror("Fork error\n");
                exit(1);
            }
        }
    }

    // Se vor afisa: val curr intoarsa de fork(), 
    // PID-ul proc curr cu ajutorul fc getpid() si
    // PID-ul parintelui poc curr cu ajutorul functiei
    // getppid().
    printf("my_pid=%i, getpid=%i, getppid=%i\n",
            my_pid, getpid(), getppid());

    // Proc parinte va fi singurul cu var my_pid nenula
    if(my_pid != 0) {
        for(i=0;i<3;i++) {
            // Ca in cazul fc fork(), in caz de succes
            // fc wait() va intoarce val PID-ului proc
            // nou creat sau -1 in caz de esec.
            if(wait(&status) < 0) perror("Wait error");
            _exit(1);
        }
    }

    return 0;
}