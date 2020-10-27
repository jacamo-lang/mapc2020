/**
 * Send an achieve performative to a zombie
 */
+!command_zombie(Z,P) : 
   step(S)
    <-
    .log(warning,zombie_do(P,S));
    .send(Z,achieve,zombie_do(P,S));
    .concat("[",P,"]",C);
    .save_stats("command_zombie",C);
.

+!zombie_do(P,S) 
    <-
    !P;
    .concat("[",P,"]",C);
    .save_stats("zombie_do",C);
.

+!synchronous_connect(Z,IM,JM,IZ,JZ):
    step(AS2) &
    .my_name(ME)
    <-
    !do(connect(Z,IM,JM),RMM0);
    !command_zombie(Z,do(connect(ME,IZ,JZ),RZZ1));
    .concat("[",do(connect(ME,IZ,JZ),RZZ1),"]",C5);
    .save_stats("do_connect",C5);
        
   .wait( step(NS) & NS > AS2 );
    if (not (lastAction(connect) & lastActionResult(success))) {
        !synchronous_connect(Z,IM,JM,IZ,JZ);
    }
.
            
