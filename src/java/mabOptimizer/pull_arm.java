package jason.stdlib;
import mabOptimizer.*;


import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Term;
import jason.asSyntax.StringTerm;
import jason.asSyntax.ASSyntax;

public class pull_arm extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        Term tBanditIndex = args[0];
        Term handoverArg = args[1];
        MAB bandit = BanditManager.bandits.get(Integer.parseInt(tBanditIndex.toString()));
        StringTerm arm = ASSyntax.createString(bandit.pullArm());
        return un.unifies(arm, handoverArg);
    }
}
