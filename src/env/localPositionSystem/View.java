package localPositionSystem;


import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.image.BufferedImage;
import java.util.Arrays;

import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.border.Border;
import javax.swing.border.LineBorder;


public class View extends JFrame 
{
        
        private int size;
        private JPanel table = new JPanel(new GridBagLayout());         
        private JLabel [][] map;
        private Color DEFAULT_COLOR;
        public static final Color [] colors = {Color.MAGENTA.darker(), Color.BLACK.darker(),
        									  Color.BLUE.darker(), Color.YELLOW.darker(),
        									  Color.GREEN.darker(),Color.RED.darker(),
        									  Color.GRAY.darker(),Color.ORANGE.darker()};
            
        public View(int size) {
            
        	this.size=size;
        	this.map = new JLabel [size][size];
            setTitle("viewer");
            setPreferredSize(new Dimension(size*8+50,size*8+50));                   
            setLayout(new BorderLayout());
                
            add(this.table, BorderLayout.CENTER);
            
            build();
            setVisible(true);
            pack();
            
            setLocation(0, 0);   
                        
            //setDefaultLookAndFeelDecorated(true);
            
        }   
        public void clear(int i, int j, int range) {
            int [] directions ={-1,1};
            for (int offsetI=0; offsetI<range;offsetI++)
                for (int offsetJ=0; offsetJ<range-offsetI;offsetJ++) 
                    for (int di:directions) 
                        for (int dj:directions) {
                            this.map[center()+i+di*offsetI][center()+j+dj*offsetJ].setBackground(Color.LIGHT_GRAY);
                            this.map[center()+i+di*offsetI][center()+j+dj*offsetJ].repaint();                   
                        }
        }
        
        
        public void mark(int i, int j, String type,String info, int vision) {
            Color c = Color.MAGENTA.darker();
            switch (type) {
            case "obstacle":
                c = Color.BLACK.darker();
                break;
            case "dispenser":
                c = Color.BLUE.darker();
                break;
            case "goal":
                c = Color.YELLOW.darker();
                break;
            case "self":
                c = Color.GREEN.darker();
                break;
            case "agent":
                c = Color.RED.darker();
                break;
            case "vision": //legacy
                c = Color.GRAY.darker();    
                break;
	        case "other":
	            c = Color.ORANGE.darker();    
	            break;
	        }
            //* ajuste do toroide
            if (center()+i+1>this.size) {
                i=i-this.size;                
            } 
            else if (i<center()*-1) {
                i=i+this.size; 
            }
            if (center()+j+1>this.size) {
                j=j-this.size;
            }
            else if (j<center()*-1) {
                j=j+this.size;
            } 
            //--------------- Vision
            Color vc = new Color(	
            		c.brighter().getRed()>155?255:c.brighter().getRed()+100,
            		c.brighter().getGreen()>155?255:c.brighter().getGreen()+100,
            		c.brighter().getBlue()>155?255:c.brighter().getBlue()+100,
					100);
            
            markVision(i, j, vc, vision);
            //---------------
            if(c!=Color.GRAY|this.map[center()+i][center()+j].getBackground()==DEFAULT_COLOR) //do not overwrite with the vision mark
               this.map[center()+i][center()+j].setBackground(c);
            this.map[center()+i][center()+j].setToolTipText( "("+String.valueOf(i)+
                                                 ","+String.valueOf(j)+") - "+
                                                 info);
            this.map[center()+i][center()+j].setIcon(new ImageIcon(emptyImage()));          
            this.map[center()+i][center()+j].setOpaque(true);
            this.map[center()+i][center()+j].repaint();
            
        }
        
        public void unmark(int i, int j) {
            //* ajuste do toroide            
            if (center()+i+1>this.size) {
                i=i-this.size;
                
            } 
            else if (i<center()*-1) {
                i=i+this.size; 
            } 
            if (center()+j+1>this.size) {
                j=j-this.size;
            }
            else if (j<center()*-1) {
                j=j+this.size;
            }
            //--------------- 
            this.map[center()+i][center()+j].setBackground(Color.LIGHT_GRAY);
            this.map[center()+i][center()+j].repaint();
        }
        
        
        public void markVision(int i, int j, Color c, int vision) {
        	int [] directions = {-1,1};
        	for (int di:directions)
	            for (int offseti=0;offseti<=vision;offseti++) {
	            	for (int dj:directions)
		            	for (int offsetj=0;offsetj<=vision-offseti;offsetj++) {
		            		int newI = i+di*offseti;
		            		int newJ = j+dj*offsetj;
		            	    //* ajuste do toroide
		                    if (center()+newI+1>this.size) {
		                        newI=newI-this.size;                
		                    } 
		                    else if (newI<center()*-1) {
		                        newI=newI+this.size; 
		                    }
		                    if (center()+newJ+1>this.size) {
		                        newJ=newJ-this.size;
		                    }
		                    else if (newJ<center()*-1) {
		                        newJ=newJ+this.size;
		                    } 
		                    //---------------
//		                    if(!Arrays.asList(colors).contains(
//		                    		this.map[center()+newI][center()+newJ].getBackground()) |
//				               this.map[center()+newI][center()+newJ].getBackground()==DEFAULT_COLOR) {
		                       this.map[center()+newI][center()+newJ].setBackground(c);
		                       this.map[center()+newI][center()+newJ].setToolTipText( "("+String.valueOf(newI)+
		                    		   											","+String.valueOf(newJ)+") - "+
		                    		   											"vision");	
		                       this.map[center()+newI][center()+newJ].setIcon(new ImageIcon(emptyImage()));          
		                       this.map[center()+newI][center()+newJ].setOpaque(true);
		                       this.map[center()+newI][center()+newJ].repaint();
//		                    }
		            	}
	            }
        
        }
        
        private void build(){                   
            GridBagConstraints c = new GridBagConstraints();

            for (int i=0;i<this.size;i++) {
                for (int j=0;j<this.size;j++) {
                    JLabel tmp = new JLabel("");    
                    tmp.setBorder (new LineBorder(Color.LIGHT_GRAY, 1));
                    tmp.setIcon(new ImageIcon(emptyImage()));
                    c.gridx=i;
                    c.gridy=j;
                    this.table.add(tmp,c);
                    this.map[i][j]=tmp;
                }
            }
            DEFAULT_COLOR = map[0][0].getBackground();
        }
        private BufferedImage emptyImage() {
            BufferedImage bi = new BufferedImage( 6, 6, 
                                            BufferedImage.TYPE_INT_ARGB);
            Graphics g = bi.getGraphics();          
            g.dispose();
            return bi;
        }
        
        /* Returns the central position considering the size of the terrain */
        private int center() {
            return (int) Math.floor(this.size/2);
        }
}
