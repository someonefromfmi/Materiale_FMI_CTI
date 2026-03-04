package org.example;
import java.util.concurrent.atomic.AtomicInteger;

// definirea unei thread ca subclasa a clasei Thread
//class HelloThread extends Thread {
//    public void run() {
//        System.out.println("Hello from a thread!");
//    }
//}

// definirea unui thread prin implementarea interfetei Runnable
//class HelloRunnable implements Runnable {
//    public void run() {
//        System.out.println("Hello from a thread!");
//    }
//
//    public static void main(String[] args) {
//        Thread t = new Thread(new HelloRunnable());
//        t.start();
//    }
//}

// executia este nedeterminista
class HelloThread implements Runnable {
    private int n;

    public HelloThread() {}
    public HelloThread(int n) { this.n = n; }
    public void run() {
        for(int x = 0; x < n; x = x + 1)
            System.out.println("Hello from " + Thread.currentThread().getId() + "!");
    }
}

class SleepMessages {
    public static void main(String[] args) throws InterruptedException {
        String importantInfo[] = { "This", "is", "important" };

        for(int i = 0; i < importantInfo.length; i++) {
            // pauza de 4 secunde
            Thread.sleep(4000); // opreste executia thread-ului curent pt ms milisecunde
            // si arunca exceptie daca thread-ul este intrerupt

            System.out.println(importantInfo[i]);
        }
    }
}

class Msg {
    public static void threadMessage(String message) {
        String threadName = Thread.currentThread().getName();
        System.out.format("%s: %s%n", threadName, message);
    }
}

class MessageLoop implements Runnable {
    public void run() {
        String importantInfo[] = { "This", "is", "important" };

        try {
        for(int i = 0; i < importantInfo.length; i++) {
                Thread.sleep(4000);
                Msg.threadMessage(importantInfo[i]);
            }
        } catch (InterruptedException e) {
            Msg.threadMessage("I wasn't done!");
            // daca thread-ul este intrerupt se va afisa acest mesaj
        }
    }
}

// comunicarea intre thread-uri
// 2 thread-uri care incrementeaza acelasi contor
class SharedCounter {
    static int c = 0;

    public static void main(String[] args) throws InterruptedException {
        Thread myThread = new Thread(
                () -> { for (int x = 0; x < 5000; ++x) c++; }
        );
        myThread.start();
//        Thread.sleep(3000);

        for(int x = 0; x < 5000; ++x) c--;

        myThread.join(); // tot nu e determinist, accesul la contor nu e sincronizat

        System.out.println("c = " + c);
    }
}

// doua thread-uri care incrementeaza acelasi contor
class Interference implements Runnable {
    static Integer counter = 0;

    public void run() {
        for(int i = 0; i < 5; i++) {
            performTask();
        }
    }

    private void performTask() {
        int temp = counter;
        counter++;
        System.out.println(
                Thread.currentThread()
                        .getName() + "-before: " + temp + " after: " + counter
        );
    }

    public static void main(String[] args) throws InterruptedException {
        // lacatul este pus pe c
        Counter c = new Counter();
//        Thread thread1 = new Thread(new Interference());
//        Thread thread2 = new Thread(new Interference());

        Thread thread1 = new Thread(new CounterThread(c));
        Thread thread2 = new Thread(new CounterThread(c));
        thread1.start();
        thread2.start();
        thread1.join();
        thread2.join();
    }
}

class Counter {
    private int counter = 0;
    // metode de sincronizare
    public synchronized void performTask() {
        int temp = counter;
        counter++;
        System.out.println(
                Thread.currentThread().getName() + "-before: " + temp + " after: " + counter
                );
    }
}

class CounterThread implements Runnable {
    Counter counter;
    CounterThread (Counter counter) { this.counter = counter; }

    public void run() {
        for(int i = 0; i < 5; i++) {
            counter.performTask();
        }
    }
}

// blocuri sincronizate
class SCounter {
    private int scounter = 0;
    private Object counter_lock = new Object();

    public void performTask() {
        synchronized (counter_lock) { // lacatul este pe counter_lock
            int temp = scounter;
            scounter++;
            System.out.println(Thread.currentThread()
                    .getName() + " -before: " + temp + " after: " + scounter
            );
        }
    }
}

// un thread poate face aquire pe un lacat pe care deja il detine (reentrant synchronization)
class reentrantEx {
    public synchronized void met1() {}
    public synchronized void met2() { this.met1(); }
    // astfel, se evita situatia in care un thread intra in deadlock incercand sa detina un lacat
    // pe care deja il detine
}

// variabile atomice
class AtomicCounter {
    private static AtomicInteger counter = new AtomicInteger();

    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(new Runnable () {
            public void run() {
                for (int i = 0; i < 1000; i++)
                    counter.incrementAndGet();
            }
        });

        Thread t2 = new Thread(new Runnable () {
            public void run() {
                for (int i = 0; i < 1000; i++)
                    counter.incrementAndGet();
            }
        });

        t1.start(); t2.start();
        t1.join(); t2.join();

        System.out.println(counter.get());
    }
}

// variabilele volatile nu asigura atomicitatea
class VolatileCounter {
    private static volatile int counter = 0;

    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(new Runnable () {
            public void run() {
                for (int i = 0; i < 10000; i++)
                    counter++;
            }
        });

        Thread t2 = new Thread(new Runnable () {
            public void run() {
                for (int i = 0; i < 10000; i++)
                    counter++;
            }
        });

        t1.start(); t2.start();
        t1.join(); t2.join();

        System.out.println(counter);
    }
}

// variab volatile - folosite atunci cand exista un thread care le actualizeaza si (eventual)
// mai multe care le citesc, situatia tipica fiind variabila de control a unui ciclu
// TODO: s47 - asa ar trebui sa fie output-ul?
class VolatileEx {
    static volatile boolean stop = false;

    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(new Runnable() {
            @Override
            public void run() {
                int count = 0;
                while(!stop) {
                    count++;
                    System.out.println(count);
                }
                System.out.println(count);
            }
        });

        Thread t2 = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Thread.sleep(10);
                } catch (InterruptedException e) {
                    System.out.println("lol");
                }
                stop = true;
            }
        });

        t1.start(); t2.start();
        t1.join(); t2.join();
        System.out.println("STOP");
    }
}


public class Main {
    public static void main(String[] args)  throws InterruptedException {
        // definirea unui thread cu subclasa anonima a clasei Thread
//        Thread t = new Thread() {
//            public void run() {
//                System.out.println("Hello from a thread!");
//            }
//        };

        // nedeterminism
//        Thread t = new Thread(new HelloThread());
//        t.start();
//        for(int x = 0; x < 1000; x = x + 1)
//            System.out.println("Hello from the main thread!");
        //TODO: join si interrupted exception - Ceva ciudat aici? s17
//        t.join();

        // transmiterea unui param catre un thread
//        Scanner myInput = new Scanner(System.in);
//        int n;
//
//        System.out.println("Enter n");
//        n = myInput.nextInt();
//
//        Thread t = new Thread(new HelloThread(n));
//        t.start();
//
//        for(int x = 0; x < n; x = x + 1)
//            System.out.println("Hello from the main thread");
        // thread-ul principal creeaza un al doilea thread si astepata ca acesta
        // sa isi termine executia
        Msg.threadMessage("Starting MessageLoop thread");
        Thread t = new Thread(new MessageLoop());
        t.start();
        Msg.threadMessage("Waiting for MessageLoop thread to finish");

        t.interrupt(); //TODO: interrupt sau interrupted? s23

        t.join();

        Msg.threadMessage("Finally");
    }
}