import java.io.File;
import java.util.Scanner;

public class ProducerConsumer {
    private static PCDrop buffer = new PCDrop();

    public static void traverseFolder(File[] files) throws InterruptedException {
        for (File f : files) {
//            System.out.println(f.getAbsolutePath());
            if (f.isDirectory()){
//                System.out.println("opening new dir " + f.getAbsolutePath());
                traverseFolder(f.listFiles());
            }
            else{
//                System.out.println("opening new file " + f.getAbsolutePath());
                // we expect only .txts otherwise
                PCDrop myBuffer = new PCDrop();
                Producer prod = new Producer(myBuffer, f.getAbsolutePath());
                Consumer cons = new Consumer(myBuffer);
                prod.start();
                cons.start();
                cons.join();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
//        String filePath = "D:\\Java\\ICLP\\src\\input.txt";
//        Producer prod = new Producer(buffer, filePath);
//        Consumer cons = new Consumer(buffer);
//
//        prod.start();
//        cons.start();
//        prod.join();
//        cons.join();

        // subpunctul b, cu ierarhie de foldere
        File[] files = (new File("D:\\Java\\ICLP\\Folder1")).listFiles();
        traverseFolder(files);
    }
}
