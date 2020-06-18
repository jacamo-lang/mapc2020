mapId(agenta0).

inMap(Map) :- mapId(M) & .substring(M,Map). 

+step(0)
   <- .abolish(mapping(_,_)); //remove informations of previous simulations
      +mapping(0,0).

+step(S): S mod 5==0 & S <= 700
   <- .findall(p(X,Y,Z,Map),gps_map(X,Y,Z,MapId)&inMap(MapId)&Z\=="obstacle",L);
      .length(L,M);
      +mapping(S,M).
      
+step(701) 
   <- .findall(mapping(S,M),mapping(S,M),L);
      .sort(L,LSort);
      !print_list(LSort).

+!print_list([]).      
+!print_list([mapping(S,M)|T])
   <- .print(S,";",M);
      !print_list(T).      
      
+!areyou(_,_,_,_,_,_,_).      

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
