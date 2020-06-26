/**
 * Test goals for agent Weak Individualist
 */

{ include("agentWeakIndividualist.asl") }
{ include("testAssert.asl") }

!executeTestPlans.

/**
 * Test rule that gives euclidean distance between two points
 */
+!testDistance :
    distance(0,0,3,3,D0) &
    distance(-30,-20,4,4,D1) &
    distance(-0,10,-9,8.9,D2) &
    distance(0.7,-17,4,-19,D3)
    <-
    !assertEquals(D0,6);
    !assertEquals(D1,58);
    !assertEquals(D2,10.1);
    !assertEquals(D3,5.3);
.

/**
 * Considering the goal area has 13 units as a diamond
 * The agent may consider it as a cross with 5 units
 * When the agent knows two edges of the goal area
 * it can tell where is the center
 */
@testGoalCenter[atomic]
+!testGoalCenter :
    true
    <-
    .abolish(map(_,_,_,_));
    .abolish(goalCenter(_,_));
    +map(0,19,-4,goal)[source(self)];
    +map(0,20,-5,goal)[source(self)];
    +map(0,20,-4,goal)[source(self)];
    +map(0,20,-3,goal)[source(self)];
    +map(0,21,-6,goal)[source(self)];
    +map(0,21,-5,goal)[source(self)];
    +map(0,21,-4,goal)[source(self)];
    +map(0,21,-3,goal)[source(self)];
    +map(0,21,-2,goal)[source(self)];
    +map(0,22,-5,goal)[source(self)];
    +map(0,22,-4,goal)[source(self)];
    +map(0,22,-3,goal)[source(self)];
    +map(0,23,-4,goal)[source(self)];
    ?map(_,X,Y,goalCenter);
    !assertEquals(X,21);
    !assertEquals(Y,-4);
.

/**
 * Test nearest rule which uses myposition and map(_X,Y,thing)
 * to return the nearest thing regarding the reference (myposition)
 */
@testNearest[atomic]
+!testNearest :
    true
    <-
    .abolish(map(_,_,_,_));
    .abolish(myposition(_,_));
    +map(0,5,5,goal)[source(self)];
    +map(0,-5,-5,goal)[source(self)];
    +map(0,-5,-4,goal)[source(self)];
    +map(0,4,2,goal)[source(self)];
    +myposition(0,0);
    ?nearest(goal,X,Y);
    !assertEquals(4,X);
    !assertEquals(2,Y);
.

/*
 * Nearest neighbour is the nearest adjacent position
 * of a given point (X,Y) in relation to myposition(X,Y)
 */
@testNearestNeighbour[atomic]
+!testNearestNeighbour :
    true
    <-
    .abolish(myposition(_,_));
    +myposition(12,12);
    ?nearest_neighbour(10,10,X,Y);
    !assertEquals(10,X);
    !assertEquals(11,Y);
.

/*
 * Test get block which request/attach a block
 * It is actually returning error since the simulator is not on
 */
@testAddGoalCenterBB[atomic]
+!testAddGoalCenterBB :
    true
    <-
    .abolish(map(_,_,_,_));
    !assertFalse(map(_,_,_,goalCenter));
    +map(ag,10,12,goalCenter);
    .wait(100);
    !assertTrue(map(_,_,_,goalCenter));
.
