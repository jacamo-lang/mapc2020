{ include("defender/common_defender.asl") }
{ include("defender/get_blocks.asl") }
{ include("defender/goto.asl") }
{ include("defender/simple_defender.asl") }

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
    gps_map(ID,JD,goal,MyMAP) // I know a goal area position
    <-
      //.log(warning,"=====================++>>>>>>>> ACHEI UM DISPENSER");
      //!do(clear(0,0),_);
      .log(warning,"CLEANS");
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
    !go_defender(I,J,TYPE);
    !defenderSimple(I,J,TYPE);
  .

+!perform_defender(B).

-attached(_,_):
  .count(attached(_,_)) \== 4 &
  not lastAction(detach) &
  .intend(defenderSimple(_,_,_))
  <-
    .log(warning,"==========LEVOU UM CLEAN");
    !defines_places;
    //!do(clear(0,0),_);
    -defenderSimple;
    -perform_defender;
    !restart_agent;
  .
