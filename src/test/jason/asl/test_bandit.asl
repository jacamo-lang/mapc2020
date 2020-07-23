/**
 * Test multi-armed bandit Jason extension
*/

{ include("tester_agent.asl") }

!execute_test_plans.

/**
 * Test bandit initialization
*/
@[atomic,test]
+!test_bandit_init :
    true
     <-
    .init_bandit(["a", "b", "c", "d", "e"], 0.1, 0.1, 20, B)
    .pull_arm(B, A)
    !assert_equals(0, R);
.
