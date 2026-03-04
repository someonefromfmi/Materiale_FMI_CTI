
class MyThread implements Runnable {
    @Override
    public void run() {
        System.out.println("Thread: " + Thread.currentThread().getName());
    }
}

public class Main {
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(new MyThread());
        t1.start();

        Thread anonThread = new Thread(() -> {
            System.out.println("Thread: " + Thread.currentThread().getName());
        });

        anonThread.start();

        t1.join();
        anonThread.join();

    }
}