package org.example;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

class ReaderWriter {
    private static Integer counter = 0; // resursa
    private static ReadWriteLock lock = new ReentrantReadWriteLock();

    static class TaskW implements Runnable {
        @Override
        public void run() {

            lock.writeLock().lock();

            try {
                int temp = counter;
                // fiecare thread incrementeaza contorul de 5 ori
                for(int i = 0; i < 5; i++) {
                    counter++;
                    Thread.currentThread().sleep(1);
                }
                System.out.println(Thread.currentThread().getName() + " Writer - before:"
                        + temp + " after:" + counter);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.writeLock().unlock();
            }
        }
    }

    static class TaskR implements Runnable {
        @Override
        public void run() {
            lock.readLock().lock();

            try {
                System.out.println(Thread.currentThread().getName() + " Reader counter: " + counter);
            } finally {
                lock.readLock().unlock();
            }
        }
    }

    public static void main(String[] args) {

        (new Thread(new TaskW())).start();
        (new Thread(new TaskR())).start();
        (new Thread(new TaskR())).start();
        (new Thread(new TaskW())).start();
        (new Thread(new TaskR())).start();
        (new Thread(new TaskR())).start();
        (new Thread(new TaskR())).start();
        (new Thread(new TaskW())).start();
    }
}

class Semaphores {
    static Semaphore semaphore = new Semaphore(3);

    static class MyThread extends Thread {
        // thread-ul va face acquire, va executa task-urile, apoi va face release
        String name = "";
        MyThread(String name) { this.name = name; }

        @Override
        public void run() {
            try {
                // acquire poate pune thread-urile in asteptare, deci poate arunca o exceptie
                semaphore.acquire();
                try {
                    for(int i = 1; i <= 3; i++) {
                        System.out.println(name + ": is performing operation " + i);
                    }
                    Thread.sleep(ThreadLocalRandom.current().nextInt(1000));
                } finally {
                    semaphore.release();
                }
            } catch(InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) {
        MyThread t1 = new MyThread("A"); t1.start();
        MyThread t2 = new MyThread("B"); t2.start();
        MyThread t3 = new MyThread("C"); t3.start();
        MyThread t4 = new MyThread("D"); t4.start();
    }
}

// ================================================================
// generarea thread-urilor folosind executors
// doua thread-uri care incrementeaza acelasi contor

class Task implements Runnable {
    static Integer counter = 0;

    @Override
    public void run() {
        for(int i = 0; i < 5; i++)
            performTask();
    }

    private synchronized void performTask() {
        int temp = counter;
        counter++;
        System.out.println(Thread.currentThread()
                .getName() + "-before:"+temp+" after:" + counter);
    }

    public static void main(String[] args) throws InterruptedException {
        ExecutorService pool = Executors.newCachedThreadPool();
        for(int i = 0; i < 3; i++)
            pool.execute(new Task());
        pool.shutdown();
        try {
            if (!pool.awaitTermination(3500, TimeUnit.MILLISECONDS)) {
                pool.shutdownNow();
            }
        } catch (InterruptedException e) {
            pool.shutdownNow();
        }
    }
}

// exemplu: ReaderWriter - generarea thread-urilor folosind executors
class ReaderWriterE {
    private static Integer counter = 0;
    private static final ReadWriteLock lock = new ReentrantReadWriteLock();

    static class TaskW implements Runnable {
        @Override
        public void run() {

            lock.writeLock().lock();

            try {
                int temp = counter;
                // fiecare thread incrementeaza contorul de 5 ori
                for(int i = 0; i < 5; i++) {
                    counter++;
                    Thread.currentThread().sleep(1);
                }
                System.out.println(Thread.currentThread().getName() + " Writer - before:"
                        + temp + " after:" + counter);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.writeLock().unlock();
            }
        }
    }

    static class TaskR implements Runnable {
        @Override
        public void run() {
            lock.readLock().lock();

            try {
                System.out.println(Thread.currentThread().getName() + " Reader counter: " + counter);
            } finally {
                lock.readLock().unlock();
            }
        }
    }

    public static void main(String[] args) {
        ExecutorService pool = Executors.newCachedThreadPool();
        pool.execute(new TaskW());
        pool.execute(new TaskR());
        pool.execute(new TaskW());
        pool.execute(new TaskR());
        pool.execute(new TaskR());
        pool.shutdown();
    }
}

class CallableAndFuture {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService exec = Executors.newSingleThreadExecutor();
        Callable<String> callable = new Callable<String>() {
            @Override
            public String call() throws Exception {
                Thread.sleep(2000);
                return "Return some result";
            }
        };
        // callable reprezinta o executie asincrona, al carei rezultat este
        // recuperat cu ajutorul unui obiect Future

        Future<String> future = exec.submit(callable);
        System.out.println(future.get());

        exec.shutdown();
    }
}

// executie asincrona
// implementarea unei instante a clasei Callable care intoarce un <String>
// instanta va fi folosita pentru a crea un obiect Future
class CallableFuture {
    static class TaskCallable implements Callable<String> {
        private static int ts;
        public TaskCallable(int ts) {this.ts = ts;}

        public String call() throws InterruptedException {
            System.out.println("Entered Callable; sleep" + ts);
            Thread.sleep(ts);
            return "Hello from Callable";
        }
    }

    public static void main(String[] args) throws Exception {
        ExecutorService pool = Executors.newSingleThreadExecutor();

        int time = ThreadLocalRandom.current().nextInt(1000,5000);

        System.out.println("Creating future");
        Future<String> futureEx = pool.submit(new TaskCallable(time));
        /* argumentul lui submit poate fi o functie anonima
        Future<String> futureEx = pool.submit(() -> {
            try { Thread.sleep(time);}
            catch(InterruptedException e) {System.out.println("error");}
            finally {return "Hello from Callable!";}
        });
         */

        // TODO: Ceva problematic aici la thenAccept, dar ns ce
        // CompletableFuture implementeaza interfata Future si reprezinta o executie asincrona
//        CompletableFuture.runAsync(()-> {
//            try{Thread.sleep(1000);} catch (InterruptedException e) {System.out.println("error");}
//            finally {return "Hello from Completable Future!";}
//        }).thenApply(
//                (String s) -> s + "!"
//        ).thenAccept((String s) ->
//            { System.out.println(s); });

        System.out.println("Do something else while callable is getting executed");

        while(!futureEx.isDone()) {
            System.out.println("Task is still not done...");
            Thread.sleep(2000);
        }

        System.out.println("Retrieve the result of the future");
        String result = futureEx.get();
        System.out.println(result);

       pool.shutdown();
    }
}

// ==================================================================
// fork-join framework cu RecursiveAction
class MyRecursiveAction extends RecursiveAction {
    private long workLoad;

    public MyRecursiveAction(long workLoad) {
        this.workLoad = workLoad;
    }

    protected void compute() {
        if (this.workLoad > 15) {
            System.out.println("Splitting workload: " + this.workLoad);
            List<MyRecursiveAction> subtasks = new ArrayList<MyRecursiveAction>();
            subtasks.addAll(createSubtasks());
            invokeAll(subtasks); // trimite in executie toate task-urile (face fork() pe toate task-urile)
        } else {
            // prelucrata de threadul curent
            System.out.println("Doing workload myself: " + this.workLoad);
        }
    }

    private List<MyRecursiveAction> createSubtasks() {
        List<MyRecursiveAction> subtasks = new ArrayList<MyRecursiveAction>();

        MyRecursiveAction subtask1 = new MyRecursiveAction(this.workLoad/2);
        MyRecursiveAction subtask2 = new MyRecursiveAction(this.workLoad/2);

        subtasks.add(subtask1);
        subtasks.add(subtask2);

        return subtasks;
    }

    public static void main(String[] args) {
        ForkJoinPool forkJoinPool = new ForkJoinPool(4);
        MyRecursiveAction myRecursiveAction = new MyRecursiveAction(64);
        forkJoinPool.invoke(myRecursiveAction);
    }
}

// fork-join framework cu RecursiveTask<V>
// TODO: Ceva ciudat aici? c3s49
class MyRecursiveTask extends RecursiveTask<Integer> {
    private long workLoad;

    public MyRecursiveTask(long workLoad) {
        this.workLoad = workLoad;
    }

    protected Integer compute() {
        if(this.workLoad > 15) {
            System.out.println("Splitting workLoad : " + this.workLoad);
            List<MyRecursiveTask> subtasks = new ArrayList<MyRecursiveTask>();
            subtasks.addAll(createSubtasks());
            invokeAll(subtasks);
            // return joinresult(subtasks);} // calculeaza rezultatele subtask-urilor care se
            // obtin cu subtask.get()

            int result = 0;
            try{
                for(MyRecursiveTask subtask : subtasks) { result = result + 2* subtask.get();}
                System.out.println("Partial result: " + result);
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            };
            return result;
        } else {
            System.out.println("Doing workLoad myself: " + this.workLoad);
            return Integer.valueOf((int)workLoad);
        }
    }

    private List<MyRecursiveTask> createSubtasks() {
        List<MyRecursiveTask> subtasks = new ArrayList<MyRecursiveTask>();

        MyRecursiveTask subtask1 = new MyRecursiveTask(this.workLoad/2);
        MyRecursiveTask subtask2 = new MyRecursiveTask(this.workLoad/2);

        subtasks.add(subtask1);
        subtasks.add(subtask2);

        return subtasks;
    }

    public static void main(String[] args) {
        ForkJoinPool forkJoinPool = ForkJoinPool.commonPool();
        MyRecursiveTask myRecursiveTask = new MyRecursiveTask(64);
        int res = forkJoinPool.invoke(myRecursiveTask);
        System.out.println("Result = " + res);
    }
}

class Main {
    public static void main(String[] args) {
        System.out.println("hi");
    }
}
