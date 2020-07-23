package mabOptimizer;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Term;

public class pull_arm extends DefaultInternalAction {

	@Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		Term tBanditIndex = args[0];
		MAB bandit = BanditManager.bandits.get(Integer.parseInt(tBanditIndex.toString()));
		return bandit.pullArm();
	}
}
