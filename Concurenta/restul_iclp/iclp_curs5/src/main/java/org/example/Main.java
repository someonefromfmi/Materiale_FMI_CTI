package org.example;

import java.util.Random;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

class PCConsumer implements Runnable {
    private BlockingQueue<String> drop;

    public PCConsumer(BlockingQueue<String> drop) { this.drop = drop; }

    public void run() {
        while(true) {
            try {
                System.out.format("Message received: %s%n", drop.take());
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

class PCProducer implements Runnable {
    private BlockingQueue<String> drop;

    public PCProducer(BlockingQueue<String> drop) { this.drop = drop; }

    public void run() {
        String importantInfo[] = { "m1", "m2", "m3", "m4" };
        Random random = new Random();

        for(int i = 0; i < importantInfo.length; ++i) {
            try {
                drop.put(importantInfo[i]);
                System.out.format("Message sent: %s%n", importantInfo[i]);
                Thread.sleep(random.nextInt(1000));
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

class ProdCons {
    public static void main(String[] args) {
        BlockingQueue<String> drop = new LinkedBlockingQueue<>();

        (new Thread(new PCProducer(drop))).start();
        (new Thread(new PCProducer(drop))).start();
        (new Thread(new PCProducer(drop))).start();
        (new Thread(new PCConsumer(drop))).start();
    }
}

// ==========================================================================
class TaskE implements Runnable {
    private AtomicInteger counter;
    private CountDownLatch controller;

    TaskE(CountDownLatch controller, AtomicInteger counter) {
        this.controller = controller;
        this.counter = counter;
    }

    public void run() {
        for(int i = 0; i < 1000; i++) counter.incrementAndGet();
        controller.countDown();
        for(int i = 0; i < 1000; i++) counter.incrementAndGet();
    }
}

class CountDownLatchExample {
    public static void main(String[] args) throws InterruptedException{
        CountDownLatch controller = new CountDownLatch(3);

        ExecutorService pool = Executors.newCachedThreadPool();
        AtomicInteger counter = new AtomicInteger(0);

        for(int i = 0; i< 3; i++) pool.execute(new TaskE(controller, counter));

        controller.await();

        System.out.println(counter);
        pool.shutdown();
        System.out.println(counter);
    }
}

// ==========================================================================

class TaskE2 implements Runnable {
    private AtomicInteger counter;
    private CyclicBarrier barrier;

    TaskE2(CyclicBarrier barrier, AtomicInteger counter) {
        this.barrier = barrier;
        this.counter = counter;
    }

    public void run() {
        for(int i = 0; i < 1000; i++) counter.incrementAndGet();

        try {
            barrier.await();
        } catch (Exception e) {
            System.out.println(e);
            return;
        }

        for(int i = 0; i < 1000; i++) counter.incrementAndGet();
        System.out.println(Thread.currentThread().getName() + ": " + counter);
    }


}

class CycclicBarrierExample {
    public static void main(String[] args) throws BrokenBarrierException, InterruptedException {
        AtomicInteger counter = new AtomicInteger(0);
        CyclicBarrier barrier =
                new CyclicBarrier(
                        4,
                        () -> System.out.println("Thread reached the barrier: " + counter)
                );

        ExecutorService pool = Executors.newCachedThreadPool();

        for(int i = 0; i< 3; i++) pool.execute(new TaskE2(barrier, counter));

        barrier.await();

        System.out.println(counter);
        pool.shutdown();
        System.out.println(counter);
    }
}

// ===============================================================================

class TaskE3 implements Runnable {
    private static AtomicInteger counter;
    private CyclicBarrier barrier;
    private CountDownLatch controller;

    TaskE3(CountDownLatch c, CyclicBarrier b, AtomicInteger counter) {
        this.controller = c;
        this.barrier = b;
        this.counter = counter;
    }

    public void run() {
        for (int i = 0; i < 100; i++) counter.incrementAndGet();

        try {
            barrier.await();
        } catch (Exception e) {
            System.out.println(e);
            return;
        }

        for (int i = 0; i < 1000; i++) counter.incrementAndGet();

        System.out.println(Thread.currentThread().getName() + ": " + counter);
        controller.countDown();
    }
}

class BarrierAndLatch {
    public static void main (String[] args) throws InterruptedException, BrokenBarrierException {
        AtomicInteger counter = new AtomicInteger(0);
        CountDownLatch controller = new CountDownLatch(3);
        CyclicBarrier barrier =
                new CyclicBarrier(
                        4,
                        ()->{System.out.println("Threads reached thebarrier:" + counter);}
                );

        ExecutorService pool = Executors.newCachedThreadPool();
        for(int i=0;i<3;i++) pool.execute(new TaskE3(controller, barrier, counter));

        barrier.await();
        controller.await();

        pool.shutdown();
        System.out.println("All done! Final value: " + counter);
    }
}

// =======================================================================================
class ConcHM {
    static class ReaderThread extends Thread {
        private ConcurrentHashMap<Integer, String> map;
        private String name;

        public ReaderThread(ConcurrentHashMap<Integer, String> map, String threadName) {
            this.map = map;
            this.name = threadName;
        }

        public void run() {
            while (ok) {
                String output = name + ": ";
                for (Integer key : map.keySet()) {
                    String value = map.get(key);
                    output += "(" + key + "," + value + ")";
                }

                System.out.println(output);
                try {
                    Thread.sleep(ThreadLocalRandom.current().nextInt(300));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }

        static class WriterThread extends Thread {
            private ConcurrentHashMap<Integer, String> map;
            private CountDownLatch controller;
            private String name;

            public WriterThread(ConcurrentHashMap<Integer, String> map, String threadName, CountDownLatch c) {
                this.map = map;
                this.name = threadName;
                this.controller = c;
            }

            public void run() {
                String value = name;

                while (ok) {
                    for (int i = 0; i < 3; i++) {
                        Integer key = ThreadLocalRandom.current().nextInt(1000);
                        if (map.putIfAbsent(key, value) == null) {
                            System.out.println(name + " has put (" + key + ", " + value + ")");
                        } else {
                            System.out.println(name + "duplicate");
                        }
                    }
                    controller.countDown();

                    try {
                        Thread.sleep(ThreadLocalRandom.current().nextInt(500));
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    private static volatile boolean ok = true;

    public static void main(String[] args) throws InterruptedException {
        ConcurrentHashMap<Integer, String> map = new ConcurrentHashMap<>();
        CountDownLatch controller = new CountDownLatch(3);

        (new ReaderThread.WriterThread(map, "W1", controller)).start();
        (new ReaderThread.WriterThread(map, "W2", controller)).start();
        (new ReaderThread(map, "R1")).start();
        (new ReaderThread(map, "R2")).start();
        (new ReaderThread(map, "R3")).start();

        controller.await();
        ok = false;
    }
}

public class Main {
    public static void main(String[] args) {
        System.out.println("hi");
    }
}
