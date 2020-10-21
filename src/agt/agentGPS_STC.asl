/** agentGPS with the Spanning Tree Coverage strategy for exloration **/
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("src/agt/STC_Strategy.asl")} //exploration strategy
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

originlead(agentA1).

nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).

directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).

//direction(w,1). //in STC strategy, the first direction is north (as below)
direction(n,1).
size(1).
lastmapping(-1).
myposition(0,0).
teammates([]).

!start.

+!start: true
    <-  
        .wait(step(_));
        ?name(NAME);
        +origin(NAME);
        !!move;
    .
    
    
  

+!move: 
    lastactionstep(STEP) & 
    step(STEP)
    <-  
        .wait (lastactionstep(STEP) & not step(STEP));
        !!move;
    .

+!move: 
    lastActionResult(null) & 
    step(STEP)
    <-        
        //action(move(w)); //disabled for STC - replaced by the two following lines
        !update_direction; ?current_direction_stc(Dir); ?directions(DIRECTIONS); .nth(Dir,DIRECTIONS,ND);
        action(move(ND));
        -+lastactionstep(STEP);
        !!move;
    .



+!move: 
    lastActionResult(failed_random) &
    direction(LD,_)  & 
    step(STEP)
    <-   
        //action(move(LD)); //disabled for STC - replaced by the two following lines
        !update_direction; ?current_direction_stc(Dir); ?directions(DIRECTIONS); .nth(Dir,DIRECTIONS,ND);
        action(move(ND));
        -+lastactionstep(STEP);
        !!move;
    .

+!move: 
    lastActionResult(failed_path) &
    direction(D,_)   & 
    size(S) & 
    step(STEP)
    <-  
        !update_direction; ?current_direction_stc(Dir); ?directions(DIRECTIONS); .nth(Dir,DIRECTIONS,ND);
        //-+direction(ND,S);     //disabled for stc 
        -+size(S+1);                
        action(move(ND));
        -+lastactionstep(STEP);
        !!move;
    .

+!move:
    lastActionResult(success) &
    direction(D,0)       &
    //nextDirection(D,ND)  & //disabled for stc
    size(S) & 
    step(STEP)     
    <-  
        !mapping(D);
        !update_direction; ?current_direction_stc(Dir); ?directions(DIRECTIONS); .nth(Dir,DIRECTIONS,ND);    
        //-+direction(ND,S+1); //disabled for stc
        -+size(S+1);
        action(move(ND));
        -+lastactionstep(STEP);
        !!move;
    .
    
+!move: 
    lastActionResult(success) &
    //direction(D,N)   &  //disabled for stc - replaced by the line below 
    lastActionParams([D]) & ////added for stc - replacing the line above
    step(STEP)
    <-  
        !mapping(D);                           
        //-+direction(D,N-1); //disabled for stc
        //action(move(D));    //disabled for stc - replaced by the line below 
        !update_direction; ?current_direction_stc(Dir); ?directions(DIRECTIONS); .nth(Dir,DIRECTIONS,ND); 
        action(move(ND));
        -+lastactionstep(STEP);
        !!move;
        .


 
+!move <- .print("*** move failed ***").

+!mapping(DIRECTION) :  
    directionIncrement(DIRECTION, INCX,  INCY) & 
    step(STEP) & 
    myposition(X,Y)
    <-  
        NX= X+INCX;
        NY= Y+INCY;
        -+myposition(NX,NY);
        if(origin(OL) & originlead(OL)) {
            unmark(X,Y); 
            mark(NX, NY, self, step);
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

+!sincMap(XR,YR): origin(OL) & originlead(OL) &
                  (math.abs(XR+1) * math.abs(YR+1)>3) & //TAMANHO DA JANELA 
                  myposition(AX,AY)
    <-   .print("SINCMAP OL: (", XR, ",",YR,")", OL);
        .findall(m(I,J,goal),goal(I,J) & pertinence(XR,YR,I,J) ,G);
        .findall(m(I,J,obst),obstacle(I,J) & pertinence(XR,YR,I,J),O);
        .findall(m(I,J,TYPE),thing(I,J,_,TYPE) & pertinence(XR,YR,I,J),T);  
        .concat(G,O,T,BRUTSCENE);
        .sort(BRUTSCENE,SCENE);
        ?buildscene(0,.length(SCENE), math.abs(XR)+1, SCENE,FINALSCENE);
        ?newpid(PID);
        +pid(PID);  
        .broadcast (achieve,areyou(XR,YR,AX,AY,FINALSCENE,PID));
    .
+!sincMap(_,_) <- true.

+!areyou(RX,RY,AX,AY,SCENE,PID)[source(AG)]: 
        thing(-RX,-RY,entity,TEAM) & team(TEAM)  & 
        checkscene(SCENE) & myposition(MX,MY) & 
        not (origin(OL) & originlead(OL))
    <-          
        OMX=AX+RX;
        OMY=AY+RY;  
        -+myposition(OMX,OMY);
        ?originlead(ORIGIN);
        -+origin(ORIGIN);   
    
        OLDORIGINX=OMX-MX;
        OLDORIGINY=OMY-MY;
        .my_name(NAG);   
        for (map(O,X,Y,TYPE) & O\==ORIGIN){ 
            -map(O,X,Y,TYPE);       
            +map(ORIGIN,OLDORIGINX+X,OLDORIGINY+Y,TYPE);
            mark(OLDORIGINX+X,OLDORIGINY+Y,TYPE, NAG);
        }
        //!rebase_tree(OLDORIGINX,OLDORIGINY); //ToDo: share the covered area with the orign agent   
        .send( AG,achieve, isme(PID) );
    .
    
    
   
      
+!areyou(_,_,_,_,_,_) <- true. 

+!isme(PID)[source(AG)]: not returnedpid(PID)
    <-
        .print("### encontrei o agente: ",AG);
        +returnedpid(PID);
        !update_teammates([AG])
    .

+!isme(PID)[source(AG)]: returnedpid(PID)
    <-
        .print(AG," ----------- HOUVE FALSO POSITIVO -----------");
    .


+!addMap(I,J,X,Y,TYPE) :  
    .my_name(AG) & origin(O)  
    <-  
        if(origin(OL) & originlead(OL)) {
            mark(X+I, Y+J, TYPE, AG);               
        }   
        +map(O,X+I,Y+J,TYPE);
    .

 
    
//ToDo: share the covered area with the orign agent     
+!rebase_tree(OldX,OldY) : parent(X,Y,D,SX,SY) & not(new_parent(OldX+X,OldY+Y,D,OldX+SX,OldY+SY))        
   <- +new_parent(OldX+X,OldY+Y,D,OldX+SX,OldY+SY);
      !rebase_tree(OldX,OldY).
+!rebase_tree(OldX,OldY).      
   


//update the list of known teammates    
+!update_teammates(Agents) : teammates(Teammates)
   <- .concat(Agents,Teammates,L);
       -+teammates(L).    
