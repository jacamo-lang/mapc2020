/**
 * Test goals for common_walking.asl
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("tasks/common_task.asl") }
{ include("test_walking.bb") }


@test_known_requirements[test]
+!test_known_requirements:
    .findall(I,task(I,J,O,_),LI)
    <-
    for ( task(T,_,_,_) ) {
        if ( known_requirements(T) ) {
            !assert_contains([task2,task1,task4,task0,task6,task5,task3],T);    
        } else {
            !assert_equals(task99,T);
        }
           
    }
.
