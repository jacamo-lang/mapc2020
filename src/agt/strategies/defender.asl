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
    not .intend(perform_defender(_)) &
    not .intend(defenderSimple(_)) &
    exploring &
    .count(attached(_,_)) \== 4 &
    origin(MyMAP) &
    gps_map(ID,JD,goal,MyMAP) // I know a goal area position
    <-
      //.log(warning,"=====================++>>>>>>>> ACHEI UM DISPENSER");
      //!do(clear(0,0),_);
      !!perform_defender(B);
.

+thing(X, Y, goal, _):
    not .intend(perform_defender(_)) &
    not .intend(defenderSimple(_)) &
    exploring &
    .count(attached(_,_)) == 4 &
    not is_defending(A,B)
    <-
      .log(warning,"=====================++>>>>>>>> ACHEI UM GOAL");
      //!do(clear(0,0),_);
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
    !!defenderSimple(I,J,TYPE);
  .

  +!perform_defender(B)
      <-
      .log(warning,"Could not defende ",B);
  .
  -!perform_task(T)
      <-
      .log(warning,"Failed on ",perform_defender(B));
      //No matter if it succeed or failed, it is supposed to be ready for another task
      .drop_desire(perform_defender(_));
      +exploring;
  .

//
// -attached(_,_):
//   .count(attached(_,_)) \== 4 &
//   not lastAction(detach) &
//   .intend(defenderSimple(_,_,_))
//   <-
//     .log(warning,"==========LEVOU UM CLEAN");
//     !defines_places;
//     //!do(clear(0,0),_);
//     -perform_defender;
//     .drop_desire(_);
//     //-restart_agent;
//     +exploring
//   .
