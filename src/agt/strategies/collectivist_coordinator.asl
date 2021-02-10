/**
*/

+!inform_map(AG,MAP)
     <-
     -map(AG,_);
     +map(AG,MAP);
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
    .send(AG,achieve,master(T,Helper));
.

+!find_helper(BH,AG,T,MAP). // there is no helper

// Someone has achieve this task or it is not necessary anymore
+unwanted_task(T,_)
    <-
    .abolish(status(_,performing(T),_));
.

+!areyou(_,_,_,_,_,_,_,_) <- true.
