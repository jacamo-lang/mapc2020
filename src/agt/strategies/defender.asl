{ include("defender/common_defender.asl") }
{ include("defender/get_blocks.asl") }
{ include("defender/meeting.asl") }
{ include("defender/goto.asl") }

{ include("tasks/drop_block.asl") }
{ include("walking/common_walking.asl") }
{ include("walking/goto_iaA_star.asl") }
{ include("simulation/watch_dog.asl") }
{ include("environment/artifact_simpleCFP.asl") }
{ include("environment/artifact_counter.asl") }
{ include("agentBase.asl") }

// when I see a dispenser
+thing(X, Y, dispenser, B):
    exploring &
    origin(MyMAP) &
    gps_map(ID,JD,goal,MyMAP)  &  // I know a goal area position
    <-
      .log(warning,"=====================++>>>>>>>> ACHEI UM DISPENSER");
      !!perform_defender(B);
.

+!perform_defender(B):
  not .intend(perform_defender(_)) &
  thing(X, Y, dispenser, B) &
  origin(MyMAP) &
  gps_map(ID,JD,goal,MyMAP)    // I know a goal area position
  <-
    -exploring;
    .log(warning,"=====================++>>>>>>>> DEFENDENDO");
    !fill_blocks(B);
    !go_goal(I,J);
    .log(warning,"CONSEGUIIIIIIIIIII!!!!!!!!");
    !defenderSimple(I,J);
  .

+!go_goal(X,Y):
  true
  <-
    !goto_center_goal(_,_,X,Y);
  .
