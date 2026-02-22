#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

// Rutina executata de toate thread-urile in afara de
// main.
void* thread_routine(void *threadid) {
    sleep(2);
    printf("I am thread %i\n", *(int*)threadid);
    pthread_exit(NULL);
}

int main(void) {
    int i;
    void* status;

    // Main va crea 3 thread-uri
    int n_threads = 3;

    int x[n_threads];
    // Iddentificatoarele unice ale thread-urilor vor fi
    // stocate intr-un vector
    pthread_t threads[n_threads];

    // Variab care stocheaza atributele thread-ului
    pthread_attr_t attr;

    int ptc, ptj;

    // Variab atributelor este initializata
    pthread_attr_init(&attr);

    // Este setat atributul 'joinable' care permite 
    // thread-ului unirea ulterioara prin fc
    // pthread_join(). Acest lucru se face mai mult pt
    // siguranta, deoarece thread-urile sunt in mod
    // explicit 'joinable'.
    pthread_attr_setdetachstate(&attr,
                                PTHREAD_CREATE_JOINABLE);
    
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

    // Variabila atributelor este eliberata
    pthread_attr_destroy(&attr);

    for(i=0;i<n_threads;i++) {
        // Thread-ul curent (adica 'main()') asteapta
        // thread-urile din sirul thread[t] sa se
        // incheie
        ptj = pthread_join(threads[i], &status);
        if(ptj!=0) {
            perror("Pthread join error\n");
            exit(1);
        }
    }

    pthread_exit(NULL);
}