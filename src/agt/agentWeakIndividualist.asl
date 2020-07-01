/*
The individualist acts alone, it will try to submit tasks that it can do alone.
The weak individualist can carry only one block, so it will only accept such simple
tasks.
*/

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("goto.asl") }
{ include("action.asl") }

//Beliefs generated by the environment
//map(_,I,J,goal): The terrain I,J is a goal spot
//map(_,I,J,B): There is a disposer of block B at I,J in which (.nth(P,[b0,b1,b2,b3],B) & P >= 0)
//map(_,I,J,taskboard): There is a taskboard I,J
//accepted(T): I am doing a task T
//attached(I,J): I have a block attached on I,J

// Return on D euclidean distance between (X1,Y1) and (X2,Y2)
distance(X1,Y1,X2,Y2,D) :- D = math.abs(X2-X1) + math.abs(Y2-Y1).

// Return the nearest specific thing in the map
nearest(T,X,Y) :-
    myposition(X1,Y1) &
    .findall(p(D,X2,Y2),map(_,X2,Y2,T) & distance(X1,Y1,X2,Y2,D),FL) &
    .min(FL,p(_,X,Y)).

// Return the nearest adjacent position, good to do an approach
nearest_neighbour(XP,YP,X,Y) :-
    myposition(X1,Y1) &
    .findall(p(D,X2,Y2),
      directionIncrement(_,I,J) & X2 = XP+I & Y2 = YP + J &
      distance(X1,Y1,X2,Y2,D), FL
    ) & .min(FL,p(_,X,Y)).

// Used to determine the goal center area
// It was created due to errors on submitting, but is probably useless
goalShape(0, -4).
goalShape(0,  4).
goalShape(-4,  0).
goalShape(4,  0).

// Use route planner for distances greater than 5
routeplan_mindist(5).

// For rotation unifies the next clock dir or counterwise dir
// e.g.: clockDir(0,1,NI,NJ) which is 3 o'clock gives 6 o'clock (cw dir)
// e.g.: clockDir(PI,PJ,0,-1) which is 12 o'clock gives 9 o'clock (ccw dir)
clockDir(0,-1,1,0).   // 12 o'clock -> 3  o'clock
clockDir(1,0,0,1).    // 3  o'clock -> 6  o'clock
clockDir(0,1,-1,0).   // 6  o'clock -> 9  o'clock
clockDir(-1,0,0,-1).  // 9  o'clock -> 12 o'clock

// Spiral walk setup
nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).
direction(w,1).
lastDirection(w).
size(1).

// Just to avoid plan not found
+!areyou.

/**
 * Spiral walk exploration
 */
 +!explore(X): // Preventing collisions
    lastDirection(LD) &
     (thing(I,J,entity,_) | obstacle(I,J)) &
     direction(D,N) &
     directionIncrement(N,I,J) &
     size(S)
     <-
     -+lastDirection(ND);
     -+direction(ND,S);
     -+size(S+1);
     !explore(X);
.
+!explore(X):
    lastDirection(LD) &
    direction(D,N) &
    nextDirection(D,ND) &
    size(S)
    <-
    !do(move(D),R);
    if (R==success) {
      !mapping(D);
      -+lastDirection(D);
      if (N==1) {
        -+direction(ND,S+1);
        -+size(S+1);
      } else {
        -+direction(D,N-1);
      }
    } else {
      -+lastDirection(ND);
      -+direction(ND,S);
      -+size(S+1);
    }
.

/**
 * If something disturbs me but I am performing a task,
 * let's go back to this or just explore
 *
 * The agent is maybe trying to do multiple rotations in
 * order to find the right position, in this case,
 * do not interrupt!
 */
+lastAction(rotate). // Don't interrupt rotates
@lastActionPerformTask[atomic]
+lastAction(X):
    not .intend(_) &
    accepted(T) &
    task(T,DL,Y,RR)
    <-
    .print("back to fulfil the task");
    !performTask(T,DL,Y,RR);
.
@lastActionExplore[atomic]
+lastAction(X):
    not .intend(_)
    <-
    .print("Let's explore the area");
    !explore(X);
.

 // Go to some random point and go back to the task board
 @performTask[atomic]
 +!performTask(T,DL,Y,R):
     not desire(performTask(_,_,_,_))
     <-
     R = req(_,_,B);
     !gotoNearestNeighbour(taskboard);
     !acceptTask(T);
     !gotoNearestNeighbour(B);
     !getBlock(B);
     !setRightPosition(R);
     !gotoNearest(goal);
     !gotoNearestNeighbour(goalCenter);
     !submitTask(T);
.

// Go to some random point around D far away from here (D should be even)
+!goRandomly:
  myposition(X,Y) &
  directions(LDIRECTIONS) &
  .nth(math.floor(math.random(4)),LDIRECTIONS,DR) &
  directionIncrement(DR,XINC,YINC)
  <-
    .print("Randomly going do ",DR," (",X+XINC,",",Y+YINC,")");
    !goto(X+XINC,Y+YINC);
.

// I've found a single block task
+task(T,DL,Y,REQs) :
    not accepted(_) &                 // I am not committed
    step(S) &
    DL > S                            // I still have time
    map(_,_,_,taskboard) &            // I know a taskboard position
    map(_,_,_,goal) &                 // I know a goal area position
    (.length(REQs,LR) & LR == 1) &    // The task is a single block task
    .nth(0,REQs,REQ) &
    REQ = req(_,_,B) &
    map(_,_,_,B)                      // I know where to find B
    <-
    .succeed_goal(explore(_));
    !performTask(T,DL,Y,REQ);
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
    not accepted(_)
    <-
    !gotoNearestNeighbour(taskboard);
.
+!acceptTask(T) : accepted(T). // If this task was already accepted, just skip.

/**
 * If I know the position of at least B, find the nearest and go there!
 */
+!gotoNearest(B) :
    myposition(X,Y) &
    map(_,_,_,B) &
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
    map(_,_,_,B) &
    nearest(B,XN,YN) &
    nearest_neighbour(XN,YN,XT,YT)
    <-
    .print("Going to nearest neighbour of ",B," from (",X,",",Y,") to (",XT,",",YT,")");
    !goto(XT,YT);
.

+!getBlock(B) :
    thing(I,J,dispenser,B) &
    directionIncrement(D,I,J) &
    not attached(_,_)
    <-
    !do(request(D),R0);
    !do(attach(D),R1);
    if ((R0 == success) & (R1 == success)) {
      .print("I have attached a block ",B);
    } else {
      .print("Could not request/attach block ",B, "::",R0,"/",R1);
    }
.
+!getBlock(B) :  // In case the agent is far away from B
    not attached(_,_)
    <-
    !gotoNearestNeighbour(B);
.
+!getBlock(B) : attached(_,_). // If I am already carrying a block B

+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(I,J,B) // no rotation is necessary
.
+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(RI,RJ,B) &
    clockDir(I,J,RI,RJ) // if it is necessary 1 clockwise rotation
    <-
    !do(rotate(cw),R);
    if (R == success) {
      .print("Rotated ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
    } else {
      .print("Could not rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");
    }
    !setRightPosition(REQ);
.
+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(_,_,B) &
    clockDir(NI,NJ,I,J) // rotate counterclockwise by default
    <-
    !do(rotate(ccw),R);
    if (R == success) {
      .print("Rotated ",B," (",I,",",J,") to  (",NI,",",NJ,") dir: ccw");
    } else {
      .print("Could not rotate ",B," (",I,",",J,") to (",NI,",",NJ,") dir: ccw");
    }
    !setRightPosition(REQ);
.
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
    .print("I've submitted");
    !do(submit(T),R0);
    if (R0 == success) {
      .print("I've submitted task ",T);
      .abolish(accepted(_));
    } else {
      .print("Fail on submitting block on (",I,",",J,") task ",T," : ",REQs," : ",R0);
      !do(detach(D),R1);
    }
.

// Mapping goal positions
+map(N,X,Y,goal) :
    goalShape(I,J) &
    map(_,X+I,Y+J,goal) &
    .my_name(ME)
    <-
    -+map(ME,X+(I/2),Y+(J/2),goalCenter);
.
