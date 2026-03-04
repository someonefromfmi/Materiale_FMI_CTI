package Cod_ICLP.Lab;

// fie urmatorul scenariu
// modelam un Blockchain
// pp ca avem un pool de trazactii
// avem N noduri in paralel care vor sa valideze tranzactiile respective
// (5 tranzactii per node))
// fiecare valideaza tranzactiile si le adauga intr-un block
// pe care apoi sa il lege de blockchain
// nodurile simuleaza PoW(asteapta un maxim de 1000ms) (Thread.sleep() * Math.random())

import java.util.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.Semaphore;
import java.util.concurrent.locks.ReentrantLock;

/*
* class Transaction - id
* class Block - index, hash, previousHash
* class Blockchain - List<Block>
class Node - aici se intampla paralelismul
* folosim LinkedBlcokingQueue - structura de date concurenta
* */
class Transaction {
    private String id;

    public Transaction(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }
}

class Block {
    private int index;
    private List<Transaction> transactions;
    private String previousHash;
    private String hash;

    public Block(int index, List<Transaction> transactions, String previousHash) {
        this.index = index;
        this.transactions = transactions;
        this.previousHash = previousHash;
        this.hash = computeHash();
    }

    private String computeHash() {
        return Integer.toHexString(Objects.hash(index, transactions, previousHash));
    }

    public String getHash() {
        return this.hash;
    }

    public String getPreviousHash() {
        return this.previousHash;
    }

    public int getIndex() {
        return this.index;
    }
}

class Blockchain {
    private List<Block> chain = new ArrayList<>();
    private ReentrantLock lock = new ReentrantLock();

    public Blockchain() {
        chain.add(new Block(0, new ArrayList<>(), "0"));
    }

    public void addBlock(Block block) {
        lock.lock();
        try {
            if(chain.get(chain.size() - 1).getHash().equals(block.getPreviousHash())) {
                chain.add(block);
                System.out.println("Block added: " + block.getIndex() + " with hash " + block.getHash());
            }
        } finally {
            lock.unlock();
        }
    }

    public Block getLastBlock() {
        return chain.get(chain.size() - 1);
    }
}

class Node implements Runnable {
    private Blockchain blockchain;
    private BlockingQueue<Transaction> transactionPool;
    private String nodeId;

    public Node(String id, Blockchain blockchain, BlockingQueue<Transaction> transactionPool) {
        this.blockchain = blockchain;
        this.transactionPool = transactionPool;
        this.nodeId = id;
    }

    @Override
    public void run() {
        while(true) {
            try {
                List<Transaction> transactions = new ArrayList<>();
                transactionPool.drainTo(transactions, 5);

                if(!transactions.isEmpty()) {
                    Block previousBlock = blockchain.getLastBlock();
                    Block newBlock = new Block(previousBlock.getIndex() + 1, transactions, previousBlock.getHash());

                    // simulam PoW
                    Thread.sleep((long) (Math.random() * 1000));

                    blockchain.addBlock(newBlock);
                } else {
                    System.out.println(nodeId + " found no transactions. Waiting...");
                    Thread.sleep(500);
                }
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
    }
}

public class l3 {
    public static void main(String[] args) {
        BlockingQueue<Transaction> transactionPool = new LinkedBlockingQueue<>();
        Blockchain blockchain = new Blockchain();

        Thread node1 = new Thread(new Node("Node 1", blockchain, transactionPool));
        Thread node2 = new Thread(new Node("Node 2", blockchain, transactionPool));
        Thread node3 = new Thread(new Node("Node 3", blockchain, transactionPool));

        node1.start();
        node2.start();
        node3.start();

        for(int i = 0; i < 100; i++) {
            System.out.println("Added transaction: " + i);
            transactionPool.add(new Transaction("Transaction " + i));

            try {
                Thread.sleep((long) (Math.random() * 300));
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

// nu mai folositi ChatGPT e toxic multumesc
// pastebin cod: https://pastebin.com/kQv2uXjA

/*
* modelam scenariul Reader-Writer
* avem un singur Writer care poate scrie la un moment de timp in zona
* critica de memorie dar putem avea mai multi Readeri simultam
*
* avem doua semafoare - unul pentru a gestiona ce rol are acces
* respectiv unul pentru sincronizarea operatiilor pe readeri
* */

/*
* trb sa tinem minte nr de readeri
* ReaderCounter.inc()
* */

class ReaderCounter {
    private static int count = 0;

    public static int get() {
        return count;
    }

    public static void inc() {
        count++;
    }

    public static void dec() {
        count--;
    }
}

class Writer implements Runnable {
    private Semaphore wrt;

    public Writer(Semaphore wrt) {
        this.wrt = wrt;
    }

    @Override
    public void run() {
        while(true) {
            try {
                wrt.acquire();

                System.out.println(Thread.currentThread().getName() + " writes...");

                Thread.sleep(3000);
                wrt.release();
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

class Reader implements Runnable {
    private Semaphore wrt;
    private Semaphore mutex;

    public Reader(Semaphore wrt, Semaphore mutex) {
        this.wrt = wrt;
        this.mutex = mutex;
    }

    @Override
    public void run() {
        while(true) {
            try {
                mutex.acquire();
                ReaderCounter.inc();

                if(ReaderCounter.get() == 1) {
                    wrt.acquire();
                }

                mutex.release();

                System.out.println(Thread.currentThread().getName() + " reads... ");
                Thread.sleep(1000);

                mutex.acquire();
                ReaderCounter.dec();

                if(ReaderCounter.get() == 0)
                    wrt.release();

                mutex.release();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

class ReaderWriter {
    public static void main(String[] args) {
        Semaphore wrt = new Semaphore(1);
        Semaphore mutex = new Semaphore(1);
        (new Thread(new Writer(wrt))).start();
        (new Thread(new Writer(wrt))).start();

        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Reader(wrt, mutex))).start();
        (new Thread(new Reader(wrt, mutex))).start();
    }
}

// https://pastebin.com/eauFgTeh
// cs.unibuc.ro/~bmacovei/iclp


