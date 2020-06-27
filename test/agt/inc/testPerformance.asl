/**
 * Performance meter helpers
 */

getIntentionId(I,ID) :- I =.. A & .nth(2,A,B) & .nth(0,B,ID).

/**
 * Check the performance of executing a plan
 */
@checkPerformance[atomic]
+!checkPerformance(P,N) :
    .current_intention(I) &
    getIntentionId(I,ID)
    <-
    -+mean(0);
    -+vl(0);
    while(vl(X) & X < N) {
      .nano_time(T0);
      !P;
      .nano_time(T1);
      ?mean(M);
      -+mean(M+((T1-T0)/N));
      -+vl(X+1);
    }
    /*
    for (.range(I,1,N)) {
    }
    */
    ?mean(MEAN);
    .print("Time intention ",ID,": ",MEAN/1000,"ms");
.
-!checkPerformance(X,Y) :
    true
    <-
    .send(testController,tell,error);
.
