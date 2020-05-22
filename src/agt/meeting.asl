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


//sincMap: the sync process
+!sincMap(XR,YR): origin(OL) & originlead(OL) &
                  (math.abs(XR+1) * math.abs(YR+1)>3) & //TAMANHO DA JANELA 
                  myposition(AX,AY)
                  &step(S)                     
    <-  
        ?newpid(PID);
        +pending_areyou(PID,S,[]);        
        
        .findall(m(I,J,goal),goal(I,J) & pertinence(XR,YR,I,J) ,G);
        .findall(m(I,J,obst),obstacle(I,J) & pertinence(XR,YR,I,J),O);
        .findall(m(I,J,TYPE),thing(I,J,_,TYPE) & pertinence(XR,YR,I,J),T);  
        .concat(G,O,T,BRUTSCENE);
        .sort(BRUTSCENE,SCENE);
        ?buildscene(0,.length(SCENE), math.abs(XR)+1, SCENE,FINALSCENE);     
         //.print("... areyou SCENE: ", SCENE, "FINAL: ", FINALSCENE);   
        .broadcast (achieve,areyou(XR,YR,AX,AY,FINALSCENE,PID,S));
                
        
         /*A possible new code. ToDo: evaluate if there is some advantage to use it.  
        .findall(m(I,J,goal),goal(I,J) & math.abs(-XR+I)+math.abs(-YR+J)<=5 ,G);
        .findall(m(I,J,obst),obstacle(I,J) & math.abs(-XR+I)+math.abs(-YR+J)<=5 ,O);
        .findall(m(I,J,TYPE),thing(I,J,_,TYPE) & math.abs(-XR+I)+math.abs(-YR+J)<=5,T);
        .concat(G,O,T,BRUTSCENE);
        .sort(BRUTSCENE,SCENE);
        .broadcast (achieve,areyou(XR,YR,AX,AY,SCENE,PID,S)[critical_section(action), priority(3)]). //priority higher than recharge to avoid false positive (might not reply while recharging)
        */
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
        step(S) & S==STEP //sync. when the areyou request sent and received in the same step. ToDo: Maybe not necessary after discover the inconsistent position problem  
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
       //.print("### Received isme PID: ", PID, " - L", L, "  NewL: ",  NewL, " Step: ", Step , "###").
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
+!sync_isme(PID)[source(AG)] : pending_isme(PID,MX,MY,AG,RX,RY,AX,AY)  & not (origin(OL) & originlead(OL)) & myposition(Xnow,Ynow)            
   <-  
       .perceive;
       ?myposition(Xnow_2,Ynow_2);
       -+myposition(AX+RX + (Xnow_2-MX), AY+RY + (Ynow_2-MY));
   
       ?originlead(ORIGIN);
       OMX=AX+RX; //(OMX,OMY): position of the agent with respect to the origin of AG
       OMY=AY+RY;  
       OLDORIGINX=OMX-MX; //origin of the agent with respect to the origin of AG
       OLDORIGINY=OMY-MY;                     
       .my_name(NAG);   
       for (map(O,X,Y,TYPE) & O\==ORIGIN){
           -map(O,X,Y,TYPE);       
           +map(ORIGIN,OLDORIGINX+X,OLDORIGINY+Y,TYPE);
           mark(OLDORIGINX+X,OLDORIGINY+Y,TYPE, NAG,0);
           //.print("...ARE YOU - mark(", OLDORIGINX+X,",",OLDORIGINY+Y,",",TYPE,",", NAG,") OldOrigin: (",OLDORIGINX,",",OLDORIGINY,")  Original Pos:(",X,",",Y,")  Current Pos: (",OMX + (Xnow-MX),",",OMY + (Ynow-MY),")  My Pos: (",MX,",",MY,")- PID: ", PID);
       }
       -+origin(ORIGIN);      
       .

+!sync_isme(PID).


//after_sync: if necessary to run something else after sync, add the belief run_after_sinc and implement a plan in the agent
+!after_sync(PID) :  pending_isme(PID,_,_,_,_,_,_,_) & not(runAfterSync) 
   <- -pending_isme(PID,_,_,_,_,_,_,_).
