package jason.stdlib;
import mabOptimizer.*;


import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Term;
import jason.asSyntax.StringTerm;
import jason.asSyntax.ASSyntax;

/**
<p>Internal action: <b><code>pull_arm(<i>B</i>, <i>A</i>)</code></b>.
<p>Description: requests a recommendation ("arm" that should be "pulled") from a particular multi-armed bandit
<p>Parameter:<ul>
<li>- bandit (number): index (ID) of the bandit that is to be used</li>
<li>- unifier (string): unifies with the bandit's recommendation ("arm")</li>

</ul>
<p>Example:<ul>
<li><code>pull_arm(0, A)</code>: Asks the bandit with index 0 for a recommendation and unifies the recommendation with A.</li>
</ul>
 */

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
