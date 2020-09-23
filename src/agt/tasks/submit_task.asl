/**
 * This library intends to solve the problem of going to the nearest
 * goal area and submitting the task T
 */

+!submitTask(T) : //thing(0,1,block,b1)
    attached(I,J) &
    directionIncrement(D,I,J) &
    .findall(attached(I,J),attached(I,J),LA) &
    task(T,DL,Y,REQs) &
    goal(0,0)         // I am over a goal
    <-
    .abolish(accepted(_));
    !do(submit(T),R0);
    if (R0 == success) {
        .log(warning,"I've submitted task ",T," : ",REQs,", attached: ",LA);
    } else {
        .fail;
    }
 .
 +!submitTask(T) :  // In case the agent is far away from goal area
     step(S) &
     not goal(0,0)
     <-
     .log(warning,"Going to a goal to submit ",T);
     !gotoNearest(goal);
     .wait(step(Step) & Step > S); //wait for the next step to continue
     !submitTask(T);
     .broadcast(tell,unwanted_task(T));
 .
+!submitTask(T) // Should not occur
    <-
    .log(warning,"Could not find a proper plan to ",submitTask(T));
.

/**
 * A submit may fail for instance if another agent already submitted T
 */
-!submitTask(T) // Fail on submitting task
    <-
    .log(warning,"Fail on submitting ",T);
.
