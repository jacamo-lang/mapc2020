{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("action.asl") }
{ include("taskmanager.asl") }
{ include("src/agt/STC_Strategy.asl")} //exploration strategy
{ include("src/agt/meeting.asl")} //exploration strategy

buildscene(SIZE, SIZE, _, _,[]).

buildscene(START, SIZE, LINESIZE, [m(X0,Y0,TYPE)|TAIL],SCENEOUTPUT):-
        X0= START div LINESIZE &
        Y0= START mod LINESIZE &
        buildscene(START+1,SIZE, LINESIZE, TAIL,SCNOUT) &
        SCENEOUTPUT=[m(X0,Y0,TYPE)|SCNOUT].

buildscene(START, SIZE, LINESIZE, [m(X0,Y0,TYPE)|TAIL],SCENEOUTPUT):-
        XT=START div LINESIZE &
        YT= START mod LINESIZE  & 
        not (X0= XT & Y0= YT) &                 
        buildscene(START+1,SIZE, LINESIZE, [m(X0,Y0,TYPE)|TAIL],SCNOUT) &
        SCENEOUTPUT=[m(XT,YT,empty)|SCNOUT].

checkscene ([m(X0,Y0,goal)|T]):-goal(-X0,-Y0) & checkscene (T).
checkscene ([m(X0,Y0,obst)|T]):-obstacle(-X0,-Y0) & checkscene (T).
checkscene ([m(X0,Y0,TYPE)|T]):-thing(-X0,-Y0,_,TYPE) & checkscene (T).
checkscene ([m(X0,Y0,empty)|T]):- not (  goal(-X0,-Y0) |
                                         obstacle(-X0,-Y0) | 
                                         thing(-X0,-Y0,_,_) ) &
                                         checkscene (T).
checkscene ([]):-true.


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

teammates([]). //for STC

run_after_sync. //for STC

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
