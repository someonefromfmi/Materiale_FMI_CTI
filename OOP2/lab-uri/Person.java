import java.util.*;

enum FieldType {
    ID,
    Name
}

public record Person (int id, String name) {}

interface Storage {
    void addPers(Person p);
}

class ListStorage implements Storage {
    List<Person> myList;

    @Override
    public void addPers(Person p) {
        myList.add(p);
    }
}

class MapStorage implements Storage {
    Map<Integer, String> myMap = new HashMap<>();

    @Override
    public void addPers(Person p) {
        myMap.put(p.id(), p.name());
}
}

class Repository {

    Storage s;

    public Repository(Storage st) {
        this.s = st;
    }

    public static void main(String args[]) {
        Repository r = new Repository(new MapStorage());
    }
    
}
