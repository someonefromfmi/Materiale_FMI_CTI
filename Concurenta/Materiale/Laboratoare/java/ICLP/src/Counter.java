public class Counter {
    static int counter = 0;
    static int ITERATIONS = 1_000_000;
    static Object lock = new Object();

    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            for (int i = 0; i < ITERATIONS; ++i){
                synchronized (lock){
                    counter++;
                }
            }
        });

        t1.start();

        for (int i = 0; i < ITERATIONS; ++i){
            synchronized (lock){
                counter++;
            }
        }


        t1.join();

        System.out.println("Counter: " + counter);
    }
}

