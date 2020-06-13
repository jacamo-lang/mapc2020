package runMAPC2020;

import java.awt.AWTException;
import java.awt.Desktop;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.net.URI;

import cartago.CartagoService;
import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.Server;

public class Control {
    public void start(String Simulation, Boolean browser, Boolean waitEnter) {
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

                    if (!waitEnter) {
                        // Simulate ENTER key press
                        Robot robot = new Robot();
                        robot.keyPress(KeyEvent.VK_ENTER);
                        robot.keyRelease(KeyEvent.VK_ENTER);
                    }

                    // Start the server
                    Server.main(new String[] { "-conf", "serverconf/SampleConfig.json", "--monitor" });
                    
                    // abre o browser automaticamente
                    if (browser && Desktop.isDesktopSupported()) {
                        Desktop.getDesktop().browse(new URI("http://127.0.0.1:8000"));
                    }

                } catch (UnsupportedOperationException | AWTException e) {
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
