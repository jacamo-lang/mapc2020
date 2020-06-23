package localPositionSystem.stc;


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


import localPositionSystem.View;

public class ViewSTC extends View
{
        public ViewSTC(int size) {
           super(size);                
        }   
        
        
        public void markVision(int i, int j, Color c, int vision) {
            i = i%this.size;
        j = j%this.size;
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
                            //if(this.map[center()+newI][center()+newJ].getBackground()!=Color.CYAN.darker()&&
                            //   this.map[center()+newI][center()+newJ].getBackground()!=Color.YELLOW.darker()&&      
                            //   this.map[center()+newI][center()+newJ].getBackground()!=Color.BLACK.darker()) {
                            if(this.map[center()+newI][center()+newJ].getBackground()==DEFAULT_COLOR){
                               this.map[center()+newI][center()+newJ].setBackground(c);
                               //this.map[center()+newI][center()+newJ].setToolTipText( "("+String.valueOf(newI)+
                               //                                                 ","+String.valueOf(newJ)+") - "+
                               //                                                 "vision");  
                               //this.map[center()+newI][center()+newJ].setIcon(new ImageIcon(emptyImage()));          
                               this.map[center()+newI][center()+newJ].setOpaque(true);
                               //this.map[center()+newI][center()+newJ].repaint();
                            }   
                        }
                }
        
        }
}
