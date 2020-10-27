+!do(A,R) : 
    not step(_) // not started yet
    <- 
    .wait( {+step(_)} );
    !do(A,R);
.

+!do(A,R) : 
    not common_step(_) &
    step(S)
    <- 
    resetStepCounter(S);
    !do(A,R);
.
  
+!do(A,R) : 
    step(S) &
    common_step(CS) &
    S > CS
    <- 
    incStepCounter(CS); // I am the first to realise the clock has changed
    !do(A,R);
.

+!do(A,R)  
    <-
    .wait( step(S) & common_step(S) ); // wait to be synchronized with common clock
    ?step(AS);
    
    action(A);
    
    .wait( step(NS) & NS > AS ); // wait next step
    if (lastActionResult(failed_random)) {
        .log(warning,A," randomly failed, trying again ...");
        !do(A,R);
    } else {
        ?lastActionResult(R);
    }
.

+!just_do(A):  
    step(S) &
    common_step(CS) &
    S > CS
    <- 
    incStepCounter(CS); // I am the first to realise the clock has changed
    !just_do(A);
.

+!just_do(A)
    <-
    .wait( step(S) & common_step(S) ); // wait to be synchronized with common clock
    
    action(A);
.


+!wait_event(E) : E.
+!wait_event(E) :
    step(S)
    <-
    !do(skip,_);
    .wait( (step(Step) & Step > S) ); //wait for the next step to continue
    !wait_event(E);
.

