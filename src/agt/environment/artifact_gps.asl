/**
 * This lib creates a route planner an extension of the local position artifact
 * which provides GPS facilities such as the beliefs gps_map(_,_,_,_)
 */
 
!make_gps.

+!make_gps :
    .my_name(NAME) &
    .substring(NAME,NUMBER,6) &
    NUMBER == "1" & // only one agent creates the artifact (agenta1 of agentb1)
    .substring(NAME,TEAM,5,6) &
    .concat("artGPS",TEAM,ArtGPS)
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
