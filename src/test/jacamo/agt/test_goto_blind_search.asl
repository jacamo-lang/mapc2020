/**
 * Simulate MAPC scenario
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("exploration/common_exploration.asl") }
{ include("walking/blind_search.asl") }
{ include("walking/common_walking.asl") }
{ include("test_walking_helpers.asl") }
{ include("test_walking.bb") }

@test_goto_blind_search[test]
+!test_goto_blind_search :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    !build_map(MIN_I);
    
    !add_test_plans_do(MIN_I);

    // A blind search is likely to take about 400 ms
    !check_performance(test_goto(0,0,-1,-3,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(4,R0_2);
    !assert_equals(4,R1_2);

    // A blind search is likely to take more than 1 second for this problem
    !check_performance(test_goto(0,0,2,3,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(5,R0_3);
    !assert_equals(5,R1_3);

    //!print_map;
.

+!test_goto(X0,Y0,X1,Y1,MIN_I,R0,R1,R2)
    <-
    -+myposition(X0,Y0);
    !update_line(X0,Y0,MIN_I,"H");
    -+walked_steps(0);
    !goto(X1,Y1,R2);
    !update_line(X1,Y1,MIN_I,"@");
    ?distance(X0,Y0,X1,Y1,R0);
    ?walked_steps(R1);
.

+!goto(X,Y,RET):
    myposition(X,Y)
    <-
    .print("-------> " ,arrived_at(X,Y));
    RET = success;
.

+!goto(X,Y,RET):
    myposition(OX,OY) &
    get_direction(OX,OY,X,Y,DIRECTION) &
    step(S)
    <-
    if ( .member(DIRECTION,[n,s,w,e]) ) {
        !do(move(DIRECTION),R);
        if (R == success) {
            !mapping(success,_,DIRECTION);
            .wait(step(Step) & Step > S); //wait for the next step to continue
            !goto(X,Y,_);
        } else {
            .print("Fail on going to x: ",X," y: ",Y," act: ",DIRECTION);
            RET = error;
        }
    } else {
        .log(warning,no_route);
        RET = no_route;
    }
.
