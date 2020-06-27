/**
 * Test controller provides general test configurations and facilities
 */

{ include("$jacamoJar/templates/common-cartago.asl") }

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
 * execute plans that contains "test" in the name
 */
@executeTestPlans[atomic]
+!executeTestPlans:
    .relevant_plans({+!_},_,LL)
    <-
    for (.member(P,LL)) {
      if (.substring("test",P)) {
        !!executeTestPlan(P);
      }
    }
.

@executeTestPlan[atomic]
+!executeTestPlan(P) :
    true
    <-
    .current_intention(I);
    I = intention(Id,IStack);
    .print("Executing ",Id," (main plan: ",P,")");
    !P;
.

/**
 * setup of the controller, including hook for shutdown
 */
+!setTestController :
    true &
    .my_name(testController)
    <-
    .println("\n\n");
    .println("**** Starting Jason unit tests...\n\n");

    .at("now +2 s", {+!shutdownAferTests});
.
+!setTestController. // avoid plan not found for asl that includes controller

/**
 * enable to shutdown after finishing tests
 */
 +!shutdownAferTests :
     shutdownHook &
     error
     <-
     .print("\n\n");
     .print("**** End of Jason unit tests.\n\n");
     exitWithError;
 .

+!shutdownAferTests :
    shutdownHook &
    not intention(_)
    <-
    .print("\n\n");
    .print("**** End of Jason unit tests.\n\n");
    .stopMAS;
.
