/**
 * Assert helpers
 */

{ include("testController.asl") }

getIntentionId(I,ID) :- I =.. A & .nth(2,A,B) & .nth(0,B,ID).

/**
 * Assert if X is equals to Y
 * IMPORTANT! Do no use this method to compare float numbers
 */
@assertEquals
+!assertEquals(X,Y) :
    .current_intention(I) &
    getIntentionId(I,ID)
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

/**
 * Assert if X is true / exists
 */
@assertTrue
+!assertTrue(X) :
    .current_intention(I) &
    getIntentionId(I,ID)
    <-
    if (not X) {
      .print("Error on assenting true!");
      .fail;
    } else {
      if (verbose) {
        .print("Intention ",ID," passed!");
      }
    }
.

-!assertTrue(X) :
    true
    <-
    .send(testController,tell,error);
    .
