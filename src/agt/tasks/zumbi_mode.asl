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

+!zumbi_do(P,S) :
    true
    <-
    .wait(step(Step) & Step > S); //wait to synchronize with master
    !P;
    .concat("[",P,"]",C);
    .save_stats("zumbi_do",C);
.
