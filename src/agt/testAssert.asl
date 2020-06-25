/**
 * Assert helpers
 */

{ include("testController.asl") }

/**
 * Assert if X is equals to Y
 * IMPORTANT! In case the arguments are result of some math of floats
 * precision errors may lead to wrong assertions
 */
+!assertEquals(X,Y) :
    true
    <-
    if (X \== Y) {
      .print("Error on assenting equals!");
      .fail;
    } else {
      if (verbose) {
        .print("passed");
      }
    }
.
