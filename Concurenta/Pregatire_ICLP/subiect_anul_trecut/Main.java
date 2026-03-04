import java.util.concurrent.Semaphore;

// Reader-Writer modificat

public class Main {
    private static final int MAX_CITITORI = 3; // N fixat
    private static final Semaphore resursa = new Semaphore(1);
    private static final Semaphore cititorMutex = new Semaphore(1); // mutex pt cititor
    private static final Semaphore NCititori = new Semaphore(MAX_CITITORI);
    private static final Semaphore wrt = new Semaphore(1);
    private static final Semaphore cor = new Semaphore(1);

    private static int nrCititori = 0;
    private static int nrCorector = 0;

    public static void main(String[] args) {
        for(int i=0;i<5;i++)
            new Thread(new Cititor()).start();
        
        for(int i=0;i<5;i++)
            new Thread(new Corector()).start();

        for(int i=0;i<5;i++)
            new Thread(new Scriitor()).start();
    }

    static class Cititor implements Runnable {
        @Override 
        public void run() {
            while (true) {
                try {
                    NCititori.acquire();
                    cititorMutex.acquire();
                    if(nrCititori + 1 == 1) {
                        nrCititori++;
                        resursa.acquire();
                    }
                    cititorMutex.release();

                    System.out.println("Cititor " + Thread.currentThread().threadId() + " citeste");
                    Thread.sleep(1000);

                    cititorMutex.acquire();
                    if(nrCititori - 1 == 0)
                    {
                        nrCititori--;
                        resursa.release();

                    }
                    cititorMutex.release();
                    NCititori.release();

                    Thread.sleep(1500);
                } catch (InterruptedException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    static class Corector implements Runnable {
    @Override public void run() {
        while (true) {
            try {
                cor.acquire();
                if(nrCorector+1 == 1) {
                    nrCorector++;
                    wrt.acquire();
                }
                cor.release();

                resursa.acquire();
                System.out.println("Corector " + Thread.currentThread().getId() + " corecteaza");
                Thread.sleep(1200);
                resursa.release();

                cor.acquire();
                if(nrCorector -1 == 0)
                {
                    nrCorector--;
                    wrt.release();

                }
                cor.release();
                

                Thread.sleep(2000);
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }
            }
        }
    }

    static class Scriitor implements Runnable {
        @Override public void run() {
            while(true) {
                try {
                    wrt.acquire();
                    resursa.acquire();

                    System.out.println("Scriitor " + Thread.currentThread().getId() + " scrie");
                    Thread.sleep(1500);

                    resursa.release();
                    wrt.release();

                    Thread.sleep(2500);
                } catch (InterruptedException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }
}

