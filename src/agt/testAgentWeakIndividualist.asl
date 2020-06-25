/**
 * Test goals for agent Weak Individualist
 */

{ include("agentWeakIndividualist.asl") }
{ include("testAssert.asl") }

distance(X1,Y1,X2,Y2,D) :- D = math.abs(X2-X1) + math.abs(Y2-Y1).

!testDistance.

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
