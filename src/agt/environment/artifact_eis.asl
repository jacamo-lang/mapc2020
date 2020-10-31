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
    .term2string(Artterm,Art) &
    team(T) &
    .concat("env",T,Env) &
    .term2string(Envterm,Env) &
    focused(Envterm,Artterm).

+!make_eis :
    .my_name(NAME) &
    .substring(NAME,ID,5) &
    .concat("art",ID,Art) &
    .concat("clientconf/eis",ID,".json",EIS)
    <-
    makeArtifact(Art,"connection.EISAccess",[EIS],ArtId);
    focusWhenAvailable(Art);
.
