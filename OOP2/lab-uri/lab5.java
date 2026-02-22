import java.util.Vector;

class ErrUtiliz extends RuntimeException {}

class NumeGresit extends ErrUtiliz {}
class ParolaGresita extends ErrUtiliz {}

abstract class Document {

}

class DocEducatie extends Document {

}

class DocCultura extends Document {

}

class User {
    private String name;
    private String password;

    public User(String un, String pass) {
        this.name = un;
        this.password = pass;
    }

    public String getName() {
        return this.name;
    }

    public String getPass() {
        return this.password;
    }

    public void sendData(Departament d) {
        if(this.name.equals("Gigel")) {
            throw new NumeGresit();
        }
        if(this.password.equals("Gigel")) {
            throw new ParolaGresita();
        }
    }
    
}

abstract class Departament {
    abstract public void handleDoc(User u, Document doc);
    
}

class Education extends Departament {
    public void handleDoc(User u, Document doc) {
        if(!(doc instanceof DocEducatie)) {
            throw new RuntimeException();
        }
    }
}

class Culture extends Departament {
    public void handleDoc(User u, Document doc) {
        if(!(doc instanceof DocEducatie)) {
            throw new RuntimeException();
        }
    }
}


public class lab5 {
    public static void main(String[] args) {
        User gig = new User("Gigel", "Gigel");
        Departament d = new Education();
        DocEducatie de = new DocEducatie();
        try{
            d.handleDoc(gig, de);
        } catch(ErrUtiliz eu) {
            System.out.println("Te rog introdu un alt nume");
        }
        

    }
}
