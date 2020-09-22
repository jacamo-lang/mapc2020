/**
 * This library intends to solve the problem of going to a taskboard
 * and accepting a task.
 * It tries to go to the nearest taskboard doing a valid approaximation
 * to the taskboard and returns with the given task accpeted
 */

 /**
  * Accept a task (need to be close to a taskboard)
  */
@acceptTask_close[atomic] // Should not accept more than one task at same time
 +!acceptTask(T) :
     not accepted(_) &
     thing(TX,TY,taskboard,_) &
     distance(0,0,TX,TY,DIST) & DIST <= 1
     <-
     !do(accept(T),R0);
     if (R0 == success) {
       .log(warning,"Task ",T," accepted!");
     } else {
       .log(warning,"Could not accept task ",T);
       .fail;
     }
 .
 /**
  * If it is far from the taskboard, first get closer
  */
 +!acceptTask(T) :
     myposition(X,Y) &
     step(S) &
     not accepted(_)
     <-
     .log(warning,"Accepting ",T," : ",myposition(X,Y));
     !gotoNearestNeighbour(taskboard);
     .wait(step(Step) & Step > S); //wait for the next step to continue
     !acceptTask(T);
 .
 /**
  * If this task was already accepted, just skip.
  */
 +!acceptTask(T) : accepted(T).
-!acceptTask(T)
    <- 
    .log(warning,"Could not accept ",T);
.
