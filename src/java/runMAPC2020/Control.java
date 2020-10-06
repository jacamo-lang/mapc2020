package runMAPC2020;

import java.awt.Desktop;
import java.net.URI;

import cartago.CartagoService;
import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.Server;

public class Control {
    public void start(String Simulation, Boolean browser) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    System.out.println("Starting simulation....");

                    // Wait for jacamo
                    boolean waitAgents = true;
                    while (waitAgents) {
                        System.out.println("Waiting jacamo to start ....");
                        if (
                                (JaCaMoLauncher.getRunner() != null) && 
                                (JaCaMoLauncher.getRunner().getAgs().size() > 0) &&
                                (CartagoService.getNode().getWorkspaces().size() > 0)
                                )
                            waitAgents = false;
                        
                        Thread.sleep(50);
                    }

                    Statistics s = Statistics.getInstance();
                    s.prepareMatchesStatsFile();

                    // Start the server
                    Server.main(new String[] { "-conf", "serverconf/SampleConfig.json", "--monitor" });
                    
                    // abre o browser automaticamente
                    if (browser && Desktop.isDesktopSupported()) {
                        Desktop.getDesktop().browse(new URI("http://127.0.0.1:8000"));
                    }

                } catch (UnsupportedOperationException e) {
                    System.err.println("No browser supported " + e.getMessage());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
        try {
            // altere a string pra carregar diferentes simulacoes
            JaCaMoLauncher.main(new String[] { Simulation });
        } catch (JasonException e) {
            System.out.println("Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
