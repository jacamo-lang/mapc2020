package runMAPC2020;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;
import java.util.Scanner;

public class GuiText {
    
    public GuiText(Control control) {
        Scanner input = new Scanner(System.in);
        System.out.println("------------- SELECIONE A SIMULAÇÃO -------------");
        List<String> files = listFiles();
        for (int i = 0; i < files.size(); i++) {
            System.out.println(i + " - " + files.get(i));
        }
        String simulation = files.get(input.nextInt());
        boolean browser = false;
        input.nextLine();
        System.out.println("Abrir um navegador?[s/N]");
        String aux = input.nextLine();
        if (aux.toLowerCase().equals("s"))
            browser = true;
        control.start(simulation, browser, false);
    }

    public List<String> listFiles() {
        List<String> listFiles = new LinkedList<>();
        File folder = null;
        try {
            folder = new File(new File("src/jcm/").getCanonicalPath());
        } catch (IOException e) {
            e.printStackTrace();
        }
        for (File fileEntry : folder.listFiles()) {
            if (fileEntry.isFile() && fileEntry.getName().contains(".jcm")) {
                listFiles.add("src/jcm/" + fileEntry.getName());
            }
        }
        return listFiles;
    }
}
