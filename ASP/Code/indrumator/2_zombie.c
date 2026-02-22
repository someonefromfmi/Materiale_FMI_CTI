#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

int main(void) {
    pid_t my_pid;

    if((my_pid = fork()) < 0) {
        perror("Fork error\n");
        exit(1);
    }
    // Proc copil va fi suspendat pt 20 de sec, in
    // schimb ce proc parinte se incheie imediat.
    if(my_pid > 0) sleep(20);

    return 0;
}