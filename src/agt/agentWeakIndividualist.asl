/**
 * The individualist acts alone, it will try to submit tasks that it can
 * do alone. The weak individualist can carry only one block, so it will
 * only accept such simple tasks.
 */

{ include("walking/common_walking.asl") }
{ include("tasks/common_task.asl") }
{ include("tasks/accept_task.asl") }
{ include("tasks/get_block.asl") }
{ include("tasks/drop_block.asl") }
{ include("tasks/submit_task.asl") }
{ include("walking/goto_A_star.asl") }
{ include("agentBase.asl") }
//{ include("exploration/goal_center.asl") }

//Beliefs generated by the environment
//gps_map(I,J,goal,_): The terrain I,J is a goal spot
//gps_map(I,J,B,_): There is a disposer of block B at I,J in which (.nth(P,[b0,b1,b2,b3],B) & P >= 0)
//gps_map(,I,J,taskboard,_): There is a taskboard I,J
//accepted(T): I am doing a task T
//attached(I,J): I have a block attached on I,J

// Use route planner for distances greater than 5
routeplan_mindist(5).

// For rotation
rotate(cw,0,-1,1,0).  // 12 o'clock -> 3  o'clock
rotate(cw,1,0,0,1).   // 3  o'clock -> 6  o'clock
rotate(cw,0,1,-1,0).  // 6  o'clock -> 9  o'clock
rotate(cw,-1,0,0,-1). // 9  o'clock -> 12 o'clock
rotate(ccw,1,0,0,-1). // 3  o'clock -> 12  o'clock
rotate(ccw,0,1,1,0).  // 6  o'clock -> 3  o'clock
rotate(ccw,-1,0,1,0). // 9  o'clock -> 6 o'clock
rotate(ccw,0,-1,-1,0).// 12  o'clock -> 9 o'clock

// Go to some random point and go back to the task board
+!performTask(T) : // Discard to expire tasks
    task(T,DL,Y,REQs) &
    .length(REQs) == 1 &        // The task is a single block task
    .nth(0,REQs,REQ) & REQ = req(_,_,B) &   // Get the requirement (must be only one)
    task_shortest_path(B,D) &
    step(S) & DL <= (S + D)        // deadline must be greater than step + shortest path
    <-
    +unwanted_task(T);
.
+!performTask(T) :
    not accepted(_) &                       // I am not committed
    task(T,DL,Y,REQs) &
    not .intend(performTask(_)) &
    .length(REQs) == 1
    <-
    .log(warning,"Performing task ",T);
    
    -exploring;

    !acceptTask(T);

    .nth(0,REQs,REQ);
    REQ = req(_,_,B);
    !getBlock(B);

    !setRightPosition(REQ);

    !submitTask(T);

    // In case the submition did not succeed
    !drop_all_blocks;

    //No matter if it succeed or failed, it is supposed to be ready for another task
    +exploring;
.
+!performTask(T)
    <-
    .log(warning,"Could not perform ",T);
.

// I've found a single block task
+task(T,DL,Y,REQs) :
    not unwanted_task(T) &
    .length(REQs) \== 1 // The task is NOT a single block task
    <-
    +unwanted_task(T);
.

+task(T,DL,Y,REQs) :
    exploring &
    not accepted(_) &                     // I am not committed
    not unwanted_task(T) &
    .length(REQs) == 1 &
    known_requirements(T)
    <-
    .log(warning,"I am able to perform ",T);
    !performTask(T);
.

@setRightPositionNoRotate[atomic]
+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(I,J,B) // no rotation is necessary
.
@setRightPositionCWRotate_1rotation[atomic]
+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(RI,RJ,B) &
    rotate(cw,I,J,RI,RJ) // if it is necessary 1 clockwise rotation
    <-
    !do(rotate(cw),R);
    if (R == success) {
      .log(warning,"Rotated ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
    } else {
      .log(warning,"Could not rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
    }
    !setRightPosition(REQ);
.
@setRightPositionCCWRotate_1rotation[atomic]
+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(RI,RJ,B) &
    rotate(ccw,I,J,RI,RJ) // if it is necessary 1 counterclockwise rotation
    <-
    !do(rotate(cw),R);
    if (R == success) {
      .log(warning,"Rotated ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
    } else {
      .log(warning,"Could not rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
    }
    !setRightPosition(REQ);
.
@setRightPositionCCWRotate[atomic]
+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(_,_,B) &
    rotate(ccw,NI,NJ,I,J) & // rotate counterclockwise by default
    step(S)
    <-
    !do(rotate(ccw),R0);
    if (R0 == success) {
        .log(warning,"Rotated ",B," (",I,",",J,") to (",NI,",",NJ,") dir: ccw");
    } else {
        .log(warning,"Could not rotate ",B," (",I,",",J,") to (",NI,",",NJ,") dir: ccw");
        .wait(step(Step) & Step > S); //wait for the next step to continue
        !do(rotate(cw),R1);
        if (R1 == success) {
          .log(warning,"Rotated ",B," (",I,",",J,") to (",NI,",",NJ,") dir: cw");
        } else {
          .log(warning,"Could not rotate ",B," (",I,",",J,") to (",NI,",",NJ,") dir: cw");
        }
    }
    !setRightPosition(REQ);
.
@setRightPositionFail[atomic]
+!setRightPosition(REQ) : // If other plans fail
    REQ = req(_,_,B)
    <-
    .log(warning,"No plans to rotate ",B," : ",REQ);
.

/**
 * For debugging if an unexpected error occurs
 */
-!P[code(C),code_src(S),code_line(L),error_msg(M)] :
    true//disabled //
    <-
    .log(warning,"...");
    .log(warning,"...");
    .log(severe,"Fail on event '",C,"' of '",S,"' at line ",L,", Message: ",M);
    .log(warning,"...");
    .log(warning,"...");
    //.stopMAS(0,1);
.
