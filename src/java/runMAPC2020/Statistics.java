package runMAPC2020;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
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
import jade.util.leap.Properties;

/**
 * @author cleber
 *
 */
public class Statistics {
    
    private static Statistics instance = null;
    final String matchesStatsFolder = "output/statistics/";
    final String matchesStatsFile   = "matches.csv";
    final String propFile           = "build/version.properties";
    
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
        this.fields.add("version");
        this.fields.add("host");
        this.fields.add("rid");
        this.fields.add("mas");
        this.fields.add("agent");
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
            line.put("rid", String.valueOf(ProcessHandle.current().pid()) + data.get("agent").substring(5, 6) + data.get("teamSize"));
            line.put("mas", JaCaMoLauncher.getRunner().getProject().getSocName());
            line.put("agent", data.get("agent").substring(5));
            line.put("event", data.get("event"));
            line.put("comment", data.get("comment"));
            line.put("version", getVersionFromPropertiesFile());

        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
        return line;
    }
    
    private void createStatisticsFolders() {
        // create folders if doesnt exist
        File file = new File(matchesStatsFolder + "tmp");
        file.getParentFile().mkdirs();
    }

    private String getVersionFromPropertiesFile() {
        File file = new File(propFile);
        try {
            if ( file.exists() ) {
                InputStream inputStream;
                inputStream = new FileInputStream(propFile);
                Properties prop = new Properties();
                prop.load(inputStream);
                return prop.getProperty("version");
            } else {
                return "0.0";
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "0.0";
    }
}
