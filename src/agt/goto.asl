nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).

directions([n,s,w,e]).
directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).
myposition(0,0).

+!goto(X,Y):
    myposition(X,Y)
    <- .print("-------> " ,arrived_at(X,Y)).

// Use route planer if distance (steps) is greater than D
+!goto(X,Y):
    (routeplan_mindist(D)) &
    (not myposition(X,Y)) &
    (myposition(I,J) & (math.abs(X-I)+math.abs(Y-J) >= D))
    <-
      ?myposition(OX,OY);
      getDirection(OX,OY,X,Y,DIRECTION);
      if (DIRECTION == error) {
        ?directions(LDIRECTIONS);
        .nth(math.floor(math.random(4)),LDIRECTIONS,DR);
        !do(move(DR),R);
        if (R=success) {
            !mapping(DR);
        } else {
            .print("Fail on random to x: ",X," y: ",Y," act: ",DR);
        }
      } else {
        !do(move(DIRECTION),R);
        if (R=success) {
            !mapping(DIRECTION);
        } else {
            .print("Fail on going to x: ",X," y: ",Y," act: ",DIRECTION);
        }
      }
      !goto(X,Y);
    .

+!goto(X,Y):
    not myposition(X,Y)
    <-
      ?myposition(OX,OY);
      DISTANCEX=math.abs(X-OX);
      DISTANCEY=math.abs(Y-OY);

      if (DISTANCEX>DISTANCEY) {
        DESIRABLEX = (X-OX)/DISTANCEX;
        DESIRABLEY = 0;
      }
      else {
        DESIRABLEX = 0;
        DESIRABLEY = (Y-OY)/DISTANCEY;
      }
      if (not obstacle(DESIRABLEX,DESIRABLEY)) {
        ?directionIncrement(DIRECTION,DESIRABLEX,DESIRABLEY);
        !do(move(DIRECTION),R);
        if (R=success) {
            !mapping(DIRECTION);
        } else {
            .print("Simply fail: ",X," y: ",Y," act: ",DIRECTION);
        }
      }
      else {
        ?directionIncrement(BLOCKEDDIRECTION,DESIRABLEX,DESIRABLEY);
        ?nextDirection(BLOCKEDDIRECTION,DIRECTION);
        !workaround(DIRECTION);
      }
      !goto(X,Y);
    .

+!workaround(DIRECTION):
    true
    <-
      if (directionIncrement(DIRECTION, X, Y) &
          obstacle(X,Y)) {
          ?nextDirection(DIRECTION,NEXTDIRECTION);
          !workaround(NEXTDIRECTION);
      }
      else {
          !do(move(DIRECTION),R);
          if (R=success) {
            !mapping(DIRECTION);
          }
          else
          //if (R=failed_path)
          {
            .print("Workaround fail: ",X," y: ",Y," act: ",DIRECTION);
            ?nextDirection(DIRECTION,NEXTDIRECTION);
            !workaround(NEXTDIRECTION);
          }
      }
    .

+!mapping(DIRECTION) :
    directionIncrement(DIRECTION, INCX,  INCY) &
    step(STEP) &
    myposition(X,Y)
    <-
        NX= X+INCX;
        NY= Y+INCY;
        -+myposition(NX,NY);
        ?vision(S);

        // First, erase previous mapping of this view
        !erase_map_view(NX,NY);

        mark(NX, NY, self, step, S);

        for (goal(I,J)) {
            !addMap(I,J,NX,NY,goal);
        }
        for (obstacle(I,J)) {
            !addMap(I,J,NX,NY,obstacle);
        }
        for (thing(I,J,dispenser,TYPE)) {
            !addMap(I,J,NX,NY,TYPE);
        }
        for (thing(I,J,taskboard,TYPE)) {
            !addMap(I,J,NX,NY,taskboard);
        }
        for (thing(I,J,entity,TYPE)) {
            // Entities of types "a" and "b" are of the corresponding teams
            if ((I \== 0) & (J \== 0)) { // Do not map himself again!
                !addMap(I,J,NX,NY,TYPE);
            }
        }
.

+!addMap(I,J,X,Y,TYPE) :
    true
    <-
    .my_name(AG);
    mark(X+I, Y+J, TYPE, AG, 0);
    +map(0,X+I,Y+J,TYPE);
.

/**
 * Erase current view, an action done before
 * a new mapping of the view area.
 * When vision(S) & S == 5, the agent's view is:
 *      0
 *     101
 *    21012
 *   3210123
 *  432101234
 * 54321012345
 *  432101234
 *   3210123
 *    21012
 *     101
 *      0
 */
+!erase_map_view(X,Y) :
    vision(S)
    <-
    for ( .range(J,-S, S) ) {
        for ( .range(I,-S, S) ) {
            if (math.abs(I) <= math.abs(math.abs(J)-S)) {
                unmark(X+I, Y+J);
            } 
        }
    }
.
