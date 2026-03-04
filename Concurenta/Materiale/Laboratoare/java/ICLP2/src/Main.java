import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

public class Main {
    public static void main(String[] args) {
        List<Thread> nodes = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            nodes.add(new Thread(new Node()));
            nodes.getLast().start();
        }
    }
}

class Transaction{
    int id;
    static int cnt = 0;

    public Transaction(){
        this.id = cnt++;
    }


}

class Block {
    int index;
    static int cnt = 0;
    String hash, prevHash;
    List<Transaction> transactions = new ArrayList<>();

    public Block(String prevHash){
        index = cnt++;
        this.prevHash = prevHash;
    }

    public void generateHash(){
        this.hash = Integer.toHexString(this.hashCode());       // ik this is bad, idc
    }

    public void addTx(Transaction tx){
        transactions.add(tx);
    }

    public String getHash(){
        return hash;
    }

    public String getPrevHash(){
        return prevHash;
    }

    public int getIndex(){
        return index;
    }
}

class Blockchain{
    Block genesis = new Block("0000");
    List<Block> blocks = new ArrayList<>();
    private ReentrantLock lock = new ReentrantLock();

    public void addBlock(Block block) throws Exception {
        lock.lock();

        if (this.getLastBlock().getHash().equals(block.getHash())){
            throw new Exception("Bad hash");
        }
        blocks.add(block);

        lock.unlock();
    }

    public Block getLastBlock(){
        if (blocks.size() == 0){
            genesis.generateHash();
            return genesis;
        }
        return blocks.getLast();
    }

}

class Node implements Runnable{
    static Blockchain blockchain = new Blockchain();
    static int cnt = 0;
    int myId;

    {
        myId = cnt++;
    }

    @Override
    public void run() {
        while (true) {
            try {
                // generate 5 txs
                List<Transaction> txs = new ArrayList<Transaction>();
                for (int i = 0; i < 5; ++i) {
                    txs.add(new Transaction());
                }

                Block block = new Block(blockchain.getLastBlock().getHash());
                block.addTx(txs.get(0));
                block.addTx(txs.get(1));
                block.addTx(txs.get(2));
                block.addTx(txs.get(3));
                block.addTx(txs.get(4));
                block.generateHash();

                try {
                    blockchain.addBlock(block);
                } catch (Exception e) {
                    System.out.println(e.getMessage());
                    throw new RuntimeException(e);
                }
                System.out.println("Worker: " + myId + " added block: " + block.getIndex());
                Thread.sleep((long)(Math.random() * 25000));
            }
            catch (Exception e) {
                System.out.println("Failed to add block");
                System.out.println(e.getMessage());
            }
            finally{
            }
        }
    }
}