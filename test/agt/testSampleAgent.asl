/**
 * Test goals for sample agent
 */

{ include("sampleAgent.asl") }
{ include("testAssert.asl") }

!executeTestPlans.

/**
 * Test sum using just equals(EXPECTED,ACTUAL)
 */
@testSum[atomic]
+!testSum :
    true
    <-
    ?sum(1.3,2.65,R);
    !assertEquals(3.95,R);
.

/**
 * Test div using equals(EXPECTED,ACTUAL,TOLERANCE)
 */
@testDivide[atomic]
+!testDivide :
    true
    <-
    ?divide(10,3,R);
    !assertEquals(3.33,R,0.01);
.

/*
 * Test if the agent has added a belief
 */
@testDoSomethingAddsBelief[atomic]
+!testDoSomethingAddsBelief :
    true
    <-
    .abolish(raining);
    !assertFalse(raining);
    +doSomethingAddsBelief;
    !assertTrue(raining);
.
