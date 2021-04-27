randomSeed(17).

!start. 

+!start <- 
   focusWhenAvailable(artGPSA); //TODO: make it not hardcoded
   focusWhenAvailable(artA1). //TODO: make it not hardcoded         
    
+!areyou(_,_,_,_,_,_,_,_).


/**
 * Notify the finding of the sizes of both the axis X and Y
 * 
 */
+size_x(X) : size_y(Y) & step(S) & teamSize(T)
   <- .print("Map size (",X,",",Y,") discovered in step ", S);
       ?randomSeed(Rs);
      .concat("Dados:	",T,"	",X,"	",Y,"	",S,"	",Rs,Message); //compor a mensagem da estatística
      .save_stats("map_size",Message).
   
+size_y(Y) : size_x(X) & step(S) & teamSize(T)
   <- .print("Map size (",X,",",Y,") discovered in step ", S);
       ?randomSeed(Rs);
      .concat("Dados:	",T,"	",X,"	",Y,"	",S,"	",Rs,Message); //compor a mensagem da estatística
      .save_stats("map_size",Message). 
     

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
