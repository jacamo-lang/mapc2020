package coordination;

import java.util.HashSet;
import java.util.Set;

import cartago.*;
import jason.asSyntax.Atom;

/**
 * Simple Call For Proposals may be useful for lightweight auctions
 *
 * @author cleber
 *
 */
public class simpleCFP extends Artifact {
    
    Set<String> cfps = new HashSet<>();

    /**
     * Tells that an agent wants to participate of a given CFP (Call For Proposals) with 
     * some predicted cost. The cost also depends on the step the agent is at.
     * If another agent comes telling that it wants to participate to this CFP and it can 
     * give a better offer (less than the actual), the property will be updated.
     * This property will keep only one register for a given CFP, it should be removed
     * at the end of the round to avoid conflicts with next round identifiers. 
     * 
     * @param agent that wants to participate on the CFP
     * @param subject unique identifier for each subject of a CFP
     * @param offer of the agent (usually the step it is in + predicted cost)
     */
    @OPERATION
    synchronized void setCFP(String cfp, String subject, int offer) {
        String agent = getCurrentOpAgentId().getAgentName();
        ObsProperty prop = getObsPropertyByTemplate(cfp, null, new Atom(subject), null);
        if (!cfps.contains(cfp)) 
            cfps.add(cfp);
        if (prop == null) {
            defineObsProperty(cfp, new Atom(agent), new Atom(subject), offer);
        } else {
            // Is this offer is better the other registered one?
            if (offer < (Integer) prop.getValue(2)) { 
                prop.updateValues(new Atom(agent), new Atom(subject), offer);
            }
        }
    }

    /**
     * In case the agent decided to quit of a CFP, it may remove
     * all CFP subjects properties signed to the agent. It has no effect if the agent is not
     * the winner of an auction. By removing this property, a new auction may be
     * done. An agent may decide to forget the subject if it was reseted. It may remove
     * old/performed auctions too.
     */
    @OPERATION
    void removeMyCFPs() {
        String agent = getCurrentOpAgentId().getAgentName();
        
        for ( String cfp : cfps ) {
            ObsProperty prop = getObsPropertyByTemplate(cfp, new Atom(agent), null, null);
            if (prop != null) {
                removeObsPropertyByTemplate(cfp, new Atom(agent), null, null);
            }
        }
    }

    /**
     * Reset the artifact. Useful when it is going to a new round.
     */
    @OPERATION
    void resetSimpleCFP() {
        for ( String cfp : cfps ) {
            while (getObsProperty(cfp) != null) {
                removeObsProperty(cfp);
            }
        }
        cfps.clear();
    }
}
