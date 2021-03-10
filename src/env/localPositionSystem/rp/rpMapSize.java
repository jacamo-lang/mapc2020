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

import jason.asSyntax.ASSyntax;
import jason.asSyntax.Atom;


import cartago.*;

public class rpMapSize extends rp {

    protected Map<Integer, Integer> mapX = new HashMap<Integer, Integer>();
    protected Map<Integer, Integer> mapY = new HashMap<Integer, Integer>();
    int size_x = 0;
    int size_y = 0;

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
                    if(axis.equals("x")) size_x = checkAgreement(map);
                    if(axis.equals("y")) size_y = checkAgreement(map);
                    updateMapSize(); 
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
        size_x = 0;
        size_y = 0;
    }

    int adaptSize(int axisSize, int size) {
        int center = axisSize/2;
        if(size>=center)
            return adaptSize(axisSize, size-axisSize);
        if(size<(center*-1))
            return adaptSize(axisSize, size+axisSize);
        return size;
    }

    @OPERATION
    protected void mark(int i, int j, String type, String info, int vision, String mapId) {        
        super.mark(i,j,type,info,vision,mapId);        
        markMapSize(i,j,type,mapId);
        //if(size_x>0&&size_y>0&&!type.equals("obstacle")) 
        //    replicateMapSizeProp(i,j, ASSyntax.createAtom(type),ASSyntax.createAtom(mapId), 3);
    }

    @OPERATION
    protected void mark(int i, int j, String type, String mapId) {   
        super.mark(i,j,type,mapId);
        markMapSize(i,j,type,mapId);
        //if(size_x>0&&size_y>0&&!type.equals("obstacle")) 
        //    replicateMapSizeProp(i,j, ASSyntax.createAtom(type),ASSyntax.createAtom(mapId), 3);
    }

    void markMapSize(int i, int j, String type, String mapId) {
        if(size_x>0&&size_y>0) {            
            int x = adaptSize(size_x,i);
            int y = adaptSize(size_y,j);      
            if(x!=i|y!=j) {
                if (this.getObsPropertyByTemplate("gps_map", x,y,ASSyntax.createAtom(type),ASSyntax.createAtom(mapId)) == null) {
                    defineObsProperty("gps_map",x,y,ASSyntax.createAtom(type),ASSyntax.createAtom(mapId));
                    //System.out.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! mark map size ("+i+","+j+") to ("+x+","+y+")");
                }
            }
        }
    }

    void updateMapSize() {
        if(size_x>0&&size_y>0) {     
            try {
                int x, y;
                ArtifactInfo info = CartagoService.getController(this.getId().getWorkspaceId().getName()).getArtifactInfo(this.getId().getName());
                for (ArtifactObsProperty op : info.getObsProperties()) {
                    if (op.getName().equals("gps_map"))
                        if(!op.getValues()[2].toString().equals("obstacle"))
                        {
                            x = adaptSize(size_x,(int)op.getValues()[0]);
                            y = adaptSize(size_y,(int)op.getValues()[1]);
                            if(x!=(int)op.getValues()[0]|y!=(int)op.getValues()[1])
                                if (this.getObsPropertyByTemplate("gps_map", x,y,(Atom)op.getValues()[2],(Atom)op.getValues()[3]) == null) {
                                    defineObsProperty("gps_map",x,y,ASSyntax.createAtom(op.getValues()[2].toString()),ASSyntax.createAtom(op.getValues()[3].toString()));
                                    //System.out.println("................................ creating gps_map("+x+","+y+","+ASSyntax.createAtom(op.getValues()[2].toString())+","+ASSyntax.createAtom(op.getValues()[3].toString())+")");
                                }
                        }
                }

            } catch (Throwable e) {
                e.printStackTrace();
            }
        }
    }

  //disabled due to performance issues. TODO: test and improve
    /*void replicateMapSizeProp(int x, int y, Atom type, Atom mapId, int times) {
    	
    	
        int factorX = (x!=0) ? x/Math.abs(x) : 1;
        int factorY = (y!=0) ? y/Math.abs(y) : 1;
        if(x>(size_x/2*-1)&x<(size_x/2)) {  //if x is in the fieldsize
            for(int i=1;i<=times;i++){
                if((x>0 & (x+size_x*i)<=size_x*times)|(x<0 & (x-size_x*i)>=size_x*times*-1)) //if the new x fits in the given range
                    for(int j=0;j<=times;j++) {
                        //if((y+size_y*j)<=size_y*times)//if the new x fits in the given range)
                        if((y>0 & (y+size_y*j)<=size_y*times)|(y<0 & (y-size_y*j)>=size_y*times*-1)) //if the new y fits in the given range
                            if (this.getObsPropertyByTemplate("gps_map", (x+size_x*i*factorX),(y+size_y*j*factorY),type,mapId) == null) {
                                defineObsProperty("gps_map", (factorX+size_x*i*factorX),(y+size_y*j*factorY),type,mapId);
                                //System.out.println(";;;;;;;;;;;;;;;;;;; creating gps_map("+ (x+size_x*i*factorX)+","+(y+size_y*j*factorY)+","+type+","+ mapId+") - original: ("+x+","+y+") factor (" + i+","+j+")");
                            }
                    }
            }

            if(y>(size_y/2*-1)&y<(size_y/2)) {  //if y is in the fieldsize
                for(int i=1;i<=times;i++){
                    if((y>0 & (y+size_y*i)<=size_y*times)|(y<0 & (y-size_y*i)>=size_y*times*-1)) //if the new x fits in the given range
                        for(int j=0;j<=times;j++) {
                            if((x>0 & (x+size_x*j)<=size_x*times)|(x<0 & (x-size_x*j)>=size_x*times*-1)) //if the new y fits in the given range
                                if (this.getObsPropertyByTemplate("gps_map", (x+size_x*j*factorX),(y+size_y*i*factorY),type,mapId) == null) {
                                    defineObsProperty("gps_map", (factorX+size_x*j*factorX),(y+size_y*i*factorY),type,mapId);
                                    //System.out.println("+++++++++++++++++++ creating gps_map("+ (x+size_x*j*factorX)+","+(y+size_y*i*factorY)+","+type+","+ mapId+") - original: ("+x+","+y+") factor (" + i+","+j+")");
                                }
                        }
                }
            }

            //if((x>(size_x/2*-1)&x<(size_x/2)) | //if x is in the fieldsize
            //   (y>(size_y/2*-1)&y<(size_y/2))) { //if y is in the fieldsize

            //}
        }
    }*/    

}
