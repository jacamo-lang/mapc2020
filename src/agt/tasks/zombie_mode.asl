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
    if (step(Step) & Step > S) { //zombie is ahead of master
        !do(skip,_);
    }
    !P;
    .concat("[",P,"]",C);
    .save_stats("zombie_do",C);
.
