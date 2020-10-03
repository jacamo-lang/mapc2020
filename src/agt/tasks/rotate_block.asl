/**
 * This library intends to solve the problem of rotating the one
 * block attached. Unfortunately, it is not suitable to rotate when 
 * multiple blocks are attached.
 */

{ include("walking/rotate_jA_star.asl") }

+!fix_rotation(req(I,J,B)) :
    attached(I,J) & thing(I,J,block,B) // no rotation is necessary
.
+!fix_rotation(req(RI,RJ,B)) :
    attached(I,J) &
    thing(I,J,block,B) & 
    get_rotation(b(I,J,B),b(RI,RJ,B),DIR) &
    step(S)
    <-
    if (DIR \== no_rotation) {
        !do(rotate(DIR),R);
        if (R == success) {
            .log(warning,"Rotated ",B," (",I,",",J,") to (",RI,",",RJ,") dir: ",DIR);
        } else {
            .log(warning,"Could not rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: ",DIR);
        }
    } else { // could not find a valid rotation, try to randomly dodge
        .nth(math.floor(math.random(4)),[n,s,w,e],DIRECTION);
        !do(move(DIRECTION),R);
        if (R == success) {
            .log(warning,"Due to no_rotation, dodged to ",DIRECTION);
        } else {
            .log(warning,"Could not dodge to ",DIRECTION);
        }    
    }
    .wait(step(Step) & Step > S); //wait for the next step to continue
    !fix_rotation(req(RI,RJ,B));
.
+!fix_rotation(req(_,_,B)) // If other plans fail
    <-
    .findall(b(I,J,B),attached(I,J) & thing(I,J,block,B),L);
    .log(warning,"No plans to rotate ",B,". Attached blocks: ",L);
.
