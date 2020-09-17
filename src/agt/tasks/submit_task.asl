/**
 * This library intends to solve the problem of going to a specific dispenser
 * and attaching block(s)
 * It tries to go to the nearest dispenser of B doing a valid approximation
 * to the dispenser to then attach the specifc block
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
     .findall(attached(I,J),attached(I,J),LA) &
     task(T,DL,Y,REQs) &
     not goal(0,0)
     <-
     .log(warning,"Going to a goal to submit ",T," : ",REQs,", attached: ",LA);
     !gotoNearest(goal);
     .wait(step(Step) & Step > S); //wait for the next step to continue
     !submitTask(T);
 .

 /**
  *A task submition may fail for instance if another agent already submitted
  *this task
  */
 -!submitTask(T) : // Fail on submitting task
    .findall(attached(I,J),attached(I,J),LA) &
     task(T,DL,Y,REQs)
     <-
     .log(warning,"Fail on submitting ",T," : ",REQs,", attached: ",LA);
 .
