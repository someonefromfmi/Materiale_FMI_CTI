#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

typedef struct {
    char* message;
    int id;
    int *val;
} my_struct;

pthread_mutex_t my_mutex;

// Rutina executata de toate thread-urile in afara de
// main.

void* thread_routine(void* thr_str) {
    // Daca mutex-ul este deblocat, thread-ul preia
    // controlul asupra lui.
    pthread_mutex_lock(&my_mutex);

    printf("%s %i and my value is %i\n",
        (*(my_struct*)thr_str).message,
        (*(my_struct*)thr_str).id,
        *(*(my_struct*)thr_str).val);

    // Thread-ul intcrementeaza val var x (definita in
    // fc main).
    (*(*(my_struct*)thr_str).val)++;

    // Thread-ul deblocheaza mutex-ul
    pthread_mutex_unlock(&my_mutex);
    pthread_exit(NULL);
}

int main(void) {
    int i, x=0;

    // Main va crea 3 thread-uri
    int n_threads=3;

    int ptc, ptj;
    pthread_attr_t attr;
    void* status;

    // Mesajul afisat de thread-uri
    char my_message[] = "I am a thread";

    // Fiecare structura asoc unui thread este
    // stocata separat
    my_struct thr_str[n_threads];

    // Identificatoarele unice ale thread-urilor vor fi
    // stocate intr-un vector
    pthread_t threads[n_threads];

    // Initializarea variabilei mutex
    pthread_mutex_init(&my_mutex, NULL);

    // Initializarea variabilei atributelor.
    pthread_attr_init(&attr);

    // Thread-urile sunt de tip 'joinable'
    pthread_attr_setdetachstate(&attr,
                                PTHREAD_CREATE_JOINABLE);
    for(i=0;i<n_threads;i++) {
        thr_str[i].message=my_message;
        thr_str[i].id=i;
        thr_str[i].val=&x;
        printf("Main: creating thread %i\n", i);
        ptc = pthread_create(&threads[i], &attr,
                            thread_routine, (void*)&thr_str[i]);
        if(ptc!=0) {
            perror("Pthread error");
            exit(1);
        }
    }

    for(i=0;i<n_threads;i++) {
        // Thread-ul curent (adica 'main()') asteapta
        // thread-urile din sirul threads[t] sa
        // finalizeze
        ptj = pthread_join(threads[i], &status);
        if(ptj!=0) {
            perror("Pthread join error\n");
            exit(1);
        }
    }

    // Variab atributelor este eliberata.
    pthread_attr_destroy(&attr);

    // Variabila mutex este eliberata
    pthread_mutex_destroy(&my_mutex);

    pthread_exit(NULL);
}