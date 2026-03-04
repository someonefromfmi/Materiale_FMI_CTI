public class PCDrop {
    private String message;
    private boolean isEmpty = true;

    public synchronized String take(){
        while (isEmpty){
            try {
                wait();
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        }
        isEmpty = true;
        notifyAll();
        return message;

    }

    public synchronized void put(String message){
        while (!isEmpty){
            try {
                wait();
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        }
        notifyAll();
        isEmpty = false;
        this.message = message;
    }


}
