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
    origin(MyMAP) &
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
//TODO: it checks whether the adjacent is not an obstacle but it is not checking whether the target is reachable
//TODO: This implementation is now checking if the adjacent is not an obstable, however an approach from another direction can be much better than go to a farther Thing
nearest_adjacent(T,X,Y,DIR) :-
    myposition(X1,Y1) &
    origin(MyMAP) &
    .findall(
        p(D,X3,Y3),
        gps_map(X2,Y2,T,MyMAP) & distance(X1,Y1,X2,Y2,D) &
        direction_increment(DIR,I,J) & X3 = X2 + I & Y3 = Y2 + J & not gps_map(X3,Y3,obstacle,MyMAP),
        FL
    ) &
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
    origin(MyMAP) &
    .findall(p(D,X2,Y2),
        direction_increment(_,I,J) & X2 = XP+I & Y2 = YP+J &
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
    origin(MyMAP) &
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
        origin(MyMAP) &
        XX = (I * It) + X &
        YY = (J * It) + Y &
        gps_map(XX,YY,obstacle,MyMAP), L) &
    //.log(warning,L) &
    .length(L) == 0
.

/**
 * Check if both master and helper have space for a meeting considering
 * X,Y the position for the master and considering the helper will be placed
 * on the right hand side of master. It is used R as the radius (stack of blocks)
 * for both agents since they may need to rotate.
 */
is_meeting_area(X,Y,R) :-
    is_walkable_area(X,Y,R) & is_walkable_area(1+(2*R)+X,Y,R)
.

/**
 * If I know the position of at least B, find the nearest and go there!
 */
+!goto_nearest(B) :
    origin(MyMAP) &
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
    origin(MyMAP) &
    myposition(X,Y) &
    gps_map(_,_,B,MyMAP) &
    nearest(B,XN,YN) &
    direction_increment(_,I,J) & not (X+I = XN & Y+J = YN) & // I am not at a neighbour
    nearest_neighbour(XN,YN,XT,YT)
    <-
    .log(warning,"Going to neighbour of ",nearest(B,XN,YN)," : ",distance(X,Y,XT,YT,DIST));
    !goto(XT,YT,RET);
    if (RET \== success & myposition(X1,Y1)) {
        if(RET==no_route){
            !do(skip,R); //ToDo: check whether skipping is the better action here (couldn't it move to a neighbour point to find a route?)
            // A .fail would be the best option but it could cause a plan failure in the beginning/middle of perform task resulting in not successful performance
        }
        .log(warning,"No success on: ",goto(XT,YT,RET)," ",myposition(X1,Y1)," ",goto_nearest_neighbour(B));
    }
.
/**
 * I am at a neighbour of a taskboard or a dispenser of B
 */
+!goto_nearest_neighbour(B) :
    ((B = taskboard & thing(I,J,B,_)) | thing(I,J,dispenser,B)) &
    direction_increment(_,I,J)
    <-
    !do(skip,R);
    .log(warning,"I am already at a neighbour of ",B," : ",thing(I,J,B,T),", skip: ",R);
.
/**
 * I am supposed to be at a neighbour of B but it is not here.
 * My map and/or myposition(X,Y) is wrong, i.e., I am lost!
 */
+!goto_nearest_neighbour(B):
    myposition(X,Y) &
    origin(MyMAP) & gps_map(_,_,B,MyMAP) & // I am sure I know where to find B
    .findall(g(It,Jt,T,TT),gps_map(X+It,Jt+Y,T,TT) & .range(It,-5,5) & .range(Jt,-5,5),LG) & // This is what I believe
    .findall(t(I,J,B,T),thing(I,J,B,T),LT) // This is what I see
    <-
    .log(warning,"I was doing ",goto_nearest_neighbour(B)," when I realised I am lost. ",myposition(X,Y),", things: ",LT,", gps: ",LG);
    +status(lost);
    !do(skip,R);
.

/**
 * If I know the position of at least B, find the nearest adjacent
 * point and go there! Only execute if myposition is not the target
 * position.
 */
+!goto_nearest_adjacent(B,DIR) :
    origin(MyMAP) &
    myposition(X,Y) &
    gps_map(_,_,B,MyMAP) &
    nearest_adjacent(B,XA,YA,DIR) &
    direction_increment(DIR,I,J) & not (X+I = XA & Y+J = YA) // I am not at the target position
    <-
    .log(warning,"Going to ",nearest_adjacent(B,XA,YA,DIR)," : ",distance(X,Y,XA,YA,DIST));
    !goto(XA,YA,RET);
    if (RET \== success & myposition(X1,Y1)) {
        if(RET==no_route){
            !do(skip,R); //ToDo: check whether skipping is the better action here (couldn't it move to a neighbour point to find a route?)
            // A .fail would be the best option but it could cause a plan failure in the beginning/middle of perform task resulting in not successful performance
        }
        .log(warning,"No success on: ",goto(XA,YA,RET)," ",myposition(X1,Y1)," ",nearest_adjacent(B,XA,YA,DIR));
    }
.
/**
 * I am at the adjacent of a taskboard or a dispenser of B
 */
+!goto_nearest_adjacent(B,DIR) :
    ((B = taskboard & thing(I,J,B,_)) | thing(I,J,dispenser,B)) &
    direction_increment(DIR,I,J)
    <-
    !do(skip,R);
    .log(warning,"I am already at an adjacent of ",B," : ",thing(I,J,B,_),", skip: ",R);
.
/**
 * If DIST from myposition and the target is 0 and I am not seeing the target, at the
 * supposed position I am lost!
 */
+!goto_nearest_adjacent(B,DIR):
    myposition(X,Y) &
    origin(MyMAP) & gps_map(_,_,B,MyMAP) & // I am sure I know where to find B
    .findall(g(It,Jt,T,TT),gps_map(X+It,Jt+Y,T,TT) & .range(It,-5,5) & .range(Jt,-5,5),LG) & // This is what I believe
    .findall(t(I,J,B,T),thing(I,J,B,T),LT) // This is what I see
    <-
    .log(warning,"I was doing ",goto_nearest_adjacent(B,DIR)," when I realised I am lost. ",myposition(X,Y),", things: ",LT,", gps: ",LG);
    +status(lost);
    !do(skip,R);
.

/**
 * goto XY, skip if no_route
 */
+!goto_XY(X,Y) :
    myposition(X,Y)
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
    } else {
        //Try again
        !goto_XY(X,Y);
    }
.

/**
 * find_meeting_area(X,Y,R,XM,YM) looks for a clear area for a meeting considering the agents are
 * carrying blocks. This simple approach considers R as the maximum stack number of blocks
 * that one is carrying. It is the radius since they may need to rotate. The approach tries to
 * put the master near the given X,Y and the helper on the right hand side of master.
 * For example, let us say we want to check if -5,-5 is a meeting area for R = 1, the approach
 * will try to check if both master (M) and helper (H) may be placed there considering they
 * are carrying at least one block and may need to rotate:
 *
 *              #     ##                                    ggg                               -7
 *  #      M  H           t          g                      1g            #                   -6
 *        MMMHHH                    ggg                                                       -5
 *         M  H       2            ggggg1                                                     -4
 *                                  ggg                                  ##                   -3
 *                                   g          #                    ##                       -2
 *
 * Notice, in this example the result unifies since -5,-5 are surrounded area is clear. However,
 * If the desired are is close to 0,-7, we can see that the agents would not have space for the
 * meeting. In this case, in a loop we will try a few possibilities near X,Y. Arbitrarily, we are
 * trying to increase X and Y at each iteration while no solution is found.
 */
+!find_meeting_area(X,Y,R,XM,YM)
    <-
    //Try a random position from the desired point
    -+desired_meeting_point(math.floor(math.random(11)) - 5 + X,math.floor(math.random(11)) - 5 + Y,R);
    -+find_meeting_iterator(0);
    while ( find_meeting_iterator(I) & (I < 10) ) {
        if ( desired_meeting_point(DX,DY,R) & is_meeting_area(DX,DY,R) ) {
            +found_meeting_point(DX,DY);
            -+find_meeting_iterator(10); // finish
        } else {
            ?desired_meeting_point(DX,DY,R);
            if (I mod 2 == 0) {
                -+desired_meeting_point(DX+1,DY,R);
            } else {
                -+desired_meeting_point(DX,DY+1,R);
            }
            -+find_meeting_iterator(I+1);
        }
    }
    ?found_meeting_point(XM,YM);
.
