/**
 * Test goals for sample agent
 */

{ include("sampleAgent.asl") }
{ include("tester_agent.asl") }

!execute_test_plans.

/**
 * Test sum using just equals(EXPECTED,ACTUAL)
 */
@testSum[atomic]
+!testSum :
    true
    <-
    ?sum(1.3,2.65,R);
    !assert_equals(3.95,R);
.

/**
 * Test div using equals(EXPECTED,ACTUAL,TOLERANCE)
 */
@testDivide[atomic]
+!testDivide :
    true
    <-
    ?divide(10,3,R);
    !assert_equals(3.33,R,0.01);
.

/*
 * Test if the agent has added a belief
 */
@testDoSomethingAddsBelief[atomic]
+!testDoSomethingAddsBelief :
    true
    <-
    .abolish(raining);
    !assert_false(raining);
    +doSomethingAddsBelief;
    !assert_true(raining);
.
