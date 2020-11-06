/**
 * 
 */

 /**
  * important belief
  * master(AG), AG is the name of master builder 
  * helper(AG), AG is the name of helper builder
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
