package coordination;

import cartago.*;
import jason.asSyntax.Atom;

/**
 * Simple Call For Proposals may be useful for lightweight auctions
 *
 * @author cleber
 *
 */
public class simpleCFP extends Artifact {

    /**
     * Tells that an agent wants to perform a given task with some predicted cost
     * The cost also depends on the step the agent is at.
     * If another agent comes telling that is can do this task earlier, the property
     * will be updated.
     * This property will keep only one register for a given task, it should be removed
     * at the end of the round to avoid conflicts with next round tasks identifiers. 
     * 
     * @param agent that wants to perform the task
     * @param task unique identifier for each wanted_task(_,task,_,_)
     * @param step the step in which the agent is at
     * @param cost the predicted cost (number of steps) the agent thinks is necessary to perform the task
     */
    @OPERATION
    synchronized void setWantedTask(String agent, String task, int step, int cost) {
        ObsProperty prop = getObsPropertyByTemplate("wanted_task", null, new Atom(task), null, null);
        if (prop == null) {
            defineObsProperty("wanted_task", new Atom(agent), new Atom(task), step, cost);
        } else {
            // Is this offer is better the other registered one?
            if ((Integer) prop.getValue(2) + (Integer) prop.getValue(3) > step + cost) { 
                prop.updateValues(new Atom(agent), new Atom(task), step, cost);
            }
        }
    }

    /**
     * In case the agent decided to do not perform the task, it may remove
     * wanted_task properties signed to its. It has no effect if the agent is not
     * the winner of an auction. By removing this property, a new auction may be
     * done. An agent may decide to forget the task if it was reseted. It may remove
     * old/performed auctions too.
     * 
     * @param agent the agent that wants to tell it is forgetting the task
     * @param task  the given task to forget
     */
    @OPERATION
    void removeMyWantedTasks(String agent) {
        ObsProperty prop = getObsPropertyByTemplate("wanted_task", new Atom(agent), null, null, null);
        if (prop != null) {
            removeObsPropertyByTemplate("wanted_task", new Atom(agent), null, null, null);
        }
    }

    /**
     * Reset the artifact. Useful when it is going to a new round.
     */
    @OPERATION
    void resetSimpleCFP() {
        while (getObsProperty("wanted_task") != null) {
            removeObsProperty("wanted_task");
        }
    }
}
