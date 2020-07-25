package jason.stdlib;

import mabOptimizer.*;

import java.util.ArrayList;
import java.util.List;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Term;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.ASSyntax;

public class set_reward extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        Term tBanditIndex = args[0];
        Term tArmName = args[1];
        Term tReward = args[2];
        Term handoverArg = args[3];
        MAB bandit = BanditManager.bandits.get(Integer.parseInt(tBanditIndex.toString()));
        bandit.setReward(tArmName.toString().replace("\"", ""), Double.parseDouble(tReward.toString()));
        ArrayList<Integer> frequencies = bandit.getFrequencies();
        List<Term> tFrequencies = new ArrayList<>();
        for (int frequency: frequencies) {
            tFrequencies.add(new NumberTermImpl(frequency));
        }
        return un.unifies(ASSyntax.createList(tFrequencies), handoverArg);
    }
}
