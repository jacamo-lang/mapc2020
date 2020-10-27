package localPositionSystem;

import cartago.*;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Atom;

/**
 *  Observable properties:
 *  gps_map(x,y,type,mapId): the map identified by mapId contains an object of some type in the coordinates (x,y)
 *
 */


public class lps extends Artifact {
    protected View view;
    protected int viewOn;

    @OPERATION 
    void init (int size, int viewOn){
        this.viewOn = viewOn;
        
        if (viewOn != 0) {
            view = new View(size);
        }
    }
    
    @OPERATION
    void clear(int i, int j, int range) {    
        if (viewOn != 0) {
            this.view.clear(i, j,range);
        }
    }
    
    /**
     * Mark an element in the viewer and add it as observable property to the shared map identified by mapId
     */
    @OPERATION
    void mark(int i, int j, String type, String info, int vision, String mapId) {       
        if (viewOn != 0) //draw in the viewer
            this.view.mark(i, j, type, info, vision);                
        this.execInternalOp("mark",i, j, type, mapId);
    }
    
    /**
     * Add as observable property to the shared map identified by mapId without mark in the viewer
     */
    @OPERATION
    void mark(int i, int j, String type, String mapId) {     
        if(!type.equals("self")) {
            ObsProperty prop = this.getObsPropertyByTemplate("gps_map",i,j,null,mapId);
            if(prop==null) 
                defineObsProperty("gps_map",i,j,new Atom(type),mapId);
            else 
                prop.updateValues(i,j,new Atom(type),mapId);
        }
    }
    
    /**
     * Add as observable property to register which map the agent is on
     */
    @OPERATION
    void setOrigin(String mapId) {
        String agent = getCurrentOpAgentId().getAgentName();
        ObsProperty prop = this.getObsPropertyByTemplate("origin",ASSyntax.createAtom(agent),null);
        if(prop==null) 
            defineObsProperty("origin",ASSyntax.createAtom(agent),ASSyntax.createAtom(mapId));
        else 
            prop.updateValues(ASSyntax.createAtom(agent),ASSyntax.createAtom(mapId));
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
    }

    @OPERATION
    void unmark(int i, int j, String type, String mapId) {   
        Atom aType = new Atom(type);
        ObsProperty prop = this.getObsPropertyByTemplate("gps_map",i,j,aType,mapId);
        if(prop!=null) 
            this.removeObsPropertyByTemplate("gps_map", i,j,aType,mapId);             
        if (viewOn != 0) {
            this.view.unmark(i, j);
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
