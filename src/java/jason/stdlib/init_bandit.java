package jason.stdlib;

import java.util.ArrayList;
import java.util.Random;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Term;
import jason.asSyntax.StringTerm;
import mabOptimizer.*;

/**
<p>Internal action: <b><code>init_bandit(<i>A</i>, <i>T</i>, <i>E</i>, <i>D</i>,  <i>S</i>, <i>B</i>)</code></b>.
<p>Description: initiates a multi-armed bandit with the specified configuration and unifies with the bandit's index (ID)
<p>Parameter:<ul>
<li>- arms (list of strings): list of "arms" the bandit should have</li>
<li>- type (string): bandit algorithm: either "EPSILON_GREEDY" or "UBC"</li>
<li>- epsilon (number): only if e-greedy bandit. initial epsilon (exploration) rate of the bandit</li>
<li>- decay rate (number): only if e-greedy bandit. epsilon decay per iteration</li>
<li>- random seed (number): optional, only if e-greedy bandit. sets a random seed</li>
<li>- unifier: unifies with the bandit's index (ID)</li>

</ul>
<p>Example:<ul>
<li><code>init_bandit(0, [a, b, c], "UBC", B)</code>: Initiates a UBC bandit with three arms.</li>
</ul>
 */

public class init_bandit extends DefaultInternalAction  {

    static Random random = new Random();


    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        ListTerm tArmNames = (ListTerm) args[0];
        ArrayList<MABArm> arms =  new ArrayList<MABArm>();
        for(Term tArmName: tArmNames) {
            arms.add(new MABArm(tArmName.toString().replace("\"", "")));
        }
        Term handoverArg;
        MAB bandit;
        String type = ((StringTerm) args[1]).getString();
        switch(BanditType.valueOf(type)) {
	        case EPSILON_GREEDY:
	        	 Term epsilon = args[2];
	             Term decayRate = args[3];
	             handoverArg = args[4];
	             if (args.length > 5) {
	                 Term seed = args[4];
	                 random.setSeed(Long.parseLong(seed.toString()));
	                 handoverArg = args[5];
	             }
	             bandit = new EGreedyMAB(
	                     arms,
	                     Double.parseDouble(epsilon.toString()),
	                     Double.parseDouble(decayRate.toString()),
	                     true,
	                     random);
	          break;
	        case UBC:
	             handoverArg = args[2];
	             bandit = new UBCMAB(arms);
	          break;
	        default:
	          throw new Exception("Bandit type not specified correctly: " + type + ". Must be one of " + BanditType.values() + ".");
        }


        BanditManager.bandits.add(bandit);
        NumberTerm banditIndex = ASSyntax.createNumber(BanditManager.bandits.size() -1);
        return un.unifies(banditIndex, handoverArg);
    }
}
