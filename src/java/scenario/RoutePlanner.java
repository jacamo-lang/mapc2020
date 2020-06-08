package scenario;

import busca.AEstrela;
import busca.Busca;
import busca.Estado;
import busca.Heuristica;
import busca.Nodo;
import jason.environment.grid.Location;

public class RoutePlanner {

    public RoutePlanner() {

    };

    void getDirection(int iagx, int iagy, int itox, int itoy) {
        try {
            Busca searchAlg = new AEstrela();
            // searchAlg.setMaxAbertos(1000);
            Location lini = new Location(iagx, iagy);

            // destination should be a free place
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
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }
}
