/*
 * - To move in a direction D, use the plan move(D) (s.t. D\in{w,n,s,e}). This keeps the position of the agent consistent along the match.  
 * - A disabled agent will always recharge.
 * - The agent keep exploring explore when the belief "explore" is true.
 * - The agent adopts an exploration strategy "S" when it beliefs exploration_strategy(S). Possible exploration strategies currently are:
 *    -> exploration_strategy(random): the agent chooses a random direction in each step. Implemented in exploration/randomExplorationStrategy.asl
 *    -> exploration_strategy(spiral): the agent moves in a spiral that grows along the match. Implemented in exploration/spiralExplorationStrategy.asl
 *    -> exploration_strategy(stc):  : the agent chooses the direction using a the spanning-tree based coverage algorithm (doi.org/10.1023/A:1016610507833) Implemented in exploration/stcExplorationStrategy.asl
 * - The known elements in the scenario are mapped to beliefs gps_map(X,Y,Type,MapId) where:
 *    -> (X,Y) is the location of the object
 *    -> Type\in {obstacle,goal,b0,b1,b2}
 *    -> MapId is the map identifier, that starts the same as the agent name and changes when the agents meet with each other 
 * 
 */

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("taskmanager.asl") }
{ include("simulation/action.asl") }
{ include("exploration/common_exploration.asl") } //common beliefs, rules and plans for all the exploration strategies
{ include("exploration/randomExplorationStrategy.asl") } //random exploration strategy
{ include("exploration/spiralExplorationStrategy.asl") } //spiral exploration strategy
{ include("exploration/stcExplorationStrategy.asl") } //stc exploration strategy - 
{ include("exploration/meeting.asl") }

{ include("environment/artifact_eis.asl") }
{ include("environment/artifact_gps.asl") }
{ include("simulation/massim.asl") }

exploring. //The agent keep exploring explore when the belief "explore" is true.
exploring :- status(exploring) & .log("use status/1 instead of exploring").
exploration_strategy(stc). //Current exploration strategy. Possible strategies: random, spiral, stc

+!start : .my_name(NAME) 
   <- .wait(step(_));  
      +origin(NAME);
      !explore[critical_section(action), priority(1)].


/* General plan to move the agent. Can be used in any phase of the game. In the exploration phase, current_direction is defined by the exploration strategies */
+!move(D): disabled(false) & step(S)
   <- !do(move(D),R);
      -+last_move_result(D,R,S); //may be useful in some strategies (e.g. spiral)
      !mapping(R,S,D).  
            
            
+!move(D).






/****************************************  Recharging ****************************************/
//if the agent is exploring, then resume exploration after having recharged
+disabled(true) : exploring & step(S)
    <-  .print("recharging...");
        !recharge[critical_section(action), priority(2)];
        !wait_to_explore. //resume the exploration after enabling
+disabled(true)
    <-  .print("recharging...");
        !recharge[critical_section(action), priority(2)].
       
+!recharge  <- !do(skip,R) .       
      
                  
      
/****************************************  Exploration ****************************************/
+!explore : disabled(true).
        
      
+!explore : disabled(false) & exploring & step(S)
   <- !check_direction; //defines the current_direction(D) belief
      ?current_direction(CD);//  .print("updated direction ", CD, " step: ", S);
      !move(CD); //moves to the selected direction
      .wait(step(Step)&Step>S); //wait for the next step to continue to explore
      !explore[critical_section(action), priority(1)].
                 
      
+!explore : not exploring
   <- .print("-------------- not exploring ----------------------")
      .wait(exploring);
      !explore[critical_section(action), priority(1)].
                        
      
              
+!explore 
   <- .wait(step(_));
      !explore[critical_section(action), priority(1)].
      
      
+!wait_to_explore
   <- .wait(disabled(false));
      .drop_desire(explore); .drop_intention(explore); //ensure a single exploration intention 
      !explore[critical_section(action), priority(1)].      


+!wait_to_explore
   <- .wait(disabled(false));
      .drop_desire(explore); .drop_intention(explore); //ensure a single exploration intention 
      !explore[critical_section(action), priority(1)].

+!check_direction : exploration_strategy(random)
   <- !update_direction_random.
   
+!check_direction : exploration_strategy(spiral)
   <- !update_direction_spiral.  
   

+!check_direction : exploration_strategy(stc)
   <- !update_direction_stc.     
     
+!check_direction 
   <- .print("No exploration strategy selected.").       
   
   
/*************************************************************************************** */  
                 
