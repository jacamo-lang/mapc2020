/**
 * Used for special actions regarding massim simulator events
 */

//TODO: Move create artifact plans to strategy/weak_individualist since other strategies may need different artifacts
/**
 * Besides the connection artifact, the weak individualist uses
 * gps and simpleCFP
 */
!make_art.
!make_gps.
!make_simpleCFP.


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
    
    if (.concat("artGPS",TEAM,ArtGPS) & focused(Env,ArtGPS)) {
        resetRP;
    }
    if (.concat("simpleCFP",TEAM,ArtCFP) & focused(Env,ArtCFP)) {
        resetSimpleCFP;
    }
    
    +exploring;
    +myposition(0,0);

    !!start;
.

+!make_art : 
    .my_name(NAME) &
    .substring(NAME,ID,5) &
    .concat("art",ID,Art) &
    team(T) &
    .concat("env",T,Env) &
    focused(Env,Art).

+!make_art :
    .my_name(NAME) &
    .substring(NAME,ID,5) &
    //.substring(NAME,TEAM,5,6) &
    .concat("art",ID,Art) &
    //.upper_case(TEAM,TTEAM) &
    //.concat("clientconf/eis",TTEAM,"config.json",EIS)
    .concat("clientconf/eis",ID,".json",EIS)
    <-
    makeArtifact(Art,"connection.EISAccess",[EIS],ArtId);
    focusWhenAvailable(Art);
.

+!make_gps :
    .my_name(NAME) &
    .substring(NAME,NUMBER,6) &
    NUMBER == "1" & // only one agent creates the artifact (agenta1 of agentb1)
    .substring(NAME,TEAM,5,6) &
    .concat("artGPS",TEAM,ArtGPS) & 
    .concat("env",TEAM,Env) &
    not focused(Env,ArtGPS) // it seems, the artifact does not exist
    <-
    .log(warning,"Making and focusing on artifact ",ArtGPS);
    makeArtifact(ArtGPS,"localPositionSystem.rp.rp",[90,0],ArtId);
    focusWhenAvailable(ArtGPS);
.

+!make_gps :
    .my_name(NAME) &
    .substring(NAME,TEAM,5,6) &
    .concat("artGPS",TEAM,ArtGPS)
    <-
    .log(warning,"Focusing on artifact ",ArtGPS);
    focusWhenAvailable(ArtGPS);
.

+!make_simpleCFP :
    .my_name(NAME) &
    .substring(NAME,NUMBER,6) &
    NUMBER == "1" & // only one agent creates the artifact (agenta1 of agentb1)
    .substring(NAME,TEAM,5,6) &
    .concat("simpleCFP",TEAM,ArtCFP) & 
    .concat("env",TEAM,Env) &
    not focused(Env,ArtCFP) // it seems, the artifact does not exist
    <-
    .log(warning,"Making and focusing on artifact ",ArtCFP);
    makeArtifact(ArtCFP,"coordination.simpleCFP",[],ArtId);
    focusWhenAvailable(ArtCFP);
.

+!make_simpleCFP :
    .my_name(NAME) &
    .substring(NAME,TEAM,5,6) &
    .concat("simpleCFP",TEAM,ArtCFP)
    <-
    .log(warning,"Focusing on artifact ",ArtCFP);
    focusWhenAvailable(ArtCFP);
.
