package org.example;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Scanner;

class Client {
    public static void main(String[] args) throws IOException {
        Socket socket = new Socket("localhost", 9090);

        PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
        BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        Scanner clientin = new Scanner(System.in);
        String message = clientin.next();
        out.println(message);

        String response = in.readLine();
        System.out.println("From server: " + response);

        socket.close();
    }
}

public class Main {
    public static void main(String[] args) {

    }
}