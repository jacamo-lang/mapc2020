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

/**
<p>Internal action: <b><code>set_reward(<i>B</i>, <i>A</i>, <i>R</i>, <i>F</i>)</code></b>.
<p>Description: sets the reward of an arm's latest "pull" and returns the bandit's current arm frequencies (after the update)
<p>Parameter:<ul>
<li>- bandit (number): index (ID) of the bandit that is to be used</li>
<li>- arm (string): name of the arm whose reward list should be appended</li>
<li>- reward (number): reward that should be append to the arm's reward list</li>
<li>- unifier (list of numbers): unifies with the bandit's current arm frequencies</li>

</ul>
<p>Example:<ul>
<li><code>set_reward(0, "a", 5, F)</code>: Sets the latest reward of the arm "a" of the bandit with index 0 to 5 and unifies F with the bandit's arm frequencies.</li>
</ul>
 */


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
