//If for some reason he lost some block
+!defenderSimple(X,Y,TYPE):
  .count(attached(_,_)) \== 4
  <-
    -perform_defender;
    -defenderSimple;
    !fill_blocks(B);
    +exploring
  .

+!defenderSimple(X,Y,small):
  thing(I,J,entity,TEAM) &
  team(TEAM) &
  (distance(0,0,I,J,L) & L <= 2) &
  myposition(X-I,Y-J)
  <-
    !do(skip,_);
    !!defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,small):
  thing(I,J,entity,TEAM) &
  team(TEAM) &
  (distance(0,0,I,J,L) & L <= 2) &
  myposition(X-I,Y-J)
  <-
    !goto(X-I,Y-J);
    !!defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,TYPE):
  thing(I,J,entity,TEAM) &
  not team(TEAM) &
  position_defenser(I,J,XM,YM) &
  myposition(X+XM,Y+YM)
  <-
    !do(skip,_);
    !!defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,TYPE):
  thing(I,J,entity,TEAM) &
  not team(TEAM)
  <-
    ?position_defenser(I,J,XM,YM);
    !goto(X+XM,Y+YM);
    !!defenderSimple(X,Y,TYPE);
    .


+!defenderSimple(X,Y,TYPE):
  myposition(X,Y)
  <-
    !do(skip,_);
    !!defenderSimple(X,Y,TYPE);
    .

+!defenderSimple(X,Y,TYPE):
  not myposition(X,Y)
  <-
    !goto(X,Y);
    !!defenderSimple(X,Y,TYPE);
    .
+!defenderSimple(X,Y,TYPE) <- !do(skip,_).
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
    !!makeSquare(X,Y,TYPE);
    .
