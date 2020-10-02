/**
 * Tests for common exploration
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("exploration/common_exploration.asl") }
{ include("exploration/meeting.asl") }

/**
 * Initial belief
 */
vision(5).

/**
 * Test the logic behind erase_mapping_view
 * The assertion of this test is visual, i.e.,
 * it must be checked if the printed output
 * is correct
 */
@test_erase_map_view[test]
+!test_erase_map_view
    <-
    ?vision(S);

    /**
     * Add mock plan for !erase_map_point which
     * instead of unmark, will print 'X' in where
     * it is supposed to erase, and '-' in unchanged
     * point
     */
    .add_plan({ +!unmark(X,Y)
        <-
        +unmarked(X,Y);
    }, self, begin);

    // Trigger erase map
    !erase_map_view(0,0);

    !assert_equals(61,.count(unmarked(_,_)));

    /* Testing against coord(X,Y,XR,YR,L,R) */
    ?coord(0,0,0,0,[],L0);
    .findall(p(X,Y),unmarked(X,Y),L1);

    .difference(L0,L1,DIFF);
    !assert_equals([],DIFF);
.

