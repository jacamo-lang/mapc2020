{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("goto.asl") }
{ include("action.asl") }

!start.

+!start: 
  true
  <-
    !goto(0,20);
    !goto(2,2);
    !goto(-22,-45);
    !goto(22,45);
 .


+!areyou(_,_,_,_,_,_,_) <- true.
