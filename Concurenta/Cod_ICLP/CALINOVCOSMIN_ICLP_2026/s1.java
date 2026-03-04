package Cod_ICLP.CALINOVCOSMIN_ICLP_2026;

import java.util.concurrent.Semaphore;

public class s1 {
    private static final int N = 3;

    private static int nrCititori = 0;
    private static int nrCorectori = 0;

    private static final Semaphore resursa = new Semaphore(1);
    private static final Semaphore wrt = new Semaphore(1);
    private static final Semaphore cor = new Semaphore(1);

    private static final Semaphore cititorMutex = new Semaphore(1);
    private static final Semaphore NCititori = new Semaphore(N);

    static class Cititor implements Runnable {
        @Override
        public void run() {
            while (true) {
                try {
                    NCititori.acquire();
                    cititorMutex.acquire();
                    if(nrCititori+1 == 1) {
                        nrCititori++;
                        resursa.acquire();
                    }
                    cititorMutex.release();

                    System.out.println(Thread.currentThread().threadId() + " citeste...");
                    Thread.sleep(1000);

                    cititorMutex.acquire();
                    if(nrCititori-1 == 0) {
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
                if(nrCorectori+1 == 1) {
                    nrCorectori++;
                    wrt.acquire();
                }
                cor.release();

                resursa.acquire();
                System.out.println(Thread.currentThread().threadId() + " corecteaza..");
                Thread.sleep(1200);
                resursa.release();

                cor.acquire();
                if(nrCorectori-1 == 0) {
                    nrCorectori--;
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

                    System.out.println(Thread.currentThread().threadId() + " scrie...");
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

    public static void main(String[] args) {
        for(int i=0; i<5; i++) new Thread(new Cititor()).start();
        for(int i=0; i<5; i++) new Thread(new Corector()).start();
        for(int i=0; i<3; i++) new Thread(new Scriitor()).start();
    }
}
