//originlead(agentA1). //TODO: import from common_exploration




//turn the coordinate A into B considering the size S. Ex. A=100,S=70
adapt_coordinate(A,B,0):-B=A.
adapt_coordinate(A,B,S):-axis_center(S,C)&(A>=C)&adapt_coordinate(A-S,Temp,S)&B=Temp.
adapt_coordinate(A,B,S):-axis_center(S,C)&(A<C*-1)&adapt_coordinate(A+S,Temp,S)&B=Temp.
adapt_coordinate(A,B,S):-axis_center(S,C)&(A<C)&(A>C*-1)&B=A.
axis_center(S,C):-C=(S)div(2).

!start. 

+!start <- focusWhenAvailable(artGPSA). //TODO: make it not hardcoded        




/**
 * As soon as map size is defined, the agent mark the missing coordinates
 */
+size_x(X) : size_y(Y) &  axis_center(X,CX) & axis_center(X,CY)& 
            .findall(m(XX,YY,Object,Map),originlead(Map)&gps_map(XX,YY,Object,Map)&Object\==obstacle&(XX>math.abs(CX)|YY>math.abs(CY)) , L)&
            .findall(n(XX,YY,Object,Map),originlead(Map)&gps_map(XX,YY,Object,Map)&Object\==obstacle&(XX<math.abs(CX)|YY>math.abs(CY)) , N)
   <- !adapt_map_size(L);
      !replicate_map_size(N);
      //.print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  ", sizes, " ", L);
      .
   
+size_y(Y) : size_x(X) & axis_center(X,CX) & axis_center(X,CY)& 
            .findall(m(XX,YY,Object,Map),originlead(Map)&gps_map(XX,YY,Object,Map)&Object\==obstacle&(XX>math.abs(CX)|YY>math.abs(CY)) , L) &
            .findall(n(XX,YY,Object,Map),originlead(Map)&gps_map(XX,YY,Object,Map)&Object\==obstacle&(XX<math.abs(CX)|YY>math.abs(CY)) , N)
   <- !adapt_map_size(L); 
      !replicate_map_size(N);  
      //.print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  ", sizes, " ", L);
      .
      
      
+gps_map(X,Y,Object,MapId) : originlead(MapId) & Object\==obstacle &
                             map_adapted & 
                             size_x(SX) & size_y(SY) //&
                             //axis_center(SX,CX) & axis_center(SY,CY) &
                             //(math.abs(X)>=CX |  math.abs(Y)>CY) 
   <- !insert_into_map(X,Y,Object,MapId);
      !replicate_map_x(X,Y,Object,MapId,2);
      !replicate_map_y(X,Y,Object,MapId,2).        
      
/**
 * Copy the mappings outside the map to into the map limits. 
 */      
+!adapt_map_size([]) <- +map_adapted.
+!adapt_map_size([m(X,Y,Object,MapId)|T]) 
   <- !insert_into_map(X,Y,Object,MapId);
      !adapt_map_size(T).       

+!replicate_map_size([]).
+!replicate_map_size([n(X,Y,Object,MapId)|T]) 
   <- !replicate_map_x(X,Y,Object,MapId,2);
      !replicate_map_y(X,Y,Object,MapId,2);
      !replicate_map_size(T). 

+!insert_into_map(X,Y,Object,MapId) : size_x(SX) & size_y(SY) &
                                      adapt_coordinate(X,NX,SX) &
                                      adapt_coordinate(Y,NY,SY) &
                                      not(gps_map(NX,NY,Object,MapId))  
<-  .print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! marking ",gps_map(X,Y,Object,MapId), " to ", gps_map(NX, NY, Object,  MapId));
    mark(NX, NY, Object, MapId);
    .
   
+!insert_into_map(X,Y,Object,MapId)
   <- .print("------------------------------- ignoring ",m(X,Y,Object,MapId)).
      
      
      
+!replicate_map_x(X,Y,Object,MapId,Times) : size_x(SX) & X+SX < SX*(Times+1) & not(gps_map(X+SX,Y,Object,MapId))
   <-  mark(X+SX,Y, Object, MapId);
       .print("================== replicating ", from(X,Y,Object,MapId,Times), " to ", mark(X+SX,Y, Object, MapId)).
       //!replicate_map_x(X+SX,Y,Object,MapId,Times).        
+!replicate_map_x(X,Y,Object,MapId,Times).   


+!replicate_map_y(X,Y,Object,MapId,Times) : size_y(SY) & Y+SY < SY*(Times+1) & not(gps_map(X,Y+SY,Object,MapId))
   <-  mark(X,Y+SY, Object, MapId);
       .print("xxxxxxxxxxxxxxxxxx replicating ", from(X,Y,Object,MapId,Times), " to ", mark(X,Y+SY, Object, MapId)).
       //!replicate_map_x(X+SX,Y,Object,MapId,Times).        
+!replicate_map_y(X,Y,Object,MapId,Times).   

+!areyou(_,_,_,_,_,_,_,_). 

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
