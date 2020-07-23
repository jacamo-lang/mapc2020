package jason.stdlib;

import mabOptimizer.*;

import java.util.ArrayList;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Term;

public class set_reward extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        Term tBanditIndex = args[0];
        Term tArmName = args[1];
        Term tReward = args[1];
        MAB bandit = BanditManager.bandits.get(Integer.parseInt(tBanditIndex.toString()));
        bandit.setReward(tArmName.toString(), Double.parseDouble(tReward.toString()));
        return true;
    }
}
