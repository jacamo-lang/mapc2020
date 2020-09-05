/**
 * Common beliefs, rules and plans for goto with algorihtm A*
 * This lib depends on exploration/common_exploration, the agent
 * must include both to work properly
 */

{ include("exploration/common_exploration.asl") }
{ include("walking/common_walking.asl") }

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
    myposition(OX,OY) &
    (OX \== X | OY \== Y)
    <-
    getDirection(OX,OY,X,Y,DIRECTION);
    if (DIRECTION == error) {
        .print("Fail on random to x: ",X," y: ",Y," act: ",DR);
    } else {
        !do(move(DIRECTION),R);
        if (R == success) {
            !mapping(success,_,DIRECTION);
        } else {
            .print("Fail on going to x: ",X," y: ",Y," act: ",DIRECTION);
        }
        !goto(X,Y);
    }
.
