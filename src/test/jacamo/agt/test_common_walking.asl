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

    //!print_map;
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
