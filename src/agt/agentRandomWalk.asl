{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("action.asl") }

directions([n,s,w,e]).

/*

// Reactive version
@step[atomic]
+step( S ): directions(LDIRECTIONS)
    <-
        .nth(math.floor(math.random(4)),LDIRECTIONS,D);
        action(move(D));
    .
*/

// Pro-active version

!walk.

+!walk : directions(LDIRECTIONS)
   <- .nth(math.floor(math.random(4)),LDIRECTIONS,D);
      !do(move(D),R); // R is the result of the execution, success, fail, ...
      !walk;
   .
