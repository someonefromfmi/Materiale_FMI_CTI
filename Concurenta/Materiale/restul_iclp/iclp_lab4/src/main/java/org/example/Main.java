package org.example;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.FutureTask;
import org.jsoup.Jsoup;


class MyTask implements Callable<String> {
    @Override
    public String call() {
        try {
            Thread.sleep(5000);
            return "Task completed";
        } catch (InterruptedException e) {
            e.printStackTrace();
            return "Error";
        }
    }
}

class CallableFuture {
    public static void main(String[] args) {
//        Callable<String> task = new MyTask();
        Callable<String> task = () -> {
            Thread.sleep(5000);
            return "Task completed";
        };

        FutureTask<String> futureTask = new FutureTask<>(task);

        Thread thread = new Thread(futureTask);
        thread.start();

        try {
            System.out.println("Main...");
            String result = futureTask.get();
            System.out.println("Result:  " + result);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}

// sa se implementeze un crawler in Java, folosind FutureTask si Callable
// vom avea o lista de url-uri pe care trebuie sa le accesam si de pe care trebuie sa luam continutul
// si vom delega fiecare url unui futureTask pt executie

class CrawlerTask implements Callable<String> {
    private String url;

    public CrawlerTask(String url) {
        this.url = url;
    }

    @Override
    public String call() {
        StringBuilder content = new StringBuilder();

        try {
            System.out.println("Accessing: " + url);

            HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
            connection.setRequestMethod("GET");
            connection.setReadTimeout(5000);
            connection.setConnectTimeout(5000);

            int status = connection.getResponseCode();

            if(status == 200) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                String line;
                while((line = reader.readLine()) != null) {
                    content.append(line).append("\n");
                }
                reader.close();
            } else {
                content.append("Cannot access this page: ").append(status);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return content.toString();
    }
}

class Crawler {
    public static void main(String[] args) {
        List<String> urls = List.of(
                "http://google.com",
                "https://jsonplaceholder.typicode.com/posts/1",
                "https://jsonplaceholder.typicode.com/posts/2",
                "https://jsonplaceholder.typicode.com/posts/3"
        );

        List<FutureTask<String>> futureTasks = new ArrayList<>();

        for(String url : urls) {
            Callable<String> task = new CrawlerTask(url);
            FutureTask<String> futureTask = new FutureTask<>(task);
            futureTasks.add(futureTask);

            Thread thread = new Thread(futureTask);
            thread.start();
        }

        for(FutureTask<String> futureTask : futureTasks) {
            try {
                String content = futureTask.get();
                System.out.println(content);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

class CompletableFutureMain {
    private static long fibonacci(int n) {
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
    }

    public static void main(String[] args) {
        int n = 20;
        System.out.println("fibo for n = " + n);
        CompletableFuture<Long> future = CompletableFuture.supplyAsync(() -> fibonacci(n));

        future.thenAccept(result -> {
            System.out.println("fibo(" + n + ") = " + result);
        });

        System.out.println("Main...");
        future.join();
    }
}

/*
* Problema:
* cs.unibuc.ro/~bmacovei/iclp
* Utilizand CompletableFuture, implementati un programa care
* aceeseaza fmi.unibuc.ro si afiseaza la STDOUT urmatoarele:
* anunturi secretariat
* noutati
* anunturi doctorat
* */

// pt solutii: bogdan.macovei.fmi@gmail.com
// pana la 2p in examen


public class Main {
    public static void main(String[] args) {
        System.out.println("hi");
    }
}