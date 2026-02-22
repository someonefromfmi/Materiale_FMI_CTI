#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define PORT 8000

// Nr de clienti pe care ii asteapta sa se conecteze
#define NO_CLIENTS 5

int main(void) {
    int i, j;
    double sum = 0;
    double temp_sum;
    int my_socket;;

    // va cont socket-urile prin care se conecteaza 
    // clientii
    int accept_fd[NO_CLIENTS];

    // Adresa serverului
    struct sockaddr_in server_address;

    //  Adresa clientului
    struct sockaddr_in clinet_address;

    // Dim addr clientului
    socklen_t cli_add_len;

    int n_matrices = NO_CLIENTS; // nr de matr
    int matrix_size = 10*10; // dim unei matr
    double **matrices; // fiecare matr este definita
    // ca un sir

    // se aloca mem pt stocarea matr
    if((matrices=malloc(n_matrices*sizeof(double*)))==NULL) {
        perror("Malloc error\n");
        exit(1);
    }

    // Matr sunt init cu val 1
    for(i=0;i<n_matrices;i++) {
        matrices[i]=malloc(matrix_size*matrix_size
                            *(sizeof(double)));

        for(j=0;j<matrix_size*matrix_size;j++) {
            matrices[i][j] = 1;
        }
    }

    // se creeaza socket-ul
    if((my_socket=socket(AF_INET,SOCK_STREAM,0)) <0) {
        perror("Socket error\n");
        exit(1);
    }

    // memoria adr este init cu 0
    memset(&server_address,0,sizeof(server_address));

    // Familia adr este IPV4
    server_address.sin_family=AF_INET;

    // htonl() coverteste un int primit ca input in
    // fmt bin pt retea.
    // param INADDR_ANI ii indica socket-ului sa 
    // asculte toate interf disponibile
    server_address.sin_addr.s_addr=htonl(INADDR_ANY);

    // htons() conv un short int primit ca in fmt bin
    // pt retea
    server_address.sin_port=htons(PORT);

    // se leaga adr de port
    if(bind(my_socket,(struct sockaddr*)&server_address,
        sizeof(server_address)) <0) {
            perror("Bind error\n");
            exit(1);
        }

    // socket-ul este indicat ca disponibil pt a accepta
    // conexiuni. Va accepta max 5 conexiune intre 
    // accept-uri. Daca nr de conexiune e depasit,
    // acestea vor fi refuzate
    if(listen(my_socket,5) <0) {
        perror("Listent error\n");
        exit(1);
    }

    printf("Waiting for clients\n");

    // Serverul intai accepta conexiunile de la clienti
    for(i=0;i<n_matrices;i++) {
        // se det marimea adr clientului
        cli_add_len=(socklen_t)sizeof(clinet_address);

        // conexiunile sunt acceptate
        accept_fd[i]=accept(my_socket,
                            (struct sockaddr*)&clinet_address,
                            &cli_add_len);
        
        if(accept_fd[i] < 0) {
            perror("Accept error\n");
            exit(1);
        }

        printf("Connected to client %i out of %i\n",
                i+1, NO_CLIENTS);
    }

    printf("Sending data\n");

    // Dupa ce s-au facut conexiunile cu clientii,
    // serverul le trimite fiecaruia dim matr si 
    // continutul ei
    for(i=0;i<n_matrices;i++) {
        if(send(accept_fd[i], &matrix_size, sizeof(int),0) <0) {
            perror("Send error\n");
            exit(1);
        }

        if(send(accept_fd[i], (void*)matrices[i],
                matrix_size*sizeof(double), 0) <0) {
                    perror("Send error\n");
                    exit(1);
                }
    }
    
    printf("Receiving data\n");

    // serverul primeste val calc de clienti
    for(i=0;i<n_matrices;i++) {
        if(recv(accept_fd[i], &temp_sum, sizeof(double),0) <0) {
            perror("Recv error\n");
            exit(1);
        }

        sum+=temp_sum;
    }

    printf("Total sum is %lf\n", sum);

    // se elibereaza mem
    for(i=0;i<n_matrices;i++) {
        free(matrices[i]);
    }
    free(matrices);

    return 0;
}