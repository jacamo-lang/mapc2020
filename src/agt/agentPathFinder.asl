{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("goto.asl") }
{ include("action.asl") }

routeplan_mindist(5).
targetPosition(_,_).
myAbsPosition(45,3).

!doDummyExploration.

+!doDummyExploration:
  true
  <-
    // First going to fixed points, the agent is starting at the absolute_position(45,3)
    !goto(-33,9); // Go to the depot in the absolute_position(12,12)
    !goto(-39,6); // Go to the depot in the absolute_position(6,9)
    !goto(-38,5); // An arbitrary point near the last
    !goto(10,-6); // Go to the depot in the absolute_position(55,67)
    !goto(8,-4); // An arbitrary point near the last

    // Keep exploring
    !doDummyExploration;
 .

+!areyou(_,_,_,_,_,_,_) <- true.
