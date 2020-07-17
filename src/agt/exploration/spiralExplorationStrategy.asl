/*
 * Spiral exploration strategy: tries to go a number of steps (given by the belief path_length) in all the 4 possible directions. 
 *                              When finished, starts again increasing the number of steps.    
 */

{ include("common_exploration.asl") }

nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).

current_direction(w). //initial direction

path_length(1). //size of the spiral edge - increments along the exploration
covered_path_length(0). //portion of the edge that has been covered

last_move_result(w,success,-1).


+!update_direction_spiral : last_move_result(_,success,S) & covered_path_length(L) & path_length(L) &
                            current_direction(D) & nextDirection(D,ND) 
   <- -+covered_path_length(0);
      -+path_length(L+1);
      -+current_direction(ND);
      . 
      
+!update_direction_spiral :  last_move_result(_,success,S) & covered_path_length(L)
    <- -+covered_path_length(L+1).   
    
+!update_direction_spiral : last_move_result(_,R,S) & current_direction(D) & nextDirection(D,ND)&
                        covered_path_length(CPL) & path_length(PL)     <- -+covered_path_length(0);
      -+current_direction(ND).
