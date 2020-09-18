/** 
 * Common beliefs, rules and plans for walking 
 */

/**
 * Initial beliefs
 */
directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).
directions([n,s,w,e]).

/**
 * Return on D euclidean distance between (X1,Y1) and (X2,Y2)
 */
distance(X1,Y1,X2,Y2,D) :- 
    D = math.abs(X2-X1) + math.abs(Y2-Y1)
.

/** 
 * Return the coordinates X,Y of the nearest specific thing 
 * in the map.
 * 
 * For instance: ?nearest(taskboard,X,Y) has unified in X,Y
 * the neareast taskboard this agent know (based on its gps_map(_,_,_,_)
 * and myposition(_,_) beliefs
 */
nearest(T,X,Y) :-
    myposition(X1,Y1) &
    .findall(p(D,X2,Y2),gps_map(X2,Y2,T,_) & distance(X1,Y1,X2,Y2,D),FL) &
    .min(FL,p(_,X,Y))
.

/**
 * Return the nearest adjacent position of a thing which is
 * useful for an approach. To use it, give the point XP,YP in which
 * it is needed the nearest neighbour X,Y
 *
 * It is based on agent's gps_map(_,_,_,_) and myposition(_,_) beliefs
 * TODO: The used heuristic is a straight line which may give bad solutions in
 * many situations. For instance, if the target nearest neighbour is an obstacle
 * and there are 2 adjacents in which euclidean distance is equal, it is not
 * guaranteed that the best solution will be chosen. Ideally, the euclidean
 * distance should be replaced by A* solution.
 */
nearest_neighbour(XP,YP,X,Y) :-
    myposition(X1,Y1) &
    .findall(p(D,X2,Y2),
      directionIncrement(_,I,J) & X2 = XP+I & Y2 = YP + J &
      not gps_map(X2,Y2,obstacle,_) &
      distance(X1,Y1,X2,Y2,D), FL
    ) & .min(FL,p(_,X,Y))
.

/**
 * Return the shortest path to solve a task of a single block.
 * It calculates the shortest path between the current position of the agent,
 * the nearest taskboard to accept a task, the nearest dispenser to grab a block
 * and the nearest goal area.
 *
 * It is useful to check if a task is feasible according to the given deadline.
 *
 * Example: ?task_shortest_path("b1",D) unify on D the shortest path to accept and
 * perform a task to submit a block b1
 */
task_shortest_path(B,D) :-
    (myposition(X1,Y1) & gps_map(_,_,taskboard,_) & nearest(taskboard,X2,Y2) & distance(X1,Y1,X2,Y2,D12)) &
    (gps_map(_,_,B,_) & nearest(B,X3,Y3) & distance(X2,Y2,X3,Y3,D23)) &
    (gps_map(_,_,goal,_) & nearest(goal,X4,Y4) & distance(X3,Y3,X4,Y4,D34)) &
    D = D12 + D23 + D34
.

/**
 * If I know the position of at least B, find the nearest and go there!
 */
+!gotoNearest(B) :
    myposition(X,Y) &
    gps_map(_,_,B,_) &
    nearest(B,XN,YN)
    <-
    .log(warning,"Going to ",nearest(B,XN,YN)," from ",myposition(X,Y));
    !goto(XN,YN,false,RET);
    .log(warning,goto(XN,YN,RET));
.

/**
 * If I know the position of at least B, find the nearest neighbour
 * point and go there!
 */
+!gotoNearestNeighbour(B) :
    myposition(X,Y) &
    gps_map(_,_,B,_) &
    nearest(B,XN,YN) &
    nearest_neighbour(XN,YN,XT,YT) &
    distance(X,Y,XT,YT,DIST) & DIST > 1
    <-
    .log(warning,"Going to neighbour of ",nearest(B,XN,YN)," : ",distance(X,Y,XT,YT,DIST));
    !goto(XT,YT,false,RET);
.

+!gotoNearestNeighbour(B) :
    myposition(X,Y) &
    gps_map(_,_,B,_) &
    nearest(B,XN,YN) &
    nearest_neighbour(XN,YN,XT,YT) &
    distance(X,Y,XN,YN,DIST) & DIST == 1
    <-
    .log(warning,"I am already in a neighbour of ",B," : ",distance(X,Y,XN,YN,DIST));
.
