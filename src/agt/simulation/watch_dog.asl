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

{ include("tasks/drop_block.asl") }

no_action_step_count(-1,0). // oldest consecutive no_action step, count of no_action
max_no_action_in_a_row(1).

/**
 * An excessive no_actions in a row was detected
 */
+lastAction(no_action) :
    step(S) &
    no_action_step_count(_,C) &
    max_no_action_in_a_row(M) &
    .my_name(ME) &
    C >= M
    <-
    .log(severe,"****** Restarting due to no_action!");
    .concat("[",no_action(ME),",",step(S),"]",STR);
    .save_stats("restarted_noact",STR);
    !restart_agent;
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

@restart_agent[atomic]
+!restart_agent
    <-
    .log(severe,"****** Restarting:  dropping all desires, intentions, events and blocks!");
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;
    !drop_all_blocks;
    !!restart;
    -+no_action_step_count(S,0);
.

/**
 * Based on !start of agentBase - just do not change origin(NAME)
 */
+!restart :
    step(S)
    <-
    !do(skip,R);
    .wait(step(Step) & Step > S); //wait for the next step to continue
    +exploring;
    !explore[critical_section(action), priority(1)]
.

/**
 * Return to individual reseted map considering this as 0,0 position
 */
@[atomic]
+status(lost) :
    .my_name(ME) &
    .term2string(ME,MEStr) &
    step(S)
    <-
    .log(severe,"****** Restarting because I am lost!");
    .concat("[",lost(ME),",",step(S),"]",STR);
    .save_stats("restarted_lost",STR);
    .abolish(gps_map(_,_,_,ME));
    .abolish(gps_map(_,_,_,MEStr));
    removeMyCFPs;
    -+myposition(0,0);
    -+origin(ME);
    .abolish(status(lost));
    !!restart_agent;
.
