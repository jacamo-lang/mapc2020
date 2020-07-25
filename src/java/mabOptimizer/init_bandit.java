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
import mabOptimizer.*;

public class init_bandit extends DefaultInternalAction  {
    
    static Random random = new Random();

    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        ListTerm tArmNames = (ListTerm) args[0];
        Term epsilon = args[1];
        Term decayRate = args[2];
        Term handoverArg = args[3];
        if (args.length > 3) {
            Term seed = args[3];
            random.setSeed(Long.parseLong(seed.toString()));
            handoverArg = args[4];
        }
        ArrayList<MABArm> arms =  new ArrayList<MABArm>();
        for(Term tArmName: tArmNames) {
            arms.add(new MABArm(tArmName.toString().replace("\"", "")));
        }
        MAB bandit = new MAB(
                arms,
                Double.parseDouble(epsilon.toString()),
                Double.parseDouble(decayRate.toString()),
                true,
                random);
        BanditManager.bandits.add(bandit);
        NumberTerm banditIndex = ASSyntax.createNumber(BanditManager.bandits.size() -1);
        return un.unifies(banditIndex, handoverArg);
    }
}
