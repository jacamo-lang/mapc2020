package routePlanner;

import busca.AEstrela;
import busca.Busca;
import busca.Estado;
import busca.Heuristica;
import busca.Nodo;

import jason.asSyntax.Atom;
import jason.environment.grid.Location;

import scenario.GridState;

import cartago.*;

public class rp extends Artifact {

    /**
     * getDirection for MAPC 2020
     * @param iagx Agent's X
     * @param iagy Agent's Y
     * @param itox Target's X
     * @param itoy Target's Y
     * @param direction can be one of the following: [n,s,e,w]
     */
    @OPERATION
    void getDirection(int iagx, int iagy, int itox, int itoy, OpFeedbackParam<Atom> direction) {
        try {
            Busca searchAlg = new AEstrela();
            // searchAlg.setMaxAbertos(1000);
            Location lini = new Location(iagx, iagy);

            // Dummy getDirection (no using A* yet):
            if (itox != iagx) {
                if (itox > iagx) { // Agent have to do EAST
                    direction.set(new Atom("e"));
                } else { // Agent have to do WEST
                    direction.set(new Atom("w"));
                }
            } else {
                if (itoy != iagy) {
                    if (itoy > iagy) { // Agent have to do SOUTH
                        direction.set(new Atom("s"));
                    } else { // Agent have to do NORTH
                        direction.set(new Atom("n"));
                    }
                }
            }
                
                
            /* 
             * This is part of original goldminers solution, left here just as an example
             * 
             * 
            // while (!model.isFreeOfObstacle(itox,itoy) && itox > 0) itox--;
            // while (!model.isFreeOfObstacle(itox,itoy) && itox < model.getWidth()) itox++;

            Nodo solution = searchAlg.busca(new GridState(lini, lini, new Location(itox, itoy), "initial"));
            if (solution != null) {
                // System.out.println(iagx+"-"+iagy+"/"+itox+"-"+itoy+" =
                // "+solution.montaCaminho());
                Nodo root = solution;
                Estado prev1 = null;
                Estado prev2 = null;
                while (root != null) {
                    prev2 = prev1;
                    prev1 = root.getEstado();
                    root = root.getPai();
                }
                if (prev2 != null) {
                    // sAction = ((GridState)prev2).op;
                }
            } else {
                // System.out.println("No route from "+iagx+"x"+iagy+" to "+itox+"x"+itoy+"!");
            }
            */
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }
}
