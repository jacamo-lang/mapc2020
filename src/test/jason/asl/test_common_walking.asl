/**
 * Test goals for common_walking.asl
 */

{ include("walking/common_walking.asl") }
{ include("$jasonJar/test/jason/inc/tester_agent.asl") }

/**
 * Test rule that gives euclidean distance between two points
 */
@testDistance[atomic,test]
+!testDistance :
    distance(0,0,3,3,D0) &
    distance(-30,-20,4,4,D1) &
    distance(-0,10,-9,8.9,D2) &
    distance(0.7,-17,4,-19,D3)
    <-
    !assert_equals(D0,6);
    !assert_equals(D1,58);
    !assert_equals(D2,10.1);
    !assert_equals(D3,5.3);
.

/**
 * Test nearest rule which uses myposition and gps_map(X,Y,thing,ag)
 * to return the nearest thing regarding the reference (myposition)
 */
@testNearest[atomic,test]
+!testNearest :
    true
    <-
    .abolish(gps_map(_,_,_,_));
    .abolish(myposition(_,_));
    +gps_map(5,5,goal,0)[source(self)];
    +gps_map(-5,-5,goal,0)[source(self)];
    +gps_map(-5,-4,goal,0)[source(self)];
    +gps_map(4,2,goal,0)[source(self)];
    +myposition(0,0);
    ?nearest(goal,X,Y);
    !assert_equals(4,X);
    !assert_equals(2,Y);
.

/*
 * Nearest neighbour is the nearest adjacent position
 * of a given point (X,Y) in relation to myposition(X,Y)
 */
@testNearestNeighbour[atomic,test]
+!testNearestNeighbour :
    true
    <-
    .abolish(myposition(_,_));
    +myposition(12,12);
    ?nearest_neighbour(10,10,X,Y);
    !assert_equals(10,X);
    !assert_equals(11,Y);
.

/**
 * Test shortest path for a task
 */
@test_task_shortest_path[atomic,test]
+!test_task_shortest_path :
    true
    <-
    .abolish(myposition(_,_));
    .abolish(gps_map(_,_,_,_));
    +myposition(0,0);
    +gps_map(0,5,taskboard,_);
    +gps_map(0,-10,tstB,_);
    +gps_map(0,10,goal,_);
    ?task_shortest_path(tstB,D);
    !assert_equals(D,40);
.
