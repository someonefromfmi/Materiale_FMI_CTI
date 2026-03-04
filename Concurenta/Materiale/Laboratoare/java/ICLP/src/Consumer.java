public class Consumer extends Thread {
    PCDrop buffer;
    public Consumer(PCDrop buffer) {
        this.buffer = buffer;
    }
    public void run() {
        String m = buffer.take();
        while (m != "DONE"){
            System.out.println(m);
            m = buffer.take();
        }
    }
}
