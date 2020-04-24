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
        
        private static final int SIZE = 81;
        private JPanel table = new JPanel(new GridBagLayout());         
        private JLabel [][] map = new JLabel [SIZE][SIZE];
        private Color DEFAULT_COLOR;
        
            
        public View() {
                        
            setTitle("viewer");
            setPreferredSize(new Dimension(SIZE*8+50,SIZE*8+50));                   
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
            case "vision":
                c = Color.GRAY;    
                break;
            }
            //* ajuste do toroide
            if (center()+i+1>this.SIZE) {
                i=i-this.SIZE;                
            } 
            else if (i<center()*-1) {
                i=i+this.SIZE; 
            }
            if (center()+j+1>this.SIZE) {
                j=j-this.SIZE;
            }
            else if (j<center()*-1) {
                j=j+this.SIZE;
            } 
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
            if (center()+i+1>this.SIZE) {
                i=i-this.SIZE;
                
            } 
            else if (i<center()*-1) {
                i=i+this.SIZE; 
            } 
            if (center()+j+1>this.SIZE) {
                j=j-this.SIZE;
            }
            else if (j<center()*-1) {
                j=j+this.SIZE;
            }
            //--------------- 
            this.map[center()+i][center()+j].setBackground(Color.LIGHT_GRAY);
            this.map[center()+i][center()+j].repaint();
        }
        
        private void build(){                   
            GridBagConstraints c = new GridBagConstraints();

            for (int i=0;i<this.SIZE;i++) {
                for (int j=0;j<this.SIZE;j++) {
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
            return (int) Math.floor(this.SIZE/2);
        }
}
