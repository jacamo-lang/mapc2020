/**
 * Used for special actions regarding massim simulator events
 */

!make_art.
!make_gps.

/**
 * The simulator just started
 */
+simStart :
    step(0)
    <-
    .log(warning,"****** Initialising agent");
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;

    .abolish(unwanted_task(_));
    .abolish(gps_map(_,_,_,_));
    .abolish(exploring);
    .abolish(myposition(_,_));
    .abolish(origin(_));
    !!erase_gps;

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
    .substring(NAME,ID,5) &
    .concat("artGPS",ID,ArtGPS) &
    .substring(NAME,TEAM,5,6) &
    .concat("env",TEAM,Env) &
    focused(Env,ArtGPS)
    <-
    focusWhenAvailable(ArtGPS);
    eraseGpsMapProps; 
.

+!make_gps :
    .my_name(NAME) &
    .substring(NAME,ID,5) &
    .concat("artGPS",ID,ArtGPS)
    <-
    makeArtifact(ArtGPS,"localPositionSystem.rp.rp",[90,0],ArtId);
    focusWhenAvailable(ArtGPS);
.

+!erase_gps :
    .my_name(NAME) &
    .substring(NAME,ID,5) &
    .concat("artGPS",ID,ArtGPS)
    <-
    focusWhenAvailable(ArtGPS);
    eraseGpsMapProps; 
.

