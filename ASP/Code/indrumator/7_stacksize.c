#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

// Atributele globale, variab pt toate thread-urile
pthread_attr_t attr;

// Rutina executata de toate thread-urile in afara de
// main.
void* thread_routine(void *threadid) {
    size_t mystacksize;
    pthread_attr_getstacksize(&attr, &mystacksize);
    printf("I am thread %i and my stack is %i bytes\n", 
            *(int*)threadid, mystacksize);
    pthread_exit(NULL);
}

int main(void) {
    int i;
    int ptc;
    size_t stack_size;

    // Main va crea 3 thread-uri
    int n_threads = 3;
    int x[n_threads];
    // Identificatoarele unice ale thread-urilor vor fi
    // stocate intr-un vector
    pthread_t threads[n_threads];

    // Variab atributelor este initializata
    pthread_attr_init(&attr);


    pthread_attr_getstacksize(&attr, &stack_size);

    printf("Initial stack size = %li\n", stack_size);

    stack_size = 1000000;

    // Se stabileste noua dimensiune a stack-ului
    pthread_attr_setstacksize(&attr, stack_size);
    
    for(i=0;i<n_threads;i++) {
        x[i]=i;
        printf("Main: creating thread %i\n", i);
        ptc = pthread_create(&threads[i], &attr,
                            thread_routine,
                            (void*)&x[i]);

        if(ptc!=0) {
            perror("Pthread create error");
            exit(1);
        }
    }
    
    pthread_exit(NULL);
}