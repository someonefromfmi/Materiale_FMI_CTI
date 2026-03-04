import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.concurrent.CompletableFuture;

public class ComplFutureTask {
    public static void main(String[] args) {

        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            try {
                return call("https://fmi.unibuc.ro");
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        });

        future.thenAccept((response) -> {
            String itemRegex = "<a[^>]*href=\"([^\"]*)\"[^>]*>(.*?)</a>";

            String noutatiBlockRegex = "Noutăți.*?<ul[^>]*>(.*?)</ul>";
            String noutatiBlock = extract(noutatiBlockRegex, response);

            if (!noutatiBlock.isEmpty()) {
                System.out.println();
                System.out.println("- Noutăți -");
                System.out.println(extractAllAnnouncements(itemRegex, noutatiBlock));
            }

            String secretariatBlockRegex = "Anunțuri secretariat.*?<ul[^>]*>(.*?)</ul>";
            String secretariatBlock = extract(secretariatBlockRegex, response);

            if (!secretariatBlock.isEmpty()) {
                System.out.println();
                System.out.println("- Anunțuri secretariat -");
                System.out.println(extractAllAnnouncements(itemRegex, secretariatBlock));
            }

            String doctoratBlockRegex = "Anunțuri doctorat.*?<ul[^>]*>(.*?)</ul>";
            String doctoratBlock = extract(doctoratBlockRegex, response);

            if (!doctoratBlock.isEmpty()) {
                System.out.println();
                System.out.println("- Anunțuri doctorat -");
                System.out.println(extractAllAnnouncements(itemRegex, doctoratBlock));
            }

        }).join();
    }

    public static String call(String url) throws Exception {
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
        System.out.println("Crawled " + url);
        return content.toString();
    }

    public static String extract(String regex, String input) {
        Pattern pattern = Pattern.compile(regex, Pattern.DOTALL);
        Matcher matcher = pattern.matcher(input);
        if (matcher.find()){
            return matcher.group(1).trim();
        }

        return "";
    }

    public static String extractAllAnnouncements(String regex, String input) {
        StringBuilder content = new StringBuilder();
        Pattern pattern = Pattern.compile(regex, Pattern.DOTALL);
        Matcher matcher = pattern.matcher(input);

        while (matcher.find()){
            String url = matcher.group(1).trim();
            String text = matcher.group(2).trim();

            content.append("TEXT: ").append(text);
            content.append("\n");
            content.append("LINK: ").append(url);
            content.append("\n--------------------------------\n");
        }

        return content.toString();
    }
}