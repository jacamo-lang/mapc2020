/**
 * Simulate MAPC scenario
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("tasks/rotate_block.asl") }
{ include("walking/common_walking.asl") }
{ include("test_walking_helpers.asl") }
{ include("test_walking.bb") }

@test_rotate_block[test]
+!test_rotate_block :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    !add_test_plans_do(MIN_I);
    !add_test_plan_mapping;

    !build_map(MIN_I);

    !rotation_in_a_free_area(MIN_I);
    !rotation_to_obstacle(MIN_I);
    !rotation_from_obstacle(MIN_I);
    !rotation_obstacle_on_diagonal(MIN_I);

    !print_map;
.

+!rotation_in_a_free_area(MIN_I)
    <-
    -+walked_steps(0);
    -+myposition(0,0);
    -+step(0);
    !update_line(0,0,MIN_I,"H");
    // 3  o'clock -> 6  o'clock
    -+attached(1,0);
    -+thing(1,0,block,b0);
    !fix_rotation(req(0,1,b0));
    ?walked_steps(R1);
    .log(warning,R1);
.

+!rotation_to_obstacle(MIN_I)
    <-
    -+walked_steps(0);
    // 3  o'clock -> 6  o'clock
    -+myposition(14,0);
    !update_line(14,0,MIN_I,"Y");
    !update_thing_from_gps_map;
    +attached(1,0);
    +thing(1,0,block,b0);
    // 3  o'clock -> 12  o'clock (it is ok, 12 is free)
    !fix_rotation(req(0,-1,b0));
    !assert_true(attached(0,-1));
    !assert_true(thing(0,-1,block,b0));

    // 12  o'clock -> 9  o'clock (not ok, 9 is an obstacle)
    !list_vision;
    !fix_rotation(req(-1,0,b0));
    ?myposition(X0,Y0);
    .print(myposition(X0,Y0));
    !update_line(X0,Y0,MIN_I,"Y");
    !assert_true(attached(-1,0));
    !assert_true(thing(-1,0,block,b0));
    !list_vision;

    .abolish(thing(_,_,_,_));
    .abolish(attached(_,_));
.

/*
 * This situation actually should never happen.
 * It is when the block starts from an obstacle, in this case,
 * the algorithm won't check the origin of the block, just the
 * destination, i.e., it should rotate as in a normal situation.
 */
+!rotation_from_obstacle(MIN_I)
    <-
    +walked_steps(0);

    -+myposition(16,3);
    !update_line(16,3,MIN_I,"K");
    !update_thing_from_gps_map;
    +attached(0,1);
    +thing(0,1,block,b0);

    !print_map;
    // 6 o'clock -> 12  o'clock (with obstacles on 3 and 9 o'clock)
    !update_thing_from_gps_map;

    !list_vision;
    !fix_rotation(req(0,-1,b0));
    ?myposition(X0,Y0);
    .print(myposition(X0,Y0));
    !update_line(X0,Y0,MIN_I,"K");
    !assert_true(attached(0,-1));
    !assert_true(thing(0,-1,block,b0));

    !print_map;

    .abolish(thing(_,_,_,_));
    .abolish(attached(_,_));
.

/*
 * In this situation there is an obstacle in a diagonal which
 * should not affect
 */
+!rotation_obstacle_on_diagonal(MIN_I)
    <-
    -+walked_steps(0);
    // 3  o'clock -> 6  o'clock
    -+myposition(16,3);
    !update_line(16,3,MIN_I,"G");
    -+attached(1,0);
    -+thing(1,0,block,b0);
    !fix_rotation(req(0,1,b0));
    ?walked_steps(R1);
.
