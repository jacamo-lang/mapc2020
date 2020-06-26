/**
 * Sample agent to show how to use jacamo unit tests
 */

/**
 * A rule to calculate the sum of two numbers
 */
sum(X,Y,R):-R = X + Y.

/**
 * A rule to calculate the division of two numbers
 */
divide(X,Y,R):-R = (X / Y).

/**
 * A sample plan in which it is expected to generate a belief
 */
+doSomethingAddsBelief :
    true
    <-
    ?sum(1,2,R);
    +raining;
.


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
