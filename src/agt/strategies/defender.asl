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
    not .intend(defenderSimple(_,_,_)) &
    exploring &
    origin(MyMAP) &
    gps_map(ID,JD,goal,MyMAP) // I know a goal area position
    <-
      .log(warning,"=====================++>>>>>>>> ACHEI UM DISPENSER");
      //!do(clear(0,0),_);
      !perform_defender(B);
.

+!perform_defender(B):
  not .intend(perform_defender(_)) &
  not .intend(defenderSimple(_,_,_)) &
  thing(X, Y, dispenser, B) &
  origin(MyMAP) &
  gps_map(ID,JD,goal,MyMAP) &  // I know a goal area position
  not is_defending(O,P)
  <-
    -exploring;
    .log(warning,"=====================++>>>>>>>> DEFENDENDO");
    !fill_blocks;
    !goto_center_goal(_,_,I,J,TYPE);
    !defenderSimple(I,J,TYPE);
    +exploring;
  .


+!perform_defender(B)
    <-
    .log(warning,"Could not defende ",B);
.
-!perform_defender(B)
    <-
    .log(warning,"Failed on ",perform_defender(B));
    //No matter if it succeed or failed, it is supposed to be ready for another task
    .drop_desire(perform_defender(_));
    +exploring;
.

//
-attached(_,_):
  .count(attached(I,J)) <= 4 &
  not attached(K,L) &
  direction_increment(DIR,K,L) &
  not lastAction(detach) &
  check_if_neighbour(DIR,success) &
  .intend(defenderSimple(_,_,_))
  <-
    .log(warning,"==========LEVOU UM Falso CLEAN");
    //!fill_blocks;
    //!defines_places;
    //!do(clear(0,0),_);
    //-defenderSimple;
    //-perform_defender;
    //-restart_agent;
  //  +exploring;
  .

-attached(_,_):
  .count(attached(I,J)) <= 4 &
  not attached(K,L) &
  direction_increment(DIR,K,L) &
  not lastAction(detach) &
  .intend(defenderSimple(_,_,_))
  <-
    .log(warning,"==========LEVOU UM CLEAN");
    //!fill_blocks;
    //!defines_places;
    //!do(clear(0,0),_);
    .drop_intention(defenderSimple(_,_,_));
    .drop_intention(perform_defender(_));
    !check_if_neighbour(DIR,T);
    //-restart_agent;
    +exploring;
  .
