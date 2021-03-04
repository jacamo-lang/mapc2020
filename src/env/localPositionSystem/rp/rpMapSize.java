package localPositionSystem.rp;


import cartago.OPERATION;

/**
 * This is an extension of the GPS artifact that includes operations and properties to calculate the size of the map.
 * 
 *  The agents use the operation setMapSize to inform the size they have calculated for each axis (x and y).
 *  A hash map stores the informations as pairs where the key is the calculated size and the value is the amount of agents that have found such result.
 *  From every new information, the artifact checks the agreement on a value for each axis through the method checkAgreement. 
 *  Agreed values become the observable properties size_x(Value) and size_y(Value). 
 * 
 */

import java.lang.Integer;
import java.util.*;

public class rpMapSize extends rp {

    protected Map<Integer, Integer> mapX = new HashMap<Integer, Integer>();
    protected Map<Integer, Integer> mapY = new HashMap<Integer, Integer>();
    
    /**
     * Inform the calculated size of an axis (x or y) 
     * 
     * @param axis
     * @param size
     */
    @OPERATION
    void setMapSize(String axis, int size) {
        if(getObsProperty("size_".concat(axis)) == null) { //if the size has not been found yet
            Map<Integer,Integer> map = null;
            if(axis.equals("x"))
                map = mapX;
            else
                if(axis.equals("y"))
                    map = mapY;

            if(map!=null) {
                doSetMapSize(map,size);
                if(checkAgreement(map)>-1) {
                    defineObsProperty("size_".concat(axis),checkAgreement(map));
                }
            }
        }
    }


    void doSetMapSize(Map<Integer,Integer> map, int size) {
        if(map.get(size)!=null)
            map.put(size,map.get(size)+1);
        else
            map.put(size,1);

    }

    /**
     *   Check whether there is an agreement on the size of the given axis.
     *   
     *   Currently, it is a naive implementation: the agreement is on the largest pointed size (minimum 5)
     *   TODO: implement a real agreement algorithm    
     */
    private int checkAgreement(Map<Integer,Integer> map) {
        int largestSize = -1;
        int MINIMUM = 5; //minimal votes for agreement
        for (Map.Entry<Integer, Integer> entry : map.entrySet()) {
            if(largestSize==-1 || entry.getValue()>map.get(largestSize))
                largestSize = entry.getKey();
        }      
        if(largestSize==-1 || map.get(largestSize)<MINIMUM)
            largestSize = -1;
        return largestSize;
    }
    
    
    @OPERATION
    void resetRP() {
        super.resetRP();
        while (getObsProperty("size_x") != null) {
            removeObsProperty("size_x");
        }
        while (getObsProperty("size_y") != null) {
            removeObsProperty("size_y");
        }
        mapX.clear();
        mapY.clear();
    }
    
}
