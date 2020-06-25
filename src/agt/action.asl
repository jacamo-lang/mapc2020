+!do( A,R ) : not step(_)  // not started yet
    <- .wait( {+step(_)} );
       !do(A,R)
    .

+!do( A,R ) : step(S)
    <- action(A);
       //.print("Doing ",A," at step ",S);
       // wait next step
       .wait( step(NS)&NS>S );
       if (lastActionResult(failed_random)) {
         // try again
         .print(A," randomly failed, trying again ...");
         !do(A,R);
       } else {
         ?lastActionResult(R);
       }
    .
