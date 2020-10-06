package localPositionSystem.rp;

import com.google.common.collect.HashBasedTable;
import com.google.common.collect.Table;

import busca.AEstrela;
import busca.Busca;
import busca.Estado;
import busca.Nodo;

import jason.asSyntax.Atom;
import jason.environment.grid.Location;
import localPositionSystem.lps;
import scenario.GridState;

import cartago.*;

/**
 * RoutePlanner (rp) class uses search algorithm to find the best path from
 * point A to B
 *
 * @author cleber
 *
 */
public class rp extends lps {

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
    @OPERATION
    void getDirection(int iagx, int iagy, int itox, int itoy, OpFeedbackParam<Atom> direction) {
        try {
            Busca search = new AEstrela();
            Location lini = new Location(iagx, iagy);

            Table<Integer, Integer, String> map = HashBasedTable.create();
            ArtifactInfo info = CartagoService.getController(this.getId().getWorkspaceId().getName()).getArtifactInfo(this.getId().getName());
            for (ArtifactObsProperty op : info.getObsProperties()) {
                if (op.getName().equals("gps_map")) {
                    map.put((int)op.getValues()[0], (int) op.getValues()[1], ((Atom) op.getValues()[2]).toString());
                }
            }

            Nodo solution = search.busca(new GridState(lini, lini, new Location(itox, itoy), "", map, null));
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
                    direction.set(new Atom(((GridState)prev2).getDirection()));
                }
            } else {
                System.out.println("No route from "+iagx+","+iagy+" to "+itox+","+itoy+"!");
                direction.set(new Atom("error"));
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    @OPERATION
    void setGpsMapForTests(int x, int y, String type, String mapId) {
        defineObsProperty("gps_map",x,y,new Atom(type),mapId);
    }

    @OPERATION
    void resetRP() {
        while (getObsProperty("gps_map") != null) {
            removeObsProperty("gps_map");
        }
        while (getObsProperty("edge") != null) { //used in stc strategy
            removeObsProperty("edge");
        }
    }
}
