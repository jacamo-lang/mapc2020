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
        // Avoiding obstacles and agents of both teams
        if (    (!map.contains(newl.x, newl.y)) || (
                (!map.get(newl.x, newl.y).equals("a") || euclidianDistance(from,newl) > 3) && // an agent of team a
                (!map.get(newl.x, newl.y).equals("b") || euclidianDistance(from,newl) > 3) && // an agent of team b
                (!map.get(newl.x, newl.y).equals("obstacle") || euclidianDistance(from,newl) > 10)
                )) {
            s.add(new GridState(newl, from, to, direction, map));
        }
    }

    public boolean equals(Object o) {
        try {
            GridState m = (GridState)o;
            return pos.equals(m.pos);
        } catch (Exception e) {}
        return false;
    }

    public int euclidianDistance(Location from, Location to) {
        return Math.abs(from.x - to.x) + Math.abs(from.y - to.y);
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
