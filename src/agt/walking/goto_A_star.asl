/**
 * Common beliefs, rules and plans for goto with algorihtm A*
 * This lib depends on exploration/common_exploration, the agent
 * must include both to work properly
 */

{ include("exploration/common_exploration.asl") }

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
    <-
    .print("-------> " ,arrived_at(X,Y));
.

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
            !mapping(success,_,DR);
        } else {
            .print("Fail on random to x: ",X," y: ",Y," act: ",DR);
        }
    } else {
        !do(move(DIRECTION),R);
        if (R=success) {
            !mapping(success,_,DIRECTION);
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
    } else {
        DESIRABLEX = 0;
        DESIRABLEY = (Y-OY)/DISTANCEY;
    }
    if (not obstacle(DESIRABLEX,DESIRABLEY)) {
        ?directionIncrement(DIRECTION,DESIRABLEX,DESIRABLEY);
        !do(move(DIRECTION),R);
        if (R=success) {
            !mapping(success,_,DIRECTION);
        } else {
            .print("Simply fail: ",X," y: ",Y," act: ",DIRECTION);
        }
    } else {
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
    } else {
        !do(move(DIRECTION),R);
        if (R=success) {
            !mapping(success,_,DIRECTION);
        } else { //if (R=failed_path)
            .print("Workaround fail: ",X," y: ",Y," act: ",DIRECTION);
            ?nextDirection(DIRECTION,NEXTDIRECTION);
            !workaround(NEXTDIRECTION);
        }
    }
.
