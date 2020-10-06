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
    .concat("env",TEAM,Env)    
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

+bye
    <-
    .stopMAS;
.
