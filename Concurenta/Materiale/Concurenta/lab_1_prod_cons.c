#include <stdio.h>
#include <unistd.h> 
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/sem.h>
#include <sys/wait.h>
 
int main(int argc, char *argv[])
{
    int shmid = shmget(IPC_PRIVATE, 1, S_IRUSR | S_IWUSR);
 
    int semprnt = semget(IPC_PRIVATE, 1, S_IRUSR | S_IWUSR);
    int semchld = semget(IPC_PRIVATE, 1, S_IRUSR | S_IWUSR);
 
    semctl(semprnt, 0, SETVAL, 0);
    semctl(semchld, 0, SETVAL, 0);
 
    int childPid; 
    if ((childPid = fork()) > 0) 
    {
        // father
        char *p = shmat(shmid, NULL, SHM_RND);
 
        struct sembuf releaseFather;
        struct sembuf acquireChild;
 
        releaseFather.sem_num = 0;
        releaseFather.sem_op = 1;
        releaseFather.sem_flg = 0;
 
        acquireChild.sem_num = 0;
        acquireChild.sem_op = -1;
        acquireChild.sem_flg = 0;
 
        for (char ch = 'a'; ch <= 'z'; ch++)
        {
            *p = ch;
            semop(semprnt, &releaseFather, 1);
            semop(semchld, &acquireChild, 1);
        }

        wait(NULL);
 
        semctl(semprnt, 0, IPC_RMID, NULL);
        semctl(semchld, 0, IPC_RMID, NULL);
 
        shmdt(p);
    }
    else 
    {
        // child 
        char *p = shmat(shmid, NULL, SHM_RND);
 
        struct sembuf acquireFather;
        struct sembuf releaseChild;
 
        acquireFather.sem_num = 0;
        acquireFather.sem_op = -1;
        acquireFather.sem_flg = 0;
 
        releaseChild.sem_num = 0;
        releaseChild.sem_op = 1;
        releaseChild.sem_flg = 0;
 
        for (int i = 0; i < 26; i++) 
        {
            semop(semprnt, &acquireFather, 1);
            printf("%c", *p);
            semop(semchld, &releaseChild, 1);
        }
 
        shmdt(p);
    }
 
    return 0;
}

// https://cs.unibuc.ro/~bmacovei/labs/iclp2024s1/iclp2024s1/iclp-lab1.html