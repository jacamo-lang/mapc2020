/**
 * Simulate MAPC scenario
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("walking/blind_search.asl") }
{ include("walking/common_walking.asl") }
{ include("test_walking.bb") }

@test_goto[test]
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

    !build_map;

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
    !goto(X1,Y1,R2,_);
    !update_line(X1,Y1,MIN_I,"@");
    ?distance(X0,Y0,X1,Y1,R0);
    ?walked_steps(R1);
.


+!build_map
    <-
    .findall(I,gps_map(I,J,O,_),LI);
    .min(LI,MIN_I);
    .max(LI,MAX_I);
    .findall(J,gps_map(I,J,O,_),LJ);
    .min(LJ,MIN_J);
    .max(LJ,MAX_J);
    //.log(info,"i:",MIN_I,":",MAX_I);
    //.log(info,"j:",MIN_J,":",MAX_J);
    for ( .range(J,MIN_J,MAX_J) ) {
        .concat("                                                                                          ",J,C);
        +line(J,C);
    }
    for ( gps_map(I,J,O,_) ) {
        !update_line(I,J,MIN_I,O);
    }
.

+!update_line(I,J,MIN_I,O) :
    line(J,L)
    <-
    -line(J,L);
    .substring( L, R0, 0, I - MIN_I);
    //.log(info,gps_map(I,J,O,_),":",I - MIN_I,":'",R0,"'");
    .length(L,LL);
    .substring( L, R1, I - MIN_I + 1, LL);
    //.log(info,gps_map(I,J,O,_),":",I + 1 - MIN_I,":",LL,":",R1);
    if (.member(O,[b0,b1,b2])) {
        // If it is a dispenser just print the block identification
        .substring(O,R,1,2);
        .concat(R0,R,R1,RF);

    } else {
        if (O == obstacle) {
            .concat(R0,"#",R1,RF);
        } elif (O == s) {
            .concat(R0,"v",R1,RF);
        } elif (O == n) {
            .concat(R0,"^",R1,RF);
        } elif (O == e) {
            .concat(R0,">",R1,RF);
        } elif (O == w) {
            .concat(R0,"<",R1,RF);
        } else {
            // For other objects print the first letter
            .substring(O,R,0,1);
            .concat(R0,R,R1,RF);
        }
    }
    +line(J,RF);
.

+!print_map :
    .findall(J,gps_map(I,J,O,_),LJ) &
    .min(LJ,MIN_J) &
    .max(LJ,MAX_J)
    <-
    for ( .range(J,MIN_J,MAX_J) ) {
        ?line(J,RF);
        .log(info,RF);
    }
.

+!goto(X,Y,RET,_):
    myposition(X,Y)
    <-
    .print("-------> " ,arrived_at(X,Y));
    RET = success;
.

+!goto(X,Y,RET,_):
    myposition(OX,OY) &
    (OX \== X | OY \== Y) &
    get_direction(OX,OY,X,Y,DIRECTION)
    <-
    if (directions(DIRS) & .member(DIRECTION,DIRS)) {
        !do(move(DIRECTION),R);
        if (R == success) {
            !goto(X,Y,_,_);
        } else {
            .print("Fail on going to x: ",X," y: ",Y," act: ",DIRECTION);
            RET = error;
        }
    } else {
        .log(warning,no_route);
        RET = no_route;
    }
.
