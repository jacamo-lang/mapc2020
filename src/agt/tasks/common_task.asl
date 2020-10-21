/**
 * This library intends to provide generic functionalities for
 * tasks achievement
 */

/**
 * The agent knows the position of at least one taskboard, one
 * goal area and a dispenser for every requirement
 */
known_requirements(T) :- task(T,DL,Y,REQs) &
                    origin_str(MyMAP) &
                    gps_map(_,_,taskboard,MyMAP) &  // I know a taskboard position
                    gps_map(_,_,goal,MyMAP) &       // I know a goal area position
                    .member(req(_,_,B),REQs) &      // For each requirement
                    gps_map(_,_,B,MyMAP).           // I know where to find B

/**
 * The agent knows the position of at least one taskboard, one
 * goal area and a dispenser for the nth requirement
 */
known_requirement(T,B) :- task(T,DL,Y,REQs) &
                    origin_str(MyMAP) &
                    gps_map(_,_,taskboard,MyMAP) &  // I know a taskboard position
                    gps_map(_,_,goal,MyMAP) &       // I know a goal area position
                    gps_map(_,_,B,MyMAP).           // I know where to find B
                    
