/**
 * Common beliefs, rules and plans for goto with algorihtm A*
 * This lib depends on exploration/common_exploration, the agent
 * must include both to work properly
 */

{ include("exploration/common_exploration.asl") }
{ include("walking/common_walking.asl") }

/**
 * Map as gps_map(X,Y,block(B),MyMAP) blocks that are not the ones that
 * this agent has attached, i.e., only maps blocks that are obstacles
 */
gps_map(XB,YB,block(B),MyMAP) :-
    origin(MyMAP) &
    thing(I,J,block,B) &
    not attached(I,J) &
    myposition(X,Y) &
    XB = X+I & YB = Y+J
.
/**
 * Map as gps_map(X,Y,entity(E),MyMAP) other agents
 */
gps_map(XB,YB,entity(E),MyMAP) :-
    origin(MyMAP) &
    thing(I,J,entity,E) &
    (I \== 0 | J \== 0) &
    myposition(X,Y) &
    XB = X+I & YB = Y+J
.

+!goto(X,Y,RET):
    myposition(X,Y)
    <-
    //.log(warning,"-------> " ,arrived_at(X,Y));
    RET = success;
.

+!goto(X,Y,RET):
    myposition(OX,OY) &
    step(S) &
    origin(MyMAP)
    <-
    .findall(gps_map(XG,YG,OG,MyMAP),gps_map(XG,YG,OG,MyMAP),LG);
    .findall(attached(I,J),attached(I,J),LA);
    .get_direction(OX,OY,X,Y,LG,LA,DIRECTION);

    if (DIRECTION == error) {
        RET = no_route;
    } else {
        !do(move(DIRECTION),R);
        if (R == success) {
            !mapping(success,_,DIRECTION);
            .wait(step(Step) & Step > S); //wait for the next step to continue
            !goto(X,Y,RET);
        } else {
            .log(warning,"Fail on going to x: ",X," y: ",Y," act: ",DIRECTION);
            RET = error;
        }
    }
.
