/**
 * Used for special actions regarding massim simulator events
 */

!make_art.
!make_gps.

/**
 * The simulator just started / new round
 */
+simStart :
    step(0)
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

