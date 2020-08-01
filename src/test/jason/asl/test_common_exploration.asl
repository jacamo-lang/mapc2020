/**
 * Tests for common exploration
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("exploration/common_exploration.asl") }

/**
 * Initial belief
 */
vision(5).

proof(-5,0).
proof(-4,-1).
proof(-4,0).
proof(-4,1).
proof(-3,-2).
proof(-3,-1).
proof(-3,0).
proof(-3,1).
proof(-3,2).
proof(-2,-3).
proof(-2,-2).
proof(-2,-1).
proof(-2,0).
proof(-2,1).
proof(-2,2).
proof(-2,3).
proof(-1,-4).
proof(-1,-3).
proof(-1,-2).
proof(-1,-1).
proof(-1,0).
proof(-1,1).
proof(-1,2).
proof(-1,3).
proof(-1,4).
proof(0,-5).
proof(0,-4).
proof(0,-3).
proof(0,-2).
proof(0,-1).
proof(0,0).
proof(0,1).
proof(0,2).
proof(0,3).
proof(0,4).
proof(0,5).
proof(1,-4).
proof(1,-3).
proof(1,-2).
proof(1,-1).
proof(1,0).
proof(1,1).
proof(1,2).
proof(1,3).
proof(1,4).
proof(2,-3).
proof(2,-2).
proof(2,-1).
proof(2,0).
proof(2,1).
proof(2,2).
proof(2,3).
proof(3,-2).
proof(3,-1).
proof(3,0).
proof(3,1).
proof(3,2).
proof(4,-1).
proof(4,0).
proof(4,1).
proof(5,0).

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
    .add_plan({ +!unmark(X,Y)
        <-
        +unmarked(X,Y);
    }, self, begin);

    // Trigger erase map
    !erase_map_view(0,0);

    !assert_equals(61,.count(unmarked(_,_)));

    .findall(p(X,Y),proof(X,Y),L0);
    .findall(p(X,Y),unmarked(X,Y),L1);

    .difference(L0,L1,DIFF);
    !assert_equals([],DIFF);
.
