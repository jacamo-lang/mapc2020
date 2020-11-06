/**
 * In the "first free" strategy, agents buildmasters make a broadcast 
 * for the agents and the first agents helpers respond to the call are hired.
 * A helper just respond a call if it not hired.
 * After a 1000 ms, buildmasters revoke the call for hiring
 * A buildmaster can't be hired by other buildmaster
 * */

/***************************** common ****************************** */
//R=0 means agent is a buildmaster
buildmaster(R) :- helpersquantity(Q) & id(ID) & R = ID mod Q+1.

id(AUX) :- name(NAME) & 
          .delete("agenta",NAME,ID) &
          .term2string(AUX,ID). 
/***************************** master ****************************** */
+!hire
  : buildmaster(0) & helpersquantity(Q) 
  <-
    +helperscounter(Q);
    .broadcast(tell, hiring);   
    !!hiredeadline; 
  .

+!hire <- true . 

+!hiredeadline
    : true
    <-
        .wait(1000);
        if (helperscounter(C) & C>0 ) {
            .broadcast(untell, hiring);
        }
    .

@t1[atomic] 
+?hireme(RESULT)[source(AGH)]
    : helperscounter(C) & C>0 
    <-
        -+helperscounter(C-1);
        +helper(AGH);
        .print("helper ->",AGH); //----------- debugger
        RESULT=hired;      
    .

@t2[atomic]   
+?hireme(RESULT)[source(AGH)]
    :true 
    <-
        RESULT=nothired;
    .

+helperscounter(0)
    : true
    <-
        .broadcast(untell, hiring);
        +readytobuild;
    .
    
/***************************** helper **************************** */
+hiring[source(AGM)]
    : not buildmaster(0) & not hired[source(_)]
    <-  
        .wait(name(_))
        !candidateapplying(AGM);
    .

@t3[atomic] 
+!candidateapplying(AGM) 
    : not buildmaster(0) & not hired[source(_)]
    <-  
        .send(AGM,askOne,hireme(_),hireme(RESULT));        
        +RESULT[source(AGM)];        
    . 
    
-!candidateapplying(AGM) 
    :  buildmaster(0) 
    <- true.
    
-!candidateapplying(AGM) 
    : not hired & not nothired[source(AGM)]
    <-
        !candidateapplying(AGM);
    .
-!candidateapplying(AGM) 
    <- true.
