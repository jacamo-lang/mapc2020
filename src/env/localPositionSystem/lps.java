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
        
        // Update map used by route planner
        this.map.put(i, j, type);
    }
    
    /**
     * Mark an element in the viewer and add it as observable property to the shared map identified by mapId
     */
    @OPERATION
    void mark(int i, int j, String type, String info, int vision, String mapId) {     
        this.execInternalOp("mark",i, j, type, info, vision);
        
        if(!type.equals("self")) {
            ObsProperty prop = this.getObsPropertyByTemplate("gps_map",i,j,null,mapId);
            if(prop==null) 
                defineObsProperty("gps_map",i,j,type,mapId);
            else 
                prop.updateValues(i,j,type,mapId);
        }
        
        // Update map used by route planner
        this.map.put(i, j, type);
    }
    
    /**
     * Add as observable property to the shared map identified by mapId without mark in the viewer
     */
    @OPERATION
    void mark(int i, int j, String type, String mapId) {     
        if(!type.equals("self")) {
            ObsProperty prop = this.getObsPropertyByTemplate("gps_map",i,j,null,mapId);
            if(prop==null) 
                defineObsProperty("gps_map",i,j,type,mapId);
            else 
                prop.updateValues(i,j,type,mapId);
        }
        
        // Update map used by route planner
        this.map.put(i, j, type);
    }
    
    /**
     * Remove all the objects of the mapId
     */
    @OPERATION
    void replaceMap(String oldMapId, String newMapId) {
        ObsProperty prop = this.getObsPropertyByTemplate("gps_map", null, null, null, oldMapId);
        while (prop != null) {
            this.removeObsPropertyByTemplate("gps_map", null, null, null, oldMapId);
            prop = this.getObsPropertyByTemplate("gps_map", null, null, null, oldMapId);
        }
        // signal("replace_map",oldMapId,newMapId);
    }
    
    @OPERATION
    void unmark(int i, int j) {     
        if (viewOn != 0) {
            this.view.unmark(i, j);
        }
        
        if (this.map.contains(i, j)) {
            this.map.remove(i,i);        
        }
    }
    
    
    /**
     * Add an edge from the point (xStart, yStart) to (xEnd,yEnd).
     * Useful in tree based exploration strategies.
     */
    @OPERATION
    void setEdge(int xStart, int yStart, int direction, int xEnd, int yEnd, String mapId) {       
        ObsProperty prop = this.getObsPropertyByTemplate("edge", xStart, yStart, direction, xEnd, yEnd, mapId);
        if(prop==null) 
            defineObsProperty("edge", xStart, yStart, direction, xEnd, yEnd, mapId);        
    }
}
