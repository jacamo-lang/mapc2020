/**
 * Test goals for goal_center.asl
 */

{ include("exploration/goal_center.asl") }
{ include("$jasonJar/test/jason/inc/tester_agent.asl") }

/**
 * Considering the goal area has 13 units as a diamond
 * The agent may consider it as a cross with 5 units
 * When the agent knows two edges of the goal area
 * it can tell where is the center
 */
@test_goal_center[atomic,test] //must be atomic due to abolish ... assert
+!test_goal_center
    <-
    .abolish(gps_map(_,_,_,_));
    +gps_map(19,-4,goal,0);
    +gps_map(20,-5,goal,0);
    +gps_map(20,-4,goal,0);
    +gps_map(20,-3,goal,0);
    +gps_map(21,-6,goal,0);
    +gps_map(21,-5,goal,0);
    +gps_map(21,-4,goal,0);
    +gps_map(21,-3,goal,0);
    +gps_map(21,-2,goal,0);
    +gps_map(22,-5,goal,0);
    +gps_map(22,-4,goal,0);
    +gps_map(22,-3,goal,0);
    +gps_map(23,-4,goal,0);
    ?gps_map(X,Y,goal_center,_);
    !assert_equals(21,X);
    !assert_equals(-4,Y);
.

/*
 * Test get block which request/attach a block
 * It is actually returning error since the simulator is not on
 */
@test_add_goal_center[atomic,test]
+!test_add_goal_center //must be atomic due to abolish ... assert
    <-
    .abolish(gps_map(_,_,_,_));
    !assert_false(gps_map(_,_,goalCenter,_));
    +gps_map(10,12,goalCenter,ag);
    !assert_true(gps_map(_,_,goalCenter,_));
.
