/*
The individualist acts alone, it will try to submit tasks that it can do alone.
The weak individualist can carry only one block, so it will only accept such simple
tasks.
*/

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("goto.asl") }
{ include("action.asl") }

//map(_,I,J,goal): The terrain I,J is a goal spot
//map(_,I,J,B): There is a disposer of block B at I,J in which (.nth(P,[b0,b1,b2,b3],B) & P >= 0)
//map(_,I,J,taskboard): There is a taskboard I,J
//accepted(T): I am doing a task T
//carrying(D): I am carrying a block in direction D

// Return on D euclidean distance between (X1,Y1) and (X2,Y2)
distance(X1,Y1,X2,Y2,D) :- D = math.abs(X2-X1) + math.abs(Y2-Y1).

// Return the nearest specific thing in the map
nearest(T,X,Y) :-
    myposition(X1,Y1) &
    .findall(p(D,X2,Y2),map(_,X2,Y2,T) & distance(X1,Y1,X2,Y2,D),FL) &
    .sort(FL,[H|R]) & H =.. A & .nth(2,A,N) & .nth(1,N,X) & .nth(2,N,Y).

goalShape(0, -4).
goalShape(0,  4).
goalShape(-4,  0).
goalShape(4,  0).

routeplan_mindist(5).

// Just to avoid plan not found
+!areyou.

// If something disturbs me but I am performing a task, let's go back to this
+lastAction(no_action):
    accepted(T) &
    task(T,DL,Y,RR) &
    not .intend(_) &
    not skipSteps
    <-
    .print("back to fulfil the task");
    -+RR;
    ?req(_,_,RQ);
    !performTask(T,DL,Y,RQ);
.

// If somehow I don't know what to do, just explore
+lastAction(no_action):
    not .intend(_) &
    not skipSteps
    <-
    .print("Let's explore the area");
    !!doDummyExploration;
.

// Go to some random point and go back to the task board
+!doDummyExploration:
    true
    <-
    // During this path I will see 3 taskboards, 1 goal and depots for b1 and b2
    !goto(-2,-2); // An arbitrary point near the last
    !goto(10,-6); // Go to the depot in the absolute_position(55,67)
    !goto(20,-4); // Go to the goal in the absolute_position(65,65)
    !goto(32,-4); // An arbitrary point near other boards
    !goto(35,8); // An arbitrary point near other boards
    //!goRandomly;
    !gotoNearest(takboard);
    !doDummyExploration;
.

 // Go to some random point and go back to the task board
 +!performTask(T,DL,Y,B):
     not desire(performTask(_,_,_,_))
     <-
     !gotoNearest(taskboard);
     !acceptTask(T);
     !gotoNearest(B);
     !getBlock(B);
     !gotoNearestGoal;
     !submitTask(T);
.

// Go to some random point around D far away from here (D should be even)
+!goRandomly:
  directions(LDIRECTIONS)
  <-
    .nth(math.floor(math.random(4)),LDIRECTIONS,DR);
    directionIncrement(DR,XINC,YINC);
    .print("Randomly going do ",DR," (",X+XINC,",",Y+YINC,")");
    !goto(X+XINC,Y+YINC)
    .

// I've found a single block task
+task(T,DL,Y,REQ) :
    not accepted(_) &               // I am not committed
    map(_,_,_,taskboard) &            // I know a taskboard position
    goalCenter(_,_) &                 // I know a goal area position
    (.length(REQ,LR) & LR == 1) &     // The task is a single block task
    (.nth(0,REQ,RR) & .literal(RR))   // The requirement is a valid literal
    <-
    .succeed_goal(doDummyExploration);
    -+RR;
    ?req(_,_,RQ);
    !performTask(T,DL,Y,RQ);
.

// If this task was already accepted, just skip.
+!acceptTask(T) : accepted(T).

// Accept a task (need to be close to a taskboard)
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

// If I know the position of at least B, find the nearest and go there!
+!gotoNearest(B) :
    myposition(X,Y) & map(_,_,_,B) & nearest(B,XN,YN)
    <-
    .print("Going from (",X,",",Y,") to in (",XN,",",YN,")");
    !goByBestApproach(XN,YN);
.

+!goByBestApproach(I,J) :
    myposition(X,Y)
    <-
    ?distance(I,J,X,Y,D);
    -+bestApproach(I,J,D);
    for (directionIncrement(_,II,JJ)) {
      ?bestApproach(_,_,D0);
      ?distance(I-II,J-JJ,X,Y,D1);
      if (D1 < D0) {
        -+bestApproach(I-II,J-JJ,D1);
      }
    }
    ?bestApproach(BI,BJ,D1);
    !goto(BI,BJ);
.

// It is supposed to keep exploring if I don't know where is a B
+!gotoNearest(B).

// If it knows at least one board, find the nearest and go there!
+!gotoNearestGoal :
    myposition(X,Y) & goalCenter(_,_)
    <-
    -+nearestGoal(_,_,9999);
    for (goalCenter(XP,YP)) {
      ?nearestGoal(_,_,ND);
      ?distance(XP,YP,X,Y,D);
      if (D < ND) {
        -+nearestGoal(XP,YP,D);
      }
    }
    ?nearestGoal(I,J,D0);
    if (D0 < 9999) {
      .print("Going to goal in ",I-1,",",J);
      !goto(I,J);
    } else {
      .print("No goal found!");
    }
.

+!getBlock(B) :
    myposition(X,Y) &
    thing(XT,YT,dispenser,B) &
    directionIncrement(D,I,J) &
    (XT == X + I & YT == Y + J)
    <-
    !do(request(D),R0);
    !do(attach(D),R1);
    if ((R0 == success) & (R1 == success)) {
      .print("I have attached a block ",B);
      +carrying(D);
    } else {
      .print("Could not request/attach block ",B, "::",R0,"/",R1);
      !goRandomly;
      !getBlock(B);
    }
.

+!submitTask(T) :
    carrying(D)
    <-
    .print("I've submitted");
    !do(submit(T),R0);
    if (R0 == success) {
      .print("I've submitted task ",T);
      .abolish(accepted(_));
      -carrying(_);
    } else {
      .print("Fail on submitting task ",T);
      !do(detach(D),R1);
    }
.

// Mapping goal positions
+map(_,X,Y,goal) :
    goalShape(I,J) & map(_,X+I,Y+J,goal)
    <-
    -+goalCenter(X+(I/2),Y+(J/2));
.
