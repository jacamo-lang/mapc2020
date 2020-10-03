/**
 * Common beliefs, rules and plans for goto with algorihtm A*
 * This lib depends on exploration/common_exploration, the agent
 * must include both to work properly
 */

{ include("exploration/common_exploration.asl") }
{ include("walking/common_walking.asl") }

+!goto(X,Y,RET):
    myposition(X,Y)
    <-
    .log(warning,"-------> " ,arrived_at(X,Y));
    RET = success;
.

+!goto(X,Y,RET):
    myposition(OX,OY) &
    step(S)
    <-
    getDirection(OX,OY,X,Y,DIRECTION);

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
