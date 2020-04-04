+!do( A ) : not step(_)  // not started yet
    <- .wait( {+step(_)} );
       !do(A)
    .

+!do( A ) : step(S)
    <- action(A);
       //.print("Doing ",A," at step ",S);
       // wait next step
       .wait( step(S+1) );
       if (lastActionResult(failed_random)) {
         // try again
         .print(A," randomly failed, trying again ...");
         !do(A);
       }
    .
