{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("action.asl") }
{ include("taskmanager.asl") }
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
      !update_direction; ?current_direction_stc(Dir); ?directions(DIRECTIONS); .nth(Dir,DIRECTIONS,ND); //STC: update to the next direction
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
      
      if (R=failed_path) {
        ?nextDirection(ND,NND);   
        !!move(NND,0,NL)[critical_section(action), priority(1)];
      }
      if (R=success) {
        !mapping(ND);
        !!move(ND,NS,NL)[critical_section(action), priority(1)];
      }     
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

+!sincMap(XR,YR): origin(OL) & originlead(OL) &
                  (math.abs(XR+1) * math.abs(YR+1)>2) & //TAMANHO DA JANELA 
                  myposition(AX,AY)
                  &step(S) & S>2 //STC - do not sincronize in the first two steps
                  //& ( (goal(I,J) | obstacle(I,J) & pertinence(XR,YR,I,J)  ) | 
                  //  (thing(PosI,PosJ,_,TYPE) & PosI\==XR & PosJ\==YR  & PosI\==0 & PosJ\==0 & pertinence(XR,YR,PosI,PosJ))
                  //) //STC: do not sincronize when there is only empty space
                  & (team(TEAM) &
                     ((goal(I,J)|obstacle(I,J)|(thing(I,J,TYPE,_)&TYPE\==entity)|(thing(I,J,entity,OP)&OP\==TEAM)) & pertinence(XR,YR,I,J)) | //STC - sinc only if there is a goal, an obstacle, a non-agent entity, or an opponent agent ...
                     (thing(PosI,PosJ,entity,TEAM)& (PosI\==0 | PosJ\==0)&(PosI\==XR|PosJ\==YR)& pertinence(XR,YR,PosI,PosJ)) //...or another teammate
                    ) 
                    
    <-  
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
        not(checkscene(SCENE)) & myposition(MX,MY) & 
        not (origin(OL) & originlead(OL))
<-  .print("NOT Areyou ",RX,",",RY,",",AX,",",AY,",",SCENE,",",PID,")").

+!areyou(RX,RY,AX,AY,SCENE,PID)[source(AG)]: 
        thing(-RX,-RY,entity,TEAM) & team(TEAM)  & 
        checkscene(SCENE) & myposition(MX,MY) & 
        not (origin(OL) & originlead(OL))
        & step(Step)
    <-  .print("Areyou ",RX,",",RY,",",AX,",",AY,",",SCENE,",",PID,") from ", AG, " Coord.: (",X,",",Y,")  MyPos: (",MX,",",MY,")   Step: ", Step);        
        OMX=AX+RX;
        OMY=AY+RY;  
        -+myposition(OMX,OMY);
        -+last_node(OMX,OMY); //STC - update the coordinates of the last visited node
        ?originlead(ORIGIN);
        -+origin(ORIGIN);   
    
        OLDORIGINX=OMX-MX;
        OLDORIGINY=OMY-MY;
        .my_name(NAG);   
        for (map(O,X,Y,TYPE) & O\==ORIGIN){
            -map(O,X,Y,TYPE);       
            +map(ORIGIN,OLDORIGINX+X,OLDORIGINY+Y,TYPE);
            mark(OLDORIGINX+X,OLDORIGINY+Y,TYPE, NAG,0);
             .print("...ARE YOU - mark(", OLDORIGINX+X,",",OLDORIGINY+Y,",",TYPE,",", NAG,") OldOrigin: (",OLDORIGINX,",",OLDORIGINY,")  ");
        }
        .print("Vai fazer rebase  de (",MX,",",MY, ") para (",OMX,",",OMY,")");
        !rebase_tree(OLDORIGINX,OLDORIGINY); //stc: modify the beliefs about the three to comply with the new location   //ToDo: share the covered area with the orign agent   
        .print("... IsMe ", PID, " ---- ", SCENE);
        .send( AG,achieve, isme(PID) );
        
        //stc - send to the origin agent the informations about the explored tree 
        .findall(new_parent(PX,PY,D,PXX,PYY),new_parent(PX,PY,D,PXX,PYY),NewTree);
        .send(AG,achieve,update_external_tree(NewTree));
        !remove_old_parent; //STC: remove the outdated informations about the explored tree
        !update_approach_factor; //STC        
.     

+!areyou(_,_,_,_,_,_) <- true. 

+!isme(PID)[source(AG)]: not returnedpid(PID)
    <-
        .print("######### encontrei o agente: ",AG, " ######### ", PID);
        +returnedpid(PID);
        !update_teammates([AG]) //STC: add the found agent to the list of teammates
        .findall(new_parent(X,Y,D,XX,YY),parent(X,Y,D,XX,YY),L);
        .send(AG,achieve,update_tree(L));
        !update_approach_factor //STC: increment the limit of approaching to other agents
    .

+!isme(PID)[source(AG)]: returnedpid(PID)
    <-
        .print(AG," ----------- HOUVE FALSO POSITIVO -----------");
    .


+!addMap(I,J,X,Y,TYPE) :  
    .my_name(AG) & origin(O)  
    &adapt_coordinate(X+I,XX)&adapt_coordinate(Y+J,YY)
    <-
        if(origin(OL) & originlead(OL)) {
            //mark(X+I, Y+J, TYPE, AG,0);                
            mark(XX, YY, TYPE, AG,0);
        }   
        //+map(O,X+I,Y+J,TYPE);
        +map(O,XX,YY,TYPE);
    .

    
    
//*************** STC specific code ************************    

//stc: modify the beliefs about the three to comply with the new location    
+!rebase_tree(OldX,OldY) : parent(X,Y,D,SX,SY) & //not(new_parent(OldX+X,OldY+Y,D,OldX+SX,OldY+SY))
                           adapt_coordinate(OldX+X,NX) & adapt_coordinate(OldY+Y,NY) & adapt_coordinate(OldX+SX,NSX) & adapt_coordinate(OldY+SY,NSY)          
   <- 
      +new_parent(NX,NY,D,NSX,NSY);
      -parent(X,Y,D,SX,SY);
      .print("fez rebase de (",X,",",Y,",",D,",",SX,",",SY,") para (",NX,",",NY,",",D,",",NSX,",",NSY,") Old: (", OldX,",",OldY,")");
      !mark_new_path(NX,NY,NSX,NSY);
      !rebase_tree(OldX,OldY)
      .
      
+!rebase_tree(OldX,OldY).




+!remove_old_parent: new_parent(X,Y,D,SX,SY) & not(parent(X,Y,D,SX,SY))
   <- +parent(X,Y,D,SX,SY);      
      !remove_old_parent.             
+!remove_old_parent <- .abolish(new_parent(_,_,_,_,_)).


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


+!update_external_tree(L)[source(Ag)]
   <- .print(">>>>>> Going to update external_tree ", Ag, " - ", L);
      !update_tree(L);
      .print("<<<<<< Updated external_tree ", Ag, " - ", L).

+!update_tree([new_parent(X,Y,D,XX,YY)|T]) : X\==XX & Y\==YY
   <- .print(".... 0 updating tree parent(",X,",",Y,",",D,",",XX,",",YY,")  ignored");
      !update_tree(T).   

+!update_tree([new_parent(X,Y,D,XX,YY)|T]) : not(parent(X,Y,D,XX,YY)) 
   <- +parent(X,Y,D,XX,YY);             
      .print(".... 1 updating tree parent(",X,",",Y,",",D,",",XX,",",YY,")");
      !update_tree(T).     
      
           
+!update_tree([new_parent(X,Y,D,XX,YY)|T]) : parent(X,Y,D,XX,YY)
   <- .print(".... 2 updating tree parent(",X,",",Y,",",D,",",XX,",",YY,")");
      !update_tree(T).   
      
+!update_tree([]) <- .print(".... 3 updating tree parent(",X,",",Y,",",D,",",XX,",",YY,")").      


//update the list of known teammates    
+!update_teammates(Agents) : teammates(Teammates)
   <- .concat(Agents,Teammates,L);
       -+teammates(L).    
       
+!update_approach_factor : approach_factor(F) & F > 0
   <- -+approach_factor(F-1).

+!update_approach_factor.    
