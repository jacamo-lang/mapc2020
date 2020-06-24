/*
The individualist acts alone, it will try to submit tasks that it can do alone.
The weak individualist can carry only one block, so it will only accept such simple
tasks.
*/

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("goto.asl") }
{ include("action.asl") }

//goal_pos(I,J): I know where is a goal area
//disp_pos(I,J,B): There is a disposer of block B at I,J
//board_pos(I,J): There is a taskboard I,J
//active_task(T,X,Y,B): I am doing a task T, should deliver block B on X,Y
//looking_for(B): I am looking for block B
//carrying(D): I am carrying a block in direction D
//know_goal_loc: I know where I should take the blocks

routeplan_mindist(5).

directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).

goal_pos(21,-4).

//!doDummyExploration.
!startFakeExploration.

// Just to avoid plan not found
+!areyou.

// It is a fake exploration to pass near important things
+!startFakeExploration:
    true
    <-
    // During this path I will see 3 taskboards, 1 goal and depots for b1 and b2
    !goto(-2,-2); // An arbitrary point near the last
    !goto(10,-6); // Go to the depot in the absolute_position(55,67)
    !goto(20,-4); // Go to the goal in the absolute_position(65,65)
    !goto(32,-4); // An arbitrary point near other boards
    !goto(35,8); // An arbitrary point near other boards
    +exploring;
.

+lastAction(no_action):
    active_task(T,DL,Y,B)
    <-
    .drop_all_intentions;
    .print("back to fulfil the task");
    !!performTask(T,DL,Y,B);
.

+lastAction(no_action):
    exploring
    <-
    .print("Let's explore the area");
    !!doDummyExploration;
.

// Go to some random point and go back to the task board
+!doDummyExploration:
    exploring
    <-
    !goRandomly(6);
    !gotoNearestBoard;
    !doDummyExploration;
.

 // Go to some random point and go back to the task board
 +!performTask(T,DL,Y,B):
     true
     <-
     -+active_task(T,DL,Y,B);
     !gotoNearestBoard;
     !acceptTask(T);
     !gotoNearestDispenser(B);
     !getBlock(B);
     !gotoNearestGoal;
     !submitTask(T);
.

// Go to some random point around D far away from here (D should be even)
+!goRandomly(D):
  myposition(X,Y)
  <-
    TX = X + math.floor(math.random(D))-(D/2);
    TY = Y + math.floor(math.random(D))-(D/2);
    .print("Target: ",TX," ",TY);
    !goto(TX,TY);
    .

// I've found a single block task
+task(T,DL,Y,REQ) :
    not active_task(_,_,_,_) &      // I am not committed
    board_pos(_,_) &                // I know a taskboard position
    goal_pos(_,_) &                   // I know a goal area position
    (.length(REQ,LR) & LR == 1) &     // The task is a single block task
    (.nth(0,REQ,RR) & .literal(RR))   // The requirement is a valid literal
    <-
    .drop_all_intentions;
    -+RR;
    ?req(_,_,RQ);
    !performTask(T,DL,Y,RQ);
.

// If it knows at least one board, find the nearest and go there!
+!gotoNearestBoard :
    myposition(X,Y) & board_pos(_,_)
    <-
    -+nearestBoard(_,_,9999);
    for (board_pos(XP,YP)) {
      ?nearestBoard(_,_,ND);
      D = math.abs(XP-X) + math.abs(YP-Y);
      if (D < ND) {
        -+nearestBoard(XP,YP,D);
      }
    }
    ?nearestBoard(I,J,D0);
    if (D0 < 9999) {
      .print("Going to taskboard in ",I,",",J);
      !goto(I,J);
    } else {
      .print("No taskboard found!");
    }
.

+!gotoNearestBoard.

+!acceptTask(T) :
    true
    <-
    !do(accept(T),R0);
    if (R0 == success) {
      .print("Task ",T," accepted!");
    } else {
      .print("Could not accept task ",T);
    }
.

// If it knows at least one dispenser of block B, find the nearest and go there!
+!gotoNearestDispenser(B) :
    myposition(X,Y) & disp_pos(_,_,B)
    <-
    -+nearestDispenser(_,_,9999);
    for (disp_pos(XP,YP,B)) {
      ?nearestDispenser(_,_,ND);
      D = math.abs(XP-X) + math.abs(YP-Y);
      if (D < ND) {
        -+nearestDispenser(XP,YP,D);
      }
    }
    ?nearestDispenser(I,J,D0);
    if (D0 < 9999) {
      .print("Going to dispenser in ",I,",",J," for block ",B);
      !goto(I,J);
    } else {
      .print("No dispenser found!");
    }
.

// If it knows at least one board, find the nearest and go there!
+!gotoNearestGoal :
    myposition(X,Y) & goal_pos(_,_)
    <-
    -+nearestGoal(_,_,9999);
    for (goal_pos(XP,YP)) {
      ?nearestGoal(_,_,ND);
      D = math.abs(XP-X) + math.abs(YP-Y);
      if (D < ND) {
        -+nearestGoal(XP,YP,D);
      }
    }
    ?nearestGoal(I,J,D0);
    if (D0 < 9999) {
      .print("Going to goal in ",I,",",J);
      !goto(I,J);
    } else {
      .print("No goal found!");
    }
.

+!getBlock(B) :
    disp_pos(_,_,B) & myposition(X,Y) & thing(I,J,dispenser,B)
    <-
    if (directionIncrement(D,I,J)) {
      !do(request(D),R0);
      !do(attach(D),R1);
      if ((R0 == success) & (R1 == success)) {
        .print("I have attached a block ",B);
        +carrying(D);
      } else {
        .print("Could not request/attach block ",B, "::",R0,"/",R1);
        }
    } else {
      .print("Dispenser is too far!");
    }
.

+!submitTask(T) :
    carrying(D)
    <-
    .print("I've submitted");
    !do(submit(T),R0);
    if (R0 == success) {
      .print("I've submitted task ",T);
      -active_task(_,_,_,_);
      -carrying(_);
    } else {
      .print("Fail on submitting task ",T);
      !do(detach(D),R1);
    }
.

// Mapping goal positions
+map(A,X,Y,goal) :
    false
    <-
    +goal_pos(X,Y);
.

// Mapping dispenser positions
+map(A,X,Y,T) :
    (.nth(P,[b0,b1,b2,b3],T) & P >= 0)
    <-
    +disp_pos(X,Y,T);
.

// Mapping taskboard positions
+map(A,X,Y,taskboard) :
    true
    <-
    +board_pos(X,Y);
.
