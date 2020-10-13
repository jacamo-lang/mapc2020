/**
 * The individualist acts alone, it will try to submit tasks that it can
 * do alone. The weak individualist can carry only one block, so it will
 * only accept such simple tasks.
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
    not .intend(perform_task(_)) &
    .my_name(ME) &
    task(T,DL,Y,REQs) &
    .nth(0,REQs,req(_,_,B)) &   // Get the requirement (must be only one)
    task_shortest_path(B,D) &
    step(S)        
    <-
    if ( DL <= (S + D) ) { // deadline must be greater than step + shortest path
        +unwanted_task(T); // Discard tasks that are going to expire    
    } else {
        .log(warning,"I want to perform the task ",T);
        
        setWantedTask(ME,T,S,D); // no need to skip, just keep exploring until the auction ends
        .wait(step(Step) & Step > S); //wait for the next step to continue
        
        if ( wanted_task(ME,T,_,_) ) { // there is no better agent to perform this task
            -exploring;
            .log(warning,"Accepting task... ",T);
            !accept_task(T);

            .log(warning,"Performing task... ",T);
            for ( .member(req(IR,JR,BR),REQs) ) {
                .log(warning,"getblock ",req(IR,JR,BR));
                !get_block(req(IR,JR,BR));
                
                .log(warning,"Setting position of the requirement for ",req(IR,JR,BR));
                !fix_rotation(req(IR,JR,BR));
            }

            .log(warning,"Submitting task... ",T);
            !submit_task(T);

            // In case submit did not succeed
            .log(warning,"Dropping blocks for ",T);
            !drop_all_blocks;

            //No matter if it succeed or failed, it is supposed to be ready for another task
            +exploring;
            !explore[critical_section(action), priority(1)];
        } else {
            +unwanted_task(T);
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
 * Thanks in which one req (math.abs(I) + math.abs(J)) is greater than  1
 * are the ones that need help, i.e., cannot be performed by an individualist
 */
+task(T,DL,Y,REQs) :
    not unwanted_task(T) &
   .member(req(I,J,_),REQs) & 
   (math.abs(I) + math.abs(J)) > 1 // There is a req which requires help from other agent
    <-
    +unwanted_task(T);
.

+task(T,DL,Y,REQs) :
    exploring &
    not accepted(_) &   // I am not committed
    not unwanted_task(T) &
    .member(req(I,J,_),REQs) & 
    (math.abs(I) + math.abs(J)) <= 1 & // reqs all placed only on adjacent squares
    known_requirements(T)
    <-
    .log(warning,"I am able to perform ",T);
    !!perform_task(T);
.

/**
 * If someone forgot task T, let us be open to perform it!
 */
-wanted_task(_,T)
    <-
    .abolish(unwanted_task(T));
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
