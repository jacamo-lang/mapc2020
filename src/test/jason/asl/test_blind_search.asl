/**
 * Simulate MAPC scenario
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("walking/blind_search.asl") }
{ include("walking/common_walking.asl") }
{ include("test_walking_helpers.asl") }
{ include("test_walking.bb") }

@[test]
+!test_get_direction :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    .add_plan({
        +!do(move(DIR),success) :
            myposition(OX,OY) &
            directionIncrement(DIR,I,J) &
            walked_steps(S)
            <-
            -+walked_steps(S+1);
            !update_line(OX,OY,MIN_I,DIR);
            -+myposition(OX+I,OY+J);
    }, self, begin);

    !build_map(MIN_I);

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
    (OX \== X | OY \== Y) &
    get_direction(OX,OY,X,Y,DIRECTION)
    <-
    if (directions(DIRS) & .member(DIRECTION,DIRS)) {
        !do(move(DIRECTION),R);
        if (R == success) {
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
