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
    !goto(0,-9);
    ?myposition(OX,OY);
    !goObstacle(OX,OY);
    ?myposition(X,Y);
    !!makeSquare(X,Y);
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

+!goObstacle(OX,OY): goal(OX,OY).

+!goObstacle(OX,OY):
  not goal(OX,OY)
  <-
    !goto(OX-1,OY);
    ?myposition(X,Y);
    !goObstacle(X,Y)
    .

+!makeSquare(X,Y):
  true
  <-
    !goto(X+3,Y);
    !goto(X+3,Y+3);
    !goto(X,Y+3);
    !goto(X,Y);
    !!makeSquare(X,Y);
    .

+!areyou(_,_,_,_,_,_,_) <- true.
