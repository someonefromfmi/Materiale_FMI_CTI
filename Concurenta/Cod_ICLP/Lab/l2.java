package Cod_ICLP.Lab;

// 1 + max(examen, (examen + proiect/2)) + max 2p lab
// va ganditi cand mutati cursul 1, poate si lab - ul mutat, dar nu de la 8
// "/home/cosmin/IdeaProjects/iclp_lab_2/src/mesaj.txt"
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Scanner;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
import java.util.stream.Stream;

class MyThread implements Runnable {
    @Override
    public void run() {
        System.out.println("Thread: " + Thread.currentThread().threadId());
    }
}

class Cntr {
    static int counter = 0;
    private static int ITERATIONS = 1_000_000;
    static Object lock = new Object();

    public static void main(String[] args) throws InterruptedException {
        Thread myThread = new Thread(() -> {
            for(int i = 0; i < ITERATIONS; i++) {
                synchronized (lock) {
                    counter++;
                }
            }
        });

        for(int i = 0; i < ITERATIONS; i++) {
            synchronized (lock) {
                counter++;
            }
        }

        myThread.start();
        myThread.join();
        System.out.println(counter);
    }
}

public class l2 {
    public static void main(String[] args) throws InterruptedException {
        System.out.println("Test");

        Thread myThread = new Thread(new MyThread());
        myThread.start();

        Thread anonThread = new Thread(() -> {
            System.out.println(Thread.currentThread().threadId());
        });

        anonThread.start();

        myThread.join();
        anonThread.join();
    }
}

// scrieti un program care citeste texte dintr-un fisier text
// pune continutul textelor in Buffer (producer)
// iar consumatorii afiseaza la STDOUT
// sirurile citite din buffer
// cu o operatie minimala asupra lor (toUpper etc)
// a. un singur fisier text
// b. o ierarhie de foldere care contin fisiere text
//      si cu mai multi produceri si mai multi consumeri
// TODO: la examen in fiecare an (b.)
class Producer implements Runnable {
    private PCDDrop buffer;

    public Producer(PCDDrop buffer) {
        this.buffer = buffer;
    }
    @Override
    public void run() {
        try (Scanner sc = new Scanner(new File("/home/cosmin/Desktop/Facultate/Anul_IV/Sem_I/Concurenta/Cod_ICLP/Lab/a.txt"))) {
            while (sc.hasNextLine()) {
                String line = sc.nextLine();
                this.buffer.put(line);
                System.out.println("dbg prod: " + line);
            }
            this.buffer.put("DONE");
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}

class Consumer implements Runnable {
    private PCDDrop buffer;

    public Consumer(PCDDrop buffer) {
        this.buffer = buffer;
    }

    @Override
    public void run() {
        String line;
        while ((line = this.buffer.take()) != "DONE") {
            System.out.println("dbg cons: " + line);
        }
    }
}

class PCDDrop {
    private String message;
    private boolean isEmpty = true;

    public synchronized String take() {
        while(isEmpty) {
            try {
                wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        isEmpty = true;
        notifyAll();
        return message;
    }

    public synchronized void put(String message) {
        while(!isEmpty) {
            try {
                wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        isEmpty = false;
        notifyAll();
        this.message = message;
    }
}

class ProdCons {
    public static void main(String[] args) throws InterruptedException {
        PCDDrop drp = new PCDDrop();

        Thread prod = new Thread(new Producer(drp));
        Thread cons = new Thread(new Consumer(drp));

        prod.start();
        cons.start();

        prod.join();
        cons.join();
    }
}

// ====================================================================
// b.

// /home/cosmin/Desktop/Facultate/Anul_IV/Sem_I/Concurenta/Cod_ICLP/Lab/fisiere
class PCDropB {
    private final List<String> buffer = new LinkedList<>();
    private final int capacity;
    private int producersDone = 0;
    private final int totalProducers;

    public PCDropB(int capacity, int totalProducers) {
        this.capacity = capacity;
        this.totalProducers = totalProducers;
    }

    public synchronized void put(String message) throws InterruptedException {
        while(buffer.size() == capacity) {
            wait();
        }
        buffer.add(message);
        notifyAll();
    }

    public synchronized String take() throws InterruptedException {
        while(buffer.isEmpty()) {
            wait();
        }
        String msg = buffer.remove(0);
        notifyAll();
        return msg;
    }

    public synchronized void producerDone() {
        producersDone++;
        notifyAll();
    }

    public synchronized boolean allProducersDone() {
        return producersDone == totalProducers;
    }
}

class ProducerB implements Runnable {
    private final PCDropB buffer;
    private final List<File> files;

    public ProducerB(PCDropB buffer, List<File> files) {
        this.buffer = buffer;
        this.files = files;
    }

    @Override
    public void run() {
        try {
            for(File file : files) {
                try(BufferedReader reader = new BufferedReader(new FileReader(file))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        buffer.put(line);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            buffer.producerDone();
        }
    }
}

class ConsumerB implements Runnable {
    private final PCDropB buffer;
    private final AtomicInteger doneMessagesNeeded;

    public ConsumerB(PCDropB buffer, AtomicInteger doneMessagesNeeded) {
        this.buffer = buffer;
        this.doneMessagesNeeded = doneMessagesNeeded;
    }

    @Override
    public void run() {
        try {
            while(true) {
                String line = buffer.take();
                if(line == null) continue;
                if(line.equals("DONE")) {
                    break;
                }
                System.out.println(Thread.currentThread().getName() + ": " + line.toUpperCase());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

class ProdConsB {
    public static List<File> findTextFiles(File rootDir) throws IOException {
        try (Stream<Path> paths = Files.walk(rootDir.toPath())) {
            return paths
                    .filter(Files::isRegularFile)
                    .filter(p -> p.toString().endsWith(".txt"))
                    .map(Path::toFile)
                    .collect(Collectors.toList());
        }
    }

    public static void main(String[] args) throws InterruptedException, IOException {
        int numProducers = 2;
        int numConsumers = 3;
        int bufferCapacity = 10;

        File rootDir = new File("/home/cosmin/Desktop/Facultate/Anul_IV/Sem_I/Concurenta/Cod_ICLP/Lab/fisiere");

        List<File> allTextFiles = findTextFiles(rootDir);
        if(allTextFiles.isEmpty()) {
            System.out.println("No text files here!");
            return;
        }

        PCDropB buffer = new PCDropB(bufferCapacity, numProducers);
        AtomicInteger doneMessages = new AtomicInteger(numConsumers);

        List<List<File>> splits = new ArrayList<>();
        for(int i = 0; i < numProducers; i++) splits.add(new ArrayList<>());
        for(int i = 0; i < allTextFiles.size(); i++)
            splits.get(i % numProducers).add(allTextFiles.get(i));

        List<Thread> threads = new ArrayList<>();
        for(int i = 0; i < numProducers; i++) {
            Thread t = new Thread(new ProducerB(buffer, splits.get(i)), "Producer-" + i);
            threads.add(t);
            t.start();
        }

        for (int i = 0; i < numConsumers; i++) {
            Thread t = new Thread(new ConsumerB(buffer, doneMessages), "Consumer-" + i);
            threads.add(t);
            t.start();
        }

        Thread doneThread = new Thread(() -> {
            try {
                synchronized (buffer) {
                    while(!buffer.allProducersDone()) {
                        buffer.wait();
                    }
                }
                for(int i = 0; i < numConsumers; i++) {
                    buffer.put("DONE");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
        doneThread.start();

        for (Thread t : threads) t.join();
        doneThread.join();

        System.out.println("FIN");
    }
}


// import java.util.concurrent.Semaphore;

// // Reader-Writer modificat

// public class Main {
//     private static final int MAX_CITITORI = 3; // N fixat
//     private static final Semaphore resursa = new Semaphore(1);
//     private static final Semaphore cititorMutex = new Semaphore(1); // mutex pt cititor
//     private static final Semaphore NCititori = new Semaphore(MAX_CITITORI);
//     private static final Semaphore wrt = new Semaphore(1);
//     private static final Semaphore cor = new Semaphore(1);

//     private static int nrCititori = 0;
//     private static int nrCorector = 0;

//     public static void main(String[] args) {
//         for(int i=0;i<5;i++)
//             new Thread(new Cititor()).start();
        
//         for(int i=0;i<5;i++)
//             new Thread(new Corector()).start();

//         for(int i=0;i<5;i++)
//             new Thread(new Scriitor()).start();
//     }

//     static class Cititor implements Runnable {
//         @Override 
//         public void run() {
//             while (true) {
//                 try {
//                     NCititori.acquire();
//                     cititorMutex.acquire();
//                     if(nrCititori + 1 == 1) {
//                         nrCititori++;
//                         resursa.acquire();
//                     }
//                     cititorMutex.release();

//                     System.out.println("Cititor " + Thread.currentThread().threadId() + " citeste");
//                     Thread.sleep(1000);

//                     cititorMutex.acquire();
//                     if(nrCititori - 1 == 0)
//                     {
//                         nrCititori--;
//                         resursa.release();

//                     }
//                     cititorMutex.release();
//                     NCititori.release();

//                     Thread.sleep(1500);
//                 } catch (InterruptedException ex) {
//                     ex.printStackTrace();
//                 }
//             }
//         }
//     }

//     static class Corector implements Runnable {
//     @Override public void run() {
//         while (true) {
//             try {
//                 cor.acquire();
//                 if(nrCorector+1 == 1) {
//                     nrCorector++;
//                     wrt.acquire();
//                 }
//                 cor.release();

//                 resursa.acquire();
//                 System.out.println("Corector " + Thread.currentThread().getId() + " corecteaza");
//                 Thread.sleep(1200);
//                 resursa.release();

//                 cor.acquire();
//                 if(nrCorector -1 == 0)
//                 {
//                     nrCorector--;
//                     wrt.release();

//                 }
//                 cor.release();
                

//                 Thread.sleep(2000);
//             } catch (InterruptedException ex) {
//                 ex.printStackTrace();
//             }
//             }
//         }
//     }

//     static class Scriitor implements Runnable {
//         @Override public void run() {
//             while(true) {
//                 try {
//                     wrt.acquire();
//                     resursa.acquire();

//                     System.out.println("Scriitor " + Thread.currentThread().getId() + " scrie");
//                     Thread.sleep(1500);

//                     resursa.release();
//                     wrt.release();

//                     Thread.sleep(2500);
//                 } catch (InterruptedException ex) {
//                     ex.printStackTrace();
//                 }
//             }
//         }
//     }
// }
