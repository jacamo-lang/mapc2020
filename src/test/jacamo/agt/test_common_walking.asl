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
    !testNearestAdjacent;
    !test_task_shortest_path;

    !print_map;

    !test_is_walkable(MIN_I);
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

    // Nearest neighbour is a straight line both west and south adjacents, west is chosen
    -+myposition(0,-7);
    !update_line(0,-7,MIN_I,"G");
    ?nearest_neighbour(5,-12,X4,Y4);
    !update_line(5,-12,MIN_I,"H");
    !assert_equals(4,X4);
    !assert_equals(-12,Y4);

    // Nearest neighbour when I am at the target, I want to go to its neighbour
    -+myposition(10,-6);
    !update_line(10,-6,MIN_I,"I");
    ?nearest_neighbour(10,-6,X5,Y5);
    !update_line(9,-6,MIN_I,"J");
    !assert_equals(9,X5);
    !assert_equals(-6,Y5);

    // Nearest neighbour  when I am at the target, I want to go to its neighbour but some of them are obstacles 
    -+myposition(37,9);
    !update_line(37,9,MIN_I,"K");
    ?nearest_neighbour(37,9,X6,Y6);
    !update_line(37,8,MIN_I,"L");
    !assert_equals(37,X6);
    !assert_equals(8,Y6);

    // Nearest neighbour  when I am at a neighbour 
    -+myposition(40,12);
    !update_line(40,12,MIN_I,"M");
    ?nearest_neighbour(40,13,X7,Y7);
    !update_line(40,12,MIN_I,"N");
    !assert_equals(40,X7);
    !assert_equals(12,Y7);

    //!print_map;
.

/*
 * Nearest adjacent is the nearest adjacent X,Y position
 * of a given thing when we want to make an approach using DIR
 */
+!testNearestAdjacent :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    !build_map(MIN_I);

    // Nearest adjacent north, it needs surround obstacles
    -+myposition(0,-16);
    !update_line(0,-16,MIN_I,"A");
    ?nearest_adjacent(b0,X1,Y1,n);
    !update_line(7,-16,MIN_I,"B");
    !assert_equals(7,X1);
    !assert_equals(-16,Y1);

    // Nearest adjacent south, it needs surround obstacles
    -+myposition(0,-13);
    !update_line(0,-13,MIN_I,"C");
    ?nearest_adjacent(b0,X2,Y2,s);
    !update_line(7,-14,MIN_I,"D");
    !assert_equals(7,X2);
    !assert_equals(-14,Y2);

    // Nearest adjacent is west but the closest target has west blocked, do go farther
    -+myposition(2,-11);
    !update_line(2,-11,MIN_I,"E");
    ?nearest_adjacent(b0,X3,Y3,w);
    !update_line(9,-32,MIN_I,"F");
    !assert_equals(9,X3);
    !assert_equals(-32,Y3);

    // Nearest neighbour when I am at the target, I want to go to its neighbour
    -+myposition(9,-6);
    !update_line(9,-6,MIN_I,"I");
    ?nearest_adjacent(taskboard,X5,Y5,e);
    !update_line(11,-6,MIN_I,"J");
    !assert_equals(11,X5);
    !assert_equals(-6,Y5);

    // Nearest adjacent when I am at the target, I want to go to its adjacent but some of them are obstacles 
    -+myposition(37,9);
    !update_line(37,9,MIN_I,"K");
    ?nearest_adjacent(taskboard,X6,Y6,n);
    !update_line(37,8,MIN_I,"L");
    !assert_equals(37,X6);
    !assert_equals(8,Y6);

    // Nearest adjacent when I am at this adjacent 
    -+myposition(40,12);
    !update_line(40,12,MIN_I,"M");
    ?nearest_adjacent(b0,X7,Y7,n);
    !update_line(40,12,MIN_I,"N");
    !assert_equals(40,X7);
    !assert_equals(12,Y7);

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

/**
 * is walkable test
 */
+!test_is_walkable(MIN_I)
    <-
    // test a completely clear area with radius = 1 surrounding 0,0
    !update_line(25,-18,MIN_I,"Y");
    +thing(0,0,entity,a);
    !update_line(25,-17,MIN_I,"b");
    +thing(0,1,block,b0);
    +attached(0,1);
    // the position this agent is should not be walkable
    !assert_false(is_walkable(0,0));
    // the position an attached block is whould be walkable
    !assert_true(is_walkable(0,1));

    // the position of a dropped block (not attaced), should not be walkabe
    !update_line(24,-18,MIN_I,"d");
    +thing(-1,0,block,b1);
    !assert_false(is_walkable(-1,0));

    // there is another agent with a block
    +thing(3,3,entity,b);
    !update_line(28,-15,MIN_I,"x");
    +thing(3,4,block,b2);
    !update_line(28,-14,MIN_I,"d");
    !assert_false(is_walkable(3,3));
    !assert_false(is_walkable(3,4));

    // other random close spots are free
    !assert_true(is_walkable(2,2));
    !assert_true(is_walkable(2,-2));
    !assert_true(is_walkable(-2,2));
    !assert_true(is_walkable(-2,-2));
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
    !find_meeting_area(35,0,1,XM2,YM2);
    !assert_equals(35,XM2,10); //around 35
    !assert_equals(0,YM2,10); //around 0
    !print_agent_with_radius(XM2,YM2,MIN_I,1);
    !print_agent_with_radius(XM2+3,YM2,MIN_I,1);

    // test an area in which the helper would find an obstacle
    !find_meeting_area(55,1,1,XM1,YM1);
    !assert_equals(55,XM1,10); //around 55
    !assert_equals(1,YM1,10); //around 1
    !print_agent_with_radius(XM1,YM1,MIN_I,1);
    !print_agent_with_radius(XM1+3,YM1,MIN_I,1);

    !print_map;
.
