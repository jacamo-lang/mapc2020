/**
 * Test goals for meeting.asl
 */

{ include("exploration/meeting.asl") }
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
vision(5).

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
@test_coord_same_position[test]
+!test_coord_same_position
    <-
    ?coord(0,0,0,0,[],L1);

    !assert_equals(61,.length(L1));

    .findall(p(X,Y),proof(X,Y),L0);

    .difference(L0,L1,DIFF);
    !assert_equals([],DIFF);
.

@test_coord_far_away[test]
+!test_coord_far_away
    <-
    ?coord(0,0,20,0,[],L1);

    !assert_equals(0,.length(L1));
.

/**
 * In the following sitution the agents
 * are sharing their view as represented below
 * They are sharing just one square in their views
 *      0         A
 *     101       BAB
 *    21012     CBABC
 *   3210123   DCBABCD
 *  432101234 EDCBABCDE
 * 54321012345EDCBABCDEF
 *  432101234 EDCBABCDE
 *   3210123   DCBABCD
 *    21012     CBABC
 *     101       BAB
 *      0         A
 */
@test_coord_sharing_one_square[test]
+!test_coord_sharing_one_square
    <-
    ?coord(0,0,10,0,[],L1);

    !assert_equals(1,.length(L1));
.

/**
 * In the following sitution the agents
 * are sharing their view as represented below
 * They are sharing two squares in their views
 *      0        A
 *     101      BAB
 *    21012    CBABC
 *   3210123  DCBABCD
 *  432101234EDCBABCDE
 * 54321012345DCBABCDEF
 *  432101234EDCBABCDE
 *   3210123  DCBABCD
 *    21012    CBABC
 *     101      BAB
 *      0        A
 */
@[test]
+!test_coord_sharing_two_squares
    <-
    ?coord(0,0,9,0,[],L1);

    !assert_equals(2,.length(L1));
.
/**
 * In the following sitution the agents
 * are sharing their view as represented below
 * They are sharing five squares in their views
 *      0       A
 *     101     BAB
 *    21012   CBABC
 *   3210123 DCBABCD
 *  432101234DCBABCDE
 * 54321012345CBABCDEF
 *  432101234DCBABCDE
 *   3210123 DCBABCD
 *    21012   CBABC
 *     101     BAB
 *      0       A
 */
@[test]
+!test_coord_sharing_five_squares
    <-
    ?coord(0,0,8,0,[],L1);

    !assert_equals(5,.length(L1));
.
