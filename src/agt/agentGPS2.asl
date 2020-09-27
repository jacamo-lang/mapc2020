{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("action.asl") }
{ include("taskmanager.asl") }
{ include("exploration/meeting.asl")}



newpid(PID):-(PID=math.random(1000000) & not pid(PID)) | newpid(PID).

pertinence(XR,YR,X,Y):- ((XR<0  & X>=XR) |
                        (XR>=0 & X<=XR)) &
                        ((YR<0  & Y>=YR) |
                        (YR>=0 & Y<=YR)). 

originlead(agenta0).

nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).

directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).

size(1).
lastmapping(-1).
myposition(0,0).


//testing_exploration. //<<< uncomment to test exploration strategies

!start.

+!start: 
    true
    <-
        .wait(step(_));
        ?name(NAME);        
        +origin(NAME);
        !!move (w,0,1)[critical_section(action), priority(1)];
    .


+disabled(true):
    true
    <-
        .print("recharging...");
        !!recharge[critical_section(action), priority(2)];
    .

+!recharge:
    true
    <-
        !do(skip,R);
    .
    
+!move(D,S,LENGTH): 
    true
    <-
      if (S=LENGTH) {
        ?nextDirection(D,ND);
        NS=0;
        NL=LENGTH+1;
      } 
      else {
        ND=D;
        NS=S+1;
        NL=LENGTH;
      }
      !do(move(ND),R);
            
      if (R=success) {
        !mapping(ND);
        !!move(ND,NS,NL)[critical_section(action), priority(1)];
      }else{
        ?nextDirection(ND,NND);   
        !!move(NND,0,NL)[critical_section(action), priority(1)];
      };     
    .

+!mapping(DIRECTION) :  
    directionIncrement(DIRECTION, INCX,  INCY) & 
    step(STEP) & 
    myposition(X,Y)
    <-  .perceive;
        NX= X+INCX;
        NY= Y+INCY;
        -+myposition(NX,NY);
        -+update_position_step(STEP); 
        if(origin(OL) & originlead(OL)) {
            unmark(X,Y); 
            ?vision(S)
            mark(NX, NY, self, step,S);
        }   
        for (goal(I,J)) {
            !addMap(I,J,NX,NY,goal);
        }
        for (obstacle(I,J)) {
            !addMap(I,J,NX,NY,obstacle);
        }
        for (thing(I,J,dispenser,TYPE)) {
            !addMap(I,J,NX,NY,TYPE);
        }
        for (thing(I,J,entity,TEAM) & 
             team(TEAM)) {
            !sincMap(I,J);
        }       
.


/* Handling exception - same exception stack as -addMap(I,J,X,Y,TYPE) below)
   TODO: check the reason for this exception */
-!mapping(DIRECTION).


//The origin is the originLead (the one that draws in the viewer)
+!addMap(I,J,X,Y,TYPE) : testing_exploration & 
                         field_size(S) & S >0 &
                         adapt_coordinate_map(X+I,XX) & adapt_coordinate_map(Y+J,YY)  &
                         .my_name(AG) & origin(O) & originlead(O) & step(Step)  
    <-  .concat(AG," - Exp. Step ", Step, Hint); 
        if(origin(OL) & originlead(OL)) {
            mark(XX, YY, TYPE, Hint,0, O); //The last parameter is the map identifier              
        }           
    .

//The origin is the originLead (the one that draws in the viewer)
+!addMap(I,J,X,Y,TYPE) :  
    .my_name(AG) & origin(O) & originlead(O)  
    <-
        if(origin(OL) & originlead(OL)) {
            mark(X+I, Y+J, TYPE, AG,0, O); //The last parameter is the map identifier              
        }   
       // +map(O,X+I,Y+J,TYPE);
    .
    
+!addMap(I,J,X,Y,self). //do not mark the agent position if it is not in the originlead map    
    
+!addMap(I,J,X,Y,TYPE) : origin(O)
   <- mark(X+I, Y+J, TYPE,  O); //The last parameter is the map identifier                
     //+map(O,X+I,Y+J,TYPE).
     .

/* Handling exception
   TODO: check the reason for this exception:

   java.lang.NullPointerException
        at cartago.ObsPropMap.readAll(ObsPropMap.java:224)
    at cartago.Artifact.readProperties(Artifact.java:1186)
    at cartago.Artifact.access$000(Artifact.java:32)
    at cartago.Artifact$ArtifactAdapter.readProperties(Artifact.java:1277)
    at cartago.WorkspaceKernel.getArtifactInfo(WorkspaceKernel.java:1397)
    at cartago.WorkspaceKernel.access$500(WorkspaceKernel.java:48)
    at cartago.WorkspaceKernel$CartagoController.getArtifactInfo(WorkspaceKernel.java:1534)
    at jaca.CAgentArch.act(CAgentArch.java:274)
    at jason.asSemantics.TransitionSystem.act(TransitionSystem.java:1498)
    at jason.infra.centralised.CentralisedAgArch.act(CentralisedAgArch.java:239)
    at jason.infra.centralised.CentralisedAgArch.reasoningCycle(CentralisedAgArch.java:250)
    at jason.infra.centralised.CentralisedAgArch.run(CentralisedAgArch.java:271)
    at java.base/java.lang.Thread.run(Thread.java:830)
   [CAgentArch] Op mark(-26,-28,obstacle,agenta4) on artifact null(artifact_name= null) by agenta4 failed - op: mark(-26,-28,obstacle,agenta4)
   [agenta4] No failure event was generated for +!addMap(-1,-2,-25,-26,obstacle)[code(mark(-26,-28,obstacle,agenta4)),code_line(139),code_src("agentGPS2_STC.asl"),env_failure_reason(env_failure(action_failed(mark,generic_error))),error(action_failed),error_msg("Action failed: mark(-26,-28,obstacle,agenta4). null"),source(self)]
   intention 10573: 
*/
-!addMap(I,J,X,Y,TYPE). 
