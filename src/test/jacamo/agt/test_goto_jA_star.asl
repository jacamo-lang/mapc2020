/**
 * Simulate MAPC scenario
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("walking/goto_jA_star.asl") }
{ include("test_walking_helpers.asl") }
{ include("test_walking.bb") }

@[test]
+!test_get_direction :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    .add_plan({
        +!do(move(DIR),success) :
            myposition(OX,OY) &
            directionIncrement(DIR,I,J) &
            walked_steps(S)
            <-
            -+walked_steps(S+1);
            !update_line(OX,OY,MIN_I,DIR);
            -+myposition(OX+I,OY+J);
    }, self, begin);

    !add_test_plans_do(MIN_I);
    
    !build_map(MIN_I);

    /**
     * The following two tests regard to a direct comparison with Jason's blind search
     * implementation which was taken about 400 ms for the first test and
     * more than 1 s for the second. In case of the blind search no other tests
     * were done since a few steps further could mean not feasible processes due
     * to the time and memory blind search needs. 
     * These first tests are showing that Jason's A* is performing much better. 
     */
    // An A* search is likely to take about 270 ms
    !check_performance(test_goto(0,0,-1,-3,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(4,R0_2);
    !assert_equals(4,R1_2);

    // An A* search is likely to take about 320 ms
    !check_performance(test_goto(0,0,2,3,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(5,R0_3);
    !assert_equals(5,R1_3);

    //!print_map;

    !test_goto_surrounding_objects(MIN_I);
    !test_goto_nearest_objects(MIN_I);
    //!test_goto_far_position(MIN_I); // These tests are working, but taking too long
    
    .log(warning,"TODO: jA_star seems to do not be ready for searches with no solution.");
    //!test_goto_obstacle(MIN_I);
    !test_goto_nearest_blocked_neighbour(MIN_I);
    !test_goto_nearest_objects_loaded(MIN_I);
.

+!test_goto_surrounding_objects(MIN_I)
    <-
    // Test a simple path in which the euclidean distance can be achieved just avoiding obstacles
    !check_performance(test_goto(0,0,19,13,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(32,R0_1);
    !assert_equals(32,R1_1);

    // Test a path in which there the euclidean distance cannot be achieved
    !check_performance(test_goto(20,13,21,6,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(8,R0_2);
    !assert_equals(18,R1_2);

    // Test a straight line path occupying a goal terrain
    !check_performance(test_goto(21,5,21,-4,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(9,R0_3);
    !assert_equals(9,R1_3);

    //!print_map;
.

+!test_goto_nearest_objects(MIN_I)
    <-
    // Go from 0,0 to 20,12: min_distance = 32 steps
    //!build_map(MIN_I);

    ?nearest(taskboard,X1,Y1);
    ?nearest_neighbour(X1,Y1,X_1,Y_1);
    !check_performance(test_goto(0,0,X_1,Y_1,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(15,R0_1);
    !assert_equals(15,R1_1);

    ?nearest(b1,X2,Y2);
    ?nearest_neighbour(X2,Y2,X_2,Y_2);
    !check_performance(test_goto(X_1+1,Y_1,X_2,Y_2,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(13,R0_2);
    !assert_equals(13,R1_2);

    ?nearest(b2,X3,Y3);
    ?nearest_neighbour(X3,Y3,X_3,Y_3);
    !check_performance(test_goto(X_2+1,Y_2,X_3,Y_3,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(12,R0_3);
    !assert_equals(12,R1_3);

    ?nearest(goal,X_4,Y_4);
    !check_performance(test_goto(X_3+1,Y_3,X_4,Y_4,MIN_I,R0_4,R1_4,_),1,_);
    !assert_equals(14,R0_4);
    !assert_equals(14,R1_4);

    //!print_map;
.

+!test_goto_far_position(MIN_I)
    <-
    // Test a simple path in which the euclidean distance can be achieved just avoiding obstacles
    !check_performance(test_goto(0,0,48,-32,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(80,R0_1);
    !assert_equals(84,R1_1);

    !check_performance(test_goto(49,-32,60,15,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(58,R0_2);
    !assert_equals(58,R1_2);

    !check_performance(test_goto(59,15,12,6,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(56,R0_3);
    !assert_equals(68,R1_3);

    //!print_map;
.

+!test_goto_obstacle(MIN_I)
    <-
    !build_map(MIN_I);

    // Going to a X,Y which is an obstacle should return no_route
    !check_performance(test_goto(0,0,10,1,MIN_I,R0_1,R1_1,R2_1),1,_);
    !assert_equals(no_route,R2_1);

    // Coming from an obstacle in the middle of other obstacles should return no_route
    !check_performance(test_goto(6,2,1,2,MIN_I,R0_2,R1_2,R2_2),1,_);
    !assert_equals(no_route,R2_2);

    // Coming from an obstacle in to a valid X,Y should return some route
    !check_performance(test_goto(1,4,1,9,MIN_I,R0_3,R1_3,R2_3),1,_);
    !assert_equals(5,R0_3);
    !assert_equals(9,R1_3);

    // Going to a valid X,Y with obstacles all around should return no_route
    !check_performance(test_goto(1,11,9,7,MIN_I,R0_4,R1_4,R2_4),1,_);
    !assert_equals(no_route,R2_4);

    //!print_map;
.

+!test_goto_nearest_objects_loaded(MIN_I)
    <-
    //!build_map(MIN_I);

    +attached(0,1);
    
    -+myposition(53,-25);
    ?nearest(goal,X_1,Y_1);
    !check_performance(test_goto(53,-25,X_1,Y_1,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(23,R0_1);
    !assert_equals(23,R1_1);

    ?nearest(b2,X2,Y2);
    ?nearest_neighbour(X2,Y2,X_2,Y_2);
    !check_performance(test_goto(X_1,Y_1,X_2,Y_2,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(29,R0_2);
    !assert_equals(29,R1_2);

    ?nearest(b1,X3,Y3);
    ?nearest_neighbour(X3,Y3,X_3,Y_3);
    !check_performance(test_goto(X_2,Y_2,X_3,Y_3,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(11,R0_3);
    !assert_equals(11,R1_3);

    //!print_map;
.

+!test_goto_nearest_blocked_neighbour(MIN_I)
    <-
    ?nearest(b0,X2,Y2);
    ?nearest_neighbour(X2,Y2,X_2,Y_2);
    !check_performance(test_goto(0,-15,X_2,Y_2,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(8,R0_2);
    !assert_equals(12,R1_2);
    .log(warning,"TODO: Replace heuristic on nearest_neighbour/4 from euclidean distance to A* solution - see common_walking.asl");

    //!print_map;
.
