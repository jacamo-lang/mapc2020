/**
 * Used for special actions regarding massim simulator events
 */

/**
 * The simulator just started / new round
 */
+simStart :
    step(0) &
    .my_name(NAME) &
    .substring(NAME,TEAM,5,6) &
    .substring(NAME,ID,6) & // only agenta1 and b1 are writing statistics
    .concat("env",TEAM,Env) &
    .term2string(Envterm,Env) &
    .concat("stepCounter",TEAM,ArtCounter) &
    .term2string(ArtCounterTerm,ArtCounter)
    <-
    .log(warning,"****** Initialising agent");
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;
    !drop_beliefs;
    
    if ( focused(Envterm,ArtCFPterm,_) ) {
        removeMyCFPs;
    }
    
    +exploring;
    +myposition(0,0);
    -+last_node(-1,-1); //from stc strategy 

    !!start;
.

+simStart : // to avoid a flood of register, only agent1 of each team generate the simStart event
    step(2) &
    .my_name(NAME) & 
    .substring(NAME,ID,6) & ID == "1" & // only agenta1 and b1 are writing statistics
    .substring(NAME,TEAM,5,6) &
    .concat("env",TEAM,Env) &
    .term2string(Envterm,Env) &
    .concat("artGPS",TEAM,ArtGPS) &
    .term2string(ArtGPSterm,ArtGPS) &
    .concat("simpleCFP",TEAM,ArtCFP) &
    .term2string(ArtCFPterm,ArtCFP) &
    teamSize(TS) &
    vision(V) &
    exploration_strategy(ES)
    <-
    -+persistTeamSize(TS);
    .concat("[",teamSize(TS),",",vision(V),",",exploration_strategy(ES),"]",C);
    .save_stats("simStart",C);
    
    if ( focused(Envterm,ArtGPSterm,_) ) {
        resetRP;
    }

    if ( focused(Envterm,ArtCFPterm,_) ) {
        resetSimpleCFP;
    }
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
    .stopMAS(3000);
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
