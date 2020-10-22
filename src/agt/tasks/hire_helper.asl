/**
 * This library intends to solve the problem of going to a taskboard
 * and accepting a task.
 * It tries to go to the nearest taskboard doing a valid approaximation
 * to the taskboard and returns with the given task accpeted
 */

 /**
  * Accept a task (need to be close to a taskboard)
  */
+!hire(AG)
    : not master(_) & not helper(_)
        <-
            .send(AG,askOne,hireyou(_),hireyou(RESULT));
            if (RESULT) {
                +helper(AG); 
                 .print("HELPER ->",AG); //----------- debugger
            }                   
        .
+!hire(AG)
    : master(_) | helper(_)
        <-  true .
        
        
@t1[atomic] 
+?hireyou(RESULT)[source(AGH)]
    :  not master(_) & not helper(_)
    <-
        +master(AGH);
        .print("MASTER ->",AGH); //----------- debugger
        RESULT=true;      
    .

@t2[atomic]   
+?hireyou(RESULT)[source(AGH)]
    :true 
    <-
        RESULT=false;
    .
