package env.connection;

//CArtAgO artifact code for project mapc2018udesc

import java.util.Collection;
import java.util.ArrayList;


import cartago.*;
import eis.AgentListener;
import eis.exceptions.AgentException;
import eis.exceptions.ManagementException;
import eis.exceptions.RelationException;
import eis.iilang.Action;
import eis.iilang.Percept;
import jason.asSyntax.Literal;
import massim.eismassim.EnvironmentInterface;

public class EISAccess extends Artifact implements AgentListener {
    
 private EnvironmentInterface ei;
 private String Agname="";
 private Boolean receiving=false;
 private int awaitTime = 100;
 private String lastStep = "-1";
 private ArrayList<ObsProperty> lastRoundPropeties = new ArrayList<ObsProperty>();

    void init(String conf) {
         ei = new EnvironmentInterface(conf);
         this.Agname=ei.getEntities().getFirst();
            try {
                ei.start();
            } catch (ManagementException e) {
                e.printStackTrace();
            }

         try {
             ei.registerAgent(this.Agname);
         } catch (AgentException e1) {
            e1.printStackTrace();
         }

         ei.attachAgentListener(this.Agname, this);

         try {
             ei.associateEntity(this.Agname, this.Agname);
         } catch (RelationException e1) {
             e1.printStackTrace();
         }
            if (ei != null) {
                this.receiving = true;
                execInternalOp("updatepercept");
            }
    }
    
    
    @INTERNAL_OPERATION void updatepercept() {      
        while (!ei.isEntityConnected(this.Agname)) {
            await_time(this.awaitTime);
        }
        
        while (this.receiving) {
            if (ei != null) {
                
                try {
                    Collection<Percept> lp = 
                            ei.getAllPercepts(this.Agname).get(this.Agname);    
                    boolean newstep=true;
                    for (Percept pe:lp) {
                        if (pe.getName().equals("step")) {
                            if (pe.getParameters().getFirst().toString().equals(this.lastStep)) {
                                newstep=false;
                                break;
                            }
                            else 
                                this.lastStep=pe.getParameters().getFirst().toString();
                        }
                    }
                    if (newstep) {
                        clearpercepts();                        
                        for (Percept pe:lp) {                           
                            this.lastRoundPropeties.add( defineObsProperty( pe.getName(),
                                                Translator.parametersToTerms(pe.getClonedParameters())));
                            }
                    }
                } catch (Exception e) {     
                    e.printStackTrace();
                }
            }
            await_time(this.awaitTime);
        }
        
    }
    private void clearpercepts () {
        for (ObsProperty obs:this.lastRoundPropeties) 
            removeObsProperty(obs.getName());
        this.lastRoundPropeties.clear();
    }
    
    @OPERATION
    void action(String action) {
        Literal literal = Literal.parseLiteral(action);
        //System.out.println("***************"+action);
        Action a = null;
        try {
            if (ei != null) {
                a = Translator.literalToAction(literal);
                ei.performAction(this.Agname, a);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public void handlePercept(String arg0, Percept arg1) {}
//  
    
}
