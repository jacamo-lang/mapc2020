package scenario;

import java.util.ArrayList;
import java.util.List;

import com.google.common.collect.Table;

import busca.Estado;
import busca.Heuristica;
import jason.environment.grid.Location;

public class FlexGridState implements Estado, Heuristica {
    // State information
    private Location pos; // current location
    private Location from,to;
    private String direction; //can be one of the following: [n,s,e,w]
    private Table<Integer, Integer, String> map;
    private ArrayList<ArrayList<Boolean>> shape;
    
    /**
     * 
     * @param l
     * @param from
     * @param to
     * @param direction can be one of the following: [n,s,e,w]
     * @param map
     * @param shape Array of arrays that describes the shape of the agent. Assuming the location is the "smallest coordinate" the shape is a grid in which each
     * 				field that is actually filled is marked as {@code true}, and otherwise as {@code false}.
     */
    public FlexGridState(Location l, Location from, Location to, String direction, Table<Integer, Integer, String> map, ArrayList<ArrayList<Boolean>> shape) {
        this.pos = l;
        this.from = from;
        this.to = to;
        this.direction = direction;
        this.map = map;
        this.shape = shape;
    }

    public int custo() { // getCost()
        return 1;
    }

    public boolean ehMeta() { // isGoal()
        return pos.equals(to);
    }

    public String getDescricao() { // getDescription()
        return "Grid search";
    }

    public int h() { // getDistance()
        return pos.distance(to);
    }

    public List<Estado> sucessores() { // get immediate successors (adjacent states)
        List<Estado> s = new ArrayList<Estado>(4);
        // four directions
        suc(s,new Location(pos.x-1,pos.y),"w");
        suc(s,new Location(pos.x+1,pos.y),"e");
        suc(s,new Location(pos.x,pos.y-1),"n");
        suc(s,new Location(pos.x,pos.y+1),"s");
        return s;
    }
    
    /**
     * Checks if a given location in the grid is accessible by an agent
     * @param loc current location of the agent (or part of an agent/agent team)
     * @return {@code true} or {@code false}
     */
    private boolean isAccessible(Location loc) {
    	return
    			(map.contains(loc.x, loc.y)) &&
    			(!map.get(loc.x, loc.y).equals("a")) && // an agent of team a
    			(!map.get(loc.x, loc.y).equals("b")) && // an agent of team b
    			(!map.get(loc.x, loc.y).equals("obstacle"));
    }

    /**
     * Determines valid successor states by checking if moving in the direction would make the agent
     * attempt to move to occupied states 
     * @param s
     * @param newl
     * @param direction
     */
    private void suc(List<Estado> s, Location newl, String direction) {
        // Avoiding obstacles and agents of both teams
    	ArrayList<Location> newLocations = new ArrayList<Location>();
    	for(int i = 0; i < shape.get(0).size(); i++) {
    		for(int j = 0; j < shape.get(i).size(); j++) {
    			if(shape.get(i).get(j)) {
    				newLocations.add(new Location(newl.x + i, newl.y + j));
    			}
        	}
    	}
    	boolean isAccessible = true;
    	for(Location location: newLocations) {
    		if(!isAccessible(location)){
    			isAccessible = false;
    			break;
    		}
    	}
        if (isAccessible) {
            s.add(new FlexGridState(newl, from, to, direction, map, shape));
        }
    }

    public boolean equals(Object o) {
        try {
            FlexGridState m = (FlexGridState)o;
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
