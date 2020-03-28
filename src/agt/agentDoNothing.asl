{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

@step[atomic]   
+step( S ): true
    <-
        action(skip);
    .   
