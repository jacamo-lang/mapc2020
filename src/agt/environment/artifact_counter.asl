/**
 * This lib creates an artifact for a very simple call for proposals approach
 */
 
!make_counter.

+!make_counter :
    .my_name(NAME) &
    .substring(NAME,NUMBER,6) &
    NUMBER == "1" & // only one agent creates the artifact (agenta1 of agentb1)
    .substring(NAME,TEAM,5,6) &
    .concat("stepCounter",TEAM,ArtCounter) & 
    .concat("env",TEAM,Env) &
    not focused(Env,ArtCounter) // it seems, the artifact does not exist
    <-
    .log(warning,"Making and focusing on artifact ",ArtCounter);
    makeArtifact(ArtCounter,"coordination.stepCounter",[-1],ArtId);
    focusWhenAvailable(ArtCounter);
.

+!make_counter :
    .my_name(NAME) &
    .substring(NAME,TEAM,5,6) &
    .concat("stepCounter",TEAM,ArtCounter)
    <-
    .log(warning,"Focusing on artifact ",ArtCounter);
    focusWhenAvailable(ArtCounter);
.
