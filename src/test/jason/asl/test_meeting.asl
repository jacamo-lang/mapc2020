/**
 * Test goals for meeting.asl
 */

{ include("meeting.asl") }
{ include("$jasonJar/test/jason/inc/tester_agent.asl") }

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

!execute_test_plans.

/**
 * ?coord/6 is supposed to return a list of 61 coordinates
 * in the format p(X,Y) which represents the agent's view like:
 *      0
 *     101
 *    21012
 *   3210123
 *  432101234
 * 54321012345
 *  432101234
 *   3210123
 *    21012
 *     101
 *      0
 */
@[test]
+!test_coord
    <-
    ?coord(0,0,0,0,[],L1);

    !assert_equals(61,.length(L1));

    .findall(p(X,Y),proof(X,Y),L0);

    .difference(L0,L1,DIFF);
    !assert_equals([],DIFF);
.
