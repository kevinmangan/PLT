import java.util.Iterator;

public class Writer{
    
    public static PCList print(PCObject toPrint){
    	PCList mylist = (PCList) toPrint;
        for(PCObject obj : mylist)
        {
            System.out.printf("%c", obj.<Character>getBase());
        }

        return mylist;
    }
}