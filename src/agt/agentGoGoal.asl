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
    !try_skip(50);
 .

+!try_skip(0):
  true
  <-
    !goto(0,12);
    !goto(6,12);
    !goto(0,12);
    !goto(2,15);
    !goto(0,15);
    !goto(0,12);
    !goto(-5,15);
    !goto(-5,12);
    !goto(0,12);
    !goto(-3,12);
    !goto(-1,8);
    !goto(0,8);
    !!try_skip(0);
    .

+!try_skip(QT):
  QT>0
  <-
    !do(skip,R);
    !!try_skip(QT-1);
    .

+!areyou(_,_,_,_,_,_,_) <- false.
