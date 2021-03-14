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
  not .intend(makeSquare(_,_))
  <-
    // !goto(X,Y,R);
    // !goto(X,Y-1,_);
    // !goto(X-1,Y-1,_);
    // !goto(X-1,Y+1,_);
    // !goto(X+1,Y+1,_);
    // !goto(X+1,Y-1,_);
    // !goto(X,Y-1,_);
    // !goto(X,Y,_);
    !do(skip,_);
    !!makeSquare(X,Y);
    .
