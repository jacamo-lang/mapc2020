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
    !goto(0,-10);
    // !goto(-25,0);
    !!goSquare;
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

+!goSquare:
  true
  <-
    !do(move(n),R);
    !do(move(o),R);
    !do(move(s),R);
    !do(move(l),R);
    !!goSquare;
    .

+!areyou(_,_,_,_,_,_,_) <- true.
