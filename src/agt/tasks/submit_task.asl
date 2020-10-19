/**
 * This library intends to solve the problem of going to the nearest
 * goal area and submitting the task T
 */

+!submit_task(T) : //thing(0,1,block,b1)
    task(T,DL,Y,REQs) &
    goal(0,0)         // I am over a goal
    <-
    .abolish(accepted(_));
    !do(submit(T),R0);
    if (R0 == success) {
        .log(warning,"I've submitted task ",T);    
        .concat("[",task(T,DL,Y,REQs),"]",STR);
        .save_stats("taskSubmitted",STR);
        .broadcast(tell,unwanted_task(T));
    } else {
        .fail;
    }
 .
 +!submit_task(T) :  // In case the agent is far away from goal area
     step(S) &
     not goal(0,0)
     <-
     .log(warning,"Going to a goal to submit ",T);
     !goto_nearest(goal);
     .wait(step(Step) & Step > S); //wait for the next step to continue
     !submit_task(T);
 .
+!submit_task(T) // Should not occur
    <-
    .log(warning,"Could not find a proper plan to ",submit_task(T));
.

/**
 * A submit may fail for instance if another agent already submitted T
 */
-!submit_task(T) // Fail on submitting task
    <-
    .log(warning,"Fail on submitting ",T);
.
