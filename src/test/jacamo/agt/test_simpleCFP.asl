/**
 * Test goals for common_walking.asl
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }


@test_simpleCFP[test]
+!test_simpleCFP
    <-
    makeArtifact("test_simpleCFP", "coordination.simpleCFP", [], CFPId);
    focus(CFPId);
    .findall(wanted_task(A,T,S,C),wanted_task(A,T,S,C),LT0);
    !assert_equals(0,.length(LT0));
    
    setWantedTask("agenta1","task0",100,40);
    setWantedTask("agenta2","task0",100,30);
    !assert_true(wanted_task(agenta2,task0,100,30));
    .findall(wanted_task(A,T,S,C),wanted_task(A,T,S,C),LT1);
    .log(warning,LT1);
    
    setWantedTask("agenta3","task0",101,25);
    !assert_false(wanted_task(agenta1,task0,100,20));
    !assert_true(wanted_task(agenta3,task0,101,25));
    .findall(wanted_task(A,T,S,C),wanted_task(A,T,S,C),LT2);
    .log(warning,LT2);
    

    setWantedTask("agenta99","task1",100,40); // just to check it is not removing other tasks
    removeMyWantedTasks("agenta2"); // it should have no effect
    !assert_true(wanted_task(agenta3,task0,101,25));
    
    removeMyWantedTasks("agenta3");
    !assert_false(wanted_task(_,task0,_,_));
    !assert_true(wanted_task(agenta99,task1,100,40));
    
    setWantedTask("agenta4","task0",110,32);
    !assert_true(wanted_task(agenta4,task0,110,32));
    
    resetSimpleCFP;
    !assert_false(wanted_task(_,_,_,_));
.
