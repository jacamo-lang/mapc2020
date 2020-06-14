{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("goto.asl") }
{ include("action.asl") }

use_routePlanner.
targetPoint(_,_).

center_goal_small(X,Y) :-
    (goal(X-1,Y)) & (goal(X+1,Y)) & (goal(X,Y+1)) & (goal(X,Y-1)) &
    (not goal(X-1,Y-1)) & (not goal(X-1,Y+1)) &
    (not goal(X+1,Y-1)) & (not goal(X+1,Y+1))
    .
center_goal_big(X,Y) :-
    (goal(X-1,Y)) & (goal(X+1,Y)) & (goal(X,Y+1)) & (goal(X,Y-1)) &
    (goal(X-1,Y-1)) & (goal(X-1,Y+1)) &
    (goal(X+1,Y-1)) & (goal(X+1,Y+1))
    .

position_defenser(X,Y,XM,YM) :- position_n(X,Y,XM,YM)  | position_nw(X,Y,XM,YM) |
                                position_sw(X,Y,XM,YM) | position_w(X,Y,XM,YM)  |
                                position_s(X,Y,XM,YM)  | position_ne(X,Y,XM,YM) |
                                position_se(X,Y,XM,YM) | position_e(X,Y,XM,YM).
position_n(X,Y,0,-1)   :- (X>=-1 & X<=1 & Y<=-1) | Y<=-2.
position_w(X,Y,-1,0)   :- (X<=-1 & Y>=-1 & Y<=1) | X<=-2.
position_nw(X,Y,-1,-1) :- (X>=-3 & X<=-1 & Y>=-2 & Y<=-1).
position_sw(X,Y,-1,1)  :- (X<=3 & X>=1 & Y>=-2 & Y<=-1).
position_s(X,Y,0,1)    :- (X>=-1 & X<=1 & Y>=1)  | Y>=2.
position_e(X,Y,1,0)    :- (X>=1 & Y>=-1 & Y<=1)  | X>=2.
position_ne(X,Y,1,-1)  :- (X>=-3 & X<=-1 & Y<=2 & Y>=1).
position_se(X,Y,1,1)   :- (X<=3 & X>=1 & Y<=2 & Y>=1).

center_goal(X,Y) :- center_goal_small(X,Y) | center_goal_big(X,Y).

!start.

+!start:
  true
  <-
    // First going to fixed points, doing almost a square
    !goto(0,-9);
    !goto(-5,-9);
    ?myposition(X,Y);
    !goDispenser(X,Y);
 .

+!goDispenser(OX,OY):
  thing(XD,YD,dispenser,_)
  <-
    !goto(OX+XD,OY+YD);
    ?myposition(X,Y);
    !goto(X,Y-1);
    !pickBlocks;
  .

+!goDispenser(OX,OY):
  not thing(XD,YD,dispenser,_)
  <-
    !goto(OX-1,OY);
    !goDispenser(OX-1,OY);
  .

+!pickBlocks:
  true
  <-
    !!fillBlocks(s,4);
    .

+!fillBlocks(_,0):
  true
  <-
    !do(rotate(cw),_);
    ?myposition(X,Y);
    !goGoal(X,Y);
  .

+!fillBlocks(DIR, QT):
  QT>0
  <-
    !do(request(DIR),R);
    !do(attach(DIR),R);
    !do(rotate(cw),_);
    !!fillBlocks(DIR, QT-1);
    .

+!goGoal(X,Y):
  goal(0,0)
  <-
    // Find Center
    for (goal(I,J)) {
      if (center_goal(I,J)) {
        !goto(X+I,Y+J);
        !!defenderSimple(X+I,Y+J);
        //!!makeSquare(X+I,Y+J);
      }
    }
    .

+!goGoal(OX,OY):
  not goal(0,0)
  <-
    !goto(OX-1,OY);
    !!goGoal(OX-1,OY);
    .

+!defenderSimple(X,Y):
  thing(I,J,entity,TEAM) &
  not team(TEAM) &
  position_defenser(I,J,XM,YM) &
  myposition(X+XM,Y+YM)
  <-
    !do(skip,_);
    !!defenderSimple(X,Y);
    .

+!defenderSimple(X,Y):
  thing(I,J,entity,TEAM) &
  not team(TEAM)
  <-
    ?position_defenser(I,J,XM,YM);
    !goto(X+XM,Y+YM);
    !!defenderSimple(X,Y);
    .

+!defenderSimple(X,Y):
  myposition(X,Y)
  <-
    !do(skip,_);
    !!defenderSimple(X,Y);
    .

+!defenderSimple(X,Y):
  not myposition(X,Y)
  <-
    !goto(X,Y);
    !!defenderSimple(X,Y);
    .

+!makeSquare(X,Y):
  true
  <-
    !goto(X,Y-1);
    !goto(X-1,Y-1);
    !goto(X-1,Y+1);
    !goto(X+1,Y+1);
    !goto(X+1,Y-1);
    !goto(X,Y-1);
    !goto(X,Y);
    !!makeSquare(X,Y);
    .

+!areyou(_,_,_,_,_,_,_) <- true.
