/**
 * Test goals for common_walking.asl
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("walking/common_walking.asl") }
{ include("test_walking_helpers.asl") }


@[test]
+!launch_common_walking_tests:
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    !build_map(MIN_I);

    !testNearest;
    !testNearestNeighbour;
    !test_task_shortest_path;

    !print_map;
.

/**
 * Test rule that gives euclidean distance between two points
 */
@[test]
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
+!testNearest :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    -+myposition(0,0);
    ?nearest(goal,X,Y);
    !update_line(19,-4,MIN_I,"G");
    !assert_equals(19,X);
    !assert_equals(-4,Y);
.

/*
 * Nearest neighbour is the nearest adjacent position
 * of a given point (X,Y) in relation to myposition(X,Y)
 */
+!testNearestNeighbour :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    !build_map(MIN_I);

    -+myposition(12,12);
    ?nearest_neighbour(10,10,X,Y);
    !update_line(10,10,MIN_I,"y");
    !assert_equals(10,X);
    !assert_equals(11,Y);

    !print_map;
.

/**
 * Test shortest path for a task
 */
+!test_task_shortest_path
    <-
    -+myposition(0,0);
    +gps_map(0,-10,tstB,_);
    //!update_line(0,-10,MIN_I,"k");
    ?task_shortest_path(tstB,D);
    !assert_equals(55,D);
.
