import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

public class Crawler {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        List<String> urls = List.of(
                "https://www.google.com",
                "https://www.baidu.com",
                "https://cs.unibuc.ro/~crusu"
        );

        List<FutureTask<String>> futureTasks = new ArrayList<>();

        for (String url : urls) {
            Callable<String> task = new CrawlerTask(url);
            FutureTask<String> futureTask = new FutureTask<>(task);
            futureTasks.add(futureTask);

            Thread thread = new Thread(futureTask);
            thread.start();
        }

        for (FutureTask<String> futureTask : futureTasks) {
            String result = futureTask.get();
            System.out.println("Result obtained: ");
            System.out.println(result);
        }
    }
}

class CrawlerTask implements Callable<String> {
    private String url;

    public CrawlerTask(String url) {
        this.url = url;
    }

    @Override
    public String call() throws Exception {
        StringBuilder content = new StringBuilder();
        try {
            System.out.println("About to crawl " + url);
            HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
            connection.setRequestMethod("GET");

            int status = connection.getResponseCode();

            if (status == 200) {
                BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    content.append(inputLine).append("\n");
                }
                in.close();
            }
            else {
                content.append(connection.getResponseMessage());
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return content.toString();
    }
}
