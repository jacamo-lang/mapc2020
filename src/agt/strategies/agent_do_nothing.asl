{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("environment/artifact_eis.asl") }
{ include("simulation/massim.asl") }

exploration_strategy(none).

@step[atomic]   
+step( S ): true
    <-
        action(skip);
    .   


+!areyou(_,_,_,_,_,_,_,_) <- true.

+!start.
