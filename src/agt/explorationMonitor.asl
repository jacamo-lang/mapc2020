{ include("simulation/massim.asl") }


mapId(agenta0).

inMap(Map) :- mapId(M) & .substring(M,Map). 

+step(0)
   <- .abolish(mapping(_,_)); //remove informations of previous simulations
      +mapping(0,0).

+step(S): S mod 5==0 & S <= 700 
   <- .findall(p(X,Y,Z,Map),gps_map(X,Y,Z,MapId)&inMap(MapId)&Z\=="obstacle"&Z\==obstacle,L);
      .length(L,M);
      +mapping(S,M).
      
+step(701) 
   <- .findall(mapping(S,M),mapping(S,M),L);
      .sort(L,LSort);
      !print_list(LSort);
      
      .findall(rX(x,Rx,S,Ag),raioX(Rx,S,Ag),Lx);
      !print_map_size(Lx);
      .findall(rY(y,Ry,S,Ag),raioY(Ry,S,Ag),Ly);
      !print_map_size(Ly).

+!print_list([]).      
+!print_list([mapping(S,M)|T])
   <- .print(S,";",M);
      !print_list(T).
      
+!print_map_size([]).
+!print_map_size([rX(Axis,R,S,Ag)|T])
   <- .print(Axis, R,";",S,"Ag");
      !print_map_size(T).            
      
+!areyou(_,_,_,_,_,_,_,_).      

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
