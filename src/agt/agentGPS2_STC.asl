{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("simulation/action.asl") }
{ include("taskmanager.asl") }
{ include("src/agt/STC_Strategy.asl")} //exploration strategy
{ include("exploration/meeting.asl")}




newpid(PID):-(PID=math.random(1000000) & not pid(PID)) | newpid(PID).

pertinence(XR,YR,X,Y):- ((XR<0  & X>=XR) |
                        (XR>=0 & X<=XR)) &
                        ((YR<0  & Y>=YR) |
                        (YR>=0 & Y<=YR)). 

originlead(agentA1).

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

teammates([]). //for STC

run_after_sync. //for STC

testing_exploration. //<<< uncomment to test exploration strategies

!start.

+!start: 
    true
    <-
        .wait(step(_));
        ?name(NAME);        
        +origin(NAME);
        !!move (w,0,1)[critical_section(action), priority(1)];
        //+path_direction(math.floor(math.random(2)))//STC - choose a starting path direction
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
      !update_direction; ?current_direction_stc(Dir); ?path_direction(PD) ?directions(PD,DIRECTIONS); .nth(Dir,DIRECTIONS,ND); //STC: update to the next direction
      if (S=LENGTH) {
        //?nextDirection(D,ND);  //Disabled for STC       
        NS=0;
        NL=LENGTH+1;
      } 
      else {
        //ND=D; //Disabled for STC 
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
    & .my_name(Me) //STC
    <-  
        NX= X+INCX;
        NY= Y+INCY;
        -+myposition(NX,NY);
        -+update_position_step(STEP);  
        if(origin(OL) & originlead(OL)) {
            //unmark(X,Y);
            //mark(X, Y, path, Me,0); //STC: keep track of the taken way 
            ?vision(S)
            mark(NX, NY, self, Me,S);
            mark(X, Y, path, Me,0); //STC: keep track of the taken way
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
                         .my_name(AG) & origin(O) & originlead(O)  
    <- 
        if(origin(OL) & originlead(OL)) {
            ?step(Step);
            .concat(AG, "Exp Step: ", Step, Hint);
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
        //+map(O,X+I,Y+J,TYPE);
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

    
    
//*************** STC specific code ************************    

//stc: modify the beliefs about the three to comply with the new location

+!rebase_tree(OldX,OldY) 
   <- .findall(new_parent(X,Y,D,SX,SY),edge(X,Y,D,SX,SY,Map) & .my_name(Me) & .substring(Me,Map), L);   
      !!rebase_tree_list(OldX,OldY,L).
             
+!rebase_tree_list(OldX,OldY,[]).                                       
+!rebase_tree_list(OldX,OldY,[new_parent(X,Y,D,SX,SY)|T]): adapt_coordinate(OldX+X,NX) & adapt_coordinate(OldY+Y,NY) & adapt_coordinate(OldX+SX,NSX) & adapt_coordinate(OldY+SY,NSY) &
                                                           (NX==NSX|NY==NSY) & //rebase only straight lines
                                                           vision(V) & (NX mod V==0) & (NY mod V==0) & (NSX mod V==0) & (NSY mod V==0)  //rebase only edges that fit in the vision range
   <- //.print("fez rebase de (",X,",",Y,",",D,",",SX,",",SY,") para (",NX,",",NY,",",D,",",NSX,",",NSY,") Old: (", OldX,",",OldY,")");
      !do_set_edge(NX,NY,D,NSX,NSY);
      !mark_new_path(NX,NY,NSX,NSY);
      !rebase_tree_list(OldX,OldY,T). 
           
+!rebase_tree_list(OldX,OldY,[new_parent(X,Y,D,SX,SY)|T]): adapt_coordinate(OldX+X,NX) & adapt_coordinate(OldY+Y,NY) & adapt_coordinate(OldX+SX,NSX) & adapt_coordinate(OldY+SY,NSY)
   <- //.print("ignored rebase de (",X,",",Y,",",D,",",SX,",",SY,") para (",NX,",",NY,",",D,",",NSX,",",NSY,") Old: (", OldX,",",OldY,")");
      !mark_new_path_vision(NX,NY,NSX,NSY);
      !rebase_tree_list(OldX,OldY,T).      
      


//STC: mark the path between the coordinates (X,Y) and (SX,SY)
+!mark_new_path(X,Y,SX,SY) : X<SX & X*SX>=0 & vision(S) & .my_name(Me)  
   <- .concat(Me,"(",X,",",Y,")",Hint);               
      mark(X, Y, self, Me,S);
      mark(X, Y, path, Hint,1);
      !mark_new_path(X+1,Y,SX,SY).
      
+!mark_new_path(X,Y,SX,SY) : X>SX & X*SX>0 & vision(S) & .my_name(Me)
   <- .concat(Me,"(",X,",",Y,")",Hint);               
      mark(X, Y, self, Me,S);
      mark(X, Y, path, Hint,1);
      !mark_new_path(X-1,Y,SX,SY).      
      
+!mark_new_path(X,Y,SX,SY) : Y<SY & Y*SY>=0 & vision(S) & .my_name(Me)
   <- .concat(Me,"(",X,",",Y,")",Hint);               
      mark(X, Y, self, Me,S);
      mark(X, Y, path, Hint,1);
      !mark_new_path(X,Y+1,SX,SY).
      
+!mark_new_path(X,Y,SX,SY) : Y>SY & Y*SY>0 & vision(S) & .my_name(Me)
   <- .concat(Me,"(",X,",",Y,")",Hint);               
      mark(X, Y, self, Me,S);
      mark(X, Y, path, Hint,1);
      !mark_new_path(X,Y-1,SX,SY).
        
+!mark_new_path(X,Y,SX,SY).       
                  
      
//STC: mark the path between the coordinates (X,Y) and (SX,SY)
+!mark_new_path_vision(X,Y,SX,SY) : X<SX & X*SX>=0 & vision(S) & .my_name(Me) 
   <- !do_mark_new_path_vision(X,Y,SX,SY); 
      !mark_new_path_vision(X+1,Y,SX,SY).
      
+!mark_new_path_vision(X,Y,SX,SY) : X>SX & X*SX>0 & vision(S) & .my_name(Me)
   <- !do_mark_new_path_vision(X,Y,SX,SY); 
      !mark_new_path_vision(X-1,Y,SX,SY).      
      
+!mark_new_path_vision(X,Y,SX,SY) : Y<SY & Y*SY>=0 & vision(S) & .my_name(Me)
   <- !do_mark_new_path_vision(X,Y,SX,SY); 
      !mark_new_path_vision(X,Y+1,SX,SY).
      
+!mark_new_path_vision(X,Y,SX,SY) : Y>SY & Y*SY>0 & vision(S) & .my_name(Me)
   <- !do_mark_new_path_vision(X,Y,SX,SY); 
      !mark_new_path_vision(X,Y-1,SX,SY).              
      
+!mark_new_path_vision(X,Y,SX,SY).

+!do_mark_new_path_vision(X,Y,SX,SY) : origin(O) & gps_map(X,Y,_,MapId) & .substring(O,MapId). //do not overwrite a marked point
+!do_mark_new_path_vision(X,Y,SX,SY) : vision(S) & .my_name(Me) 
   <- markVision(X,Y,S).      




//update the list of known teammates    
+!update_teammates(Agent) : teammates(Teammates) & not(.member(Agent,Teammates))
   <- .concat([Agent],Teammates,L);
       -+teammates(L).               
+!update_teammates(Agent).       
       
+!update_approach_factor : approach_factor(F) & F > 0
   <- -+approach_factor(F-1).

+!update_approach_factor.  

   
+!after_sync(PID) : run_after_sync & not(pending_isme(PID,MX,MY,AG,RX,RY,AX,AY)).
     
      
+!after_sync(PID): run_after_sync & pending_isme(PID,MX,MY,AG,RX,RY,AX,AY) & .my_name(Me)
   <-   
        OMX=AX+RX;
        OMY=AY+RY;  
        OLDORIGINX=OMX-MX;
        OLDORIGINY=OMY-MY;
        //?last_node(LX,LY);
        //-+last_node(OLDORIGINX+LX,OLDORIGINY+LY);
        ?myposition(X,Y);
        -+last_node(X,Y);
        -+current_moving_step(0); 
        //.print("Vai fazer rebase  de (",MX,",",MY, ") para (",OMX,",",OMY,")");
        !rebase_tree(OLDORIGINX,OLDORIGINY); //stc: modify the beliefs about the three to comply with the new location   //ToDo: share the covered area with the orign agent
        removeTree(Me); //remove the tree build by this agent   
        //.print("... IsMe ", PID, " ---- ", SCENE);
        //.send( AG,achieve, isme(PID) );
        
        //stc - send to the origin agent the informations about the explored tree 
        //.findall(new_parent(PX,PY,D,PXX,PYY),new_parent(PX,PY,D,PXX,PYY)&(PX==PXX | PY\==PYY)&(vision(V) & (PX mod V==0 & PY mod V==0 & PXX mod V==0 & PYY mod V==0)),NewTree);
        //.send(AG,achieve,update_external_tree(NewTree));
        //!remove_old_parent; //STC: remove the outdated informations about the explored tree
        //!update_approach_factor; //STC    
        //!update_teammates(AG); //STC: add the found agent to the list of teammates    
        //!require_tree(AG); //require the tree from the sender
  
.


//TODO: - check the efficiency of reducing the approach factor       
//the agent has found a neighbour       
-pending_areyou(PID,S,L) : .length(L,Size) & Size==1 & .nth(0,L,Ag)
   //<- !update_approach_factor;
      //!update_teammates(Ag).          
.
