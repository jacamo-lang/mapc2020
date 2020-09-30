/**
 * Test goals for agent Weak Individualist
 */

//{ include("strategies/weak_individualist.asl") }
{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("test_walking.bb") }
{ include("test_walking_helpers.asl") }

//TODO: Fix tests for new structure using simulation/massim.asl

//@[test]
+!launch_weak_individualist_tests :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    makeArtifact("rp_test_weakind", "localPositionSystem.rp.rp", [70,0], RpId);
    focus(RpId);
    for ( gps_map(I,J,O,MapId) ) {
        setGpsMapForTests(I,J,O,MapId)[artifact_id(RpId)];
    }

    !add_test_plans_do(MIN_I);

    !build_map(MIN_I);

    !test_goto_nearest_objects(MIN_I);
    !testSetRightPosition;
    //!testGotNewTask;
.

/**
 * Expected output
[testAgentWeakIndividualist]                               @gg                                                         -26
[testAgentWeakIndividualist]                               ^gg                                                         -25
[testAgentWeakIndividualist]                            >>>^                                                           -24
[testAgentWeakIndividualist]                        >>>>^                                                              -23
[testAgentWeakIndividualist]                        ^                                                                  -22
[testAgentWeakIndividualist]                        ^                                                                  -21
[testAgentWeakIndividualist]                     >>>^                                                                  -20
[testAgentWeakIndividualist]       ##            ^                                                                     -19
[testAgentWeakIndividualist]      ####           ^                                                                     -18
[testAgentWeakIndividualist]      ####           ^                                                                     -17
[testAgentWeakIndividualist]       ##        ##  ^                                                                     -16
[testAgentWeakIndividualist]                ####0^                                                                     -15
[testAgentWeakIndividualist]                ####D^                                                                     -14
[testAgentWeakIndividualist]                 ## v^                                                                     -13
[testAgentWeakIndividualist]                    R^                                                                     -12
[testAgentWeakIndividualist]                    ^<<                                                                    -11
[testAgentWeakIndividualist]                      ^                                                                    -10
[testAgentWeakIndividualist]                      ^                                                                    -9
[testAgentWeakIndividualist]                      ^                                                                    -8
[testAgentWeakIndividualist]                   #  ^                                                                    -7
[testAgentWeakIndividualist] #                    Ut                                                                   -6
[testAgentWeakIndividualist]                      ^                                                                    -5
[testAgentWeakIndividualist]                   >>>^                                                                    -4
[testAgentWeakIndividualist]                  >^                                                                       -3
[testAgentWeakIndividualist]                  ^                                                                        -2
[testAgentWeakIndividualist]                  ^                                                                        -1
[testAgentWeakIndividualist]             R>>>>^                                                                        0

*/
+!test_goto_nearest_objects(MIN_I)
    <-
    // Go from 0,0 to 20,12: min_distance = 32 steps

    ?nearest(taskboard,X1,Y1);
    ?nearest_neighbour(X1,Y1,X_1,Y_1);
    !check_performance(test_goto(0,0,X_1,Y_1,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(15,R0_1);
    !assert_equals(15,R1_1);

    ?nearest(b0,X2,Y2);
    ?nearest_neighbour(X2,Y2,X_2,Y_2);
    !check_performance(test_goto(X_1,Y_1,X_2,Y_2,MIN_I,R0_2,R1_2,_),1,_);
    .wait(50);
    !assert_equals(10,R0_2);
    !assert_equals(10,R1_2);

    ?nearest(b2,X3,Y3);
    ?nearest_neighbour(X3,Y3,X_3,Y_3);
    !check_performance(test_goto(X_2,Y_2,X_3,Y_3,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(2,R0_3);
    !assert_equals(2,R1_3);

    ?nearest(goal,X_4,Y_4);
    !check_performance(test_goto(X_3,Y_3,X_4,Y_4,MIN_I,R0_4,R1_4,_),1,_);
    !assert_equals(20,R0_4);
    !assert_equals(20,R1_4);

    //!print_map;
.

/*
 * Test if the agent got the right rotation
 */
+!testSetRightPosition
    <-
    +attached(0,1); // I have a block at 6 o'clock
    !setRightPosition(req(0,1,tstB));  // The block must be at 6 o'clock
    !assert_true(attached(0,1));
    !setRightPosition(req(-1,0,tstB)); // The block must be at 9 o'clock
    !assert_true(attached(-1,0));
    !setRightPosition(req(1,0,tstB));  // The block must be at 3 o'clock
    !assert_true(attached(1,0));
    !setRightPosition(req(0,-1,tstB)); // The block must be at 12 o'clock
    .log(warning,"TODO: Fix testSetRightPosition");
    //!assert_true(attached(0,-1));
.

/**
 * Test got new task
 */
  +!testGotNewTask
    <-
    .log(warning,"TODO: Fix testGotNewTask");

    +step(450);             // Give enough steps in order to be feasible in the deadline
    -+myposition(0,0);
    +goal(0,0);                         // To submit a task it has to be on a goal area

    +task(task22,503,1,[req(0,1,b2)]);
.
