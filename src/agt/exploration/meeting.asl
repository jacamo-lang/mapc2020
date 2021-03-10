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

 
 /*
  * Cluster formation
  *
  * 1. Send an areyou request when find an agent, indepent of the current mapismee
  * 2. Include the map id in the areyou request
  *
  */
{ include("exploration/findMapSize.asl") }

field_size(70). //size of the field
field_center(C):-field_size(S)&C=(S)div(2).

steps_for_sync(4). /* Number of steps to wait for answers of possible neighbours */

/* Useful to compare atoms (e.g. agent name) with String arguments from artifacts */
compare_bels(Bel1,Bel2):- .concat("-",Bel1,NewBel1) & .concat("-",Bel2,NewBel2) &
                          .length(NewBel1, LNewBel1) & .length(NewBel2, LNewBel2) & LNewBel1==LNewBel2 &
                          .substring(NewBel1,NewBel2).


coord(X,Y,XR,YR,L,R) :- vision(Range) & coordXpositive(X,Y,XR,YR,Range,L,XP) & coordXnegative(X-1,Y,XR,YR,Range,L,XN) & .concat(XP,XN,R).

coordXpositive(X,Y,XR,YR,Range,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))<=Range & (math.abs(X)+ math.abs(Y))<= Range & coordYpositive(X,Y+1,XR,YR,Range,[],N) & coordYnegative(X,Y-1,XR,YR,Range,[],NN) & coordXpositive(X+1,Y,XR,YR,Range,L,M) & .concat([p(X,Y)],M,N,NN,R).
coordXpositive(X,Y,XR,YR,Range,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))>Range  & (math.abs(X)+ math.abs(Y))<= Range & coordYpositive(X,Y+1,XR,YR,Range,[],N) & coordYnegative(X,Y-1,XR,YR,Range,[],NN) & coordXpositive(X+1,Y,XR,YR,Range,L,M) & .concat(M,N,NN,R).
coordXpositive(X,Y,XR,YR,Range,L,R) :- .concat(L,[],R).

coordXnegative(X,Y,XR,YR,Range,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))<=Range & (math.abs(X)+ math.abs(Y))<= Range & coordYpositive(X,Y+1,XR,YR,Range,[],N) & coordYnegative(X,Y-1,XR,YR,Range,[],NN) & coordXnegative(X-1,Y,XR,YR,Range,L,M) & .concat([p(X,Y)],M,N,NN,R).
coordXnegative(X,Y,XR,YR,Range,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))>Range  & (math.abs(X)+ math.abs(Y))<= Range & coordYpositive(X,Y+1,XR,YR,Range,[],N) & coordYnegative(X,Y-1,XR,YR,Range,[],NN) & coordXnegative(X-1,Y,XR,YR,Range,L,M) & .concat(M,N,NN,R).
coordXnegative(X,Y,XR,YR,Range,L,R) :- .concat(L,[],R).


coordYpositive(X,Y,XR,YR,Range,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))<=Range & (math.abs(X)+ math.abs(Y))<= Range & coordYpositive(X,Y+1,XR,YR,Range,L,M) & .concat([p(X,Y)],M,R) .
coordYpositive(X,Y,XR,YR,Range,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))>Range  & (math.abs(X)+ math.abs(Y))<= Range & coordYpositive(X,Y+1,XR,YR,Range,L,M) & .concat(M,R).
coordYpositive(X,Y,XR,YR,Range,L,R) :- .concat(L,[],R).

coordYnegative(X,Y,XR,YR,Range,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))<=Range & (math.abs(X)+ math.abs(Y))<= Range & coordYnegative(X,Y-1,XR,YR,Range,L,M) & .concat([p(X,Y)],M,R) .
coordYnegative(X,Y,XR,YR,Range,L,R) :- (math.abs(-XR+X)+math.abs(-YR+Y))>Range  & (math.abs(X)+ math.abs(Y))<= Range & coordYnegative(X,Y-1,XR,YR,Range,L,M) & .concat(M,R).
coordYnegative(X,Y,XR,YR,Range,L,R) :- .concat(L,[],R).


checkscene ([m(X0,Y0,goal)|T]):-goal(X0,Y0) & checkscene (T).
checkscene ([m(X0,Y0,obst)|T]):-obstacle(X0,Y0) & checkscene (T).
checkscene ([m(X0,Y0,TYPE)|T]):-thing(X0,Y0,_,TYPE) & checkscene (T).
checkscene ([m(X0,Y0,empty)|T]):- not (  goal(X0,Y0) |
                                         obstacle(X0,Y0) |
                                         thing(X0,Y0,_,_) ) &
                                         checkscene (T).

checkscene ([]):-true.

//adapt a coordinate A to to a new value B that fits with the field size
adapt_coordinate_map(A,B) :- field_size(S) & field_center(C) & (A>=C) & AA=A-S & adapt_coordinate_map(AA,B).
adapt_coordinate_map(A,B) :- field_size(S) & field_center(C) & (A<(C*-1)) & AA=A+S & adapt_coordinate_map(AA,B).
adapt_coordinate_map(A,B) :- field_size(S) & field_center(C) & A<C & A >= (C*-1) &  B=A.                                             

//+origin(O) <- .print("++++++++++++++++++++++++++++ origin", O).

+replace_map(OldMapId, NewMapId, Dx, Dy) : origin(O) & compare_bels(OldMapId,O) & step(S)
   <- +to_replace_map(OldMapId, NewMapId, Dx, Dy,S);
       .abolish(agentA_data(_,_,_,_,_,_,_)); //discard map size data 
       .abolish(my_data(_,_,_)); //discard map size data
      !do_replace_map(OldMapId, NewMapId).
      /*.wait(step(Step)&update_position_step(Step)&myposition(X,Y)); //wait for the consistent position belief
      -+myposition(X+Dx,Y+Dy);
      -+origin(NewMapId);
      .print(">>>> I should replaceMap from ", OldMapId, " to ", NewMapId, " - Step: ", S, ". Moved from(",X,",",Y,") to(",X+Dx,",",Y+Dy,")").
      */

+!do_replace_map(OldMapId, NewMapId): origin(O) & compare_bels(OldMapId,O) &
                                      to_replace_map(OldMapId, NewMapId, Dx, Dy,S) &
                                      step(Step)&update_position_step(Step)&myposition(X,Y)
   <- .abolish(pending_isme(_,_,_,_,_,_,_,_,_)); //discard pending synchronizations after sync
      -+myposition(X+Dx,Y+Dy);
      -+origin(NewMapId);      
      -to_replace_map(OldMapId, NewMapId, Dx, Dy,S); 
      //.print(">>>> I should replaceMap from ", OldMapId, " to ", NewMapId, " - Step: ", S,"/",Step, ". Moved from(",X,",",Y,") to(",X+Dx,",",Y+Dy,") - (",Dx,",",Dy,")");
      .

+!do_replace_map(OldMapId, NewMapId): origin(O) & compare_bels(OldMapId,O) &
                                      to_replace_map(OldMapId, NewMapId, Dx, Dy,S) &
                                      step(Step)
   <-  //print(">>>> waiting to replaceMap from ", OldMapId, " to ", NewMapId, " - Step: ", S, ". Moved from(",X,",",Y,") to(",X+Dx,",",Y+Dy,")");
      .wait(step(S)&S>Step);
      //.wait(100);
      !do_replace_map(OldMapId, NewMapId).


+!do_replace_map(OldMapId, NewMapId).

/* */

//sincMap: the sync process
/*+!sincMap(XR,YR,AX,AY,S): origin(OL) & //   originlead(OL) &
                  (math.abs(XR+1) * math.abs(YR+1)>3) & //TAMANHO DA JANELA
                  //myposition(AX,AY)&
                  step(S) & update_position_step(S)

    <-
        ?newpid(PID);
        +pending_areyou(PID,S,[]);




        .findall(m(-XR+I,-YR+J,goal),goal(I,J) & math.abs(-XR+I)+math.abs(-YR+J)<=5 ,G);
        .findall(m(-XR+I,-YR+J,obst),obstacle(I,J) & math.abs(-XR+I)+math.abs(-YR+J)<=5 ,O);
        .findall(m(-XR+I,-YR+J,TYPE),thing(I,J,_,TYPE) & math.abs(-XR+I)+math.abs(-YR+J)<=5,T);
        ?coord(0,0,XR,YR,[],Coord); //Coord is a list of all coordinates visible to both the agents involved in the interaction
        .findall(m(-XR+X,-YR+Y,empty),.member(p(X,Y),Coord)&not(.member(m(-XR+X,-YR+Y,goal),G))&not(.member(m(-XR+X,-YR+Y,obs),O))&not(.member(m(-XR+X,-YR+Y,Ag),T)) & math.abs(-XR+X)+math.abs(-YR+Y)<=5,Empty);
        .concat(G,O,T,Empty,FinalScene);
        .broadcast (achieve,areyou(XR,YR,AX,AY,FinalScene,PID,S,OL)[critical_section(sync), priority(2)]);

        .

+!sincMap(_,_,_,_,_) <- true.

  */

  //sincMap: the sync process
+!sincMap(XR,YR): origin(OL) & //originlead(OL) &
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



        .findall(m(-XR+I,-YR+J,goal),goal(I,J) & math.abs(-XR+I)+math.abs(-YR+J)<=5 ,G);
        .findall(m(-XR+I,-YR+J,obst),obstacle(I,J) & math.abs(-XR+I)+math.abs(-YR+J)<=5 ,O);
        .findall(m(-XR+I,-YR+J,TYPE),thing(I,J,_,TYPE) & math.abs(-XR+I)+math.abs(-YR+J)<=5,T);
        ?coord(0,0,XR,YR,[],Coord); //Coord is a list of all coordinates visible to both the agents involved in the interaction
        .findall(m(-XR+X,-YR+Y,empty),.member(p(X,Y),Coord)&not(.member(m(-XR+X,-YR+Y,goal),G))&not(.member(m(-XR+X,-YR+Y,obs),O))&not(.member(m(-XR+X,-YR+Y,Ag),T)) & math.abs(-XR+X)+math.abs(-YR+Y)<=5,Empty);
        .concat(G,O,T,Empty,FinalScene);
        .broadcast (achieve,areyou(XR,YR,AX,AY,FinalScene,PID,S,OL)[critical_section(sync), priority(2)]);

        .

+!sincMap(_,_) <- true.


//TODO: merge areyou/7, areyou8, and do_areyou when possible (conditions overlapping)

//areyou/7 - Case 1.0: empty scene -> it is not possible to check whether is a neighbour
+!areyou(XR,YR,AX,AY,[],PID,STEP,MapId).

//areyou/7 - Case 1.1: ignore self areyou
+!areyou(RX,RY,AX,AY,SCENE,PID,STEP,MapId)[source(AG)] : .my_name(AG).

+!areyou(XR,YR,AX,AY,[],PID,STEP,MapId) : not exploring.

//+!areyou(XR,YR,AX,AY,SCENE,PID,STEP,MapId)[source(AG)] : not(originlead(MapId))
   //<- .print("############ Received areyou from ", AG, " MapId: ", MapId, "  -  Step: ", STEP).
//   .

//areyou/7 - Case 2: The agent is some step behind the sender (perceptions may be outdated) -> wait until reaching the same step of the sender, then add the intention areyou/8
+!areyou(RX,RY,AX,AY,SCENE,PID,STEP,MapId)[source(AG)] : step(S) & S<STEP
   <- //.print("1 Received areyou from ", AG, " MapId: ", MapId, "  -  Step: ", STEP,"/",S, " PID: ", PID);
      .wait(step(ST)&ST>=STEP); //wait until to reach the same step of the sender
      //.print("...resuming areyou PID ", PID);
      !areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId).


+!areyou(RX,RY,AX,AY,SCENE,PID,STEP,MapId)[source(AG)] : step(S) & S>STEP <- .send( AG,achieve, isme(PID) ).
  //<-  .print("=======================================AHEADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ######################").

//areyou/7 - Case 3: The agent is in the same step (or ahead) as the sender -> add the intention areyou/8
+!areyou(RX,RY,AX,AY,SCENE,PID,STEP,MapId)[source(AG)]
   <- //.print("2 Received areyou from ", AG, " MapId: ", MapId, "  -  Step: ", STEP,"/",S, " PID: ", PID);
      !areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId).

+!areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId) : not exploring.

//areyou/8 - Case 1: The agent is in the same step as the sender but the position has not been updated in the current step -> wait for updating the position
+!areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId): step(S) & S<=STEP & update_position_step(U) & U<S
   <- .wait(update_position_step(UPS)&step(STP)&STP>=UPS&STP==STEP); //wait until (i) the perceptions of the map are updated in the current step or (ii) step is higher that updating (stopped to explore or problems in the exploration)
      //!do_areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId)[critical_section(sync), priority(2)].
      !do_areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId).

//areyou/8 - Case 2: The agent is in the same step as the sender but the position has been updated in the current step -> proceed to synchronize
+!areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId): step(S) & S==STEP & update_position_step(U) & U==S
   <- //!do_areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId)[critical_section(sync), priority(2)].
      !do_areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId).

//areyou/8 - Case 3: The agent is not in a different step as the sender or the position updating is ahead the sender's step -> ignore the synchronization
+!areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId).


//Case 2: the agent is not synchronized: returns an isme achieve message and add the pending_isme belief
+!do_areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId):
        thing(-RX,-RY,entity,TEAM) & team(TEAM)  &
        checkscene(SCENE) &
        //not (origin(OL) & originlead(OL)) &
        not (origin(MapId)) &
        myposition(MX,MY) &
        step(S) & S==STEP & update_position_step(STEP) //sync. when the areyou request sent and received in the same step. ToDo: Maybe not necessary after discover the inconsistent position problem
    <-
        +pending_isme(PID,MX,MY,AG,RX,RY,AX,AY,MapId);
        .send( AG,achieve, isme(PID) );
        //.print("1. Areyou ",RX,",",RY,",",AX,",",AY,",",SCENE,",",PID,") from ", AG, " Coord.: (",X,",",Y,")  MyPos: (",MX,",",MY,")   Step: ", S,"/",STEP);
        
       //calcular o raio do mapa
       +agentA_data(PID,RX,RY,AX,AY,MapId,STEP); //dados do agente que iniciou a intera��o
       !checkPosition(PID,STEP,MapId); // coleta os dados do agente vizinho.
        .

//Case 3: the agent is already synchronized: returns an isme message to avoid a false positive, but does not add the pending_isme belief to not sync again
+!do_areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId):
        thing(-RX,-RY,entity,TEAM) & team(TEAM)  &
        checkscene(SCENE) &
        step(S)
    <-
        .send( AG,achieve, isme(PID) );
        //.print("2. Areyou ",RX,",",RY,",",AX,",",AY,",",SCENE,",",PID,") from ", AG, " Coord.: (",X,",",Y,")  MyPos: (",MX,",",MY,")    Step: ", S,"/",STEP);
       
       //calcular o raio do mapa 
       +agentA_data(PID,RX,RY,AX,AY,MapId,STEP); //dados do agente que iniciou a intera��o
       !checkPosition(PID,STEP,MapId); //verifica se � possivel coletar os dados do agente vizinho.
        .


//Case 3: the agent is already synchronized: returns an isme message to avoid a false positive, but does not add the pending_isme belief to not sync again
+!do_areyou(RX,RY,AX,AY,SCENE,PID,STEP,AG,MapId):
        thing(-RX,-RY,entity,TEAM) & team(TEAM)  &
        not(checkscene(SCENE)) &
        step(S)
    <-
        .send( AG,achieve, isme(PID) );
        //.print("3. Areyou ",RX,",",RY,",",AX,",",AY,",",SCENE,",",PID,") from ", AG, " Coord.: (",X,",",Y,")  MyPos: (",MX,",",MY,")    Step: ", S,"/",STEP);
        
        //calcular o raio do mapa 
       +agentA_data(PID,RX,RY,AX,AY,MapId,STEP); //dados do agente que iniciou a intera��o
       !checkPosition(PID,STEP,MapId); //verifica se � possivel coletar os dados do agente vizinho.
        .

+!do_areyou(_,_,_,_,_,_,_,_,_).

//Receiving messages of possible neighbours, adding their names to the possible neighbours list
//it is atomic to ensure that incoming messages of possible neighbours be processed one at a time, keeping the list of possible neighbours consistent
@isme[atomic]
+!isme(PID)[source(AG)]: pending_areyou(PID,Step,L)
    <- .concat([AG],L,NewL);
       -pending_areyou(PID,Step,L);
       +pending_areyou(PID,Step,NewL);
       //.print("### Received isme PID: ", PID, " - L", L, "  NewL: ",  NewL, " Step: ", Step , "###");
       .

+!isme(PID).


+pending_areyou(PID,S,[]) <- !!sync_areyou(PID)[critical_section(sync), priority(1)].

//Case 1: the minimum number of steps has not been achieved - wait for the next step
+!sync_areyou(PID) : pending_areyou(PID,S,L)  &
                     step(Step) & steps_for_sync(SS) & Step-S <= SS //the minimum number of steps has not been achieved
   <-  .wait(step(SNext) & SNext>Step);
       !sync_areyou(PID).
       

//Case 1.1: the minimum number of steps has not been achieved but the position has not been updated in the current step
+!sync_areyou(PID) : pending_areyou(PID,S,L)  &
                     step(Step) & steps_for_sync(SS) & Step-S > SS & //the minimum number of steps has been achieved
                     not(update_position_step(Step)) //the position has not been updated in the current step
   <-  .wait(step(Current)&update_position_step(Supdate)&Supdate>=Current);
       !sync_areyou(PID).      
       
//Case 2: the minimum number of steps has been achieved and there is a potential neighbour - the neighbour is achieved and must sync  
+!sync_areyou(PID) : pending_areyou(PID,S,L)  &
                     step(Step) & steps_for_sync(SS) & Step-S > SS & //the minimum number of steps has been achieved
                     update_position_step(Step) & //the position has been updated in the current step
                     .length(L,Size) & Size==1 & .nth(0,L,Ag) //
   <-  //.print("2. sync_areyou steps achieved ONE answer PID: ", PID, "  S: ", S, "  Step: ", Step, " Ag: ", Ag, " L: ", L);
       //.send( Ag, achieve, sync_isme(PID)[critical_section(sync), priority(0)]); //sends a message to the neighbour to update its coordinates
       .send( Ag, achieve, sync_isme(PID)); //sends a message to the neighbour to update its coordinates
       //.send( Ag, achieve, sync_isme(PID)); //sends a message to the neighbour to update its coordinates
       //-pending_areyou(PID,S,L). //the update of this PID is no longer pending
       
       //CALCULO DO RAIO- se o outro agente for realmente um vizinho, manda ele executar mapSize.
       ?name(AgentName);
       ?origin(ORIGIN);
       .send(Ag, achieve, mapSize(PID,AgentName,ORIGIN));
       .

//Case 3: the minimum number of steps has been achieved and there is zero or more than one potential neighbours
+!sync_areyou(PID) : pending_areyou(PID,S,L)  &
                     step(Step) & steps_for_sync(SS) & Step-S > SS &
                     .length(L,Size) & Size\==1
   //<-
      //-pending_areyou(PID,S,L).
      .
+!sync_areyou(PID).

//sync_isme(PID): synchronize the coordinates given in referred PID
//(MX,MY): position of the agent when meets with AG
//(RX,RY): relative position of the agent with respect to AG
//(AX,AY): position of AG when meets with the agent
@sync_isme[atomic]   //atomic to avoid update the coordinates before (i) finishing the plan and (ii) start a parallel update
+!sync_isme(PID)[source(AG)] : pending_isme(PID,MX,MY,AG,RX,RY,AX,AY,Map)  & origin(OL) & not (originlead(OL)) & myposition(Xnow,Ynow)  &
                               step(Step) & update_position_step(Step) //synchronize only if the agent has updated its position in the current step
                               & originlead(Map)            
   <-  
       .abolish(update_position_step(_));
       .perceive;
       .abolish(goal(_,_)); .abolish(obstacle(_,_)); .abolish(thing(_,_,_,_));

       ?myposition(Xnow_2,Ynow_2);
       -+myposition(AX+RX + (Xnow_2-MX), AY+RY + (Ynow_2-MY));

       ?originlead(ORIGIN);
       OMX=AX+RX; //(OMX,OMY): position of the agent with respect to the origin of AG
       OMY=AY+RY;
       OLDORIGINX=OMX-MX; //origin of the agent with respect to the origin of AG
       OLDORIGINY=OMY-MY;                     
       .my_name(NAG);
       -+origin(ORIGIN);   
       for (gps_map(X,Y,TYPE,MapId) & compare_bels(MapId,OL) & OL\==ORIGIN){
           !sync_mark(OLDORIGINX+X,OLDORIGINY+Y,TYPE, NAG,ORIGIN);
           //.print("...ARE YOU 1- mark(", OLDORIGINX+X,",",OLDORIGINY+Y,",",TYPE,",", MapId,") OldMap: ", OL, " OldOrigin: (",OLDORIGINX,",",OLDORIGINY,")  Original Pos:(",X,",",Y,")  Current Pos: (",OMX + (Xnow-MX),",",OMY + (Ynow-MY),")  My Pos: (",MX,",",MY,")- PID: ", PID);
       }       
       //-+origin(ORIGIN);
       .my_name(Me);
       replaceMap(OL,ORIGIN,AX+RX-MX,AY+RY-MY,Me); //remove the old map from the shared representation
       .abolish(map(OL,_,_,_));      
       ?step(S); //.print("... SYNC areyou origin: ", ORIGIN, " Agent: ", AG, " Step ", S, " from(",Xnow_2,",",Ynow_2,") to (",AX+RX + (Xnow_2-MX),",",AY+RY + (Ynow_2-MY)," - PID: ", PID); 
       .abolish(pending_isme(_,_,_,_,_,_,_,_,_)); //discard pending synchronizations after sync
       .abolish(to_replace_map(_,_,_,_,_)); //discard map replacement after sync     
       .abolish(agentA_data(_,_,_,_,_,_,_)); //discard map size data 
       .abolish(my_data(_,_,_)); //discard map size data
       
       !after_sync(PID). 



//+!sync_isme(PID)[source(AG)] : pending_isme(PID,_,_,_,_,_,_,_,_) &  pending_isme(PID2,_,_,_,_,_,_,_,_) & PID\==PID2
//   <- .abolish(pending_isme(_,_,_,_,_,_,_,_)). //discard pending synchronizations after synching

//sync_isme(PID): synchronize the coordinates given in referred PID
//(MX,MY): position of the agent when meets with AG
//(RX,RY): relative position of the agent with respect to AG
//(AX,AY): position of AG when meets with the agent
@sync_isme2[atomic]   //atomic to avoid update the coordinates before (i) finishing the plan and (ii) start a parallel update
+!sync_isme(PID)[source(AG)] : pending_isme(PID,MX,MY,AG,RX,RY,AX,AY,ORIGIN)  & origin(OL) & not (originlead(OL)) & myposition(Xnow,Ynow)  &
                               step(Step) & update_position_step(Step) //synchronize only if the agent has updated its position in the current step
                               //& not originlead(Map) 
                               & ORIGIN < OL           
   <-  .abolish(update_position_step(_));
       .perceive;
       .abolish(goal(_,_)); .abolish(obstacle(_,_)); .abolish(thing(_,_,_,_));

       ?myposition(Xnow_2,Ynow_2);
       -+myposition(AX+RX + (Xnow_2-MX), AY+RY + (Ynow_2-MY));

       //?originlead(ORIGIN);
       OMX=AX+RX; //(OMX,OMY): position of the agent with respect to the origin of AG
       OMY=AY+RY;
       OLDORIGINX=OMX-MX; //origin of the agent with respect to the origin of AG
       OLDORIGINY=OMY-MY;                     
       .my_name(NAG);   
       -+origin(ORIGIN);       
       for (gps_map(X,Y,TYPE,MapId) & compare_bels(MapId,OL) & OL\==ORIGIN){
           !sync_mark(OLDORIGINX+X,OLDORIGINY+Y,TYPE, NAG,ORIGIN,PID);
           //.print("...ARE YOU 2 - mark(", OLDORIGINX+X,",",OLDORIGINY+Y,",",TYPE,",", MapId,") OldMap: ", OL, " OldOrigin: (",OLDORIGINX,",",OLDORIGINY,")  Original Pos:(",X,",",Y,")  Current Pos: (",OMX + (Xnow-MX),",",OMY + (Ynow-MY),")  My Pos: (",MX,",",MY,")- PID: ", PID);
       }       
       //-+origin(ORIGIN);
       .my_name(Me);
       replaceMap(OL,ORIGIN,AX+RX-MX,AY+RY-MY,Me); //remove the old map from the shared representation
       .abolish(map(OL,_,_,_));
       ?step(S); //.print("... SYNC 2 areyou origin: ", OL, " New Map: ",ORIGIN ," Agent: ", AG, " Step ", S, " from(",Xnow_2,",",Ynow_2,") to (",AX+RX + (Xnow_2-MX),",",AY+RY + (Ynow_2-MY),") - PID: ", PID);
       .abolish(pending_isme(_,_,_,_,_,_,_,_,_));  //discard pending synchronizations after synching             
       .abolish(to_replace_map(_,_,_,_,_)); //discard map replacement after sync
       .abolish(agentA_data(_,_,_,_,_,_,_)); //discard map size data 
       .abolish(my_data(_,_,_)); //discard map size data   
       !after_sync(PID).

//If the agent has not updated its position in the current step, ignore the synchronization
+!sync_isme(PID)[source(AG)] : pending_isme(PID,MX,MY,AG,RX,RY,AX,AY,Map) & step(Step) & not(update_position_step(Step))
   <- -pending_isme(PID,_,_,_,_,_,_,_,_).



+!sync_isme(PID).

//when testing (STC mainly) under a known field size, must adapt the coordinates
+!sync_mark(X,Y,Type,Agent,MapId,PID) : testing_exploration &
                                    field_size(S) & S >0 & field_center(C) &
                                    (math.abs(X)>C | math.abs(Y)>C) &
                                    adapt_coordinate_map(X,XX) & adapt_coordinate_map(Y,YY) &
                                    step(Step)   
   <- 
      .concat(Agent, " Sync - Step: ", " PID: ", PID, Step, Legend);      
      //.print("sync mark 1");
      !sync_mark(XX,YY,Type,Legend,MapId, PID).                                    



//when testing (STC mainly) under a known field size, must adapt the coordinates
+!sync_mark(X,Y,Type,Agent,MapId) : testing_exploration & 
                                    field_size(S) & S >0 & field_center(C) &
                                    (math.abs(X)>C | math.abs(Y)>C) &
                                    adapt_coordinate_map(X,XX) & adapt_coordinate_map(Y,YY) &
                                    step(Step)   
   <- 
      .concat(Agent, " Sync - Step: ", " PID: ", PID, Step, Legend);
      //.print("sync mark 2 X: ", X, ", Y: ", Y, " XX: ", XX, "YY: ", YY, " Type: ", Type, "  Map: ", MapId);      
      !sync_mark(XX,YY,Type,Legend,MapId).                                    


+!sync_mark(X,Y,Type,Agent,MapId,PID) : originlead(MapId)
   <- mark(X,Y,Type,Agent,0,MapId).


+!sync_mark(X,Y,Type,Agent,MapId,PID) : not(originlead(MapId))
   <- mark(X,Y,Type,MapId). 



+!sync_mark(X,Y,Type,Agent,MapId) : originlead(MapId)
   <- mark(X,Y,Type,Agent,0,MapId).

+!sync_mark(X,Y,Type,Agent,MapId) : not(originlead(MapId))
   <- mark(X,Y,Type,MapId). 






//after_sync: if necessary to run something else after sync, add the belief run_after_sinc and implement a plan in the agent
/*+!after_sync(PID) :  pending_isme(PID,_,_,_,_,_,_,_,_) & not(run_after_sync)
   <-
      -pending_isme(PID,_,_,_,_,_,_,_,_).
*/

//after_sync: if necessary to run something else after sync, add the belief run_after_sinc and implement a plan in the agent
+!after_sync(PID) : not(run_after_sync).
