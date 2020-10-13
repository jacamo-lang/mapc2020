/**
 * Rotation plans
 */

{ include("walking/jA_star_search.asl") }
{ include("walking/common_walking.asl") }

/**
 * Sample set of requirements: task(task0,119,16,[req((-2),2,b2),req((-1),2,b2),req(0,1,b2),req(0,2,b1)])
 * task(T,D,R,REQs) & REQs = [req(I,J,B)|Tail]
 * Other important beliefs: attached(I,J) and thing(I,J,B)
 */

/**
 * jA_star search setup
 * state transitions and heuristic
 */
suc(b(I1,J1),b(I2,J2),1,D) :- rotate(D,I1,J1,I2,J2) & is_walkable(I2,J2).                              

// very simple and not very useful heuristic: 0 when no rotation is needed, 1 if any rotation is needed
h(b(I1,J1),b(I1,J1),0). 
h(b(I1,J1),b(I2,J2),1).

// For rotation
rotate(cw,0,-1,1,0).  // 12 o'clock -> 3  o'clock
rotate(cw,1,0,0,1).   // 3  o'clock -> 6  o'clock
rotate(cw,0,1,-1,0).  // 6  o'clock -> 9  o'clock
rotate(cw,-1,0,0,-1). // 9  o'clock -> 12 o'clock
rotate(ccw,1,0,0,-1). // 3  o'clock -> 12  o'clock
rotate(ccw,0,1,1,0).  // 6  o'clock -> 3  o'clock
rotate(ccw,-1,0,1,0). // 9  o'clock -> 6 o'clock
rotate(ccw,0,-1,-1,0).// 12  o'clock -> 9 o'clock

/**
 * Get the necessary rotation moviment to get from b(I,J,B) to
 * b(II,JJ,B). If more than one movement is needed, it returns
 * the next.
 */
get_rotation(b(I,J,B),b(II,JJ,B),DIR) :- 
    a_star( b(I,J), b(II,JJ), [_,op(DIR,b(III,JJJ))|_], Cost)
.
get_rotation(b(I,J,B),b(II,JJ,B),no_rotation).

