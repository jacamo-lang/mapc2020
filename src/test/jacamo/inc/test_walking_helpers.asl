/**
 * Helpful plans for testing walking functions
 */
direction_increment(n,0,-1).
direction_increment(s,0,1).
direction_increment(w,-1,0).
direction_increment(e,1,0).

get_printed_object(I,J,MIN_I,O) :-
    line(J,L) &
    .substring( L, O, I - MIN_I, I - MIN_I + 1)
.

+!build_map(MIN_I)
    <-
    .findall(J,gps_map(I,J,O,_),LJ);
    .min(LJ,MIN_J);
    .max(LJ,MAX_J);
    //.log(info,"i:",MIN_I,":",MAX_I);
    //.log(info,"j:",MIN_J,":",MAX_J);
    for ( .range(J,MIN_J-50,MAX_J+50) ) {
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
    .substring( L, OLD, I - MIN_I, I - MIN_I + 1);
    //.log(info,gps_map(I,J,O,_),":",I + 1 - MIN_I,":",LL,":",R1);
    if (.member(O,[b0,b1,b2])) {
        // If it is a dispenser just print the block identification
        .substring(O,R,1,2);
        .concat(R0,R,R1,RF);

    } else {
        if (O == obstacle) {
            .concat(R0,"#",R1,RF);
        } elif (O == s) {
            if (OLD \== "@" & OLD \== "H") {
                .concat(R0,"v",R1,RF);
            } else {
                .concat(R0,"D",R1,RF);
            }
        } elif (O == n) {
            if (OLD \== "@" & OLD \== "H") {
                .concat(R0,"^",R1,RF);
            } else {
                .concat(R0,"U",R1,RF);
            }
        } elif (O == e) {
            if (OLD \== "@" & OLD \== "H") {
                .concat(R0,">",R1,RF);
            } else {
                .concat(R0,"R",R1,RF);
            }
        } elif (O == w) {
            if (OLD \== "@" & OLD \== "H") {
                .concat(R0,"<",R1,RF);
            } else {
                .concat(R0,"L",R1,RF);
            }
        } else {
            // For other objects print the first letter
            .substring(O,R,0,1);
            .concat(R0,R,R1,RF);
        }
    }
    +line(J,RF);
.


+!update_line_conditional(I,J,MIN_I,O,O1,O2) :
    get_printed_object(I,J,MIN_I,OO) 
    <-
    if ( OO \== O ) {
        !update_line(I,J,MIN_I,O1); 
    } else {
        !update_line(I,J,MIN_I,O2);
    }
.

+!print_agent_with_radius(I,J,MIN_I,R)
    <- 
    for ( .range(II,-R,R) ) {
        if (II == 0) {
            for ( .range(JJ,-R,R) ) {
                !update_line_conditional(I+II,J+JJ,MIN_I,"#","C","B");
            }
        } else {
            !update_line_conditional(I+II,J,MIN_I,"#","C","B");
        }
    }
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

+!add_test_plans_do(MIN_I)
    <-
    .add_plan({
        +!do(move(DIR),success) :
            myposition(OX,OY) &
            direction_increment(DIR,I,J) &
            walked_steps(S) & step(SS)
            <-
            -+walked_steps(S+1);
            -+step(SS+1);
            //-+myposition(OX+I,OY+J); !mapping is doing that
            !update_line(OX,OY,MIN_I,DIR);
    }, self, begin);

    /**
     * Add mock plan for !do(rotate(D)) since it needs external library
     */
    .add_plan({ +!do(rotate(D),success) :
        attached(I,J) & 
        rotate(D,I,J,II,JJ) &
        thing(I,J,block,B) &
        step(SS)
        <-
        .print("mock ",rotate(D));
        -+step(SS+1);
        -+attached(II,JJ);
        -+thing(II,JJ,block,B);
    }, self, begin);

    /**
     * Add mock plan for !do(A) since it needs external library
     */
    .add_plan({ +!do(submit(T),success) :
            step(SS)
            <-
            -+step(SS+1); 
            .print("mock ",A)
    }, self, begin);
    
    .add_plan({ +!do(attach(D),success) : 
        direction_increment(D,I,J) &
        step(SS) 
        <-
        .print("mock ",attach(B));
        -+step(SS+1); 
        +attached(I,J);
    }, self, begin);
.

+!add_test_plan_mapping
    <-
    .add_plan({ +!mapping(success,_,DIR):
        myposition(X,Y) &
        direction_increment(DIR,I,J)
        <-
        -+myposition(X+I,Y+J);
        !update_thing_from_gps_map;
    }, self, begin);
.

+!add_test_plans_sincMap
    <-
    .add_plan({
        +!sincMap(_,_) 
            <-
            .log(warning,"Map synced.");
    }, self, begin);
.

/**
 * Remove all thing(_,_,_,_) and create new ones based on vision(V),
 * my_position(_,_) and gps_map(_,_,_,_)
 */
+!update_thing_from_gps_map :
    myposition(OX,OY) &
    origin(MyMAP) &
    vision(V)
    <-
    .abolish(thing(_,_,_,_));
    .abolish(obstacle(_,_));
    for ( gps_map(X,Y,O,MyMAP) & math.abs(OX-X) <= V & math.abs(OY-Y) <= V ) {
        if (O == obstacle) {
            +obstacle(X-OX,Y-OY);
        } else {
            +thing(X-OX,Y-OY,O,_);
        }
    }
    for (attached(IB,JB)) {
        +thing(IB,JB,block,b0);
    }

.

+!list_vision
    <-
    .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,block,BB),L);
    .findall(t(I,J,T,TT),thing(I,J,T,TT),LT);
    .findall(o(I,J),obstacle(I,J),LO);
    .concat("[",a(L),",",t(LT),",",o(LO),"]",STR);
    .print(STR);
.
