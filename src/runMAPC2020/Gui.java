package runMAPC2020;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

import com.sun.source.tree.ParenthesizedTree;


public class Gui extends JFrame
{
		public Gui(Control control) {		
			JFrame frame = this;
			setTitle("Start configuration");
			setPreferredSize(new Dimension(300,200));					
			setLayout(new GridBagLayout());			
			GridBagConstraints c = new GridBagConstraints();
		    
			JLabel rSimulations = new JLabel("Selecione a simulação");
			JComboBox simulations = new JComboBox(listFiles().stream().toArray());
		    JCheckBox browser = new JCheckBox("Abrir um navegador");
		    JButton start = new JButton("Iniciar simulação");
		    start.addActionListener((new ActionListener() {
		        @Override
		        public void actionPerformed(ActionEvent e) {		            
		            frame.dispose();
		            control.start(simulations.getSelectedItem().toString(), browser.isSelected());
		        }
		    }));

		    				    
		    c.gridx=0;
		    c.gridy=0;
		    add(rSimulations, c);
		    c.gridy=1;
		    add(simulations, c);
		    c.gridy=2;
		    add(browser,c);
		    c.gridy=3;
		    add(start,c);
		    
		    setVisible(true);
		    pack();
		   	
		}
		
		public List<String> listFiles() {
			LinkedList<String> listFiles = new LinkedList();
			File folder=null;
			try {
				folder = new File( new File( "." ).getCanonicalPath());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		    for (File fileEntry : folder.listFiles()) {
		        if (fileEntry.isFile() && fileEntry.getName().contains(".jcm")) {
		        	listFiles.add(fileEntry.getName());
		        } 
		    }
		    return listFiles;		    		
		}
}
