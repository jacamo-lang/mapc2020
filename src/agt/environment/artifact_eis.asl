/**
 * This lib creates eismassim artifact which is the bridge between the
 * agent and its representation in the massim environment.
 * 
 * All strategies should include this file in order to have each agent
 * creating and focusing its own connection with massim.
 */
 
!make_eis.

+!make_eis : 
    .my_name(NAME) &
    .substring(NAME,ID,5) &
    .concat("art",ID,Art) &
    team(T) &
    .concat("env",T,Env) &
    focused(Env,Art).

+!make_eis :
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
