package localPositionSystem;
// CArtAgO artifact code for project teste

import cartago.*;
public class lps extends Artifact {
    View view;

    @OPERATION 
    void init (){
        view = new View();
    }
    
    @OPERATION
    void clear(int i, int j, int range) {       
        this.view.clear(i, j,range);
    }
    
    
    @OPERATION
    void mark(int i, int j, String type, String info) {     
        this.view.mark(i, j, type, info);
    }
    
    @OPERATION
    void unmark(int i, int j) {     
        this.view.unmark(i, j);
    }
    
//      this.players[this.handlerPlayers]=getCurrentOpAgentId();
//      this.dhw.setPlayer(getCurrentOpAgentId().getAgentName(), this.handlerPlayers); 
//      this.handlerPlayers=(this.handlerPlayers+1)%2;      
//      if (this.handlerPlayers==0) {
//          execInternalOp("start");
//      }
//  }
    
    
}
