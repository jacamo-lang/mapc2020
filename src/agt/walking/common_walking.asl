/** 
 * Common beliefs, rules and plans for walking 
 */

/**
 * Initial beliefs
 */
direction_increment(n,0,-1).
direction_increment(s,0,1).
direction_increment(w,-1,0).
direction_increment(e,1,0).

/**
 * Return on D euclidean distance between (X1,Y1) and (X2,Y2)
 */
distance(X1,Y1,X2,Y2,D) :- 
    D = math.abs(X2-X1) + math.abs(Y2-Y1)
.

/** 
 * Return the coordinates X,Y of the nearest specific thing 
 * on the map.
 * 
 * For instance: ?nearest(taskboard,X,Y) has unified in X,Y
 * the nearest taskboard this agent know (based on its gps_map(_,_,_,_)
 * and myposition(_,_) beliefs
 */
nearest(T,X,Y) :-
    myposition(X1,Y1) &
    origin_str(MyMAP) &
    .findall(p(D,X2,Y2), gps_map(X2,Y2,T,MyMAP) & distance(X1,Y1,X2,Y2,D), FL) &
    .min(FL,p(_,X,Y))
.

/** 
 * Returns the coordinates X,Y that leaves thing T at direction DIR, i.e.,
 * returns the adjacent of the specific thing in which the thing is at DIR
 * of this adjacent
 * 
 * Example: let a thing T at X=0 and Y=0 be surrounded by its 4 adjacent 
 * (n,w,s,e) as below.  
 * ....n....
 * ...wTe...
 * ....s....
 * nearest_adjacent(T,X,Y,w) unifies X=1,Y=0 which matches with the position 'e'
 * i.e., the position that leaves T at west direction.
 * 
 * For instance: ?nearest_dir(taskboard,X,Y,DIR) has unified in X,Y
 * the nearest taskboard this agent know (based on its gps_map(_,_,_,_)
 * and myposition(_,_) beliefs plus the given direction DIR
 */
nearest_adjacent(T,X,Y,DIR) :-
    myposition(X1,Y1) &
    origin_str(MyMAP) &
    .findall(p(D,X2,Y2), gps_map(X2,Y2,T,MyMAP) & distance(X1,Y1,X2,Y2,D), FL) &
    .min(FL,p(_,X3,Y3)) & direction_increment(DIR,I,J) &
    X = X3 + I & Y = Y3 + J
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
    origin_str(MyMAP) &
    .findall(p(D,X2,Y2),
        direction_increment(_,I,J) & X2 = XP+I & Y2 = YP + J &
        not gps_map(X2,Y2,obstacle,MyMAP) &
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
    origin_str(MyMAP) &
    (myposition(X1,Y1) & gps_map(_,_,taskboard,MyMAP) & nearest(taskboard,X2,Y2) & distance(X1,Y1,X2,Y2,D12)) &
    (gps_map(_,_,B,MyMAP) & nearest(B,X3,Y3) & distance(X2,Y2,X3,Y3,D23)) &
    (gps_map(_,_,goal,MyMAP) & nearest(goal,X4,Y4) & distance(X3,Y3,X4,Y4,D34)) &
    D = D12 + D23 + D34
.

/**
 * Unifies when the position is clear for walk, used for close/visible areas
 */
is_walkable(I,J) :- 
    not thing(I,J,obstacle,_) &
    not thing(I,J,entity,_) &
    not ( thing(I,J,block,_) & not attached(I,J) )
.

/**
 * Unifies when the X,Y and its surrounding positions are clear for walk,
 * used for far areas (mapped by gps_map, not necessarily visible).
 */
is_walkable_area(X,Y,R) :-
    not gps_map(X,Y,obstacle,MyMAP) &
    .findall(p(XX,YY), 
        .range(It,1,R) &
        .member(DIR,[n,s,w,e]) &
        direction_increment(DIR,I,J) &
        origin_str(MyMAP) &
        XX = (I * It) + X &
        YY = (J * It) + Y &
        gps_map(XX,YY,obstacle,MyMAP), L) &
    //.log(warning,L) &
    .length(L) == 0
.

/**
 * If I know the position of at least B, find the nearest and go there!
 */
+!goto_nearest(B) :
    origin_str(MyMAP) &
    myposition(X,Y) &
    gps_map(_,_,B,MyMAP) &
    nearest(B,XN,YN)
    <-
    .log(warning,"Going to ",nearest(B,XN,YN)," from ",myposition(X,Y));
    !goto(XN,YN,RET);
    if (RET \== success & myposition(X1,Y1)) {
        if(RET == no_route){
            //!do(skip,R); //ToDo: check whether skipping is the better action here (couldn't it move to a neighbour point to find a route?)
            .fail; // .fail is better because it is used in submit, so the agent may drop the intention
        }
        .log(warning,"No success on: ",goto(XN,YN,RET)," ",myposition(X1,Y1));
    }
.

/**
 * If I know the position of at least B, find the nearest neighbour
 * point and go there!
 */
+!goto_nearest_neighbour(B) :
    origin_str(MyMAP) &
    myposition(X,Y) &
    gps_map(_,_,B,MyMAP) &
    nearest(B,XN,YN) &
    distance(X,Y,XN,YN,DIST) & DIST > 1 &
    nearest_neighbour(XN,YN,XT,YT)
    <-
    .log(warning,"Going to neighbour of ",nearest(B,XN,YN)," : ",distance(X,Y,XT,YT,DIST));
    !goto_XY(XT,YT);
.
+!goto_nearest_neighbour(B) :
    thing(I,J,B,_) &
    distance(0,0,I,J,1)
    <-
    !do(skip,R);
    .log(warning,"I am already at a neighbour of ",B," : ",thing(I,J,B,_),", skip: ",R);
.
//TODO: Sometimes the agent is not mapping correctly, it is thinking it is in another X,Y
+!goto_nearest_neighbour(B) :
    myposition(X,Y) &
    gps_map(_,_,B,MyMAP) &
    nearest(B,XN,YN) &
    nearest_neighbour(XN,YN,X,Y) &  // I think I am at the nearest neighbour
    not thing(XN-X,YN-Y,B,_) // But, in fact, there is not a thing in the position it is supposed to be
    <-
    .log(warning,"I am lost looking for ",B," : ",myposition(X,Y)," : ",distance(X,Y,XN,YN,DIST));
    +status(lost);
    !do(skip,R);
.

/**
 * If I know the position of at least B, find the nearest adjacent
 * point and go there! Only execute if myposition is not the target
 * position.
 */
+!goto_nearest_adjacent(B,DIR) :
    origin_str(MyMAP) &
    myposition(X,Y) &
    gps_map(_,_,B,MyMAP) &
    nearest_adjacent(B,XA,YA,DIR) &
    distance(X,Y,XA,YA,DIST) & DIST > 0
    <-
    .log(warning,"Going to adjacent of ",nearest_adjacent(B,XA,YA,DIR)," : ",distance(X,Y,XA,YA,DIST));
    !goto_XY(XA,YA);
.
/**
 * This plan should be executed when myposition is the target position
 * i.e., I should be seeing the target object, if not, I am lost! 
 */
+!goto_nearest_adjacent(B,DIR) :
    thing(I,J,B,_) &
    direction_increment(DIR,I,J)
    <-
    !do(skip,R);
    .log(warning,"I am already at an adjacent of ",B," : ",thing(I,J,B,_),", skip: ",R);
.
/**
 * If DIST from myposition and the target is 0 and I am not seeing the target, at the 
 * supposed position I am lost!
 */
+!goto_nearest_adjacent(B,DIR)
    <-
    .log(warning,"I was doing ",goto_nearest_adjacent(B,DIR)," when I realised I am lost.");
    +status(lost);
    !do(skip,R);
.

/**
 * goto XY, skip if no_route
 */
+!goto_XY(X,Y) : myposition(X,Y)
    <-
    !do(skip,R);
    .log(warning,"I am already at ",X,",",Y,", skip: ",R);
.
+!goto_XY(X,Y)
    <-
    !goto(X,Y,RET);
    if (RET \== success & myposition(XP,YP)) {
        if(RET == no_route){
            !do(skip,R); //ToDo: check whether skipping is the better action here (couldn't it move to a neighbour point to find a route?)
            // A .fail would be the best option but it could cause a plan failure in the beginning/middle of perform task resulting in not successful performance 
        }
        .log(warning,"No success on: ",goto(X,Y,RET)," ",myposition(XP,YP));
    }
.
