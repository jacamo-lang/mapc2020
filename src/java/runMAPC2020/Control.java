package runMAPC2020;

import java.awt.AWTException;
import java.awt.Desktop;
import java.awt.Robot;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.net.URI;

import javax.swing.Timer;

import cartago.CartagoService;
import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.Server;

public class Control {
    public void start(String Simulation, Boolean browser, Boolean autoRun) {
        int runTimes = 1;
        if (autoRun) {
            runTimes = 10;
        }
        for (int i = 0; i < runTimes; i++) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
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

                        if (autoRun) {
                            System.out.println(" >>>>>>>>>>>>>> Starting simulation in 15 seconds....");
                            Timer timer = new Timer(15 * 1000, new ActionListener() {
                                @Override
                                public void actionPerformed(ActionEvent e) {
                                    // Simulate ENTER key press
                                    Robot robot;
                                    try {
                                        robot = new Robot();
                                        System.out.println(" >>>>>>>>>>>>>> Run simulation!");
                                        robot.keyPress(KeyEvent.VK_ENTER);
                                        robot.keyRelease(KeyEvent.VK_ENTER);
                                    } catch (AWTException ex) {
                                        ex.printStackTrace();
                                    }
                                }
                            });
                            timer.setRepeats(false); // Only execute once
                            timer.start(); // Go go go!
                        }

                        // Start the server
                        //Server.main(new String[] { "-conf", "serverconf/SampleQualification.json", "--monitor" });
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
}
