{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("massim.asl") }


@step[atomic]   
+step( S ): true
    <-
        action(skip);
    .   


+!areyou(_,_,_,_,_,_,_,_) <- true.

+!start.
