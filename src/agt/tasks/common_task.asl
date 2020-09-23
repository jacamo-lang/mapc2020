/**
 * This library intends to provide generic functionalities for
 * tasks achievement
 */


known_requirements(T) :- task(T,DL,Y,REQs) &
                    gps_map(_,_,taskboard,_) & // I know a taskboard position
                    gps_map(_,_,goal,_) &      // I know a goal area position
                    .member(req(_,_,B),REQs) & // For each requirement
                    gps_map(_,_,B,_).          // I know where to find B
