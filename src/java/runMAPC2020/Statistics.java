package runMAPC2020;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;

import jacamo.infra.JaCaMoLauncher;

/**
 * @author cleber
 *
 */
public class Statistics {
    
    private static Statistics instance = null;
    final String matchesStatsFolder = "output/statistics/";
    final String matchesStatsFile   = "matches.csv";
    
    int id = 0;
    
    List<String> fields = new ArrayList<>();
    
    public static Statistics getInstance() 
    { 
        if (instance == null) 
            instance = new Statistics(); 
  
        return instance; 
    } 
    
    private Statistics() {
        //fields and sequence of columns in the CSV file
        this.fields.add("date");
        this.fields.add("host");
        this.fields.add("asls");
        this.fields.add("team");
        this.fields.add("event");
        this.fields.add("comment");
    }
    
    public void prepareMatchesStatsFile() {
        id = 0;
        
        createStatisticsFolders();
        
        File file = new File(matchesStatsFolder + matchesStatsFile);
        if ( !file.exists() ) {
            try (FileWriter fw = new FileWriter(matchesStatsFolder + matchesStatsFile, false);
                    BufferedWriter bw = new BufferedWriter(fw);
                    PrintWriter out = new PrintWriter(bw)) {
                out.print(StringUtils.join(this.fields, "\t"));
        
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    
    public void saveMatchStats(Map<String, String> data) {
        try (FileWriter fw = new FileWriter(matchesStatsFolder + matchesStatsFile, true);
                BufferedWriter bw = new BufferedWriter(fw);
                PrintWriter out = new PrintWriter(bw)) {
            
            Map<String, String> line = writeLine(data);
            
            out.print("\n");
            for (int i = 0; i < fields.size(); i++) {
                out.print(line.get(fields.get(i)));
                if (i != fields.size()-1) out.print("\t");
            }
    
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    private Map<String, String> writeLine(Map<String, String> data) {
        Map<String, String> line = new HashMap<>();
        try {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            line.put("date", formatter.format(new Date()));
            line.put("host", InetAddress.getLocalHost().getHostName());
            line.put("asls", JaCaMoLauncher.getRunner().getProject().getAllASFiles().toString());
            line.put("team", data.get("team"));
            line.put("event", data.get("event"));
            line.put("comment", data.get("comment"));
            // line.put("rDL", (String.format("%.2f", assignedDataLoad)));

        } catch (UnknownHostException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return line;
    }
    
    private void createStatisticsFolders() {
        // create folders if doesnt exist
        File file = new File(matchesStatsFolder + "tmp");
        file.getParentFile().mkdirs();
    }
}
