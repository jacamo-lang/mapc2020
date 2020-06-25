/**
 * Assert helpers
 */

{ include("testController.asl") }

getIntentionId(I,ID) :- I =.. A & .nth(2,A,B) & .nth(0,B,ID).

/**
 * Assert if X is equals to Y
 * IMPORTANT! In case the arguments are result of some math of floats
 * precision errors may lead to wrong assertions
 */
@assertEquals
+!assertEquals(X,Y) :
    true & .current_intention(I) & getIntentionId(I,ID)
    <-
    if (X \== Y) {
      .print("Error on assenting equals!");
      .fail;
    } else {
      if (verbose) {
        .print("Intention ",ID," passed!");
      }
    }
.
