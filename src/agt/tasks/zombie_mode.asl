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

+!zombie_do(A)[source(Master)] 
    <-
    !just_do(A);
    .concat("[",just_do(A),"]",C);
    .save_stats("zombie_do",C);
.

+!synchronous_connect(Z,IM,JM,IZ,JZ):
    step(S) &
    .my_name(MEE) &
    .substring(MEE,ID,6) &
    .concat("agentJaCaMo_Builders",ID,ME) &
    .substring(Z,IDZ,6) &
    .concat("agentJaCaMo_Builders",IDZ,ZZ)
    <-
    !just_do(connect(ZZ,IM,JM));
    !command_zombie(Z,connect(ME,IZ,JZ));
        
    .wait(step(NS) & NS > S); // wait massim return with lastActionResult
    .wait(300); // give a few milli seconds to make sure zombie is also in the new step
    ?lastAction(LA);
    ?lastActionResult(LR);
    .send(Z,askOne,lastAction(ZA),LZA[_]);
    .send(Z,askOne,lastActionResult(ZR),LZR[_]);
    .concat("[",lastAction(LA),",",lastActionResult(LR),",",LZA,",",LZR,"]",C);
    .save_stats("do_connect",C);

    if (not (lastAction(connect) & lastActionResult(success) & lastAction(connect) == LZA & lastActionResult(success) == LZR)) {
        !synchronous_connect(Z,IM,JM,IZ,JZ);
    }
.

+!synchronous_detach(Z,DIR):
    step(S) 
    <-
    !just_do(skip);
    !command_zombie(Z,detach(DIR));
        
    .wait(step(NS) & NS > S); // wait massim return with lastActionResult
    .wait(300); // give a few milli seconds to make sure zombie is also in the new step
    ?lastAction(LA);
    ?lastActionResult(LR);
    .send(Z,askOne,lastAction(ZA),LZA[_]);
    .send(Z,askOne,lastActionResult(ZR),LZR[_]);
    .concat("[",lastAction(LA),",",lastActionResult(LR),",",LZA,",",LZR,"]",C);
    .save_stats("do_detach",C);

    if (not (lastAction(skip) & lastActionResult(success) & lastAction(detach) == LZA & lastActionResult(success) == LZR)) {
        !synchronous_detach(Z,DIR);
    }
.
