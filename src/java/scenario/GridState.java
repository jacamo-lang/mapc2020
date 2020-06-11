package scenario;

import java.util.ArrayList;
import java.util.List;

import busca.Estado;
import busca.Heuristica;
import jason.environment.grid.Location;

public class GridState implements Estado, Heuristica {
    // State information
    private Location pos; // current location
    private Location from,to;
    private String direction; //can be one of the following: [n,s,e,w]

    /**
     * 
     * @param l
     * @param from
     * @param to
     * @param direction can be one of the following: [n,s,e,w]
     */
    public GridState(Location l, Location from, Location to, String direction) {
        this.pos = l;
        this.from = from;
        this.to = to;
        this.direction = direction;
    }

    public int custo() {
        return 1;
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
        // Dummy implementation: It is not pruning any possibility, just creating all of them
        s.add(new GridState(newl,from,to,direction));
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
