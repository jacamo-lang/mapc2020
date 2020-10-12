/**
 * This library intends to solve the problem of going to a specific dispenser
 * and attaching block(s)
 * It tries to go to the nearest dispenser of B doing a valid approximation
 * to the dispenser to then attach the specifc block
 */


/**
 *TODO: It is necessary to put into this library the capability to Rotate since
 *it is possible to have requerements of multiple blocks, so, the position of
 * existing ones should be also solved
 */
+!get_block(req(I,J,B)) :
    myposition(X,Y) &
    (thing(ID,JD,dispenser,B) & distance(0,0,ID,JD,1) & direction_increment(DD,ID,JD)) & // direction of the dispenser
    not attached(ID,JD) &
    .my_name(ME)
    <-
    !do(request(DD),R0);
    !do(attach(DD),R1);
    if ((R0 == success) & (R1 == success)) {
        .log(warning,"I have attached a block ",B);
        .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,BB), L);
        .findall(t(I,J,T),thing(I,J,T,_), LT);
        .concat("[",req(I,J,B),",",agent(ME),",",myposition(X,Y),",",a(L),",",t(LT),",",R0,"/",R1,"]",STR);
        .save_stats("blockAttached",STR);
    } else {
        .log(warning,"Could not request/attach block ",B, "::",R0,"/",R1," my position: (",X,",",Y,"), target (",I,",",J,")");
        .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,BB), L);
        .findall(t(I,J,T),thing(I,J,T,_), LT);
        .concat("[",req(I,J,B),",",agent(ME),",",myposition(X,Y),",",a(L),",",t(LT),",",R0,"/",R1,"]",STR);
        .save_stats("errorOnAttach",STR);
    }
.
+!get_block(req(I,J,B)) :  // In case the agent is far away from B
     step(S) &
     direction_increment(DIR,I,J)
     <-
     !goto_nearest_adjacent(B,DIR);
     .wait(step(Step) & Step > S); //wait for the next step to continue
     !get_block(req(I,J,B));
.
