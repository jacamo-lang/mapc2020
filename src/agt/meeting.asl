/*
 * Meeting protocol:
 * 1. The agent (sender) sends an areyou achieve message with some PID and adds a believe pending_areyou(PID,Step,[List]) where List is the list, initially, empty of possible neighbours.
 *    When the pending_areyou is adedd, the agent starts to wait for steps_for_sync before to synchronize  
 *    (cf. plan syncMap). 
 * 2. The receiver executes the areyou plan. If it is a potential neighbour, sends an isme achieve message with the same PID and adds a belief pending_isme(PID,X,Y,Origin) s.t (X,Y) are the new coordinates.
 * 3. The sender executes the isme plan and adds name of the potential neighbur to list of pending_areyou
 * 4. The sender waits for steps_for_sync steps for check how many answers have been received. Is this number is 1, sync. Otherwise, discard the pending_areyou.  
 * 
 */



steps_for_sync(4). /* Number of steps to wait for answers of possible neighbours */

/* Useful to compare atoms (e.g. agent name) with String arguments from artifacts */
compare_bels(Bel1,Bel2):- .concat("-",Bel1,NewBel1) & .concat("-",Bel2,NewBel2) & 
                          .length(NewBel1, LNewBel1) & .length(NewBel2, LNewBel2) & LNewBel1==LNewBel2 & 
                          .substring(NewBel1,NewBel2).


coord(X,Y,XR,YR,L,R) :- coordXpositive(X,Y,XR,YR,L,XP) & coordXnegative(X-1,Y,XR,YR,L,XN) & .concat(XP,XN,R).  
coordXpositive(X,Y,XR,YR,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))<=5 & (math.abs(X)+ math.abs(Y))<= 5 & coordYpositive(X,Y+1,XR,YR,[],N) & coordYnegative(X,Y-1,XR,YR,[],NN) & coordXpositive(X+1,Y,XR,YR,L,M) & .concat([p(X,Y)],M,N,NN,R).
coordXpositive(X,Y,XR,YR,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))>5  & (math.abs(X)+ math.abs(Y))<= 5 & coordYpositive(X,Y+1,XR,YR,[],N) & coordYnegative(X,Y-1,XR,YR,[],NN) & coordXpositive(X+1,Y,XR,YR,L,M) & .concat(M,N,NN,R).
coordXpositive(X,Y,XR,YR,L,R) :- .concat(L,[],R).

coordXnegative(X,Y,XR,YR,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))<=5 & (math.abs(X)+ math.abs(Y))<= 5 & coordYpositive(X,Y+1,XR,YR,[],N) & coordYnegative(X,Y-1,XR,YR,[],NN) & coordXnegative(X-1,Y,XR,YR,L,M) & .concat([p(X,Y)],M,N,NN,R).
coordXnegative(X,Y,XR,YR,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))>5  & (math.abs(X)+ math.abs(Y))<= 5 & coordYpositive(X,Y+1,XR,YR,[],N) & coordYnegative(X,Y-1,XR,YR,[],NN) & coordXnegative(X-1,Y,XR,YR,L,M) & .concat(M,N,NN,R).                            
coordXnegative(X,Y,XR,YR,L,R) :- .concat(L,[],R).


coordYpositive(X,Y,XR,YR,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))<=5 & (math.abs(X)+ math.abs(Y))<= 5 & coordYpositive(X,Y+1,XR,YR,L,M) & .concat([p(X,Y)],M,R) .
coordYpositive(X,Y,XR,YR,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))>5  & (math.abs(X)+ math.abs(Y))<= 5 & coordYpositive(X,Y+1,XR,YR,L,M) & .concat(M,R).
coordYpositive(X,Y,XR,YR,L,R) :- .concat(L,[],R).

coordYnegative(X,Y,XR,YR,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))<=5 & (math.abs(X)+ math.abs(Y))<= 5 & coordYnegative(X,Y-1,XR,YR,L,M) & .concat([p(X,Y)],M,R) .
coordYnegative(X,Y,XR,YR,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))>5  & (math.abs(X)+ math.abs(Y))<= 5 & coordYnegative(X,Y-1,XR,YR,L,M) & .concat(M,R).
coordYnegative(X,Y,XR,YR,L,R) :- .concat(L,[],R).


buildscene(Goals,Obstacles,Things,[p(X,Y)|T],L,R) :- .member(m(X,Y,goal),Goals) & .concat([m(X,Y,goal)],L,RR) & buildscene(Goals,Obstacles,Things,T,RR,R).
buildscene(Goals,Obstacles,Things,[p(X,Y)|T],L,R) :- .member(m(X,Y,obst),Obstacles) & .concat([m(X,Y,obst)],L,RR) & buildscene(Goals,Obstacles,Things,T,RR,R).
buildscene(Goals,Obstacles,Things,[p(X,Y)|T],L,R) :- .member(m(X,Y,W),Things) & .concat([m(X,Y,W)],L,RR) & buildscene(Goals,Obstacles,Things,T,RR,R).
buildscene(Goals,Obstacles,Things,[p(X,Y)|T],L,R) :- .concat(L,[m(X,Y,empty)],RR) & buildscene(Goals,Obstacles,Things,T,RR,R).                                                  
buildscene(Goals,Obstacles,Things,[],L,R) :- R=L.                                                  

//+replace_map(OldMapId, NewMapId) <- .print(">>>> I should replaceMap from ", OldMapId, " to ", NewMapId).

//sincMap: the sync process
+!sincMap(XR,YR): origin(OL) & originlead(OL) &
                  (math.abs(XR+1) * math.abs(YR+1)>3) & //TAMANHO DA JANELA 
                  myposition(AX,AY)
                  &step(S)                     
    <-  
        ?newpid(PID);
        +pending_areyou(PID,S,[]);        
        
        /*.findall(m(I,J,goal),goal(I,J) & pertinence(XR,YR,I,J) ,G);
        .findall(m(I,J,obst),obstacle(I,J) & pertinence(XR,YR,I,J),O);
        .findall(m(I,J,TYPE),thing(I,J,_,TYPE) & pertinence(XR,YR,I,J),T);  
        .concat(G,O,T,BRUTSCENE);
        .sort(BRUTSCENE,SCENE);
        ?buildscene(0,.length(SCENE), math.abs(XR)+1, SCENE,FINALSCENE);     
         //.print("... areyou SCENE: ", SCENE, "FINAL: ", FINALSCENE);   
        .broadcast (achieve,areyou(XR,YR,AX,AY,FINALSCENE,PID,S));
         */        
        
   
        .findall(m(I,J,goal),goal(I,J) & math.abs(-XR+I)+math.abs(-YR+J)<=5 ,G);
        .findall(m(I,J,obst),obstacle(I,J) & math.abs(-XR+I)+math.abs(-YR+J)<=5 ,O);
        .findall(m(I,J,TYPE),thing(I,J,_,TYPE) & math.abs(-XR+I)+math.abs(-YR+J)<=5,T);             
        ?coord(0,0,XR,YR,[],Coord); //Coord is a list of all coordinates visible to both the agents involved in the interaction
        ?buildscene(G,O,T,Coord,[],FinalScene); //Build a final list with goals, obstacles, entities, and empty coordinates        
        .broadcast (achieve,areyou(XR,YR,AX,AY,FinalScene,PID,S)); 
        
        .
    
+!sincMap(_,_) <- true.
 
 
//Case 1: empty scene -> it is not possible to check whether is a neighbour 
+!areyou(XR,YR,AX,AY,[],PID,STEP).



//Case 2: the agent is not synchronized: returns an isme achieve message and add the pending_isme belief  
+!areyou(RX,RY,AX,AY,SCENE,PID,STEP)[source(AG)]: 
        thing(-RX,-RY,entity,TEAM) & team(TEAM)  & 
        checkscene(SCENE) & 
        not (origin(OL) & originlead(OL)) &
        myposition(MX,MY) &
        step(S) & S==STEP & update_position_step(STEP) //sync. when the areyou request sent and received in the same step. ToDo: Maybe not necessary after discover the inconsistent position problem  
    <-  
        +pending_isme(PID,MX,MY,AG,RX,RY,AX,AY);
        .send( AG,achieve, isme(PID) );
        //.print("1. Areyou ",RX,",",RY,",",AX,",",AY,",",SCENE,",",PID,") from ", AG, " Coord.: (",X,",",Y,")  MyPos: (",MX,",",MY,")   Step: ", S,"/",STEP);
        .
        
//Case 3: the agent is already synchronized: returns an isme message to avoid a false positive, but does not add the pending_isme belief to not sync again  
+!areyou(RX,RY,AX,AY,SCENE,PID,STEP)[source(AG)]: 
        thing(-RX,-RY,entity,TEAM) & team(TEAM)  & 
        checkscene(SCENE) &
        step(S)
    <-  
        .send( AG,achieve, isme(PID) );
        //.print("2. Areyou ",RX,",",RY,",",AX,",",AY,",",SCENE,",",PID,") from ", AG, " Coord.: (",X,",",Y,")  MyPos: (",MX,",",MY,")    Step: ", S,"/",STEP);
        .            

+!areyou(_,_,_,_,_,_,_) <- true.



//Receiving messages of possible neighbours, adding their names to the possible neighbours list 
//it is atomic to ensure that incoming messages of possible neighbours be processed one at a time, keeping the list of possible neighbours consistent  
@isme[atomic]
+!isme(PID)[source(AG)]: pending_areyou(PID,Step,L)
    <- .concat([AG],L,NewL);
       -+pending_areyou(PID,Step,NewL);
       //.print("### Received isme PID: ", PID, " - L", L, "  NewL: ",  NewL, " Step: ", Step , "###");
       .
 
+!isme(PID).    


+pending_areyou(PID,S,[]) <- !!sync_areyou(PID). 

//Case 1: the minimum number of steps has not been achieved - wait for the next step
+!sync_areyou(PID) : pending_areyou(PID,S,L)  &
                     step(Step) & steps_for_sync(SS) & Step-S <= SS //the minimum number of steps has not been achieved
   <-  .wait(step(SNext) & SNext>Step);
       !!sync_areyou(PID).
       
//Case 2: the minimum number of steps has been achieved and there is a potential neighbour - the neighbour is achieved and must sync  
+!sync_areyou(PID) : pending_areyou(PID,S,L)  &
                     step(Step) & steps_for_sync(SS) & Step-S > SS & //the minimum number of steps has been achieved
                     .length(L,Size) & Size==1 & .nth(0,L,Ag) //   
   <-  //.print("2. sync_areyou steps achieved ONE answer PID: ", PID, "  S: ", S, "  Step: ", Step, " Ag: ", Ag);
       .send( Ag, achieve, sync_isme(PID)); //sends a message to the neighbour to update its coordinates 
       -pending_areyou(PID,S,L). //the update of this PID is no longer pending
       
//Case 3: the minimum number of steps has been achieved and there is zero or more than one potential neighbours              
+!sync_areyou(PID) : pending_areyou(PID,S,L)  &
                     step(Step) & steps_for_sync(SS) & Step-S > SS & 
                     .length(L,Size) & Size\==1     
   <- 
      -pending_areyou(PID,S,L).     

+!sync_areyou(PID).      

//sync_isme(PID): synchronize the coordinates given in referred PID 
//(MX,MY): position of the agent when meets with AG
//(RX,RY): relative position of the agent with respect to AG
//(AX,AY): position of AG when meets with the agent   
@sync_isme[atomic]   //atomic to avoid update the coordinates before (i) finishing the plan and (ii) start a parallel update          
+!sync_isme(PID)[source(AG)] : pending_isme(PID,MX,MY,AG,RX,RY,AX,AY)  & origin(OL) & not (originlead(OL)) & myposition(Xnow,Ynow)            
   <-  .abolish(update_position_step(_));
       .perceive;
       ?myposition(Xnow_2,Ynow_2);
       -+myposition(AX+RX + (Xnow_2-MX), AY+RY + (Ynow_2-MY));
   
       ?originlead(ORIGIN);
       OMX=AX+RX; //(OMX,OMY): position of the agent with respect to the origin of AG
       OMY=AY+RY;  
       OLDORIGINX=OMX-MX; //origin of the agent with respect to the origin of AG
       OLDORIGINY=OMY-MY;                     
       .my_name(NAG);   
       for (gps_map(X,Y,TYPE,MapId) & compare_bels(MapId,OL) & OL\==ORIGIN){
           mark(OLDORIGINX+X,OLDORIGINY+Y,TYPE, NAG,0,ORIGIN);
           //.print("...ARE YOU - mark(", OLDORIGINX+X,",",OLDORIGINY+Y,",",TYPE,",", MapId,") OldMap: ", OL, " OldOrigin: (",OLDORIGINX,",",OLDORIGINY,")  Original Pos:(",X,",",Y,")  Current Pos: (",OMX + (Xnow-MX),",",OMY + (Ynow-MY),")  My Pos: (",MX,",",MY,")- PID: ", PID);
       }       
       -+origin(ORIGIN);
       replaceMap(OL,ORIGIN); //remove the old map from the shared representation
       .abolish(map(OL,_,_,_));      
       //?step(S); .print("... SYNC areyou origin: ", ORIGIN, " Agent: ", AG, " Step ", S, "");
       !after_sync(PID).    

+!sync_isme(PID).


//after_sync: if necessary to run something else after sync, add the belief run_after_sinc and implement a plan in the agent
+!after_sync(PID) :  pending_isme(PID,_,_,_,_,_,_,_) & not(run_after_sync) 
   <- 
      -pending_isme(PID,_,_,_,_,_,_,_).
