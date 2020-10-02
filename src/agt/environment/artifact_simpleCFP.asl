/**
 * This lib creates an artifact for a very simple call for proposals approach
 */
 
!make_simpleCFP.

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
