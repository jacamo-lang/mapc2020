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

    !update_line(0,0,MIN_I,"H");

    -+myposition(0,0);
    -+attached(1,0);
    -+thing(1,0,block,b0);
    !fix_rotation(req(0,1,b0));

    !print_map;
    !assert_true(true);
.

