#include <unistd.h>
#include <sys/types.h>
int main(void) {
    pid_t my_pid;
    
    while(1) {
        if((my_pid=fork()) < 0) {
            perror("Fork error\n");
            _exit(1);
        }
    }

    return 0;
}