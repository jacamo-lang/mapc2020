/**
 * Send an achieve performative to a zumbi
 */
+!command_zumbi(Z,P) : 
   step(S)
    <-
    .log(warning,zumbi_do(P,S));
    .send(Z,achieve,zumbi_do(P,S));
    .concat("[",P,"]",C);
    .save_stats("command_zumbi",C);
.

+!zumbi_do(P,S) 
    <-
    if (step(Step) & Step > S) { //zumbi is ahead of master
        !do(skip,_);
    }
    !P;
    .concat("[",P,"]",C);
    .save_stats("zumbi_do",C);
.
