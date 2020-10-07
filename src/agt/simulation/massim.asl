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
    .concat("artGPS",TEAM,ArtGPS) & 
    .concat("env",TEAM,Env) &
    teamSize(TS)
    <-
    .log(warning,"****** Initialising agent");
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;

    .abolish(unwanted_task(_));
    .abolish(wanted_task(_,_,_,_));
    .abolish(gps_map(_,_,_,_));
    .abolish(exploring);
    .abolish(myposition(_,_));
    .abolish(origin(_));
    .abolish(edge(_,_,_,_,_,_)); //from stc exploration strategy
    .abolish(pending_isme(_,_,_,_,_,_,_,_)); //from meeting protocol 
    .abolish(pending_areyou(_,_,_)); //from meeting protocol
    
    
    if (.concat("artGPS",TEAM,ArtGPS) & focused(Env,ArtGPS)) {
        resetRP;
    }
    if (.concat("simpleCFP",TEAM,ArtCFP) & focused(Env,ArtCFP)) {
        resetSimpleCFP;
    }
    
    +exploring;
    +myposition(0,0);
    -+last_node(-1,-1); //from stc strategy 

    !!start;
.

+simStart :
    step(2) &
    .my_name(NAME) & 
    .substring(NAME,ID,6) & ID == "1" & // only agenta1 and b1 are writing statistics
    teamSize(TS) &
    vision(V) &
    exploration_strategy(ES)
    <-
    .concat("[",teamSize(TS),",",vision(V),",",exploration_strategy(ES),"]",C);
    .save_stats("simStart",C);
.
/**
 * The simulator just stopped / end of a round
 */
+simEnd :
    step(1) &
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
    .save_stats("simEnd",C);
    -ranking(R);
    -score(R);
.
