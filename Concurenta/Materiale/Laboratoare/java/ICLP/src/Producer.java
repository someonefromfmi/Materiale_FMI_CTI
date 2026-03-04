import java.io.File;
import java.util.Scanner;

public class Producer extends Thread {
    PCDrop buffer;
    String filePath = "";
    public Producer(PCDrop buffer, String filePath) {
        this.buffer = buffer;
        this.filePath = filePath;
    }
    public void run() {
        // open ./input.txt
        File f = new File(filePath);

        try (Scanner myReader = new Scanner(f)) {
            while (myReader.hasNextLine()) {
                buffer.put(myReader.nextLine());
            }
            buffer.put("DONE");
        } catch (Exception e) {
            System.out.println("plang");
        }
    }
}
