/**
 * Test goals for common_walking.asl
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }


@test_simpleCFP[test]
+!test_simpleCFP
    <-
    makeArtifact("test_simpleCFP", "coordination.simpleCFP", [], CFPId);
    focus(CFPId);
    .findall(wanted_task(A,T,S),wanted_task(A,T,S),LT0);
    !assert_equals(0,.length(LT0));

    setCFP("wanted_task","task0",100+40);
    setCFP("wanted_task","task0",100+30);
    !assert_true(wanted_task(test_simpleCFP,task0,100+30));

    setCFP("wanted_task","task0",101+25);
    !assert_false(wanted_task(test_simpleCFP,task0,100+30));
    !assert_true(wanted_task(test_simpleCFP,task0,101+25));

    removeMyCFPs;
    !assert_false(wanted_task(test_simpleCFP,task0,101+25));

    setCFP("wanted_task","task0",110+32);
    !assert_true(wanted_task(test_simpleCFP,task0,110+32));

    resetSimpleCFP;
    !assert_false(wanted_task(_,_,_));
.
