//If for some reason he lost some block
+!defenderSimple(X,Y,TYPE):
  .count(attached(_,_)) < 4
  <-
    //-defenderSimple;
    !do(skip,_);
    !perform_defender(_);
  .

+!defenderSimple(X,Y,small):
  thing(I,J,entity,TEAM) &
  team(TEAM) &
  (distance(0,0,I,J,L) & L <= 4) &
  myposition(X-2,Y-2)
  <-
    !do(skip,_);
    !defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,small):
  thing(I,J,entity,TEAM) &
  team(TEAM) &
  (distance(0,0,I,J,L) & L <= 4) &
  myposition(X,Y)
  <-
    !goto(X-2,Y-2);
    !defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,TYPE):
  thing(I,J,entity,TEAM) &
  not team(TEAM) &
  position_defenser(I,J,XM,YM) &
  myposition(X+XM,Y+YM)
  <-
    !do(skip,_);
    !defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,TYPE):
  thing(I,J,entity,TEAM) &
  not team(TEAM)
  <-
    ?position_defenser(I,J,XM,YM);
    !goto(X+XM,Y+YM);
    !defenderSimple(X,Y,TYPE);
    .


+!defenderSimple(X,Y,TYPE):
  myposition(X,Y)
  <-
    !do(skip,_);
    !defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,TYPE):
  not myposition(X,Y)
  <-
    !goto(X,Y);
    !defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,TYPE) <- !do(skip,_); !defenderSimple(X,Y,TYPE).

+!makeSquare(X,Y,TYPE):
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
    !makeSquare(X,Y,TYPE);
    .
