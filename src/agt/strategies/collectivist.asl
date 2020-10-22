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
{ include("tasks/zumbi_mode.asl") }
{ include("walking/common_walking.asl") }
{ include("walking/goto_iaA_star.asl") }
{ include("simulation/watch_dog.asl") }
{ include("environment/artifact_simpleCFP.asl") }
{ include("environment/artifact_counter.asl") }
{ include("agentBase.asl") }
{ include("origin_workaround.asl") }

+!perform_task(T) : unwanted_task(T). // do nothing
+!perform_task(T) :
    not accepted(_) &                       // I am not committed
    not .intend(bring_block(_,_,_,_)) &
    not .intend(perform_task(_)) &
    .my_name(ME) &
    task(T,DL,Y,REQs) &
    .member(req(IR,JR,BR),REQs) & (math.abs(IR) + math.abs(JR)) == 1 & // This is the block that the master must go for
    .member(req(IH,JH,BH),REQs) & (math.abs(IH) + math.abs(JH)) > 1 & // This is the block that the HELPER must go for
    task_shortest_path(BR,D) &
    step(S) &
    origin_str(MAP) &
    myposition(XX,YY)
    <-
    if ( DL <= (S + D) ) { // deadline must be greater than step + shortest path
        +unwanted_task(T); // Discard tasks that are going to expire
    } else {
        .log(warning,"I want to perform the task ",T);

        setCFP("bring_block",block_to(BH,ME,T,MAP),9999); // Start the CFP with a very high offer

        .wait(step(Step) & Step > S); //wait for the next step to continue

        //TODO: Sometimes the master or the helper get stuck which compromise the whole task
        //TODO: Sometimes another pair of agents are concurring to this same task and going to same place
        //TODO: Sometimes an agent is winning two auction as helper giving false hope to one of them         
        if ( bring_block(Helper,block_to(B,ME,T,MAP),_) & Helper \== ME ) { // someone is coming to help me and I won the master's auction
            !close_bring_CFP(block_to(BH,ME,T,MAP));

            -+performing(T,Helper);
            -exploring;

            ?nearest(goal,XG,YG);
            !find_meeting_area(XG,YG,1,XM,YM);
            .send(Helper,achieve,bring_block(B,ME,T,MAP,meeting_point(XM+4,YM)));

            .concat("[",task(T),",",myposition(XX,YY),",",helper(Helper),",",myreq(IR,JR,BR),"]",C2);
            .save_stats("mastering_task",C2);

            .log(warning,"Accepting task... ",T);
            !accept_task(T);

            .log(warning,"getblock ",req(IR,JR,BR));
            .log(warning,"Setting position for connecting with a helper comming from east");
            !get_block(req(1,0,BR));

            while ( not myposition(XM,YM) ) {
                !goto_XY(XM,YM);
                !fix_rotation(req(1,0,BR));
            }
            .concat("[",myposition(XM,YM),",",helper(Helper),"]",C3);
            .save_stats("waiting_helper",C3);

            !wait_event( helper_at(XM+4,YM)[source(Helper)],do(skip,_) );
            .concat("[",helper_at(XM+4,YM),",",helper(Helper),"]",C4);
            .save_stats("assembly_ready",C4);

            while ( not thing(3,0,entity,_) & step(AS1) ) {
                !do(skip,_);
                !command_zumbi(Helper,do(move(w),RZZ0));
                .wait( step(NS) & NS > AS1 );
            }

            while (not (lastAction(connect) & lastActionResult(success)) & step(AS2)) {
                !do(connect(Helper,1,0),RMM0);
                !command_zumbi(Helper,do(connect(ME,-1,0),RZZ1));
                .concat("[",do(connect(ME,-1,0),RZZ1),"]",C5);
                .save_stats("do_connect",C5);
                .wait( step(NS) & NS > AS2 );
            }
            
            //TODO: coordination issues since Helper must be successful on detach to make master able to submit 
            while (not thing(4,0,entity,_) & step(AS3) ) {
                !do(skip,_);
                !command_zumbi(Helper,do(detach(w),RZZ2));
                !do(skip,_);
                !command_zumbi(Helper,do(move(e),RZZ3));
                .wait( step(NS) & NS > AS3 );
            }

            // Setting for submit position
            while (not thing(IR,JR,block,BR) & step(AS4) ) {
                !fix_rotation(req(IR,JR,BR));
                .wait( step(NS) & NS > AS4 );
            }

            .log(warning,"Submitting task... ",T);
            !submit_task(T);
            .broadcast(tell,unwanted_task(T));

            // In case submit did not succeed
            .log(warning,"Dropping blocks for ",T);
            !drop_all_blocks;
            removeMyCFPs; // in case the agent did not succeed, another agent can try

            //No matter if it succeed or failed, it is supposed to be ready for another task
            +exploring;
            !explore[critical_section(action), priority(1)];
        }
    }
.
+!perform_task(T).// <- .log(warning,"Could not perform ",T).
-!perform_task(T) :
    .my_name(ME)
    <-
    .log(warning,"Failed on ",perform_task(T)," dropping desire, back to explore.");
    //No matter if it succeed or failed, it is supposed to be ready for another task
    .concat("[",perform_task(T),"]",C);
    .save_stats("perform_fail",C);
    .drop_desire(perform_task(_));
    .drop_desire(explore);
    .drop_desire(bring_block(_,_,_,_,_));
    !drop_all_blocks;
    +exploring;
    !explore[critical_section(action), priority(1)];
.

// solve conflict in which I am master of an auction and helper of another agent
+!close_bring_CFP(block_to(B,ME,T,MAP)) :
    .my_name(ME)
    <-
    if (bring_block(ME,block_to(_,AnotherMaster,_,_),_) ) {
        if (ME < AnotherMaster) {
            .drop_intention( bid_to_bring_block(_,_,_,_) );
            .drop_intention( bring_block(_,_,_,_,_) );
            .concat("[",bring_block(ME,block_to(_,AnotherMaster,_,_),_),"]",C);
            .save_stats("dropped_bring",C);
        } else {
            .drop_intention( perform_task(_) );
            .concat("[",bring_block(ME,block_to(_,Master,_,_),_),",",bring_block(Master,block_to(_,ME,_,_),_),"]",C);
            .save_stats("dropped_mastering",C);
            .fail;
        }
    }
    setCFP("bring_block",block_to(B,ME,T,MAP),-1);
.

/**
 * Tasks in which one req (math.abs(I) + math.abs(J)) is greater than  1
 * are the ones that need help, i.e., cannot be performed by an individualist
 */
+task(T,DL,Y,REQs) :
    not unwanted_task(T) &
   .length(REQs) \== 2 // Currently I am focusing only on two blocks tasks that needs help
    <-
    +unwanted_task(T);
    //+task(task999,1000,1000,[req(0,1,b0),req(0,2,b0)]);
.

+task(T,DL,Y,REQs) :
    exploring &
    not accepted(_) &   // I am not committed
    not unwanted_task(T) &
    .member(req(IR,JR,BR),REQs) & (math.abs(IR) + math.abs(JR)) == 1 & // This is the block that the master must go for
    .member(req(IH,JH,BH),REQs) & (math.abs(IH) == 2 | math.abs(JH) == 2) & // Tho simplify, only accepting tasks with blocks on cardeal positions
    known_requirement(T,BR)
    <-
    //.log(warning,"I am able to perform ",T);
    !!perform_task(T);
.

+bring_block(_,_,_) : .intend(bid_to_bring_block(_,_,_,_)). // I am busy
+bring_block(_,_,_) : .intend(bring_block(_,_,_,_,_)). // I am busy
+bring_block(_,block_to(_,ME,_,_),_) : .my_name(ME). // it is me asking for help...
+bring_block(_,block_to(B,Master,T,MAP),_)
    <-
    !bid_to_bring_block(B,Master,T,MAP);
.

+!bid_to_bring_block(B,Master,T,MAP) :
    gps_map(_,_,B,MAP) &
    origin_str(MAP) & // My map is same of Master's map
    nearest(B,XB,YB) &
    myposition(X,Y) &
    distance(X,Y,XB,YB,D1) &
    step(S)
    <-
    // for the auction, it is used the current position of master
    .send(Master,askOne,myposition(XM,YM),myposition(XM,YM));
    ?distance(XB,YB,XM,YM,D2);
    D = D1 + D2;
    setCFP("bring_block",block_to(B,Master,T,MAP),S+D);
.
+!bid_to_bring_block(B,Master,T,MAP). // I am busy

+!bring_block(B,Master,T,MAP,meeting_point(XM,YM)):
    not .intend(bring_block(_,_,_,_,_)) &
    not performing(_,_) &
    myposition(XO,YO) &
    .my_name(ME) &
    step(S)
    <-
    // remove the auction that lead to this helping plan and other ones to do not give false hope
    removeMyCFPs;

    // In case it is performing a task
    .drop_intention( perform_task(_) );
    
    -exploring;

    .concat("[",block_to(B,Master,T,MAP),",",step(S),",",myposition(XO,YO),",",meeting_point(XM,YM),"]",C1);
    .save_stats("helping_task",C1);

    !get_block(req(-1,0,B));

    .concat("[",meeting_point(XM,YM),",",myposition(XO,YO),"]",C2);
    .save_stats("goto_meeting",C2);

    !goto_XY(XM,YM);
    ?myposition(XMO,YMO);
    .send(Master,tell,helper_at(XMO,YMO));

    !fix_rotation(req(-1,0,B));
    
    .concat("[",myposition(XMO,YMO),",",master(Master),"]",C3);
    .save_stats("waiting_master",C3);
    !wait_event( connect(B,I,J)[source(Master)],do(skip,_) );

    // In case submit did not succeed
    .log(warning,"Dropping blocks for ",T);
    !drop_all_blocks;

    //No matter if it succeed or failed, it is supposed to be ready for another task
    +exploring;
    !explore[critical_section(action), priority(1)];
.
//TODO: this is not a good solution but at least the other master may start a new auction 
+!bring_block(B,Master,T,MAP,meeting_point(XM,YM)) // I am committed to another task
    <-
    .send(Master,achieve,restart_agent);
.

+!wait_event(E,A) : E.
+!wait_event(E,A) :
    step(S)
    <-
    !do(skip,_);
    //!!A;
    .wait( (step(Step) & Step > S) ); //wait for the next step to continue
    !wait_event(E,A);
.

/**
 * For debugging if an unexpected error occurs
-!P[code(C),code_src(S),code_line(L),error_msg(M)] :
    true//disabled //
    <-
    .log(warning,"...");
    .log(warning,"...");
    .log(severe,"Fail on event '",C,"' of '",S,"' at line ",L,", Message: ",M);
    .log(warning,"...");
    .log(warning,"...");
    .stopMAS(0,1);
.
*/
