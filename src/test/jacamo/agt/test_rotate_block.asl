/**
 * Simulate MAPC scenario
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("tasks/rotate_block.asl") }
{ include("test_walking_helpers.asl") }
{ include("test_walking.bb") }

@test_rotate_block[test]
+!test_rotate_block :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    !add_test_plans_do(MIN_I);
    
    !build_map(MIN_I);

    !rotation_in_a_free_area(MIN_I);
    !rotation_to_obstacle(MIN_I);

    !print_map;
    !assert_true(true);
.

+!rotation_in_a_free_area(MIN_I)
    <-
    -+walked_steps(0);
    -+myposition(0,0);
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
    -+attached(1,0);
    -+thing(1,0,block,b0);
    !fix_rotation(req(0,1,b0));
    ?walked_steps(R1);
.
