package localPositionSystem;

import cartago.*;
import com.google.common.collect.Table;
import com.google.common.collect.HashBasedTable;

/**
 *  Observable properties:
 *  gps_map(x,y,type,mapId): the map identified by mapId contains an object of some type in the coordinates (x,y)
 *
 */


public class lps extends Artifact {
    protected View view;
    protected int viewOn;
    protected Table<Integer, Integer, String> map;

    @OPERATION 
    void init (int size, int viewOn){
        this.viewOn = viewOn;
        map = HashBasedTable.create();
        
        if (viewOn != 0) {
            view = new View(size);
        }
    }
    
    @OPERATION
    void clear(int i, int j, int range) {    
        // TODO: implement clear of Table map?
        
        if (viewOn != 0) {
            this.view.clear(i, j,range);
        }
    }
    
    @OPERATION
    void mark(int i, int j, String type, String info, int vision) {     
        if (viewOn != 0) {
            this.view.mark(i, j, type, info, vision);
        }
        
        if (!this.map.contains(i, j)) {
            this.map.put(i, j, type);
        }
    }
    
    /**
     * Mark an element in the viewer and add it as observable property to the shared map identified by mapId
     */
    @OPERATION
    void mark(int i, int j, String type, String info, int vision, String mapId) {     
        //this.execInternalOp("mark",i, j, type, info, vision);
        if (viewOn != 0) {
            this.view.mark(i, j, type, info, vision);
        }
        
        if (!this.map.contains(i, j)) {
            this.map.put(i, j, type);
        }
        
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
        if (viewOn != 0) {
            this.view.unmark(i, j);
        }
        
        if (!this.map.contains(i, j)) {
            this.map.remove(i,i);        
        }
    }
}
