package localPositionSystem.stc;

import java.awt.Color;
import cartago.*;

import localPositionSystem.lps;

public class lpsSTC extends lps {

    @OPERATION 
    void init (int size, int viewOn){
        this.viewOn = viewOn;

        if (viewOn != 0)
           view = new ViewSTC(size);
    }

    @OPERATION
    void setEdge(int xStart, int yStart, int direction, int xEnd, int yEnd, String mapId) {       
        ObsProperty prop = this.getObsPropertyByTemplate("edge", xStart, yStart, direction, xEnd, yEnd, mapId);
        if(prop==null) 
            defineObsProperty("edge", xStart, yStart, direction, xEnd, yEnd, mapId);        
    }

    @OPERATION
    void removeTree(String mapId){
        ObsProperty prop = this.getObsPropertyByTemplate("edge", null, null, null, null, null, mapId);
        while(prop!=null) {
            this.removeObsPropertyByTemplate("edge", prop.getValue(0), prop.getValue(1),prop.getValue(2), prop.getValue(3), prop.getValue(4), prop.getValue(5));            
            prop = this.getObsPropertyByTemplate("edge", null, null, null, null, null, mapId);
        }
    }

    @OPERATION
    void markVision(int x, int y, int vision){
        Color c = Color.CYAN.darker();
        Color vc = new Color(   
                c.brighter().getRed()>155?255:c.brighter().getRed()+100,
                        c.brighter().getGreen()>155?255:c.brighter().getGreen()+100,
                                c.brighter().getBlue()>155?255:c.brighter().getBlue()+100,
                                        100);

        view.markVision(x, y, vc, vision);
    }
}
