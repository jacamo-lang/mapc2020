/**
 * This library intends to solve the problem of going to the nearest
 * goal area and submitting the task T
 */

 +!submit_task(T) : //thing(0,1,block,b1)
     task(T,DL,Y,REQs) &
     step(S) &
     S > DL
     <-
     +status(tardy);
  .
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
        .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,block,BB),L);
        .findall(t(I,J,T,TT),thing(I,J,T,TT),LT);
        .findall(o(I,J),obstacle(I,J),LO);
        .concat("[",task(T,DL,Y,REQs),",",return(R0),",",step(S),",",a(L),",",t(LT),",",o(LO),"]",STR);
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
     .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,block,BB),L);
     .findall(t(I,J,T,TT),thing(I,J,T,TT),LT);
     .findall(o(I,J),obstacle(I,J),LO);
     .concat("[",task(T,DL,Y,REQs),",",return(R0),",",step(S),",",a(L),",",t(LT),",",o(LO),",",direction_increment(D,I,J),"]",STR);
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
-!submit_task(T): // It is probably due fail on goto_nearest
    task(T,DL,Y,REQs) &
    step(S)
    <-
    !do(skip,R);
    .wait(step(Step) & Step > S); //wait for the next step to continue
    //A submit may fail for instance if another agent already submitted T
    .log(warning,"Retrying to submit ",T);
    .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,block,BB),L);
    .findall(t(I,J,Thing,TT),thing(I,J,Thing,TT),LT);
    .findall(o(I,J),obstacle(I,J),LO);
    ?nearest(goal,X1,Y1);
    ?nearest_walkable(goal,X2,Y2);
    .concat("[",task(T,DL,Y,REQs),",",step(S),",",a(L),",",t(LT),",",o(LO),",",nearest(goal,X1,Y1),",",nearest_walkable(goal,X2,Y2),"]",STR);
    .save_stats("submit_retry",STR);
    !submit_task(T);
.
