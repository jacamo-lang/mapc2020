/**
 * Send an achieve performative to a zombie
 */
+!command_zombie(Z,A) 
    <-
    .log(warning,zombie_do(A));
    .send(Z,achieve,zombie_do(A));
    .concat("[",zombie_do(A),"]",C);
    .save_stats("command_zombie",C);
.

+!zombie_do(A) 
    <-
    !do(A,R);
    .concat("[",do(A,R),"]",C);
    .save_stats("zombie_do",C);
.

+!synchronous_connect(Z,IM,JM,IZ,JZ):
    step(AS2) &
    .my_name(ME)
    <-
    !do(connect(Z,IM,JM),RMM0);
    !command_zombie(Z,connect(ME,IZ,JZ));
    .concat("[",connect(ME,IZ,JZ),"]",C5);
    .save_stats("do_connect",C5);
        
   .wait( step(NS) & NS > AS2 );
    if (not (lastAction(connect) & lastActionResult(success))) {
        !synchronous_connect(Z,IM,JM,IZ,JZ);
    }
.
