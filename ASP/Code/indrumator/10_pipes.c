#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

// Header in care sunt definite constantele implementate
// in acest caz, ne intereseaza dim max a bufferului
// unui pipe
#include <limits.h>

int main(void) {
    int i, status;
    pid_t my_pid;
    int size;
    char* buf;

    // un sir stocheaza descriptorii de fisier care
    // indica cele 2 capete ale pipe-ului (intrare
    // si iesire)
    int pipefd[2];

    // Este creat canalul de comunicare (piep-ul).
    if(pipe(pipefd)!=0) {
        perror("Pipe error\n");
        exit(1);
    }

    // Este creat noul proces
    if((my_pid=fork()) < 0) {
        perror("Fork error\n");
        exit(1);
    }

    // Daca este procesul copil:
    if(my_pid=0) {
        // Procesul copil isi inchide descriptorul de
        // scriere
        close(pipefd[1]);

        // Asteapta sa primeasca un mesaj prin fc de tip
        // blocking read(). In acest caz astepata doar
        // pt a nu afisa in terminal msg inaintea
        // proc parinte
        if(read(pipefd[0], &i, sizeof(int))<0) {
            perror("Read error\n");
            exit(1);
        }

        printf("PID %i receiving size\n", getpid());

        // Primeste dimensiunea mesajului
        if(read(pipefd[0], &size, sizeof(int))<0) {
            perror("Read error\n");
            exit(1);
        }

        printf("From PID=%i -> Size is %i\n", getpid(), size);

        // Aloca mem pt stocarea msg. Cum strlen() nu numara
        // si caract de term al sirului, mem necesara
        // acestuia trb adaugata prin 'size+1'

        buf = malloc((size+1)*sizeof(char));

        if(read(pipefd[0], buf, size)<0) {
            perror("Read error\n");
            exit(1);
        }
        printf("From PID=%i -> Message is: %s\n", getpid(), buf);

        // Elibereaza mem
        free(buf);
        close(pipefd[0]);
    }

    // Daca este procesul parinte:
    if(my_pid!=0) {
        // procesul parinte isi inchide descriptorul de
        // citire
        close(pipefd[0]);

        // Afiseaza dim max a msg care poate fi scris
        // Aceasta limita este data de dim buffer-ului
        // unui pipe. Dim este buffer-2 pt a avea loc 
        // pt caract de linie noua care apare cand este
        // apasat 'enter' si pt caract de terminare
        // a sirului.
        printf("Write something shorther than %li characters"
                "and press enter\n", _PC_PIPE_BUF/sizeof(char)-2);
        
        // aloca mem pt buffer si citeste input-ul
        buf=malloc((int)_PC_PIPE_BUF);
        fgets(buf, (int)_PC_PIPE_BUF-2, stdin);
        size=strlen(buf);

        // Da semnalul de start procesului copil
        if(write(pipefd[1], &i, sizeof(int)) <0) {
            perror("Write error\n");
            exit(1);
        }

        // trimite dim sirului
        if(write(pipefd[1], &size, sizeof(int))<0) {
            perror("Write error\n");
            exit(1);
        }

        // trimite sirul
        if(write(pipefd[1], buf, size)<0) {
            perror("Write error\n");
            exit(1);
        }
        free(buf);
        close(pipefd[1]);
    }

    // proc parinte va fi singurul cu variab my_pid 
    // nenula si va astepta incheierea proc copil

    if(my_pid!=0) {
        if(wait(&status)<0) {
            perror("Wait error");
            _exit(1);
        }

        return 0;
    }
}