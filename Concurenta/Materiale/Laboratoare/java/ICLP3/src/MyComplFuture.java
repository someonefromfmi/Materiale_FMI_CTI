import java.util.concurrent.CompletableFuture;

public class MyComplFuture {
    public static void main(String[] args) {
        int n = 50;
        System.out.println("fibonacci of " + n);
        CompletableFuture<Long> future = CompletableFuture.supplyAsync(() -> fibonacci(n));

        future.thenAccept(System.out::println);
        future.join();
    }


    private static long fibonacci(long n) {
        if (n == 0 || n == 1) {
            return n;
        }
        return fibonacci(n - 1) + fibonacci(n - 2);
    }

}




