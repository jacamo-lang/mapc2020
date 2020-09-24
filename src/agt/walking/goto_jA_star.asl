/**
 * Common beliefs, rules and plans for goto with algorihtm A*
 * This lib depends on exploration/common_exploration, the agent
 * must include both to work properly
 */

{ include("exploration/common_exploration.asl") }
{ include("walking/common_walking.asl") }
{ include("walking/jA_star_search.asl") }

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

+!goto(X,Y,RET):
    myposition(X,Y)
    <-
    .log(warning,"-------> " ,arrived_at(X,Y));
    RET = success;
.

+!goto(X,Y,RET):
    myposition(OX,OY) &
    (OX \== X | OY \== Y) &
    step(S) &
    get_direction(OX,OY,X,Y,DIRECTION)
    <-
    if (directions(DIRS) & .member(DIRECTION,DIRS)) {
        !do(move(DIRECTION),R);
        if (R == success) {
            !mapping(success,_,DIRECTION);
            .wait(step(Step) & Step > S); //wait for the next step to continue
            !goto(X,Y,_);
        } else {
            .print("Fail on going to x: ",X," y: ",Y," act: ",DIRECTION);
            RET = error;
        }
    } else {
        .log(warning,no_route);
        RET = no_route;
    }
.
