package jason.stdlib;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import jason.JasonException;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;
import jason.asSyntax.StringTerm;
import jason.asSyntax.Term;
import runMAPC2020.Statistics;

/**
 * Save statistics of the match
 */
@SuppressWarnings("serial")
public class save_stats extends DefaultInternalAction {

    @Override
    public int getMinArgs() {
        return 2;
    }

    @Override
    public int getMaxArgs() {
        return 2;
    }

    @Override
    protected void checkArguments(Term[] args) throws JasonException {
        super.checkArguments(args); // check number of arguments
    }
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        checkArguments(args);
        
        try {
            Statistics s = Statistics.getInstance();
            
            Map<String, String> data = new HashMap<>();
            data.put("team", ts.getAgArch().getAgName().substring(5, 6));

            Iterator<Literal> it = ts.getAg().getBB().iterator();
            while (it.hasNext()) {
                Literal l = it.next();
                if ( ((Literal)l).getFunctor().equals("persistTeamSize") ) {
                    data.put("teamSize", ((Literal)l).getTerm(0).toString() );
                    break;
                }
            }
            data.put("event", ((StringTerm)args[0]).getString());
            data.put("comment", ((StringTerm)args[1]).getString());
            
            s.saveMatchStats(data);
        } catch (Throwable e) {
            e.printStackTrace();
        }
        
        return true;
    }
}
