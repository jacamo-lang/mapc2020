package scenario;

import java.util.ArrayList;
import java.util.List;

import com.google.common.collect.Table;

import busca.Estado;
import busca.Heuristica;
import jason.environment.grid.Location;

public class GridState implements Estado, Heuristica {
    // State information
    private Location pos; // current location
    private Location from,to;
    private String direction; //can be one of the following: [n,s,e,w]
    private Table<Integer, Integer, String> map;
    private int custoAcumulado;

    /**
     * It is used to allow path costs until a certain tolerance comparing to
     * a "straight line" (euclidean distance). At least empirically, 4 times
     * was enough for the tests we have created so far.
     */
    private final double SOLVABILITY_THRESHOLD = 4.0;

    /**
     *
     * @param l
     * @param from
     * @param to
     * @param direction can be one of the following: [n,s,e,w]
     */
    public GridState(Location l, Location from, Location to, String direction, Table<Integer, Integer, String> map) {
        this.pos = l;
        this.from = from;
        this.to = to;
        this.direction = direction;
        this.map = map;
    }

    public int custo() {
        return 1;
    }

    public void setCustoAcumulado(int custoAcumulado) {
        this.custoAcumulado = custoAcumulado;
    }

    public int custoAcumulado() {
        return this.custoAcumulado;
    }

    public boolean ehMeta() {
        return pos.equals(to);
    }

    public String getDescricao() {
        return "Grid search";
    }

    public int h() {
        return pos.distance(to);
    }

    public List<Estado> sucessores() {
        List<Estado> s = new ArrayList<Estado>(4);
        // four directions
        suc(s,new Location(pos.x-1,pos.y),"w");
        suc(s,new Location(pos.x+1,pos.y),"e");
        suc(s,new Location(pos.x,pos.y-1),"n");
        suc(s,new Location(pos.x,pos.y+1),"s");
        return s;
    }

    private void suc(List<Estado> s, Location newl, String direction) {
        if (isWalkable(newl)) {
            GridState newState = new GridState(newl, from, to, direction, map);
            newState.setCustoAcumulado(this.custoAcumulado() + this.custo());
            if (newState.custoAcumulado <= from.distance(to) * SOLVABILITY_THRESHOLD) {
                s.add(newState);
            }
        }
    }
    
    public boolean isWalkable(Location newl) {
        return (!map.contains(newl.x, newl.y)) || (
                (!map.get(newl.x, newl.y).equals("a") || from.distance(newl) > 3) && // an agent of team a
                (!map.get(newl.x, newl.y).equals("b") || from.distance(newl) > 3) && // an agent of team b
                (!map.get(newl.x, newl.y).equals("obstacle")) );
    }

    public boolean equals(Object o) {
        try {
            GridState m = (GridState)o;
            return pos.equals(m.pos);
        } catch (Exception e) {}
        return false;
    }

    public int hashCode() {
        return pos.hashCode();
    }

    public String toString() {
        return "(" + pos + "-" + direction + ")";
    }

    public String getDirection() {
        return direction;
    }
}
