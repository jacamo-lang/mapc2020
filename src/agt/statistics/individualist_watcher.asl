/**
 * The individualist watcher generates specific statistics for
 * individualist agents
 */

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

exploration_strategy(none).

!focus_eis.

/**
 * Focus the eis artifact created by/for agentA1
 */
+!focus_eis
    <-
    focusWhenAvailable("artA1");
.

+!areyou(_,_,_,_,_,_,_,_) <- true.

+!start 
    <-
    .abolish(relevant_task(_,_,_));
.

+simStart :
    step(2) &
    teamSize(TS) 
    <-
    -+persistTeamSize(TS);
.

+task(T,DL,Y,REQs) : 
    .member(req(I,J,_),REQs) & (math.abs(I) + math.abs(J)) > 1 // There is a req which requires help from other agent
.

+task(T,DL,Y,REQs) 
    <- 
    +relevant_task(T,DL,REQs);
.

+relevant_task(T,DL,REQs):
    step(S)
    <-
    .concat("[",task(T,DL,REQs),",",step(S),"]",STR);
    .save_stats("relevantTask",STR);
.
