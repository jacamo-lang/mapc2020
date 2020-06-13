{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("goto.asl") }
{ include("action.asl") }

use_routePlanner.
targetPoint(_,_).

!start.

+!start: 
  true
  <-
    // First going to fixed points, the agent is starting at the absolute_position(45,3)
    !goto(-33,9); // Go to the depot in the absolute_position(12,12)
    !goto(10,-6); // Go to the depot in the absolute_position(55,67)
    !goto(-39,6); // Go to the depot in the absolute_position(6,9)
    
    // Later go randomly elsewhere
    !!goRandomly;
 .

+!goRandomly:
  true
  <-
    // Go to some random position
    -+targetPoint(math.floor(math.random(40))-20,math.floor(math.random(40))-20);
    ?targetPoint(TX,TY);
    .print("Target: ",TX," ",TY);
    !goto(TX,TY);
    !goRandomly;
    .
    
+!areyou(_,_,_,_,_,_,_) <- true.
