/* Common beliefs, rules and plans for all the exploration strategies */

myposition(0,0).


originlead(agenta0).

directions([n,s,w,e]).

directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).

newpid(PID):-(PID=math.random(1000000) & not pid(PID)) | newpid(PID).

//testing_exploration. //<< if true, the exploration runs in test mode to count the found objects


+!mapping(success,Step,D): myposition(X,Y) & directionIncrement(D, INCX,  INCY) & step(S)
   <- -+myposition(X+INCX,Y+INCY);
      -+update_position_step(S);
      if(origin(OL) & originlead(OL)) {
            unmark(X,Y); 
            ?vision(Vision)
            .concat("",S,Info);
            mark(X+INCX, Y+INCY, self, Info,Vision);
        }           
        for (goal(I,J)) {           
            !addMap(I,J,X+INCX,Y+INCY,goal);
        }
        for (obstacle(I,J)) {
            !addMap(I,J,X+INCX,Y+INCY,obstacle);
        }
        for (thing(I,J,dispenser,TYPE)) {
            !addMap(I,J,X+INCX, Y+INCY,TYPE);
        }
        for (thing(I,J,entity,TEAM) & team(TEAM)) {
            !sincMap(I,J);
        }
   .
   
         
+!mapping(R,Step,D).



//To be used in testing exploration - The origin is the originLead (the one that draws in the viewer)
+!addMap(I,J,X,Y,TYPE) : testing_exploration & 
                         field_size(S) & S >0 &
                         adapt_coordinate_map(X+I,XX) & adapt_coordinate_map(Y+J,YY)  &
                         .my_name(AG) & origin(O) & originlead(O) & step(Step)  
    <-  .concat(AG," - Exp. Step ", Step, Hint); 
        if(origin(OL) & originlead(OL)) {
            mark(XX, YY, TYPE, Hint,0, O); //The last parameter is the map identifier              
        }           
    .

//The origin is the originLead (the one that draws in the viewer)
+!addMap(I,J,X,Y,TYPE) : .my_name(AG) & origin(O) & originlead(O)  
    <- if(origin(OL) & originlead(OL)) {
            mark(X+I, Y+J, TYPE, AG,0, O); //The last parameter is the map identifier              
       }   
    .
    
+!addMap(I,J,X,Y,self). //do not mark the agent position if it is not in the originlead map    
    
+!addMap(I,J,X,Y,TYPE) : origin(O)
   <- mark(X+I, Y+J, TYPE,  O); //The last parameter is the map identifier                
     .
     
//TODO: Check the exception: No failure event was generated for +!addMap(-4,1,35,-141,obstacle)[code(mark(31,-140,obstacle,agenta1)),code_line(108),code_src(".../src/agt/exploration/common_exploration.asl"),env_failure_reason(env_failure(action_failed(mark,generic_error))),error(action_failed),error_msg("Action failed: mark(31,-140,obstacle,agenta1). null"),source(self)]
-!addMap(I,J,X,Y,TYPE).     
     
+!after_sync(PID).     