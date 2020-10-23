/**
 * This library intends to solve the problem of going to a specific dispenser
 * and attaching block(s)
 * It tries to go to the nearest dispenser of B doing a valid approximation
 * to the dispenser to then attach the specifc block
 */


/**
 *TODO: It is necessary to put into this library the capability to Rotate since
 *it is possible to have requerements of multiple blocks, so, the position of
 * existing ones should be also solved
 */
//dockpoint(B,ID+1,JD):- gps_map(ID,JD,B,"agenta1") &
//                    gps_map(ID+1,JD,obstacle,"agenta1") &
//                    gps_map(ID+1,JD-1,obstacle,"agenta1") &
//                    gps_map(ID+1,JD+1,obstacle,"agenta1") &
//                    gps_map(ID+2,JD,obstacle,"agenta1").
//
//dockpoint(B,ID,JD-1):- gps_map(ID,JD,B,"agenta1") &
//                    gps_map(ID,JD-1,obstacle,"agenta1") &
//                    gps_map(ID-1,JD-1,obstacle,"agenta1") &
//                    gps_map(ID+1,JD-1,obstacle,"agenta1") &
//                    gps_map(ID,JD-2,obstacle,"agenta1").
//
//dockpoint(B,ID,JD+1):- gps_map(ID,JD,B,"agenta1") &
//                    gps_map(ID,JD+1,obstacle,"agenta1") &
//                    gps_map(ID-1,JD+1,obstacle,"agenta1") &
//                    gps_map(ID+1,JD+1,obstacle,"agenta1") &
//                    gps_map(ID,JD+2,obstacle,"agenta1").
 
+!get_block(B) :
    myposition(X,Y) &
    (thing(ID,JD,dispenser,B) & distance(0,0,ID,JD,1) & direction_increment(DD,ID,JD)) & // direction of the dispenser
    not attached(ID,JD) &
    .my_name(ME)
    <-
    !do(request(DD),R0);
    !do(attach(DD),R1);
    if (R1 == success) {
        .log(warning,"I have attached a block ",B);
        .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,BB), L);
        .findall(t(I,J,T),thing(I,J,T,_), LT);
        .concat("[",req(I,J,B),",",myposition(X,Y),",",R0,"/",R1,"]",STR);
        .save_stats("blockAttached",STR);
    } else {
        .log(warning,"Could not request/attach block ",B, "::",R0,"/",R1," my position: (",X,",",Y,"), target (",I,",",J,")");
        .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,BB), L);
        .findall(t(I,J,T),thing(I,J,T,_), LT);
        .concat("[",req(I,J,B),",",myposition(X,Y),",",R0,"/",R1,"]",STR);
        .save_stats("errorOnAttach",STR);
    }
.
+!get_block(B) :  // In case the agent is far away from B
     gps_map(X,Y,B,"agenta1") 
     <-              
     ?myposition(X0,Y0);
     .print(myposition(X0,Y0)," ==> ", end(X-1,Y));
     !goto(X-1,Y,RET);
     !get_block(B);
.
+!get_block(B) : 
     not gps_map(X,Y,B,"agenta1")     
     <-         
     .print("================= passou batido ====================");
.


