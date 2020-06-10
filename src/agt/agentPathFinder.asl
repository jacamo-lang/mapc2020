{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("goto.asl") }
{ include("action.asl") }

use_routePlanner.

!start.

+!start: 
  true
  <-
    // First going to fixed points, doing almost a square
    !goto(0,-20);
    !goto(-20,-20);
    !goto(-20,10);
    !goto(0,0);
    // Later maybe try going to random points in the map
    // !goto(math.floor(math.random(30)),math.floor(math.random(30)));
 .


+!areyou(_,_,_,_,_,_,_) <- true.
