import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;

public class Main {
    public static void main(String[] args) {

        Callable<String> task = new MyTask();
        FutureTask<String> futureTask = new FutureTask<>(task);

        Callable<String> task2 = () -> {
            Thread.sleep(5000);
            return "alsdglsjkfng jksrhdvj hdfkv";
        };

        Thread thread = new Thread(futureTask);
        thread.start();

        FutureTask<String> futureTask2 = new FutureTask<>(task2);
        Thread thread2 = new Thread(futureTask2);
        thread2.start();

        try{
            System.out.println("MAIN");
            String result = futureTask.get();
            System.out.println(result);
            System.out.println(futureTask2.get());
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}

class MyTask implements Callable<String> {
    @Override
    public String call() throws Exception {
        try{
            Thread.sleep(5000);
            return "Task completed";
        }
        catch(InterruptedException e){
            return "Task interrupted";
        }
    }
}