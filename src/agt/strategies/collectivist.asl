/**
 * The collectivist is an agent that may act collectively with other agents
 * to build structures. It can be the 'master' of the task or a 'helper'.
 *
 * Key beliefs:
 * gps_map(X,Y,goal,_): The terrain X,Y is a goal spot [source(lps/rp artifact)]
 * gps_map(X,Y,B,_): There is a disposer of block B at X,Y in which (.nth(P,[b0,b1,b2,b3],B) & P >= 0) [source(lps/rp artifact)]
 * gps_map(X,Y,taskboard,_): There is a taskboard X,Y [source(lps/rp artifact)]
 * accepted(T): I am doing a task T [source(eis artifact)]
 * attached(I,J): I have a block attached on I,J [source(eis artifact)]
 * thing(I,J,O): I can see an object O on I,J (with attached you know the kind you have attached) [source(eis artifact)]
 */

{ include("tasks/common_task.asl") }
{ include("tasks/accept_task.asl") }
{ include("tasks/get_block.asl") }
{ include("tasks/rotate_block.asl") }
{ include("tasks/drop_block.asl") }
{ include("tasks/submit_task.asl") }
{ include("tasks/zombie_mode.asl") }
{ include("walking/common_walking.asl") }
{ include("walking/goto_iaA_star.asl") }
{ include("simulation/watch_dog.asl") }
{ include("environment/artifact_counter.asl") }
{ include("environment/artifact_simpleCFP.asl") }
{ include("agentBase.asl") }

+!perform_task(T) :
    not accepted(_) &                       // I am not committed
    not unwanted_task(T,_) &
    .my_name(ME) &
    task(T,DL,Y,REQs) &
    .member(req(IR,JR,BR),REQs) & (math.abs(IR) + math.abs(JR)) == 1 & // This is the block that the master must go for
    .member(req(IH,JH,BH),REQs) & (math.abs(IH) + math.abs(JH)) > 1 & // This is the block that the HELPER must go for
    task_shortest_path(BR,D) &
    step(S) &
    origin(MAP) &
    myposition(XX,YY)
    <-
    if ( DL <= (S + D) ) { // deadline must be greater than step + shortest path
        +unwanted_task(T,-1); // Discard tasks that are going to expire
    } else {
        .log(warning,"I want to perform the task ",T);

        .send(coordinator,achieve,find_helper(BH,ME,T,MAP));
    }
.
+!perform_task(T).// <- .log(warning,"Could not perform ",T).
-!perform_task(T) :
    .my_name(ME)
    <-
    .log(warning,"Failed on ",perform_task(T)," dropping desire, back to explore.");
    //No matter if it succeed or failed, it is supposed to be ready for another task
    .concat("[",perform_task(T),"]",C);
    .save_stats("master_failed",C);
    .drop_desire(explore);
    !drop_all_blocks;
    +exploring;
    !explore[critical_section(action), priority(1)];
.

+!master_task(T,Helper):
    .my_name(ME) &
    task(T,DL,Y,REQs) &
    .member(req(IR,JR,BR),REQs) & (math.abs(IR) + math.abs(JR)) == 1 & // This is the block that the master must go for
    .member(req(IH,JH,BH),REQs) & (math.abs(IH) + math.abs(JH)) > 1 & // This is the block that the HELPER must go for
    step(S) &
    origin(MAP) &
    myposition(XX,YY)
    <-
    -exploring;

    //TODO: More than one pair of agents are often competing for the same space, it is better to try other ways to find clear areas
    ?nearest(goal,XG,YG);
    !find_meeting_area(XG,YG,1,XM,YM);
    .send(Helper,achieve,bring_block(BH,ME,T,MAP,meeting_point(XM+3,YM)));

    .concat("[",task(T),",",myposition(XX,YY),",",helper(Helper),",",myreq(IR,JR,BR),"]",C2);
    .save_stats("mastering_task",C2);

    .log(warning,"Accepting task... ",T);
    !accept_task(T);

    .log(warning,"getblock ",req(IR,JR,BR));
    .log(warning,"Setting position for connecting with a helper comming from east");
    !get_block(req(1,0,BR));

    while ( not thing(1,0,block,BR) & step(AS3) ) {
        !fix_rotation(req(1,0,BR));
        .wait( step(NS) & NS > AS3 );
    }
    while ( not myposition(XM,YM) & step(AS2) ) {
        !goto_XY(XM,YM);
        .wait( step(NS) & NS > AS2 );
    }
    .concat("[",myposition(XM,YM),",",helper(Helper),"]",C3);
    .save_stats("waiting_helper",C3);

    !wait_event(helper_at(XM+3,YM)[source(Helper)]);
    .concat("[",helper_at(XM+3,YM),",",helper(Helper),"]",C4);
    .save_stats("assembly_ready",C4);
    .send(Helper,tell,assembly_ready);

    !do(skip,_); // Give one step to the zombie get ready

    !synchronous_connect(Helper,1,0,-1,0);

    !synchronous_detach(Helper,w);

    .send(Helper,tell,assembly_ends);

    // Setting for submit position
    while (not thing(IR,JR,block,BR) & step(AS4) ) {
        !fix_rotation(req(IR,JR,BR));
        .wait( step(NS) & NS > AS4 );
    }

    .log(warning,"Submitting task... ",T);
    !submit_task(T);
    .broadcast(tell,unwanted_task(T,-1));

    // In case submit did not succeed
    .log(warning,"Dropping blocks for ",T);
    !drop_all_blocks;

    //No matter if it succeed or failed, it is supposed to be ready for another task
    +exploring;
.

+origin(MAP):
    .my_name(ME)
    <-
    .send(coordinator,achieve,inform_map(ME,MAP));
.

/**
 * Tasks in which one req (math.abs(I) + math.abs(J)) is greater than  1
 * are the ones that need help, i.e., cannot be performed by an individualist
 */
+task(T,DL,Y,REQs) :
    not unwanted_task(T,_) &
   .length(REQs) \== 2 // Currently I am focusing only on two blocks tasks that needs help
    <-
    +unwanted_task(T,-1);
.
+task(T,DL,Y,REQs) : //unwanted_task aging
    unwanted_task(T,N) &
    N > 0
    <-
    -unwanted_task(T,N);
    +unwanted_task(T,N-1);
.
+task(T,DL,Y,REQs) : //unwanted_task aged, let us try to perform task again
    unwanted_task(T,N) &
    N == 0
    <-
    -unwanted_task(T,_);
.
+task(T,DL,Y,REQs) :
    exploring &
    not accepted(_) &   // I am not committed
    not unwanted_task(T,_) &
    .member(req(IR,JR,BR),REQs) & (math.abs(IR) + math.abs(JR)) == 1 & // This is the block that the master must go for
    .member(req(IH,JH,BH),REQs) & (math.abs(IH) == 2 | math.abs(JH) == 2) & // Tho simplify, only accepting tasks with blocks on cardeal positions
    known_requirement(T,BR)
    <-
    //.log(warning,"I am able to perform ",T);
    !!perform_task(T);
.

+!bring_block(B,Master,T,MAP,meeting_point(XM,YM)):
    myposition(XO,YO) &
    .my_name(ME) &
    step(S)
    <-
    -exploring;

    .abolish(assembly_ready);
    .abolish(assembly_ends);
    // remove the auction that lead to this helping plan and other ones to do not give false hope

    .concat("[",block_to(B,Master,T,MAP),",",step(S),",",myposition(XO,YO),",",meeting_point(XM,YM),"]",C1);
    .save_stats("helping_task",C1);

    !get_block(req(-1,0,B));

    .concat("[",meeting_point(XM,YM),",",myposition(XO,YO),"]",C2);
    .save_stats("goto_meeting",C2);

    while ( not thing(-1,0,block,B) & step(AS3) ) {
        !fix_rotation(req(-1,0,B));
        .wait( step(NS) & NS > AS3 );
    }
    while ( not myposition(XM,YM) & step(AS2) ) {
        !goto_XY(XM,YM);
        .wait( step(NS) & NS > AS2 );
    }
    ?myposition(XMO,YMO);
    .send(Master,tell,helper_at(XMO,YMO));

    .concat("[",myposition(XMO,YMO),",",master(Master),"]",C3);
    .save_stats("waiting_master",C3);
    !wait_event(assembly_ready[source(Master)]);


    /**
     * Meanwhile the helper is on zombie mode, so master should give action to it
     * every step
     */
    .concat("[",master(Master),"]",C4);
    .save_stats("zombie_on",C4);

    .wait(assembly_ends[source(Master)]);

    // In case submit did not succeed
    .log(warning,"Dropping blocks for ",T);
    !drop_all_blocks;

    //No matter if it succeed or failed, it is supposed to be ready for another task
    +exploring;
.

+!drop_task
    <-
    .log(severe,"****** Dropping task:  dropping all desires, intentions, events and blocks!");
    .drop_all_events;
    .drop_all_desires;
    .drop_all_intentions;
    !drop_all_blocks;
    +exploring;
.
