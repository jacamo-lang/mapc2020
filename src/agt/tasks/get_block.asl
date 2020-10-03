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
 
 +!get_block(B) :
     myposition(X,Y) &
     not attached(_,_) &
     (thing(I,J,dispenser,B) & directionIncrement(D,I,J))
     <-
     !do(request(D),R0);
     !do(attach(D),R1);
     if ((R0 == success) & (R1 == success)) {
       .log(warning,"I have attached a block ",B);
     } else {
       .log(warning,"Could not request/attach block ",B, "::",R0,"/",R1," my position: (",X,",",Y,"), target (",I,",",J,")");
     }
 .
 +!get_block(B) :  // In case the agent is far away from B
     step(S) &
     not attached(_,_)
     <-
     !goto_nearest_neighbour(B);
     .wait(step(Step) & Step > S); //wait for the next step to continue
     !get_block(B);
 .
 +!get_block(B) : attached(_,_). // If I am already carrying a block B
