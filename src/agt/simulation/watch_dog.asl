/**
 * Shameful macgyvering workaround for many situations where agents are crashing 
 * and I don't know why and how to resolve it properly.
 *
 * It is counting how many no_action in a row it is happening. Sometimes,
 * I saw that the agent resumed after one missed step (I guess due to a seldom
 * very expensive process).
 * In my observations I did not see any situation in which the agent get back
 * after two missed steps in a row, that is why I am using this parameter.
 */

no_action_step_count(-1,0). // oldest consecutive no_action step, count of no_action
max_no_action_in_a_row(1).

/**
 * An excessive no_actions in a row was detected
 */
+lastAction(no_action) :
    step(S) &
    no_action_step_count(_,C) &
    max_no_action_in_a_row(M) &
    C >= M
    <-
    .log(severe,"****** Restarting due to no_action: dropping all desires, intentions and events!");
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;
    -+exploring;
    !!start;
    -+no_action_step_count(S,0);
.
/**
 * This is NOT the first no_action in a row -> INCREMENT
 */
+lastAction(no_action) :
    step(S) &
    no_action_step_count(ONAS,C) &
    ONAS + C == S
    <-
    -+no_action_step_count(ONAS,C+1);
.
/**
 * This is the first no_action in a row
 */
+lastAction(no_action) :
    step(S)
    <-
    -+no_action_step_count(S,1);
.