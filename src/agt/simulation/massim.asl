/**
 * Used for special actions regarding massim simulator events
 */

/**
 * The simulator just started / new round
 */

+simStart :
    step(0)
    <-
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;
    !drop_beliefs;

    !init_agent;
.

+!init_agent :
    .my_name(NAME) &
    .substring(NAME,ID,6) &
    .substring(NAME,TEAM,5,6) &
    .concat("env",TEAM,Env) &
    .term2string(Envterm,Env) &
    .concat("artGPS",TEAM,ArtGPS) &
    .term2string(ArtGPSterm,ArtGPS) &
    .concat("simpleCFP",TEAM,ArtCFP) &
    .term2string(ArtCFPterm,ArtCFP) &
    .concat("stepCounter",TEAM,ArtCounter) &
    .term2string(ArtCounterTerm,ArtCounter)
    <-
    .log(warning,"****** Initialising agent");

    -+exploring;
    -+myposition(0,0);
    -+last_node(-1,-1); //for stc exploration strategy
    -+current_moving_step(99); //for stc exploration strategy
    -+forward; //for stc strategy
    -+current_direction_stc(0); //for stc exploration strategy

    if ( ID == "1" & focused(Envterm,ArtCounterTerm,_) ) {
        resetStepCounter(-1);
    }

    if ( ID == "1" & focused(Envterm,ArtGPSterm,_) ) {
        resetRP;
    }

    if ( ID == "1" & focused(Envterm,ArtCFPterm,_) ) {
        resetSimpleCFP;
    }

    if (not .intend(explore)) {
        !!start;
    }
.

+simStart : // to avoid a flood of register, only agent1 of each team generate the simStart event
    step(2) &
    .my_name(NAME) &
    .substring(NAME,ID,6) & ID == "1" & // only agenta1 and b1 are writing statistics
    teamSize(TS) &
    vision(V) &
    exploration_strategy(ES)
    <-
    -+persistTeamSize(TS);
    .concat("[",teamSize(TS),",",vision(V),",",exploration_strategy(ES),"]",C);
    .save_stats("simStart",C);
.
+simStart : // for the other agents, just write persistTeamSize(TS)
    step(2) &
    teamSize(TS)
    <-
    -+persistTeamSize(TS);
.

/**
 * Drop beliefs for a refreshed agent's mind
 */
+!drop_beliefs
    <-
    .abolish(unwanted_task(_));
    .abolish(wanted_task(_,_,_));
    .abolish(gps_map(_,_,_,_));
    .abolish(exploring);
    .abolish(myposition(_,_));
    .abolish(origin(_));
    .abolish(edge(_,_,_,_,_,_)); //from stc exploration strategy
    .abolish(pending_isme(_,_,_,_,_,_,_,_)); //from meeting protocol
    .abolish(pending_areyou(_,_,_)); //from meeting protocol
    .abolish(task(_,_,_,_));
    .abolish(performing(_,_));

    .abolish(perform_defender(_));
    .abolish(defenderSimple(_,_));
    .abolish(goto_center_goal(_,_,_,_,_));
    .abolish(defines_places);
.

/**
 * The simulator just stopped / end of a round
 */
+simEnd : // I was expecting this just once at step(749) but I am getting it at every step!
    step(1) & // This is the first step of the next round (also works for the last round!)
    .my_name(NAME) &
    .substring(NAME,ID,6) & ID == "1" // only agenta1 and b1 are writing statistics
    <-
    !saveEnd;
    .log(warning,"End of round.");
.

/**
 * End of third round
 */
+bye :
    .my_name(NAME) &
    .substring(NAME,ID,6) & ID == "1" // only agenta1 and b1 are writing statistics
    <-
    !saveEnd;
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;

    .stopMAS(3000);
.
+bye
    <-
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;
.

+!saveEnd :
    ranking(R) &
    score(S)
    <-
    .concat("[",score(S),",",ranking(R),"]",C);
    .save_stats("simEnd  ",C);
    -ranking(R);
    -score(R);
.
