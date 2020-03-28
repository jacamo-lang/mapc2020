package runMAPC2020;

import java.awt.Desktop;
import java.awt.Frame;
import java.net.URI;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.Server;

public class Control {
	public void start(String Simulation, Boolean browser) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					//abre o browser automaticamente
					if (browser && Desktop.isDesktopSupported()) {
					    Desktop.getDesktop().browse(new URI("http://127.0.0.1:8000"));
					}
					Server.main(new String[] {"-conf", "serverconf/SampleConfig.json", "--monitor"});					
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}).start();
		try {
			//altere a string pra carregar diferentes simulacoes
			JaCaMoLauncher.main(new String[] {Simulation});
		} catch (JasonException e) {
			System.out.println("Exception: "+e.getMessage());
			e.printStackTrace();
		}
	}
}
