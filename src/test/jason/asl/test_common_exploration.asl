/**
 * Tests for common exploration
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("exploration/common_exploration.asl") }

/**
 * Initial belief
 */
vision(5).
proof(-5,"-----X-----").
proof(-4,"----XXX----").
proof(-3,"---XXXXX---").
proof(-2,"--XXXXXXX--").
proof(-1,"-XXXXXXXXX-").
proof( 0,"XXXXXXXXXXX").
proof( 1,"-XXXXXXXXX-").
proof( 2,"--XXXXXXX--").
proof( 3,"---XXXXX---").
proof( 4,"----XXX----").
proof( 5,"-----X-----").

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
    for ( .range(J,-S, S) & proof(J,L1) & line(J,L2)) {
        !assert_equals(L1,L2);
    }
.
