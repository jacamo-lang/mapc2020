/**
 * Test controller provides general test configurations and facilities
 */


/**
 * Configurations
 */
verbose.        // enable to see full log debug
shutdownHook.     // enable to shutdown after finishing tests



/**
 * Startup operations
 */
!setTestController.    // starts test controller operations



/**
 * setup of the controller, including hook for shutdown
 */
+!setTestController :
    true & .my_name(testController)
    <-
    .print("\n\n\n");
    .print("**** Starting Jason unit tests...");
    .at("now +2 s", {+!shutdownAferTests});
.

// avoid plan not found for asl that includes controller
+!setTestController.

/**
 * enable to shutdown after finishing tests
 */
+!shutdownAferTests :
    shutdownHook
    <-
    if (not intention(_)) {
      .print("**** End of Jason unit tests.");
      .print("\n\n\n");
      .stopMAS;
    }
.
