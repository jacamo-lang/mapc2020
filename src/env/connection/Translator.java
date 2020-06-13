package connection;

import jason.JasonException;
import jason.NoValueException;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.StringTerm;

import jason.asSyntax.Term;
import jason.asSyntax.parser.ParseException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

import eis.iilang.Action;
import eis.iilang.Function;
import eis.iilang.Identifier;
import eis.iilang.Numeral;
import eis.iilang.Parameter;
import eis.iilang.ParameterList;
import eis.iilang.Percept;

public class Translator {

    public static Literal perceptToLiteral(Percept per) throws JasonException {
        Literal l = ASSyntax.createLiteral(per.getName());
        for (Parameter par : per.getParameters())
            l.addTerm(parameterToTerm(par));
        return l;
    }

    public static Percept literalToPercept(jason.asSyntax.Literal l) throws NoValueException {
        Percept p = new Percept(l.getFunctor());
        for (Term t : l.getTerms())
            p.addParameter(termToParameter(t));
        return p;
    }

    public static Action literalToAction(Literal action) throws NoValueException {
        Parameter[] pars = new Parameter[action.getArity()];
        for (int i = 0; i < action.getArity(); i++)
            pars[i] = termToParameter(action.getTerm(i));
        return new Action(action.getFunctor(), pars);
    }

    public static Parameter termToParameter(Term t) throws NoValueException {
        if (t.isNumeric()) {
            double d = ((NumberTerm) t).solve();
            if((d == Math.floor(d)) && !Double.isInfinite(d)) return new Numeral((int)d);
            return new Numeral(d);
        } else if (t.isList()) {
            ListTerm lt=(ListTerm) t;
            Parameter[] terms = new Parameter[lt.size()];
            for (int i=0;i<lt.size();i++)
                terms[i]=termToParameter(lt.get(i));
            return new ParameterList(terms);
        } else if (t.isString()) {
            return new Identifier(((StringTerm) t).getString());
        } else if (t.isLiteral()) {
            Literal l = (Literal) t;
            if (!l.hasTerm()) {
                return new Identifier(l.getFunctor());
            } else {
                Parameter[] terms = new Parameter[l.getArity()];
                for (int i = 0; i < l.getArity(); i++)
                    terms[i] = termToParameter(l.getTerm(i));
                return new Function(l.getFunctor(), terms);
            }
        }
        return new Identifier(t.toString());
    }

    public static Term parameterToTerm(Parameter par) throws JasonException {
        if (par instanceof Numeral) {
            return ASSyntax.createNumber(((Numeral) par).getValue().doubleValue());
        } else if (par instanceof Identifier) {
            try {
                Identifier i = (Identifier) par;
                String a = i.getValue();
                if (!Character.isUpperCase(a.charAt(0)))
                    return ASSyntax.parseTerm(a);
            } catch (Exception e) {
            }
            return ASSyntax.createString(((Identifier) par).getValue());
        } else if (par instanceof ParameterList) {
            ListTerm list = new ListTermImpl();
            ListTerm tail = list;
            for (Parameter p : (ParameterList) par)
                tail = tail.append(parameterToTerm(p));
            return list;
        }
        throw new JasonException("The type of parameter " + par + " is unknown!");
    }



    public static Term[] parametersToTerms(List<Parameter> list) {
        Term [] ret = new Term[list.size()];
        Term aux=null;
        for (int i=0; i<list.size();i++) {
            aux=null;
            if (list.get(i) instanceof Numeral) {
                aux = ASSyntax.createNumber(((Numeral) list.get(i)).getValue().doubleValue());
            } //else if (pe.get(i) instanceof Identifier) {
//              try {
//                  Identifier id = (Identifier) pe.get(i);
//                  String a = id.getValue().toLowerCase();
//                  if (!Character.isUpperCase(a.charAt(0)))
//                      aux =  ASSyntax.parseTerm(a);
//              } catch (Exception e) {
//              }
            else {
                try {
                    if (list.get(i).toProlog().equals("")) {
                        aux = ASSyntax.createLiteral("null");
                    }
                    else {
                        aux = ASSyntax.parseTerm(list.get(i).toString().toLowerCase());//pe.get(i).toProlog());
                    }
                } catch (ParseException e) {
                    e.printStackTrace();
                }
            }
            ret[i]=aux;
        }
        return ret;
    }
}
