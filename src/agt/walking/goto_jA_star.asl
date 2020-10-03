/**
 * Common beliefs, rules and plans for goto with algorihtm A*
 * This lib depends on exploration/common_exploration, the agent
 * must include both to work properly
 */

{ include("exploration/common_exploration.asl") }
{ include("walking/common_walking.asl") }
{ include("walking/jA_star_search.asl") }


/**
 * jA_star search setup
 * state transitions and heuristic
 */
suc(s(X,Y),s(X+1,Y),1,e) :- not gps_map(X+1,Y,obstacle,_).
suc(s(X,Y),s(X-1,Y),1,w) :- not gps_map(X-1,Y,obstacle,_).
suc(s(X,Y),s(X,Y-1),1,n) :- not gps_map(X,Y-1,obstacle,_).
suc(s(X,Y),s(X,Y+1),1,s) :- not gps_map(X,Y+1,obstacle,_).
h(s(X1,Y1),s(X2,Y2),math.abs(X2-X1) + math.abs(Y2-Y1)).

/**
 * Get the next direction \in [n,s,e,w] from origin OX,OY to a target X,Y
 * ?get_direction(0,0,1,2,DIR);
 */
get_direction(OX,OY,X,Y,DIR) :- 
    a_star( s(OX,OY), s(X,Y), [_,op(DIR,_)|_], Cost)
.

//TODO: Provide a way to return no_route when no solution is found after certain number of attempts
a_star( _, _, no_route, _).

+!goto(X,Y,RET):
    myposition(X,Y)
    <-
    .log(warning,"-------> " ,arrived_at(X,Y));
    RET = success;
.

+!goto(X,Y,RET):
    myposition(OX,OY) &
    step(S) &
    get_direction(OX,OY,X,Y,DIRECTION)
    <-
    if ( .member(DIRECTION,[n,s,w,e]) ) {
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
