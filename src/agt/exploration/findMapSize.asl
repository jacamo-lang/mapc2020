+raioX(Rx)
<-.print("# RaioX: ",Rx).
+raioy(Ry)
<-.print("# Raioy: ",Ry).


+!mapSize(PID,AgentName,ORIGIN) : agentA_data(PID,RX,RY,AX,AY,MapId,S) & //dados do agente que começou a interação
                                  my_data(PID,MX,MY) &  //meus dados
                                  origin(ORIGIN)  //está no mesmo mapa do outro agente     
   <- 
   !update_raioX(math.abs(MX-(AX+RX)));
   !update_raioY(math.abs(MY-(AY+RY))).
   
+!mapSize(PID,AgentName,ORIGIN).    


+!update_raioX(CalcX) : CalcX == 0.

+!update_raioX(CalcX) : CalcX \== 0 & 
                        //not raioX(_) &
                        not raioX(CalcX) & //se o valor calculado é novo
                        step(S) & .my_name(Me)
<-  +raioX(CalcX);
    //.send(explorationMonitor,tell,raioX(CalcX,S,Me)); //for testing 
    setMapSize("x",CalcX);
    //.broadcast (tell,raioX(CalcX));
    .
/* 
+!update_raioX(CalcX) : CalcX \== 0 & raioX(Rx) & CalcX < Rx
<-  //updateRaioX(Rx, CalcX);
    .broadcast (tell,raioX(CalcX)).
    * */
    
+!update_raioX(CalcX).  


+!update_raioY(CalcY) : CalcY == 0.

+!update_raioY(CalcY) : CalcY \== 0 & 
                        //not raioY(_)&
                        not raioY(CalcY)& //se o valor calculado é novo
                        step(S) & .my_name(Me)
<-  +raioY(CalcY);
    //.send(explorationMonitor,tell,raioY(CalcY,S,Me));
    setMapSize("y",CalcY);
    //.broadcast (tell,raioY(CalcY));
    .

/* 
+!update_raioY(CalcY) : CalcY \== 0 & raioY(Yx) & CalcY < Ry
<-  //updateRaioX(Ry, CalcY);
    .broadcast (tell,raioY(CalcY)). 
    */
+!update_raioY(CalcY).



+!checkPosition(PID,STEP,MapId) : step(S) & S<STEP 
   <- .wait(step(ST)&ST>=STEP); //wait until to reach the same step of the sender
      !checkPosition(PID,STEP,MapId) .  
      
+!checkPosition(PID,STEP,MapId): step(S) & S==STEP & update_position_step(U) & U<S
   <- .wait(update_position_step(UPS)&step(STP)&STP>=UPS); //wait until (i) the perceptions of the map are updated in the current step or (ii) step is higher that updating (stopped to explore or problems in the exploration)
      !collectPosition(PID,STEP,MapId).           

+!checkPosition(PID,STEP,MapId) : step(S) & S==STEP & update_position_step(U) & U==S
   <- !collectPosition(PID,STEP,MapId). 

+!checkPosition(PID,STEP,MapId).

  

+!collectPosition(PID,STEP,MapId)  : step(STEP) & origin(MapId) & update_position_step(STEP)// certifica-se de estarem no mesmo mapa
    <-   ?myposition(MX,MY);
         +my_data(PID,MX,MY).
           
+!collectPosition(PID,STEP,MapId). 
