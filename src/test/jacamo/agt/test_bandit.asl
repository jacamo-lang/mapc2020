/**
 * Test multi-armed bandit Jason extension
*/
    
{ include("$jasonJar/test/jason/inc/tester_agent.asl") }

/**
 * Tests all interactions with the MAB Jason extension
 * in a "happy path" scenario
*/
@test_egreedy_bandit_api[test]
+!test_egreedy_bandit_api :
    true
    <-
    //.init_bandit(tArmNames, type = "EPSILON_GREEDY", epsilon, decayRate, seed, handoverArg, unifier)
    .init_bandit([a, b, c, d, e], "EPSILON_GREEDY", 0.1, 0.1, 20, B);
    !assert_equals(0, B);
    .pull_arm(B, A);
    !assert_equals("e", A);
    .set_reward(B, A, 2, F);
    !assert_equals([0, 0, 0, 0, 1], F);
.

@test_ubc_bandit_api[test]
+!test_ubc_bandit_api :
    true
    <-
    .init_bandit([a, b, c, d, e], "UBC", B);
    !assert_equals(1, B);
    .pull_arm(B, A);
    !assert_equals("e", A);
    .set_reward(B, A, 2, F);
    !assert_equals([1, 0, 0, 0, 0], F);
.
