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
//attached(I,J): I have a block attached on I,J

// Return on D euclidean distance between (X1,Y1) and (X2,Y2)
distance(X1,Y1,X2,Y2,D) :- D = math.abs(X2-X1) + math.abs(Y2-Y1).

// Return the nearest specific thing in the map
nearest(T,X,Y) :-
    myposition(X1,Y1) &
    .findall(p(D,X2,Y2),map(_,X2,Y2,T) & distance(X1,Y1,X2,Y2,D),FL) &
    .sort(FL,[H|R]) & H =.. A & .nth(2,A,N) & .nth(1,N,X) & .nth(2,N,Y).

// Return the nearest adjacent position, good to do an approach
nearest_neighbour(XP,YP,X,Y) :-
    myposition(X1,Y1) &
    .findall(p(D,X2,Y2),
      directionIncrement(_,I,J) & X2 = XP+I & Y2 = YP + J &
      distance(X1,Y1,X2,Y2,D), FL
    ) & .sort(FL,[H|R]) & H =.. A & .nth(2,A,N) & .nth(1,N,X) &
    .nth(2,N,Y).

// Used to determine the goal center area
// It was created due to errors on submitting, but is probably useless
goalShape(0, -4).
goalShape(0,  4).
goalShape(-4,  0).
goalShape(4,  0).

// Use route planner for distances greater than 5
routeplan_mindist(5).

// For rotation unifies the next clock dir or counterwise dir
// e.g.: clockDir(0,1,NI,NJ) which is 6 o'clock gives 3 o'clock
// e.g.: clockDir(PI,PJ,0,-1) which is 12 o'clock gives 3 o'clock
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

// FAKE EXPLORATION just for tests!!!
+!explore(fakeExploration):
    true
    <-
    // During this path I will see 3 taskboards, 1 goal and depots for b1 and b2
    !goto(-2,-2); // An arbitrary point near the last
    !goto(10,-6); // Go to the depot in the absolute_position(55,67)
    //!goto(20,-4); // Go to the goal in the absolute_position(65,65)
    !goto(35,8); // An arbitrary point near other boards
    !gotoNearest(takboard);
    !explore(fakeExploration);
.

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
     !gotoNearest(taskboard);
     !acceptTask(T);
     !gotoNearest(B);
     !getBlock(B);
     !setRightPosition(R);
     !gotoNearest(goal);
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
+task(T,DL,Y,REQ) :
    not accepted(_) &                 // I am not committed
    map(_,_,_,taskboard) &            // I know a taskboard position
    map(_,_,_,goal) &           // I know a goal area position
    (.length(REQ,LR) & LR == 1) &     // The task is a single block task
    (.nth(0,REQ,RR) & .literal(RR))   // The requirement is a valid literal
    <-
    .succeed_goal(explore(_));
    !performTask(T,DL,Y,RR);
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

/**
 * If I know the position of at least goalCenter, find the nearest and go there!
 */
+!gotoNearest(goalCenter) :
    B = goalCenter &
    myposition(X,Y) &
    map(_,_,_,B) &
    nearest(B,XN,YN)
    <-
    .print("Going from (",X,",",Y,") to (",XN-1,",",YN,")");
    !goto(XN,YN);
.

/**
 * If I know the position of at least B, find the nearest neighbour
 * point and go there!
 */
+!gotoNearest(B) :
    myposition(X,Y) &
    map(_,_,_,B) &
    nearest(B,XN,YN) &
    nearest_neighbour(XN,YN,XT,YT)
    <-
    .print("Going to nearest ",B," from (",X,",",Y,") to (",XT,",",YT,")");
    !goto(XT,YT);
.

// It is supposed to keep exploring if I don't know where is a B
+!gotoNearest(B).

+!getBlock(B) :
    thing(I,J,dispenser,B) &
    directionIncrement(D,I,J)
    <-
    !do(request(D),R0);
    !do(attach(D),R1);
    if ((R0 == success) & (R1 == success)) {
      .print("I have attached a block ",B);
    } else {
      .print("Could not request/attach block ",B, "::",R0,"/",R1);
    }
.

+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(RI,RJ,B) &
    ((I == RI) & (J == RJ)) // no rotation is necessary
.
+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(RI,RJ,B) &
    clockDir(I,J,RI,RJ) // if it is necessary 1 clockwise rotation
    <-
    .print("I will rotate if necessary");
    !do(rotate(cw),R);
    if (R == success) {
      .print("I have done a clockwise rotation");
      -+attached(RI,RJ);
    } else {
      .print("Could not rotate in cw");
    }
    !setRightPosition(REQ);
.
+!setRightPosition(REQ) :
    attached(I,J) &
    REQ = req(RI,RJ,B) & // rotate counterclockwise by default
    clockDir(NI,NJ,I,J)
    <-
    .print("I will rotate if necessary");
    !do(rotate(ccw),R);
    if (R == success) {
      .print("I have done a counterclockwise rotation");
      -+attached(NI,NJ);
    } else {
      .print("Could not rotate in ccw");
    }
    !setRightPosition(REQ);
.

+!submitTask(T) :
    attached(I,J)
    <-
    .print("I've submitted");
    !do(submit(T),R0);
    if (R0 == success) {
      .print("I've submitted task ",T);
      .abolish(accepted(_));
    } else {
      .print("Fail on submitting task ",T);
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
