/**
 * This library intends to solve the problem of rotating the one
 * block attached. Unfortunately, it is not suitable to rotate when 
 * multiple blocks are attached.
 */

{ include("walking/rotate_jA_star.asl") }
{ include("exploration/common_exploration.asl") }

+!fix_rotation(req(I,J,B)) :
    attached(I,J) & thing(I,J,block,B) // no rotation is necessary
.
+!fix_rotation(req(RI,RJ,B)) :
    attached(I,J) &
    thing(I,J,block,B) & 
    get_rotation(b(I,J,B),b(RI,RJ,B),DIR) &
    step(S) &
    .my_name(ME)
    <-
    if (DIR \== no_rotation) {
        !do(rotate(DIR),R);
        if (R == success) {
            .log(warning,"Rotated ",B," (",I,",",J,") to (",RI,",",RJ,") dir: ",DIR);
            .wait(step(Step) & Step > S); //wait for the next step to continue
            !fix_rotation(req(RI,RJ,B));
        } else {
            .log(warning,"Could not rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: ",DIR);
            .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,block,BB),L);
            .findall(t(I,J,T,TT),thing(I,J,T,TT),LT);
            if (is_walkable(RI,RJ)) {
                .concat("[",req(RI,RJ,B),",",DIR,",",a(L),",",t(LT),",",R,",",is_walkable(RI,RJ),"=true]",STR);
            } else {
                .concat("[",req(RI,RJ,B),",",DIR,",",a(L),",",t(LT),",",R,",",is_walkable(RI,RJ),"=false]",STR);
            }
            .save_stats("errorOnRotate",STR);
        }
    } else { // could not find a valid rotation, try to randomly dodge
        .findall(D,direction_increment(D,Ip,Jp) & not thing(Ip,Jp,_,_) & not obstacle(Ip,Jp),LD);
        if (.length(LD) > 0) {
            .nth(math.floor(math.random(.length(LD))),LD,DIRECTION);
            !do(move(DIRECTION),R);
            if (R == success) {
                !mapping(success,_,DIRECTION);
                .log(warning,"Due to no_rotation, dodged to ",DIRECTION);
                .wait(step(Step) & Step > S); //wait for the next step to continue
                !fix_rotation(req(RI,RJ,B));
            } else {
                .log(warning,"Could not dodge to ",DIRECTION);
                .wait(step(Step) & Step > S); //wait for the next step to continue
                !fix_rotation(req(RI,RJ,B));
            }
        } else {
            .log(warning,"Could not dodge to rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: ",DIR);
            .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,block,BB),L);
            .findall(t(I,J,T,TT),thing(I,J,T,TT),LT);
            .concat("[",req(RI,RJ,B),",",DIR,",",a(L),",",t(LT),",",R,"]",STR);
            .save_stats("dodgeNoScape",STR);
        }
    }
.
+!fix_rotation(req(_,_,B)) // If other plans fail
    <-
    .findall(b(I,J,B),attached(I,J) & thing(I,J,block,B),LA);
    .findall(b(I,J,B),attached(I,J),LT);
    .log(warning,"No plans to rotate ",B,". Attached: ",LA," - ",LT);
.

+!rotate(DIR) :
    .member(DIR,[cw,ccw])
    <-  
    !do(rotate(cw),R);  
    if (R \== success) {    
      .log(warning,"Could not rotate ",B," (",I,",",J,") to (",RI,",",RJ,") dir: cw");  
    }   
.   
