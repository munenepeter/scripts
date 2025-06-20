#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>

#define EXIT_FAILURE 1

#define PORT 8080

int main() {
  int server_sock;
  struct sockaddr_in server_addr;

  // create the server socket
  server_sock = socket(AF_INET, SOCK_STREAM, 0);
  if (server_sock < 0) {
    perror("Failed to create socket");
    exit(EXIT_FAILURE);
  }
  // configure the server address
  server_addr.sin_family = AF_INET;
  server_addr.sin_port = htons(PORT);
  server_addr.sin_addr.s_addr = INADDR_ANY;

  // bind the socket to the server address
  if (bind(server_sock, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
    perror("Failed to bind socket");
    exit(EXIT_FAILURE);
  }

  // listen for connections
  if (listen(server_sock, 1) < 0) {
    perror("Failed to listen");
    close(server_sock);
    exit(EXIT_FAILURE);
  }

  printf("Server listening on port %d\n", PORT);

  while (1) {
    struct sockaddr_in client_addr;
    socklen_t client_addr_len = sizeof(client_addr);

    // accept a connection
    int client_sock = accept(server_sock, (struct sockaddr *)&client_addr, &client_addr_len);
    if (client_sock < 0) {
      perror("Failed to accept connection");
      continue;
    }


    //allocate memory for thread arguments
    thread_args_t *args = malloc(sizeof(thread_args_t));
    if(!args) {
      perror("Failed to allocate memory for thread arguments");
      close(client_sock);
      continue;
    }
    args->client_sock = client_sock;

  }
}