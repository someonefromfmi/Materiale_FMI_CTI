package org.example;

import java.util.LinkedList;
import java.util.Queue;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.locks.*;

class Chopstick {
    private int id;
    public Chopstick(int id) { this.id = id; }
    public int getId() { return id; }
}

class Philosopher extends Thread {
    private String name;
    private Chopstick first, second;

    public Philosopher(String name, Chopstick left, Chopstick right) {
        this.name = name;
        // ia furculitele -> deadlock
//        this.first = left;
//        this.second = right;
        // Solutia (Dijskstra)
        if(left.getId() < right.getId()) {
            first = left; second = right;
        } else {
            first = right; second = left;
        }
        /*
        * ordine globala pe lacate (furculite)
        * lacatele (furculitele) sunt luate in ordine:
        * - intai cea mai mica (in ordinea globala)
        * - intai cea mai mare (in ordinea globala)
        * */

    }

    public void run() {
        try {
            while(true) {
                System.out.println(name + " is hungry."); // vrea sa manance
                synchronized(first) {
                    Thread.sleep(ThreadLocalRandom.current().nextInt(10));
                    synchronized(second) {
                        System.out.println(name + " is eating.");
                        Thread.sleep(ThreadLocalRandom.current().nextInt(1000)); // mananca }
                    }}
                System.out.println(name + " is thinking.");
                Thread.sleep(ThreadLocalRandom.current().nextInt(10000)); // gandeste
            }
        } catch(InterruptedException e) {}
    }
}

class DiningPhilosophers {
    public static void main(String[] args) throws InterruptedException {
        Chopstick[] chopsticks = new Chopstick[5]; // pentru crearea betelor

        Philosopher[] philosophers = new Philosopher[5]; // crearea thread-urilor filozof
                                                        // parametrizate de bete

        for(int i  = 0; i< 5; i++)
            chopsticks[i] = new Chopstick(i);

        for(int i = 0; i < 5; i++) {
            philosophers[i] = new Philosopher("Phil"+i, chopsticks[i], chopsticks[(i + 1)%5]);
            philosophers[i].start();
        }

        for (int i = 0; i < 5; i++)
            philosophers[i].join();
    }
}

class PCDrop {
    private String message;
    private boolean empty = true;

    public synchronized String take() {
        // testarea unei conditii se face intotdeauna folosind while
        while(empty) {
            try {
                wait();
            } catch (InterruptedException e) {}
        }
        /*
        * implementarea foloseste blocuri cu garzi
        * thread-ul este suspendat pana cand o anume conditie este satisfacuta
        * */
        empty = true;
        notifyAll();
        return message;
    }

    public synchronized void put(String message) {
        while(!empty) {
            try {
                wait();
            } catch (InterruptedException e) {}
        }
        empty = false;
        this.message = message;
        notifyAll();
    }
}

class PCProducer implements Runnable {
    private PCDrop drop;
    public PCProducer(PCDrop drop) { this.drop = drop; }

    public void run() {
        String importantInfo[] = { "m1", "m2", "m3", "m4" };
        Random random = new Random();

        for(int i = 0; i < importantInfo.length; i++) {
            drop.put(importantInfo[i]); // metoda sincronizata a obiectului drop
            try {
                Thread.sleep(random.nextInt(5000));
            } catch (InterruptedException e) {}
        }

        drop.put("DONE");
    }
}

class PCConsumer implements Runnable {
    private PCDrop drop;
    public PCConsumer(PCDrop drop) { this.drop = drop; }

    public void run() {
        Random random = new Random();

        for(String message = drop.take(); !message.equals("DONE"); message = drop.take()) {
            System.out.format("MESSAGE RECEIVED: %s%n", message);
            try {
                Thread.sleep(random.nextInt(5000));
            } catch (InterruptedException e) {}
        }
    }
}

class ProducerConsumer {
    public static void main(String[] args) {
        PCDrop drop = new PCDrop();

        (new Thread(new PCProducer(drop))).start();
        // mai multi consumeri -> data race
        (new Thread(new PCConsumer(drop))).start();
        (new Thread(new PCProducer(drop))).start();
        (new Thread(new PCConsumer(drop))).start();
    }
}

class Counter {
    private int counter = 0;
    private Lock counter_lock = new ReentrantLock(true);
    public void performTask() {
        counter_lock.lock();
        try {
            int temp = counter;
            counter++;
            System.out.println(Thread.currentThread()
                    .getName() + " -before:" + temp + " after:" + counter);
        } finally {
            counter_lock.unlock();
        }
    }
}

class CounterThread implements Runnable {
    Counter counter;
    CounterThread(Counter counter) {
        this.counter = counter;
    }

    @Override
    public void run() {
        for(int i = 0; i < 5; i++) {
            counter.performTask();
        }
    }
}

class InterferenceLock {
    public static void main(String[] args) throws InterruptedException {
        Counter c = new Counter();
        Thread thread1 = new Thread(new CounterThread(c));
        Thread thread2 = new Thread(new CounterThread(c));
        thread1.start();
        thread2.start();
        thread1.join();
        thread2.join();
    }
}

class PCDropCond {
    private String message;
    private boolean empty = true;

    private Lock dropLock = new ReentrantLock();
    private Condition cond_dropLock = dropLock.newCondition();

    public synchronized String take() {
        dropLock.lock();
        try {
            while (empty) {
                try {
                    cond_dropLock.await();
                } catch (InterruptedException e) {
                }
            }
            empty = true;
            cond_dropLock.signalAll();
            return message;
        } finally {
            dropLock.unlock();
        }
    }

    public synchronized void put(String message) {
        dropLock.lock();
        try {
            while (!empty) {
                try {
                    cond_dropLock.await();
                } catch (InterruptedException e) {
                }
            }
            empty = false;
            this.message = message;
            cond_dropLock.signalAll();
        } finally {
            dropLock.unlock();
        }
    }
}

class PCDrop2Cond {
    private Queue<String> drop = new LinkedList<>(); // buffer de capacitate coada
    private static int Max = 5;

    private Lock dLock = new ReentrantLock();
    // semnaleaza ca exista spatiu pt a produce
    private Condition cond_empty = dLock.newCondition();
    // semnaleaza ca exista produse care pot fi consumate
    private Condition cond_full = dLock.newCondition();

    public String take() {
        dLock.lock();
        try {
            while (drop.size() == 0) {
                try {
                    cond_full.await();
                } catch (InterruptedException e) {}
            }
            String message = drop.remove();
            System.out.format("Buffer items: %d%n", drop.size());

            cond_empty.signalAll();
            return message;
        } finally {
            dLock.unlock();
        }
    }

    public void put(String message) {
        dLock.lock();
        try {
            while (drop.size() == Max) {
                try {
                    cond_empty.await();
                } catch (InterruptedException e) {}
            }
            drop.add(message);
            System.out.format("Buffer items: %d%n", drop.size());
            cond_full.signalAll();
        } finally {
            dLock.unlock();
        }
    }
}

class PCProducer2 implements Runnable {
    private PCDrop2Cond drop;
    public PCProducer2(PCDrop2Cond drop) { this.drop = drop; }

    public void run() {
        Random random = new Random();

        while(true) {
            drop.put("Message" + random.nextInt(50));
            try {
                Thread.sleep(random.nextInt(50));
            } catch (InterruptedException e) {}
        }
    }
}

class PCConsumer2 implements Runnable {
    private PCDrop2Cond drop;
    public PCConsumer2(PCDrop2Cond drop) { this.drop = drop; }

    public void run() {
        Random random = new Random();

        while(true) {
            String message = drop.take();
            System.out.format("MESSAGE RECEIVED: %s%n", message);
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {}
        }
    }
}

class ProducerConsumerLockCond {
    public static void main(String[] args) {
        PCDrop2Cond drop = new PCDrop2Cond();
        (new Thread(new PCProducer2(drop))).start();
        (new Thread(new PCProducer2(drop))).start();

        (new Thread(new PCConsumer2(drop))).start();
        (new Thread(new PCConsumer2(drop))).start();
        (new Thread(new PCConsumer2(drop))).start();
    }
}

class PhilosopherLock extends Thread {
    private String name;
    private boolean eating;
    private PhilosopherLock left;
    private PhilosopherLock right;
    private ReentrantLock table;
    private Condition condition;

    public PhilosopherLock(String name, ReentrantLock table) {
        this.name = name;
        this.table = table;
        condition = table.newCondition();
        eating = false;
    }

    public void setLeft(PhilosopherLock left) { this.left = left; }
    public void setRight(PhilosopherLock right) { this.right = right; }

    public void run() {
        try {
            while(true) {
                think();
                eat();
            }
        } catch (InterruptedException e) {}
    }

    // un thread filozof trb sa detina lacatul pt a incepe sa manance si pt aceasta
    // asteapta pana cand ambii vecini au terminat de mancat.
    private void eat() throws InterruptedException {
        if (table.tryLock()) {
            // lock.tryLock() ia lacatul daca poate si intoarce true imediat;
            // daca nu poate sa detina lacatul intoarce false dar thread-ul
            // nu este blocat si poate executa altceva
            try {
                while (left.eating || right.eating) {
                    condition.await();
                }
                eating = true;
            } finally {
                table.unlock();
            }

            System.out.println(name + " is eating");
            Thread.sleep(ThreadLocalRandom.current().nextInt(1000));
        } else {
            System.out.println(name + " giving up trying for now, …");
            Thread.sleep(ThreadLocalRandom.current().nextInt(1000));
        }
    }


    public void think() throws InterruptedException {
        table.lock();

        // cand termina de mancat semnalizeaza vecinilor ca pot incerca sa ia lacatul
        // comun pt a manca
        try {
            eating = false;
            left.condition.signal();
            right.condition.signal();
        } finally {
            table.unlock();
        }

        System.out.println(name + " is thinking");
        Thread.sleep(ThreadLocalRandom.current().nextInt(1000));
    }
}

class DiningPhilosophersLockCond {
    public static void main(String[] args) throws InterruptedException {
        PhilosopherLock[] philosophers = new PhilosopherLock[5];
        ReentrantLock table = new ReentrantLock();

        for(int i = 0; i < 5; i++)
            philosophers[i] = new PhilosopherLock("Phil"+i, table);

        for(int i = 0; i < 5; i++) {
            philosophers[i].setLeft(philosophers[(i+4) % 5]);
            philosophers[i].setRight(philosophers[(i+1) % 5]);
            philosophers[i].start();
        }
        // fiecare filozof trb sa acceseze starea filozofilor vecini pt a sti daca acestia
        // mananca sau gandesc

        for(int i = 0; i < 5; i++)
            philosophers[i].join();
    }
}

// un contor incrementat de doua thread-uri care il acceseaza repetat
class InterfaceLockFair {
    public static void main(String[] args) throws InterruptedException {
        Counter c = new Counter();
        Thread thread1 = new Thread(new CounterThread(c));
        Thread thread2 = new Thread(new CounterThread(c));

        thread1.start();
        thread2.start();
        thread1.join();
        thread2.join();
    }
}

public class Main {
    public static void main(String[] args) {
        System.out.println("Hello");
    }
}