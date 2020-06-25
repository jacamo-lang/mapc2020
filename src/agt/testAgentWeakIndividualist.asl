/**
 * Test goals for agent Weak Individualist
 */

{ include("agentWeakIndividualist.asl") }
{ include("testAssert.asl") }

distance(X1,Y1,X2,Y2,D) :- D = math.abs(X2-X1) + math.abs(Y2-Y1).

!testDistance.
!testGoalCenter.

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
    ?goalCenter(X,Y);
    !assertEquals(X,21);
    !assertEquals(Y,-4);
.
