/**
 * Performance meter helpers
 */

intention_id(I,ID) :- I =.. A & .nth(2,A,B) & .nth(0,B,ID).

/**
 * Check the performance of executing a plan
 */
@check_performance[atomic]
+!check_performance(P,N) :
    .current_intention(I) &
    intention_id(I,ID)
    <-
    -+mean(0);
    for (.range(J,1,N)) {
      .nano_time(T0);
      !P;
      .nano_time(T1);
      ?mean(M);
      -+mean(M+((T1-T0)/N));
    }
    ?mean(MEAN);
    .print("Time intention ",ID,": ",math.round(MEAN/1000)," microseconds");
.
-!check_performance(X,Y) :
    true
    <-
    .send(test_controller,tell,error);
.
