#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

// Val pana la care va numara fiecare thread
#define COUNT_UP_TO 5

// Val de la care thread-ul nr 3 va incepe sa numere
#define COUNT_LIMIT 5

// Val def global pt ca sunt impartite de toate
// thread-urile si de fc main()
int count = 0;
pthread_mutex_t my_mutex;
pthread_cond_t my_condition_variable;

// Rutina de numarare simpla (fara asteptare) a
// thread-urilor 1 si 2
void* just_count(void *id) {
    int i;
    for(i=0;i<COUNT_UP_TO;i++) {
        // Se blocheaza mutex-ul
        pthread_mutex_lock(&my_mutex);
        count++;

        // Verif daca a ajuns la val limita. Aceasta
        // verificare se face numai cu mutex-ul blocat
        // pt ca val comparata sa nu mai modificata
        // poata fi in acest timp
        if(count == COUNT_LIMIT) {
            printf("Thread %i has now reached the threshold %i\n",
                *(int*)id, count);
            pthread_cond_signal(&my_condition_variable);
            printf("Thread %i has sent a signal to thread 3 "
                "to start\n",*(int*) id);
        }

        printf("Thread %i has counted up to %i\n",
            *(int*)id, count);

        // Se deblocheaza mutex-ul
        pthread_mutex_unlock(&my_mutex);

        // Intarziere temporala pt a permite si
        // celorlalte thread-uri sa fie activate
        sleep(1);
    }
    pthread_exit(NULL);
}

// Rutina de numarare a thread-ului 3 (cu asteptare)
void* wait_and_count(void* id) {
    int i;
    printf("Thread %i is now waiting\n", *(int*)id);

    // Mutex-ul este blocat pt a putea apela fc
    // pthread_cond_wait()
    pthread_mutex_lock(&my_mutex);
    while(count < COUNT_LIMIT) {
        // Odata apelata, fc pthread_cond_wait()
        // deblocheaza in mod automat mutex-ul
        pthread_cond_wait(&my_condition_variable, &my_mutex);
    }

    // In acest pc mutex-ul apartine din nou thread-ului
    // 3 pt ca pthread_cond_signal() l-a deblocat
    printf("Thread %i is no longer waiting\n", *(int*)id);
    printf("Thread %i is now unlocking the mutex\n",
            *(int*)id);
    
    pthread_mutex_unlock(&my_mutex);

    for(i=0;i<COUNT_UP_TO;i++) {
        pthread_mutex_lock(&my_mutex);
        count++;
        printf("Thread %i has counted up to %i\n",
                *(int*)id, count);
        pthread_mutex_unlock(&my_mutex);
        sleep(1);
    }
    pthread_exit(NULL);
}

int main(void) {
    int i, rc;

    // Main va crea 3 thread-uri
    int n_threads = 3;

    int x=1, y=2, z=3;
    pthread_t threads[3];
    pthread_attr_t attr;

    // Se init mutex-ul si variab de cond
    pthread_mutex_init(&my_mutex, NULL);
    pthread_cond_init(&my_condition_variable, NULL);

    // Thread-urile primesc in mod explicit atributul
    // 'joinable'
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr,
                                PTHREAD_CREATE_JOINABLE);
    
    // Thread-urile sunt create, fiecare cu propria
    // rutina de executie
    pthread_create(&threads[0], &attr,
                    just_count, (void*)&x);

    pthread_create(&threads[1], &attr,
                    just_count, (void*)&y);
    
    pthread_create(&threads[2], &attr,
                wait_and_count, (void*)&z);

    // Asteapta thread-urile sa finalizeze
    for (i=0;i<n_threads;i++) {
        pthread_join(threads[i], NULL);
    }

    pthread_attr_destroy(&attr);
    pthread_mutex_destroy(&my_mutex);
    pthread_cond_destroy(&my_condition_variable);
    pthread_exit(NULL);
}

