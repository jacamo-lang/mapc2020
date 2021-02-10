/**
*/

+!inform_map(AG,MAP)
     <-
     -map(AG,_);
     +map(AG,MAP);
.

/**
 * The map of the master/helper has changed. Did it reset? Found another map?
 * If the another agent has not the same map, a current commited task cannot
 * be kept.
 */
+map(AG,MAP):
    (status(AG,performing(_),team(AG,Helper)) & not map(Helper,MAP)) |
    (status(AG,performing(_),team(Master,AG)) & not map(Master,MAP))
    <-
    .send(AG,achieve,drop_task);
    .send(Helper,achieve,drop_task);
.

@[atomic]
+!find_helper(BH,AG,T,MAP):
    map(Helper,MAP) &
    Helper \== AG &
    not status(AG,performing(_),_) &
    not status(Helper,performing(_),_)
    <-
    +status(AG,performing(T),team(AG,Helper));
    +status(Helper,performing(T),team(AG,Helper));
    .send(AG,achieve,master_task(T,Helper));
.

+!find_helper(BH,AG,T,MAP). // there is no helper

// Someone has achieve this task or it is not necessary anymore
+unwanted_task(T,_)
    <-
    .abolish(status(_,performing(T),_));
.

+!areyou(_,_,_,_,_,_,_,_) <- true.

+simStart :
    step(0)
    <-
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;
    .abolish(_);
.
