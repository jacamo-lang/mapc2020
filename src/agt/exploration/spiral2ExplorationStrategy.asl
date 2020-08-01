/*
 * Spiral2 is the simplest method which tries to increase the 
 * radius of a circular walking
 */

{ include("common_exploration.asl") }

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
+!update_direction_spiral2:
    lastDirection(LD,N) &
    current_direction(D) &
    nextDirection(D,ND) &
    size(S)
    <-
    !do(move(D),R);
    if (R==success) {
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
