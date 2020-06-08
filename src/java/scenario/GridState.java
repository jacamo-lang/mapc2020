package scenario;

import java.util.ArrayList;
import java.util.List;

import busca.Estado;
import busca.Heuristica;
import jason.environment.grid.Location;

public class GridState implements Estado, Heuristica {
    // State information
    Location pos; // current location
    Location from,to;
    String op;

    public GridState(Location l, Location from, Location to, String op) {
        this.pos = l;
        this.from = from;
        this.to = to;
        this.op = op;
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
        suc(s,new Location(pos.x-1,pos.y),"left");
        suc(s,new Location(pos.x+1,pos.y),"right");
        suc(s,new Location(pos.x,pos.y-1),"up");
        suc(s,new Location(pos.x,pos.y+1),"down");
        return s;
    }

    private void suc(List<Estado> s, Location newl, String op) {
        //if (model.isFree(newl) || (from.distance(newl) > 3 && model.isFreeOfObstacle(newl))) {
            s.add(new GridState(newl,from,to,op));
        //}
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
        return "(" + pos + "-" + op + ")";
    }
}
