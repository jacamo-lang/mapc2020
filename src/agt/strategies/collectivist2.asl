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
{ include("walking/common_walking.asl") }
{ include("walking/goto_iaA_star.asl") }
{ include("simulation/watch_dog.asl") }
{ include("environment/artifact_simpleCFP.asl") }
{ include("agentBase.asl") }
{ include("origin_workaround.asl") }
{ include("tasks/hire_helper.asl")} /** alteracao */ 

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
        
            -exploring;
            ?helper(Helper);
            
            ?nearest(goal,XG,YG);
            !find_meeting_area(XG,YG,1,XM,YM);
            .send(Helper,achieve,bring_block(B,ME,T,MAP,meeting_point(XM+4,YM)));

            .concat("[",task(T),",",myposition(XX,YY),",",helper(Helper),",",myreq(IR,JR,BR),"]",C2);
            .save_stats("mastering_task",C2);
            
            .log(warning,"Accepting task... ",T);
            !accept_task(T);

            .log(warning,"getblock ",req(IR,JR,BR));
            !get_block(req(IR,JR,BR));
                
            .log(warning,"Setting position of the requirement for ",req(IR,JR,BR));
            !fix_rotation(req(IR,JR,BR));

            !goto_XY(XM,YM);
            ?myposition(XO,YO);
            .concat("[",myposition(XO,YO),",",helper(Helper),"]",C3);
            .save_stats("waiting_helper",C3);
                
            !wait_event( helper_at(XMO,YMO)[source(Helper)] );
            .concat("[",helper_at(XMO,YMO),"]",C4);
            .save_stats("assembly_ready",C4);

            //task(task10,191,4,[req((-1),1,b2),req(0,1,b1)]) req(IH,JH,BH)
            .send(Helper,achieve,rotate(cw));

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
//        }
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
   .member(req(I,J,_),REQs) & 
   (math.abs(I) + math.abs(J)) <= 1 & // There is no req which requires help from other agent
   .length(REQs) \== 2 // Currently I am focusing only on two blocks tasks that needs help
    <-
    +unwanted_task(T);
.

+task(T,DL,Y,REQs) :
    exploring &
    not accepted(_) &   // I am not committed
    not unwanted_task(T) &
    .member(req(IR,JR,BR),REQs) & (math.abs(IR) + math.abs(JR)) == 1 & // This is the block that the master must go for 
    known_requirement(T,BR) &
    helper(_) /* *** alteracao faz apenas se ja tiver um helper */
    <-
    //.log(warning,"I am able to perform ",T);
    !!perform_task(T);
.

/**
 * If someone forgot task T, let us be open to perform it!
 */
-wanted_task(_,T,_)
    <-
    .abolish(unwanted_task(T));
.

+bring_block(_,_,_) : .intend(bid_to_bring_block(_,_,_,_)). // I am busy
+bring_block(_,_,_) : .intend(bring_block(_,_,_,_,_)). // I am busy
+bring_block(_,_,_) : .my_name(ME) & wanted_task(ME,_,_). // I am busy performing a task as master
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
    //.log(warning,"I am able to help on ",block_to(B,Master,T,MAP));
    //removeMyCFPs; // clear other auction, just in case

    // for the auction, it is used the current position of master
    .send(Master,askOne,myposition(XM,YM),myposition(XM,YM));
    ?distance(XB,YB,XM,YM,D2);
    D = D1 + D2;
    setCFP("bring_block",block_to(B,Master,T,MAP),S+D);
.
+!bid_to_bring_block(B,Master,T,MAP). // I am busy

// if it said it may help an agent and did not won a master auction yet
+!bring_block(B,Master,T,MAP,meeting_point(XM,YM)):
    .intend(perform_task(TT)) & 
    not wanted_task(ME,TT,_)
    <-
    .drop_intention( perform_task(_) );
     .concat("[","]",C);
    .save_stats("dropped_perform",C);
.

+!bring_block(B,Master,T,MAP,meeting_point(XM,YM)):
    not .intend(bring_block(_,_,_,_,_)) &
    myposition(XO,YO) &
    .my_name(ME) &
    step(S)
    <-
    -exploring;

    .concat("[",block_to(B,Master,T,MAP),",",step(S),",",myposition(XO,YO),",",meeting_point(XM,YM),"]",C1);
    .save_stats("helping_task",C1);

    !get_block(req(-1,0,B));
        
    .concat("[",meeting_point(XM,YM),",",myposition(XO,YO),"]",C2);
    .save_stats("goto_meeting",C2);

    !goto_XY(XM,YM);
    ?myposition(XMO,YMO);
    .send(Master,tell,helper_at(XMO,YMO));
            
    .concat("[",myposition(XMO,YMO),"]",C3);
    .save_stats("waiting_master",C3);
    !wait_event( connect(B,I,J)[source(Master)] );
        
    // In case submit did not succeed
    .log(warning,"Dropping blocks for ",T);
    !drop_all_blocks;
        
    //No matter if it succeed or failed, it is supposed to be ready for another task
    +exploring;
    !explore[critical_section(action), priority(1)];
.

+!wait_event(E) : E.
+!wait_event(E) :
    step(S)
    <-
    !do(skip,R);
    .wait( (step(Step) & Step > S) ); //wait for the next step to continue
    !wait_event(E);
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
