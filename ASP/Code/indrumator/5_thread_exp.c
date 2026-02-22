#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

// Rutina executata de toate thread-urile in afara de 
// main
void *thread_routine(void *threadid) {
    sleep(2);
    printf("I am thread no. %i\n", *(int*)threadid);
    pthread_exit(NULL);
}

int main (void) {
    int i; // sau long i ---> periculos

    // Main va crea 3 thread-uri.
    int n_threads = 3;
    int x[n_threads];

    // Identificatoarele unice ale thread-urilor vor fi
    // stocate intr-un vector
    pthread_t threads[n_threads];

    int ptc;

    for(i=0;i<n_threads;i++) {
        x[i] = i;
        printf("Main: creating thread no. %i\n", i);
        ptc = pthread_create(&threads[i], NULL,
                            thread_routine, (void*)&x[i]);
        if(ptc!=0) {
            perror("Pthread create error");
            exit(1);
        }
    }

    pthread_exit(NULL);
}