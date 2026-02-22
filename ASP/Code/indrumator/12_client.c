#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define PORT 8000

// adr locala - localhost
#define SERVER_IP "127.0.0.1"

int main(void) {
    int i;
    double sum = 0;
    int matrix_size;
    double* matrix;
    int my_socket;

    // adresa serverului
    struct sockaddr_in server_address;

    // se creeaza socket-ul
    if((my_socket=socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("Socket error\n");
        exit(1);
    }

    memset(&server_address, 0, sizeof(server_address));
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(PORT);

    // converteste adrese IPV4 si IPV6 din fmt text in
    //  fmt binpt retea
    if(inet_pton(AF_INET, SERVER_IP,
                &server_address.sin_addr) <= 0) {
                    perror("Pton error\n");
                    exit(1);
                }

    // conecteaza socket-ul (my_socket) la adr 
    // serverului a carei dim este sockaddr_in
    if(connect(my_socket,(struct sockaddr*)&server_address,
                sizeof(struct sockaddr_in)) < 0) {
                    perror("Connect error\n");
                    exit(1);
                }

    printf("Connected\n");

    // clientul primeste dim matricii
    if(recv(my_socket, &matrix_size, sizeof(int),0) < 0) {
        perror("Recv error\n");
        exit(1);
    }

    printf("Matrix size %i\n", matrix_size);

    if((matrix=malloc(matrix_size*sizeof(double))) == NULL) {
        perror("Malloc error\n");
        exit(1);
    }

    // clientul primeste matricea
    if(recv(my_socket,matrix,matrix_size*sizeof(double), 0) < 0) {
        perror("Recv error\n");
        exit(1);
    }

    // clientul aduna toate elem matricii
    for(i=0;i<matrix_size;i++) sum+=matrix[i];

    // clientul trimite serverului sum elem
    if(send(my_socket, &sum, sizeof(double), 0) < 0) {
        perror("Send error\n");
        exit(1);
    }

    free(matrix);

    return 0;
 }