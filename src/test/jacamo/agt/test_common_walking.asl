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

    !test_is_walkable(MIN_I);
    !test_is_walkable_area(MIN_I);
    !test_is_meeting_area(MIN_I);
    !test_find_meeting_area(MIN_I);
    
    !test_nearest_walkable(MIN_I);
    !test_nearest_walkable_situation(MIN_I);
    !test_nearest_walkable_situation2(MIN_I);
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
 * is walkable test
 */
 @[atomic]
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

    .abolish(thing(_,_,_,_));
    .abolish(attached(_,_));
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
    .set_random_seed(20);
    !find_meeting_area(35,0,1,XM2,YM2);
    !assert_equals(38,XM2);
    !assert_equals(-3,YM2);
    !print_agent_with_radius(XM2,YM2,MIN_I,1);
    !print_agent_with_radius(XM2+3,YM2,MIN_I,1);

    .set_random_seed(10);
    // test an area in which the helper would find an obstacle
    !find_meeting_area(55,1,1,XM1,YM1);
    !assert_equals(62,XM1);
    !assert_equals(2,YM1);
    !print_agent_with_radius(XM1,YM1,MIN_I,1);
    !print_agent_with_radius(XM1+3,YM1,MIN_I,1);

    //!print_map;
.

/**
 * nearest walkable test
 */
@[atomic]
+!test_nearest_walkable(MIN_I)
    <-
    //!print_map;
    // test a completely clear area with radius = 1 surrounding 0,0
    -+myposition(40,-8);
    !update_line(40,-8,MIN_I,"Y");

    +thing(0,0,entity,a);
    // The closest goal area is on 43,-8
    ?nearest_walkable(goal,X1,Y1);
    !assert_equals(43,X1,0);
    !assert_equals(-8,Y1,0);

    // Let us say now that there is an agent with two blocks
    +thing(3,0,entity,b);
    +thing(4,0,block,b0);
    +thing(4,1,block,b1);
    !update_line(43,-8,MIN_I,"a");
    !update_line(44,-8,MIN_I,"b");
    !update_line(44,-7,MIN_I,"b");
    // The closest goal area is on 44,-9
    ?nearest_walkable(goal,X2,Y2);
    !assert_equals(44,X2,0);
    !assert_equals(-9,Y2,0);

    // Althout we don't have obstacle in goals, let us say we have some
    +obstacle(4,-1);
    +obstacle(5,-2);
    +obstacle(5,-1);
    +obstacle(5,0);
    !update_line(44,-9,MIN_I,"o");
    !update_line(45,-10,MIN_I,"o");
    !update_line(45,-9,MIN_I,"o");
    !update_line(45,-8,MIN_I,"o");
    // The closest goal area is on 45,-9
    ?nearest_walkable(goal,X3,Y3);
    !assert_equals(45,X3,0);
    !assert_equals(-7,Y3,0);

    .abolish(thing(_,_,_,_));
    .abolish(obstacle(_,_));
.

/**
 * nearest walkable test on a specific situation
 [test_common_walking]       # #                       g        ######           #    g            # #           -24
 [test_common_walking]           #                               #####               ggg               #         -23
 [test_common_walking]           #                                            #      Bg      #         #         -22
 [test_common_walking]                                                              B                            -21
 [test_common_walking]    #      #                                               A BB           #      #         -20
 [test_common_walking]       ##                                                  bBBB              ##            -19
 */
@[atomic]
+!test_nearest_walkable_situation(MIN_I)
    <-
    // goal area
    +gps_map(50,-23,goal,agenta0);
    +gps_map(51,-24,goal,agenta0);
    +gps_map(51,-23,goal,agenta0);
    +gps_map(51,-22,goal,agenta0);
    +gps_map(52,-23,goal,agenta0);
    !update_line(50,-23,MIN_I,"g");
    !update_line(51,-24,MIN_I,"g");
    !update_line(51,-23,MIN_I,"g");
    !update_line(51,-22,MIN_I,"g");
    !update_line(52,-23,MIN_I,"g");

    // the agent
    -+myposition(46,-20);
    +thing(0,0,entity,a);
    +thing(0,1,block,b2);
    +attached(0,1);
    !update_line(46,-20,MIN_I,"A");
    !update_line(46,-19,MIN_I,"b");

    // other agents
    +thing(1,1,entity,b);
    !update_line(47,-19,MIN_I,"B");
    +thing(2,1,entity,b);
    !update_line(48,-19,MIN_I,"B");
    +thing(3,1,entity,b);
    !update_line(49,-19,MIN_I,"B");
    +thing(2,0,entity,b);
    !update_line(48,-20,MIN_I,"B");
    +thing(3,0,entity,b);
    !update_line(49,-20,MIN_I,"B");
    +thing(3,-1,entity,b);
    !update_line(49,-21,MIN_I,"B");
    +thing(4,-2,entity,b);
    !update_line(50,-22,MIN_I,"B");

    ?nearest(goal,X1,Y1);
    !assert_equals(50,X1);
    !assert_equals(-23,Y1);
    ?nearest_walkable(goal,X2,Y2);
    !assert_equals(51,X2);
    !assert_equals(-22,Y2);

    .abolish(thing(_,_,_,_));
    .abolish(obstacle(_,_));
    //!print_map;
.

/**
 * nearest walkable test on a specific situation 2
[test_common_walking]                   #             g                           ##                          # -28
[test_common_walking]                                ggg                                                        -27
[test_common_walking]                            ###ggggg                                                       -26
[test_common_walking]                             ###ggg       ######                                           -25
[test_common_walking]       # #                       g        ######           #    g            # #           -24
[test_common_walking]           #                               #####               ggg               #         -23
[test_common_walking]           #                                            #      Bg      #         #         -22
[test_common_walking]                                                              B                            -21
[test_common_walking]    #      #               A                               A BB           #      #         -20
[test_common_walking]       ##                  B                               bBBB              ##            -19

 */
@[atomic]
+!test_nearest_walkable_situation2(MIN_I)
    <-
    -+myposition(14,-20);
    -+vision(5);

    // obstacles
    !add_item_to_map(15,-27,obstacle,MIN_I,"#");
    !add_item_to_map(16,-27,obstacle,MIN_I,"#");
    !add_item_to_map(17,-27,obstacle,MIN_I,"#");
    !add_item_to_map(18,-27,obstacle,MIN_I,"#");
    !add_item_to_map(17,-26,obstacle,MIN_I,"#");
    !add_item_to_map(16,-26,obstacle,MIN_I,"#");
    !add_item_to_map(15,-26,obstacle,MIN_I,"#");
    !add_item_to_map(16,-25,obstacle,MIN_I,"#");
    !add_item_to_map(17,-25,obstacle,MIN_I,"#");
    !add_item_to_map(18,-25,obstacle,MIN_I,"#");

    // the agent
    !add_thing_to_map(0,0,entity,a,MIN_I,"A");
    !add_thing_to_map(0,1,block,b2,MIN_I,"B");
    +attached(0,1);

    ?nearest(goal,X1,Y1);
    !assert_equals(18,X1);
    !assert_equals(-26,Y1);
    ?nearest_walkable(goal,X2,Y2);
    !assert_equals(19,X2);
    !assert_equals(-25,Y2);
    !add_item_to_map(18,-26,goal,MIN_I,"*");
    !add_item_to_map(19,-25,goal,MIN_I,"&");

    !print_map;

    .abolish(thing(_,_,_,_));
    .abolish(obstacle(_,_));
.

+!add_item_to_map(X,Y,Item,MIN_I,Char):
    myposition(X0,Y0) &
    vision(V)
    <-
    +gps_map(X,Y,Item,agenta0);
    !update_line(X,Y,MIN_I,Char);

    //it is a thing or obstacle in my vision
    if ((X-X0 <= V) & (Y-Y0 <= V)) {
        if (Item == obstacle) {
            +obstacle(X-X0,Y-Y0);
        }
    }
.

+!add_thing_to_map(I,J,T,D,MIN_I,Char):
    myposition(X,Y)
    <-
    +thing(I,J,T,D);
    !update_line(X+I,Y+J,MIN_I,Char);
.
