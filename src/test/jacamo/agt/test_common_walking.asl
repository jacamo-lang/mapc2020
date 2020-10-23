/**
 * Test goals for common_walking.asl
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("walking/common_walking.asl") }
{ include("test_walking.bb") }
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

    !test_is_walkable_area(MIN_I);
    !test_is_meeting_area(MIN_I);
    !test_find_meeting_area(MIN_I);
    
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

    // Nearest neighbour is adjacent north, it needs surround obstacles
    -+myposition(0,-16);
    !update_line(0,-16,MIN_I,"A");
    ?nearest_neighbour(7,-15,X1,Y1);
    !update_line(7,-15,MIN_I,"B");
    !assert_equals(7,X1);
    !assert_equals(-16,Y1);

    // Nearest neighbour is adjacent south, it needs surround obstacles
    -+myposition(0,-13);
    !update_line(0,-13,MIN_I,"C");
    ?nearest_neighbour(7,-14,X2,Y2);
    !update_line(7,-14,MIN_I,"D");
    !assert_equals(7,X2);
    !assert_equals(-13,Y2);

    // Nearest neighbour is both adjacent north and south, north is chosen
    -+myposition(0,-7);
    !update_line(0,-7,MIN_I,"E");
    ?nearest_neighbour(7,-7,X3,Y3);
    !update_line(7,-7,MIN_I,"F");
    !assert_equals(7,X3);
    !assert_equals(-8,Y3);

    // Nearest neighbour is a streigh line both west and south adjacents, west is chosen
    -+myposition(0,-7);
    !update_line(0,-7,MIN_I,"G");
    ?nearest_neighbour(5,-12,X4,Y4);
    !update_line(5,-12,MIN_I,"H");
    !assert_equals(4,X4);
    !assert_equals(-12,Y4);

    //!print_map;
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

/**
 * is walkable area test
 */
+!test_is_walkable_area(MIN_I)
    <-
    // test a completely clear area with radius = 1 surrounding 0,0
    !print_agent_with_radius(0,0,MIN_I,1);
    !assert_true(is_walkable_area(0,0,1));

    // test a NOT clear area with radius = 1 surrounding 10,0 (southern position is an obstacle)
    !print_agent_with_radius(10,0,MIN_I,1);
    !assert_false(is_walkable_area(10,0,1));

    // test a completely clear area with radius = 2 surrounding -5,-5
    !print_agent_with_radius(-5,-5,MIN_I,2);
    !assert_true(is_walkable_area(-5,-5,2));
    
    // test a completely clear area with radius = 2 surrounding 0,10
    !print_agent_with_radius(0,10,MIN_I,2);
    !assert_false(is_walkable_area(0,10,2));
.

+!test_is_meeting_area(MIN_I)
    <-
    // test a completely clear meeting area
    !print_agent_with_radius(45,8,MIN_I,1);
    !print_agent_with_radius(48,8,MIN_I,1);
    !assert_true(is_meeting_area(45,8,1));

    // test an area in which the helper would find an obstacle
    !print_agent_with_radius(35,10,MIN_I,1);
    !print_agent_with_radius(38,10,MIN_I,1);
    !assert_false(is_meeting_area(35,10,1));
.

+!test_find_meeting_area(MIN_I)
    <-
    // test a completely clear meeting area
    !print_agent_with_radius(35,0,MIN_I,1);
    !print_agent_with_radius(38,0,MIN_I,1);
    !find_meeting_area(35,0,1,XM2,YM2);
    !assert_between(XM2,30,40); //around 35
    !assert_equals(YM2,-5,5); //around 0

    // test an area in which the helper would find an obstacle
    !print_agent_with_radius(58,3,MIN_I,1);
    !print_agent_with_radius(61,3,MIN_I,1);
    !find_meeting_area(55,1,1,XM1,YM1);
    !assert_equals(XM1,53,63); //around 58
    !assert_equals(YM1,-2,8); //around 3
.
