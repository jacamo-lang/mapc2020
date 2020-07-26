/**
 * goal_center adds a belief like gps_map(X,Y,goal_center,MapId)
 * to inform where is the center of the respective goal area
 *
 * IMPORTANT! Currently, it is working just for goal areas with
 * 5 squares in length 
 */
 
 
/**
 * Used to determine the goal center area (for 5 squares in length)
 */
goal_share(0, -4).
goal_share(0,  4).
goal_share(-4,  0).
goal_share(4,  0).

/**
 * Map goal center position based on new gps_map(X,Y,goal,_)
 * beliefs. When the agent figures out that he knows another
 * edge of the goal area, it can determine the center of the
 * area
 */
+gps_map(X,Y,goal,_) :
    goal_share(I,J) &
    gps_map(X+I,Y+J,goal,_) &
    .my_name(ME)
    <-
    -+gps_map(X+(I/2),Y+(J/2),goal_center,ME);
.
