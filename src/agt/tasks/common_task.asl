/**
 * This library intends to provide generic functionalities for
 * tasks achievement
 */


known_requirements(T) :- task(T,DL,Y,REQs) &
                    origin(MyMAP) &
                    gps_map(_,_,taskboard,MyMAP) &  // I know a taskboard position
                    gps_map(_,_,goal,MyMAP) &       // I know a goal area position
                    .member(req(_,_,B),REQs) &      // For each requirement
                    gps_map(_,_,B,MyMAP).           // I know where to find B
