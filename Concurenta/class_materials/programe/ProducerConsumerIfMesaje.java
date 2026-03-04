import java.util.Random;


public class ProducerConsumerIfMesaje {
    public static void main(String[] args) {
        PCDrop drop = new PCDrop();
        (new Thread(new PCProducer(drop))).start();
        (new Thread(new PCConsumer(drop))).start();
        (new Thread(new PCConsumer(drop))).start();
    }
    
}

class PCProducer implements Runnable {
    private PCDrop drop;

    public PCProducer(PCDrop drop) {
        this.drop = drop;
    }

    public void run() {
        String importantInfo[] = { "m1", "m2", "m3", "m4" };
        Random random = new Random();

        for (int i = 0; i < importantInfo.length; ++i) {
            drop.put(importantInfo[i]); 
            try {
                Thread.sleep(random.nextInt(5000));
            }
            catch (InterruptedException ex) {

            }
        }

        drop.put("DONE"); 
        drop.put("DONE");
    }
}

class PCConsumer implements Runnable {
    private PCDrop drop;

    public PCConsumer(PCDrop drop) {
        this.drop = drop;
    }

    public void run() {
        Random random = new Random();
        for (String message = drop.take(); !message.equals("DONE"); message = drop.take()) {
            System.out.println(Thread.currentThread().getName()+": Message received:"+ message);
            try {
                Thread.sleep(random.nextInt(5000));
            }
            catch (InterruptedException ex) {

            }
        }
        System.out.println(Thread.currentThread().getName()+": Message received: DONE");
        //drop.put("DONE");
    }
}

class PCDrop {
    private String message;
    private boolean empty = true;

    public synchronized String take() {
        if (empty) {
            try {
                System.out.println(Thread.currentThread().getName()+" is waiting to take.");
                wait();
            }
            catch (InterruptedException ex) {

            }
        }
        empty = true;
        notifyAll();
        return message;
    }

    public synchronized void put(String message) {
        if (!empty) {
            try {
                System.out.println(Thread.currentThread().getName()+" is waiting to put.");
                wait();
            }
        
            catch (InterruptedException ex) {

            }
        }
        empty = false;
        this.message = message;
        System.out.println(Thread.currentThread().getName()+": Message delivered:"+ message);
        notifyAll();
    }
}