/**
 * The coordinator uses agents in the same map to make teams
 */
+!inform_map(AG,MAP)
     <-
     -map(AG,_);
     +map(AG,MAP);
.

/**
 * The master or helper has restarted. A current commited task cannot
 * be kept.
 */
+restarted(AG):
    status(AG,performing(_),team(Master,Helper))
    <-
    .send(Master,achieve,drop_task);
    .send(Helper,achieve,drop_task);
    -status(_,performing(_),team(Master,Helper));
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

+task_done(T,ME,Helper)
    <-
    -status(_,performing(T),team(Master,Helper));
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
