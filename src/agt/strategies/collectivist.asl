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


+!perform_task(T) :
    not accepted(_) &                       // I am not committed
    not .intend(bring_block(_,_,_,_)) &
    not .intend(perform_task(_)) &
    .my_name(ME) &
    task(T,DL,Y,REQs) &
    .nth(0,REQs,req(_,_,B)) &   // Get the requirement (must be only one)
    task_shortest_path(B,D) &
    step(S) &
    origin_str(MyMAP) &
    myposition(XX,YY)     
    <-
    if ( DL <= (S + D) ) { // deadline must be greater than step + shortest path
        +unwanted_task(T); // Discard tasks that are going to expire    
    } else {
        .log(warning,"I want to perform the task ",T);
        
        .nth(1,REQs,req(IH,JH,BH));
        .log(warning,"Asking help... ",T);
        removeMyCFPs; // clear other auction, just in case
        
        setCFP("bring_block",block_to(BH,ME,T,MyMAP),9999); // Start the CFP with a very high offer
        //!do(skip,R1);
        .wait(step(Step) & Step > S); //wait for the next step to continue
          
        if ( bring_block(Helper,block_to(B,Master,T,MAP),_) & Helper \== ME) { // someone is coming to help me
        
            setCFP("bring_block",block_to(BH,ME,T,MyMAP),-1);

            setCFP("wanted_task",T,S+1+D); // no need to skip, just keep exploring until the auction ends
            //!do(skip,R2);
            .wait(step(Step2) & Step2 > S+1); //wait for the next step to continue

            if ( wanted_task(ME,T,_) ) { // there is no better agent to perform this task
                -exploring;
                
                -+helper(T,Helper);

                ?nearest(goal,XG,YG);
                .send(Helper,tell,meeting_point(T,XG,YG));
            
                .log(warning,"Accepting task... ",T);
                !accept_task(T);

                .log(warning,"Performing task... ",T);
                .nth(0,REQs,req(IR,JR,BR));

                .log(warning,"getblock ",req(IR,JR,BR));
                !get_block(req(IR,JR,BR));
                
                .log(warning,"Setting position of the requirement for ",req(IR,JR,BR));
                !fix_rotation(req(IR,JR,BR));

                !goto_XY(XG+3,YG+3);
                ?myposition(XO,YO);
                .concat("[",ME,",",myposition(XO,YO),",",helper_at(XG,YG)[source(Helper)],"]",C2);
                .save_stats("ready_to_assembly",C2);
            
                .log(warning,"Submitting task... ",T);
                !submit_task(T);

                // In case submit did not succeed
                .log(warning,"Dropping blocks for ",T);
                !drop_all_blocks;
                removeMyCFPs; // in case the agent did not succeed, another agent can try

                //No matter if it succeed or failed, it is supposed to be ready for another task
                +exploring;
                !explore[critical_section(action), priority(1)];
            }
        }
    }
.
+!perform_task(T)
    <-
    .log(warning,"Could not perform ",T);
.
-!perform_task(T)
    <-
    .log(warning,"Failed on ",perform_task(T)," dropping desire, back to explore.");
    //No matter if it succeed or failed, it is supposed to be ready for another task
    .drop_desire(perform_task(_));
    +exploring;
    !explore[critical_section(action), priority(1)];
.

/**
 * Tasks in which one req (math.abs(I) + math.abs(J)) is greater than  1
 * are the ones that need help, i.e., cannot be performed by an individualist
 */
+task(T,DL,Y,REQs) :
    not unwanted_task(T) &
   .member(req(I,J,_),REQs) & 
   (math.abs(I) + math.abs(J)) <= 1 & // There is a req which requires help from other agent
   .length(REQs) \== 2 // Currently I am focusing only on two blocks tasks
    <-
    +unwanted_task(T);
.

+task(T,DL,Y,REQs) :
    exploring &
    not accepted(_) &   // I am not committed
    not unwanted_task(T) &
    known_requirement(T,0)
    <-
    .log(warning,"I am able to perform ",T);
    !!perform_task(T);
.

/**
 * If someone forgot task T, let us be open to perform it!
 */
-wanted_task(_,T,_)
    <-
    .abolish(unwanted_task(T));
.

+bring_block(_,block_to(B,Master,T,MAP),_):
    not .intend(bring_block(_,_,_,_)) &
    not .intend(perform_task(_)) &
    .my_name(ME) &
    Master \== ME & // do not attend to CFP that it is the master
    origin_str(MAP)  // My map is same of Master's map
    <-
    .log(warning,"I am able to help on ",block_to(B,Master,T,MAP));
    .abolish(meeting_point(_,_,_));
    removeMyCFPs; // clear other auction, just in case
    !!bring_block(B,Master,T,MAP);
.

+!bring_block(B,Master,T,MAP):
    gps_map(_,_,B,MAP) &
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
    //!do(skip,R1);
    .wait(step(Step) & Step > S); //wait for the next step to continue

    if ( bring_block(ME,block_to(B,Master,T,MAP),_) ) { // I won
        .concat("[",ME,",",block_to(B,Master,T,MAP),",",step(S),",",myposition(X,Y),",",master_position(XM,YM),"]",C1);
        .save_stats("bring_block",C1);

        -exploring;
        
        !get_block(req(0,1,B));
        
        if ( meeting_point(T,XG,YG) & myposition(XO,YO) ) {
            .concat("[",ME,",",meeting_point(T,XG,YG),",",myposition(XO,YO),"]",C2);
            .save_stats("goto_meeting_point",C2);

            !goto_XY(XG,YG);
            .send(Master,tell,helper_at(XG,YG));
            
            .concat("[",ME,",",connect(B,I,J)[source(Master)],"]",C3);
            .save_stats("connect",C3);
            .wait(connect(B,I,J)[source(Master)]);
        }
        
        // In case submit did not succeed
        .log(warning,"Dropping blocks for ",T);
        !drop_all_blocks;
        
        //No matter if it succeed or failed, it is supposed to be ready for another task
        +exploring;
        !explore[critical_section(action), priority(1)];
    }
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
