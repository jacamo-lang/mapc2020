/*
 * Spiral exploration strategy: tries to go a number of steps (given by the belief path_length) in all the 4 possible directions. 
 *                              When finished, starts again increasing the number of steps.    
 */

//{ include("common_exploration.asl") }

current_direction(w). //initial direction

// Spiral walk setup
nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).
current_direction(w).
lastDirection(w,1).
size(1).

/**
 * Spiral walk exploration
 */
+!explore(X):
    lastDirection(LD,N) &
    current_direction(D) &
    nextDirection(D,ND) &
    size(S)
    <-
    !do(move(D),R);
    if (R==success) {
      !mapping(success,_,D);
      if (N==1) {
        -+lastDirection(D,S+1);
        -+current_direction(ND);
        -+size(S+1);
      } else {
        -+lastDirection(D,N-1);
        -+current_direction(D);
      }
    } else {
      -+lastDirection(ND,S);
      -+current_direction(ND);
      -+size(S+1);
    }
.
