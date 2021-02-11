/**
 * This library intends to solve the problem of going to the nearest
 * goal area and submitting the task T
 */

+!submit_task(T) : //thing(0,1,block,b1)
    task(T,DL,Y,REQs) &
    goal(0,0) &        // I am over a goal
    step(S)
    <-
    .abolish(accepted(_));
    !do(submit(T),R0);
    if (R0 == success) {
        .log(warning,"I've submitted task ",T);
        .concat("[",task(T,DL,Y,REQs),"]",STR);
        .save_stats("taskSubmitted",STR);
        .broadcast(tell,unwanted_task(T));
    } else {
        //A submit may fail for instance if another agent already submitted T
        .log(warning,"Fail on submitting ",T," ",R0);
        .concat("[",task(T,DL,Y,REQs),",",return(R0),",",step(S),"]",STR);
        .save_stats("submit_failed",STR);
    }
 .
 +!submit_task(T) :  // In case the agent is far away from goal area
     step(S) &
     not goal(0,0) &
     direction_increment(D,I,J) &
     goal(I,J)
     <-
     .log(warning,"Doing one step towards a goal area to submit ",T);
     !do(move(D),R);
     if (R == success) {
         !mapping(success,_,D);
     } else {
         .log(warning,"Fail on doing one step towards a goal area: ",D);
     }
     .wait(step(Step) & Step > S); //wait for the next step to continue
     .concat("[",task(T,DL,Y,REQs),",",return(R),",",step(S),"]",STR);
     .save_stats("one_step_fix",STR);
     !submit_task(T);
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
