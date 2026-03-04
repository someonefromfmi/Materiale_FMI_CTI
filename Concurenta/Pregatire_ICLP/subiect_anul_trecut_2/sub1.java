import java.util.LinkedList;
import java.util.Queue;
import java.util.Random;

// ============================================================================
// Subiectul I - Java (maxim 3p)
// a. Buffer de dimensiune fixa - Producer-Consumer simplu
// b. Producer-Consumer cu tipuri de obiecte (0 si 1)
// ============================================================================

// ----------------------------------------------------------------------------
// a. Buffer de dimensiune fixa
// ----------------------------------------------------------------------------

class FixedBuffer {
    private final Queue<String> buffer = new LinkedList<>();
    private final int capacity;

    public FixedBuffer(int capacity) {
        this.capacity = capacity;
    }

    public synchronized void put(String item) throws InterruptedException {
        // Producatorul se blocheaza daca buffer-ul este plin
        while (buffer.size() == capacity) {
            System.out.println(Thread.currentThread().getName() + ": Buffer plin, astept...");
            wait(); // Blocheaza pana cand se face loc
        }
        
        buffer.add(item);
        System.out.println(Thread.currentThread().getName() + ": Pus in buffer -> " + item + 
                         " (dimensiune: " + buffer.size() + "/" + capacity + ")");
        notifyAll(); // Trezeste consumatorii
    }

    public synchronized String take() throws InterruptedException {
        // Consumatorul se blocheaza daca buffer-ul este gol
        while (buffer.isEmpty()) {
            System.out.println(Thread.currentThread().getName() + ": Buffer gol, astept...");
            wait(); // Blocheaza pana cand apare ceva
        }
        
        String item = buffer.poll();
        System.out.println(Thread.currentThread().getName() + ": Luat din buffer -> " + item + 
                         " (dimensiune: " + buffer.size() + "/" + capacity + ")");
        notifyAll(); // Trezeste producatorii
        return item;
    }
}

class SimpleProducer implements Runnable {
    private final FixedBuffer buffer;
    private final int id;

    public SimpleProducer(FixedBuffer buffer, int id) {
        this.buffer = buffer;
        this.id = id;
    }

    @Override
    public void run() {
        try {
            Random random = new Random();
            for (int i = 1; i <= 5; i++) {
                String item = "Item-P" + id + "-" + i;
                buffer.put(item);
                Thread.sleep(random.nextInt(1000)); // Simuleaza timp de productie
            }
            buffer.put("DONE-P" + id);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

class SimpleConsumer implements Runnable {
    private final FixedBuffer buffer;
    private final int id;

    public SimpleConsumer(FixedBuffer buffer, int id) {
        this.buffer = buffer;
        this.id = id;
    }

    @Override
    public void run() {
        try {
            Random random = new Random();
            while (true) {
                String item = buffer.take();
                if (item.startsWith("DONE")) {
                    System.out.println(Thread.currentThread().getName() + ": Primit semnal DONE, opresc.");
                    break;
                }
                // Simuleaza procesare (de exemplu, toUpperCase)
                System.out.println(Thread.currentThread().getName() + ": Procesat -> " + item.toUpperCase());
                Thread.sleep(random.nextInt(1500)); // Simuleaza timp de procesare
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

// ----------------------------------------------------------------------------
// b. Buffer cu tipuri de obiecte (0 si 1)
// ----------------------------------------------------------------------------

class TypedItem {
    private final int type; // 0 sau 1
    private final String data;

    public TypedItem(int type, String data) {
        this.type = type;
        this.data = data;
    }

    public int getType() {
        return type;
    }

    public String getData() {
        return data;
    }

    @Override
    public String toString() {
        return "TypedItem{type=" + type + ", data='" + data + "'}";
    }
}

class TypedBuffer {
    private final Queue<TypedItem> buffer = new LinkedList<>();
    private final int capacity;

    public TypedBuffer(int capacity) {
        this.capacity = capacity;
    }

    public synchronized void put(TypedItem item) throws InterruptedException {
        // Producatorul se blocheaza daca buffer-ul este plin
        while (buffer.size() == capacity) {
            System.out.println(Thread.currentThread().getName() + ": Buffer plin, astept...");
            wait();
        }
        
        buffer.add(item);
        System.out.println(Thread.currentThread().getName() + ": Pus in buffer -> " + item + 
                         " (dimensiune: " + buffer.size() + "/" + capacity + ")");
        notifyAll();
    }

    public synchronized TypedItem takeByType(int type) throws InterruptedException {
        // Consumatorul asteapta pana cand gaseste un element de tipul dorit
        while (true) {
            // Cauta in buffer un element de tipul dorit
            for (TypedItem item : buffer) {
                if (item.getType() == type) {
                    buffer.remove(item);
                    System.out.println(Thread.currentThread().getName() + ": Luat din buffer -> " + item + 
                                     " (dimensiune: " + buffer.size() + "/" + capacity + ")");
                    notifyAll();
                    return item;
                }
            }
            
            // Daca nu gaseste element de tipul dorit, asteapta
            System.out.println(Thread.currentThread().getName() + ": Nu gasesc element de tip " + type + ", astept...");
            wait();
        }
    }
}

class TypedProducer implements Runnable {
    private final TypedBuffer buffer;
    private final int id;

    public TypedProducer(TypedBuffer buffer, int id) {
        this.buffer = buffer;
        this.id = id;
    }

    @Override
    public void run() {
        try {
            Random random = new Random();
            for (int i = 1; i <= 6; i++) {
                // Produce obiecte de tip 0 sau 1 aleatoriu
                int type = random.nextInt(2); // 0 sau 1
                TypedItem item = new TypedItem(type, "Data-P" + id + "-" + i);
                buffer.put(item);
                Thread.sleep(random.nextInt(800));
            }
            // Trimite semnal DONE pentru fiecare tip
            buffer.put(new TypedItem(0, "DONE-P" + id));
            buffer.put(new TypedItem(1, "DONE-P" + id));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

class TypedConsumer implements Runnable {
    private final TypedBuffer buffer;
    private final int id;
    private final int preferredType; // Tipul de obiecte pe care il consuma (0 sau 1)

    public TypedConsumer(TypedBuffer buffer, int id, int preferredType) {
        this.buffer = buffer;
        this.id = id;
        this.preferredType = preferredType;
    }

    @Override
    public void run() {
        try {
            Random random = new Random();
            int itemsProcessed = 0;
            int doneCount = 0;
            while (doneCount < 2) { // Asteapta 2 mesaje DONE (de la fiecare producer)
                TypedItem item = buffer.takeByType(preferredType);
                
                if (item.getData().startsWith("DONE")) {
                    doneCount++;
                    System.out.println(Thread.currentThread().getName() + ": Primit DONE (" + doneCount + "/2)");
                    if (doneCount >= 2) {
                        break;
                    }
                    continue;
                }
                
                // Simuleaza procesare
                itemsProcessed++;
                System.out.println(Thread.currentThread().getName() + ": Procesat -> " + 
                                 item.getData().toUpperCase() + " [tip=" + item.getType() + "]");
                Thread.sleep(random.nextInt(1200));
            }
            System.out.println(Thread.currentThread().getName() + ": Terminat! (procesat " + itemsProcessed + " itemi)");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

// ----------------------------------------------------------------------------
// Main - Teste
// ----------------------------------------------------------------------------

public class sub1 {
    
    public static void testSimpleBuffer() throws InterruptedException {
        System.out.println("=== Test a) Buffer simplu de dimensiune fixa ===\n");
        
        FixedBuffer buffer = new FixedBuffer(3); // Capacitate 3
        
        Thread producer = new Thread(new SimpleProducer(buffer, 1), "Producer-1");
        Thread consumer = new Thread(new SimpleConsumer(buffer, 1), "Consumer-1");
        
        producer.start();
        consumer.start();
        
        producer.join();
        consumer.join();
        
        System.out.println("\n=== Test a) finalizat ===\n");
    }
    
    public static void testTypedBuffer() throws InterruptedException {
        System.out.println("=== Test b) Buffer cu tipuri de obiecte ===\n");
        
        TypedBuffer buffer = new TypedBuffer(5); // Capacitate 5
        
        // 2 producatori care produc obiecte de tip 0 si 1
        Thread producer1 = new Thread(new TypedProducer(buffer, 1), "Producer-1");
        Thread producer2 = new Thread(new TypedProducer(buffer, 2), "Producer-2");
        
        // 1 consumator pentru tip 0 si 1 consumator pentru tip 1
        Thread consumer_t0 = new Thread(new TypedConsumer(buffer, 1, 0), "Consumer-Type0");
        Thread consumer_t1 = new Thread(new TypedConsumer(buffer, 2, 1), "Consumer-Type1");
        
        producer1.start();
        producer2.start();
        consumer_t0.start();
        consumer_t1.start();
        
        producer1.join();
        producer2.join();
        consumer_t0.join();
        consumer_t1.join();
        
        System.out.println("\n=== Test b) finalizat ===\n");
    }
    
    public static void main(String[] args) {
        try {
            // Ruleaza testul (a)
            testSimpleBuffer();
            
            Thread.sleep(2000); // Pauza intre teste
            
            // Ruleaza testul (b)
            testTypedBuffer();
            
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
