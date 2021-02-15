+!do(A,R) :
    not step(_) // not started yet
    <-
    .wait( {+step(_)} );
    !do(A,R);
.

/**
 * It is the first !do/2 of the match
 */
+!do(A,R) :
    not common_step(_,_) &
    step(S)
    <-
    resetStepCounter(S);
    !do(A,R);
.

/**
 * This agent is the first (or one of the firsts) to trigger !do/2
 * so, let us update the clock
 */
+!do(A,R) :
    step(S) &
    common_step(CS,_) &
    S > CS
    <-
    incStepCounter(CS); // I am the first to realise the clock has changed
    !do(A,R);
.

/**
 * The agent is going to make its action for this step but the agent is
 * busy doing other(s) intention(s), so before !do/2 let us wait as long
 * as we can in order to finish the other(s) intention(s).
 *
 * 2 from the max 4 seconds is being used since because of losses due to latency
 * and synchronization
 */
+!do(A,R):
    .findall(I,.intention(I,running),L) & .length(L) > 1 &
    common_step(_,T0) & system.time - T0 < 3000
    <-
    .log(warning,"Postponing action. Current Intentions: ",L);

    /**
     * It means the agent is spending too much time doing other actions which may be
     * problematic because it may lose steps and have no enough time for other actions.
     */
    if (system.time - T0 > 2800) {
        .concat("[",current_intentions(L),"]",STR);
        .save_stats("excessive_delay",STR);
    }

    .wait(200);
    !do(A,R);
.

/**
 * Effectively !do/2 something on the simulator/environment
 */
+!do(A,R)
    <-
    .wait( step(S) & common_step(S,_) ); // wait to be synchronized with common clock
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
    common_step(CS,_) &
    S > CS
    <-
    incStepCounter(CS); // I am the first to realise the clock has changed
    !just_do(A);
.

+!just_do(A)
    <-
    .wait( step(S) & common_step(S,_) ); // wait to be synchronized with common clock

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
