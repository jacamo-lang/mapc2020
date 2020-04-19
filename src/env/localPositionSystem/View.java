package localPositionSystem;


import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.image.BufferedImage;

import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.border.Border;
import javax.swing.border.LineBorder;


public class View extends JFrame 
{
        
        private JPanel table = new JPanel(new GridBagLayout());         
        private JLabel [][] map = new JLabel [81][81];
            
        public View() {
                        
            setTitle("viewer");
            setPreferredSize(new Dimension(700,700));                   
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
                            this.map[40+i+di*offsetI][40+j+dj*offsetJ].setBackground(Color.LIGHT_GRAY);
                            this.map[40+i+di*offsetI][40+j+dj*offsetJ].repaint();                   
                        }
        }
        
        
        public void mark(int i, int j, String type,String info) {
            Color c = Color.MAGENTA;
            switch (type) {
            case "obstacle":
                c = Color.BLACK;
                break;
            case "dispenser":
                c = Color.BLUE;
                break;
            case "goal":
                c = Color.YELLOW;
                break;
            case "self":
                c = Color.GREEN;
                break;
            case "agent":
                c = Color.RED;
                break;
            }
            //* ajuste do toroide
            if (i>39) {
                i=i-80;
                
            } 
            else if (i<-40) {
                i=i+80; 
            } 
            if (j>39) {
                j=j-80;
            }
            else if (j<-40) {
                j=j+80;
            }
            //---------------
            this.map[40+i][40+j].setBackground(c);
            this.map[40+i][40+j].setToolTipText( "("+String.valueOf(i)+
                                                 ","+String.valueOf(j)+") - "+
                                                 info);
            this.map[40+i][40+j].setIcon(new ImageIcon(emptyImage()));          
            this.map[40+i][40+j].setOpaque(true);
            this.map[40+i][40+j].repaint();
        }
        
        public void unmark(int i, int j) {
            //* ajuste do toroide
            if (i>39) {
                i=i-80;
                
            } 
            else if (i<-40) {
                i=i+80; 
            } 
            if (j>39) {
                j=j-80;
            }
            else if (j<-40) {
                j=j+80;
            }
            //--------------- 
            this.map[40+i][40+j].setBackground(Color.LIGHT_GRAY);
            this.map[40+i][40+j].repaint();
        }
        
        private void build(){                   
            GridBagConstraints c = new GridBagConstraints();

            for (int i=0;i<80;i++) {
                for (int j=0;j<80;j++) {
                    JLabel tmp = new JLabel("");    
                    tmp.setBorder (new LineBorder(Color.LIGHT_GRAY, 1));
                    tmp.setIcon(new ImageIcon(emptyImage()));
                    c.gridx=i;
                    c.gridy=j;
                    this.table.add(tmp,c);
                    this.map[i][j]=tmp;
                }
            }
        }
        private BufferedImage emptyImage() {
            BufferedImage bi = new BufferedImage( 6, 6, 
                                            BufferedImage.TYPE_INT_ARGB);
            Graphics g = bi.getGraphics();          
            g.dispose();
            return bi;
        }
}
