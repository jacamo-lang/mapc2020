/*
 *  Random exploration strategy: the agent chooses a random direction. 
*/

{ include("common_exploration.asl") }


 +!update_direction_random : directions(LDIRECTIONS)
    <- .nth(math.floor(math.random(4)),LDIRECTIONS,D);
       -+current_direction(D).

