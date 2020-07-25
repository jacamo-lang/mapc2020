/**
 * Tests for common exploration
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("exploration/common_exploration.asl") }

/**
 * Initial belief
 */
vision(5).

/**
 * Execute test plans!
 */
!execute_test_plans.

/**
 * Test the logic behind erase_mapping_view
 * The assertion of this test is visual, i.e.,
 * it must be checked if the printed output
 * is correct
 */
@[atomic,test]
+!test_erase_map_view
    <-
    .log(warning,"Starting test_erase_map_view...");

    ?vision(S);

    /**
     * Add mock plan for !erase_map_point which
     * instead of unmark, will print 'X' in where
     * it is supposed to erase, and '-' in unchanged
     * point
     */
    .add_plan({ +!erase_map_point(X,Y,J,T) :
        true
        <-
        ?line(J,L);
        -line(J,L);
        if (T == true) {
            .concat(L,"X",LL);
        } else {
            .concat(L,"-",LL);
        }
        +line(J,LL);
    }, self, begin);

    // Create an empty map view
    for ( .range(J,-S, S) ) {
        +line(J,"");
    }

    // Trigger erase map
    !erase_map_view(0,0);

    // Show final view
    for ( .range(J,-S, S) ) {
        ?line(J,L);
        .print(L);
    }

    .log(warning,"End of test_erase_map_view");
.
