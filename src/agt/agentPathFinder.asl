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
    // First going to fixed points, doing almost a square
    !goto(0,-20);
    !goto(-20,-20);
    !goto(-20,10);
    !goto(-2,0);
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
