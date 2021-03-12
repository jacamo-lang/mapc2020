/**
 * This library intends to solve the problem of going to a taskboard
 * and accepting a task.
 * It tries to go to the nearest taskboard doing a valid approaximation
 * to the taskboard and returns with the given task accpeted
 */

 /**
  * Accept a task (need to be close to a taskboard)
  */
@accept_task_close[atomic] // Should not accept more than one task at same time
+!accept_task(T) :
    not accepted(_) &
    task(T,DL,Y,REQs) &
    thing(TX,TY,taskboard,_) &
    distance(0,0,TX,TY,DIST) & DIST <= 2 &
    .my_name(ME) &
    step(S)
    <-
    !do(accept(T),R0);
    if (R0 == success) {
        .log(warning,"Task ",T," accepted!");
        ?accepted(LT);
        .concat("[",task(T,DL,Y,REQs),",",accepted(LT),",",step(S),"]",STR);
        .save_stats("taskAccepted",STR);
    } else {
        .log(warning,"Could not accept task ",T);
        .concat("[",task(T,DL,Y,REQs),",",step(S),"]",STR);
        .save_stats("errorOnAccept",STR);
        .fail;
    }
.
 /**
  * If it is far from the taskboard, first get closer
  */
+!accept_task(T) :
    myposition(X,Y) &
    step(S) &
    not accepted(_)
    <-
    //.log(warning,"Accepting ",T," : ",myposition(X,Y));
    !goto_nearest(taskboard);
    .wait(step(Step) & Step > S); //wait for the next step to continue
    !accept_task(T);
.
 /**
  * If this task was already accepted, just skip.
  */
+!accept_task(T) : accepted(T).

-!accept_task(T)
    <-
    .log(warning,"Could not accept ",T);
.
