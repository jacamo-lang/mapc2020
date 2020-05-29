package localPositionSystem;
// CArtAgO artifact code for project teste

import cartago.*;
public class lps extends Artifact {
    View view;

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

        if(!type.equals("self")) {
            ObsProperty prop = this.getObsPropertyByTemplate("gps_map",i,j,null);
            if(prop==null) 
                defineObsProperty("gps_map", i,j,type);
            else 
                prop.updateValues(i,j,type);
        }
    }
    
    @OPERATION
    void unmark(int i, int j) {     
        this.view.unmark(i, j);
    }



}
