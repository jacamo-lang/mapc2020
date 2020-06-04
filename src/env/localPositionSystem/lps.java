package localPositionSystem;

import cartago.*;

/**
 *  Observable properties:
 *  gps_map(x,y,type,mapId): the map identified by mapId contains an object of some type in the coordinates (x,y)
 *
 */


public class lps extends Artifact {
    protected View view;

    @OPERATION 
    void init (int size){
        view = new View(size);
    }
    
    @OPERATION
    void clear(int i, int j, int range) {       
        this.view.clear(i, j,range);
    }
    
    
    @OPERATION
    void mark(int i, int j, String type, String info, int vision) {     
        this.view.mark(i, j, type, info, vision);
    }
    
    
    /**
     * Mark an element in the viewer and add it as observable property to the shared map identified by mapId
     */
    @OPERATION
    void mark(int i, int j, String type, String info, int vision, String mapId) {     
        this.view.mark(i, j, type, info, vision);

        if(!type.equals("self")) {
            ObsProperty prop = this.getObsPropertyByTemplate("gps_map",i,j,null,mapId);
            if(prop==null) 
                defineObsProperty("gps_map",i,j,type,mapId);
            else 
                prop.updateValues(i,j,type,mapId);
        }
    }
    
    
    
    @OPERATION
    void unmark(int i, int j) {     
        this.view.unmark(i, j);
    }



}
