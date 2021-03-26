!start. 

+!start <- 
   focusWhenAvailable(artGPSA); //TODO: make it not hardcoded
   focusWhenAvailable(artA1). //TODO: make it not hardcoded         
    
+!areyou(_,_,_,_,_,_,_,_).


/**
 * Notify the finding of the sizes of both the axis X and Y
 * 
 */
+size_x(X) : size_y(Y) & step(S)
   <- .print("Map size (",X,",",Y,") discovered in step ", S).
   
+size_y(Y) : size_x(X) & step(S)
   <- .print("Map size (",X,",",Y,") discovered in step ", S).  

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
