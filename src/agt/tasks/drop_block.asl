
/**
 * If the agent decide to do something else, this plan
 * detaches all blocks, dropping them on the ground
 */
+!drop_all_blocks : // Fail on submitting task
   .findall(attached(I,J),attached(I,J),LA)
    <-
    .log(warning,"I will drop the ", .length(LA) ," blocks I have attached.");
    for ( .member(attached(I,J),LA) & directionIncrement(D,I,J)) {
        !do(detach(D),R1);
        if (R1 \== success) {
          .log(warning,"Fail on detaching block on ",D);
        }
    }
.
