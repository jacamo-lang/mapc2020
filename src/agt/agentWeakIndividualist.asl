/**
 * The individualist acts alone, it will try to submit tasks that it can
 * do alone. The weak individualist can carry only one block, so it will
 * only accept such simple tasks.
 */

{ include("walking/common_walking.asl") }
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
+!performTask(T):
    task(T,DL,Y,REQs) &
    not desire(performTask(_)) &            // I am not committed
    (.length(REQs,LR) & LR == 1) &          // The task is a single block task
    .nth(0,REQs,REQ) & REQ = req(_,_,B) &   // Get the requirement (must be only one)
    task_shortest_path(BB,D) &
    step(S) & DL > (S + D)                  // deadline must be greater than step + shortest path
    <-
    !acceptTask(T);
    !getBlock(B);
    !setRightPosition(REQ);
    !submitTask(T);
.

// I've found a single block task
+task(T,DL,Y,REQs) :
    exploring &
    not desire(performTask(_)) &
    not accepted(_) &                     // I am not committed
    gps_map(_,_,taskboard,_) &            // I know a taskboard position
    gps_map(_,_,goal,_) &                 // I know a goal area position
    (.length(REQs,LR) & LR == 1) &        // The task is a single block task
    .nth(0,REQs,REQ) & REQ = req(_,_,B) & // Get the requirement (must be only one)
    BB = B &
    gps_map(_,_,BB,_) &                    // I know where to find B
    task_shortest_path(BB,D) &
    step(S) & DL > (S + D)                // deadline must be greater than step + shortest path
    <-
    .print("Performing task ",T);
    -exploring;
    !performTask(T);
.

/**
 * Accept a task (need to be close to a taskboard)
 */
+!acceptTask(T) :
    not accepted(_) &
    thing(_,_,taskboard,_)
    <-
    !do(accept(T),R0);
    if (R0 == success) {
      .print("Task ",T," accepted!");
    } else {
      .print("Could not accept task ",T);
    }
.
+!acceptTask(T) : // If somehow the taskboard is far away
    step(S) &
    not accepted(_)
    <-
    !gotoNearestNeighbour(taskboard);
    .wait(step(Step) & Step > S); //wait for the next step to continue
    !acceptTask(T);
.
+!acceptTask(T) : accepted(T). // If this task was already accepted, just skip.

/**
 * If I know the position of at least B, find the nearest and go there!
 */
+!gotoNearest(B) :
    myposition(X,Y) &
    gps_map(_,_,B,_) &
    nearest(B,XN,YN)
    <-
    .print("Going to nearest ",B," from (",X,",",Y,") to (",XN,",",YN,")");
    !goto(XN,YN);
.

/**
 * If I know the position of at least B, find the nearest neighbour
 * point and go there!
 */
+!gotoNearestNeighbour(B) :
    myposition(X,Y) &
    gps_map(_,_,B,_) &
    nearest(B,XN,YN) &
    nearest_neighbour(XN,YN,XT,YT)
    <-
    .print("Going to nearest neighbour of ",B,"(",XN,",",YN,") from (",X,",",Y,") to (",XT,",",YT,")");
    !goto(XT,YT);
.

+!getBlock(B) :
    myposition(X,Y) &
    not attached(_,_) &
    ((thing(I,J,dispenser,B) & directionIncrement(D,I,J)) | (thing(0,0,dispenser,B) & D = e))
    <-
    !do(request(D),R0);
    !do(attach(D),R1);
    if ((R0 == success) & (R1 == success)) {
      .print("I have attached a block ",B);
    } else {
      .print("Could not request/attach block ",B, "::",R0,"/",R1," my position: (",X,",",Y,"), target (",I,",",J,")");
    }
.
+!getBlock(B) :  // In case the agent is far away from B
    step(S) &
    not attached(_,_)
    <-
    !gotoNearestNeighbour(B);
    .wait(step(Step) & Step > S); //wait for the next step to continue
    !getBlock(B);
.
+!getBlock(B) : attached(_,_). // If I am already carrying a block B

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
      .print("Rotated ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
    } else {
      .print("Could not rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
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
      .print("Rotated ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
    } else {
      .print("Could not rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
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
        .print("Rotated ",B," (",I,",",J,") to (",NI,",",NJ,") dir: ccw");
    } else {
        .print("Could not rotate ",B," (",I,",",J,") to (",NI,",",NJ,") dir: ccw");
        .wait(step(Step) & Step > S); //wait for the next step to continue
        !do(rotate(cw),R1);
        if (R1 == success) {
          .print("Rotated ",B," (",I,",",J,") to (",NI,",",NJ,") dir: cw");
        } else {
          .print("Could not rotate ",B," (",I,",",J,") to (",NI,",",NJ,") dir: cw");
        }
    }
    !setRightPosition(REQ);
.
@setRightPositionFail[atomic]
+!setRightPosition(REQ) : // If other plans fail
    REQ = req(_,_,B)
    <-
    .print("No plans to rotate ",B," : ",REQ);
.

+!submitTask(T) : //thing(0,1,block,b1)
    attached(I,J) &
    directionIncrement(D,I,J) &
    task(T,DL,Y,REQs) &
    goal(0,0)         // I am over a goal
    <-
    .abolish(accepted(_));
    !do(submit(T),R0);
    if (R0 == success) {
      .print("I've submitted task ",T);
      +exploring;
    } else {
      .fail;
    }
.
+!submitTask(T) :  // In case the agent is far away from goal area
    step(S) &
    not goal(0,0)
    <-
    !gotoNearest(goal);
    .wait(step(Step) & Step > S); //wait for the next step to continue
    !submitTask(T);
.
-!submitTask(T) : // Fail on submitting task
    attached(I,J) &
    directionIncrement(D,I,J)
    <-
    .print("Fail on submitting block on (",I,",",J,") task ",T," : ",REQs," : ",R0);
    !do(detach(D),R1);
    if (R1 \== success) {
      .print("Fail on detaching block on ",D);
    }
.

/**
 * Just for debugging, stop the system if an unexpected error occurs
 */
-!P[code(C),code_src(S),code_line(L),error_msg(M)] :
    disabled //true
    <-
    .print("...");
    .print("...");
    .log(severe,"Fail on event '",C,"' of '",S,"' at line ",L,", Message: ",M);
    .print("...");
    .print("...");
    .stopMAS(0,1);
.
