package jason.stdlib;

import java.util.Iterator;

import com.google.common.collect.HashBasedTable;
import com.google.common.collect.Table;

import busca.AEstrela;
import busca.Busca;
import busca.Estado;
import busca.Nodo;
import jason.JasonException;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jason.environment.grid.Location;
import jason.asSyntax.Atom;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Literal;
import scenario.GridState;

/**
 * getDirection for MAPC 2020. It uses A* to generate the path to driven an
 * agent 'from' iagx/y 'to' itox/y. The solution should be the next step of the
 * path. Unless some caching apparatus is developed, the search should be
 * performed on each step.
 *
 * @param iagx      Agent's X
 * @param iagy      Agent's Y
 * @param itox      Target's X
 * @param itoy      Target's Y
 * @param direction can be one of the following: [n,s,e,w]
 */
@SuppressWarnings("serial")
public class get_direction extends DefaultInternalAction {

    @Override
    public int getMinArgs() {
        return 6;
    }

    @Override
    public int getMaxArgs() {
        return 6;
    }

    @Override
    protected void checkArguments(Term[] args) throws JasonException {
        super.checkArguments(args); // check number of arguments
        if (!args[0].isNumeric() || !args[1].isNumeric() || !args[2].isNumeric() || !args[3].isNumeric())
            throw JasonException.createWrongArgument(this, "First 4 arguments must be numbers");
        if (!args[4].isList())
            throw JasonException.createWrongArgument(this, "Fifth argument must be a list");
        if (!args[5].isVar())
            throw JasonException.createWrongArgument(this, "Sixth argument must be a var");
    }
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        checkArguments(args);

        int iagx = (int)((NumberTerm)args[0]).solve();
        int iagy = (int)((NumberTerm)args[1]).solve();
        int itox = (int)((NumberTerm)args[2]).solve();
        int itoy = (int)((NumberTerm)args[3]).solve();
        
        try {
            Busca search = new AEstrela();
            Location lini = new Location(iagx, iagy);

            Table<Integer, Integer, String> map = HashBasedTable.create();

            final Iterator<Term> i = ((ListTerm)args[4]).iterator();
            while (i.hasNext()) {
                Literal l = (Literal)i.next();
                if (l.getFunctor().equals("gps_map") && l.getArity() == 4) {
                        map.put(
                                (int)((NumberTerm)l.getTerm(0)).solve(), 
                                (int)((NumberTerm)l.getTerm(1)).solve(), 
                                ((Literal)l.getTerm(2)).toString()
                        );
                } 
            }

            Nodo solution = search.busca(new GridState(lini, lini, new Location(itox, itoy), "", map));
            /*
            //The view of the agent
            int SIZE = 50;
            for (int i = -SIZE; i < SIZE; i++ ) {
                for (int j = -SIZE; j < SIZE; j++ ) {
                    if (map.contains(j, i))
                        System.out.printf("%c",map.get(j, i).charAt(0));
                    else
                        System.out.printf("%c",' ');
                }
                System.out.printf("%n");
            }
            */
            // The solution "solution.montaCaminho()" can be a long path, we need the next direction
            if (solution != null) {
                Nodo root = solution;
                Estado prev1 = null;
                Estado prev2 = null;
                while (root != null) {
                    prev2 = prev1;
                    prev1 = root.getEstado();
                    root = root.getPai();
                }
                if (prev2 != null) {
                    return un.unifies(args[5], new Atom(((GridState)prev2).getDirection()));
                }
            } 
        } catch (Throwable e) {
            e.printStackTrace();
        }
        
        System.err.println("No route from "+iagx+","+iagy+" to "+itox+","+itoy+"!");
        return un.unifies(args[5], new Atom("error"));
    }
}
