
+!fill_blocks(B):
  step(S)
  <-
    .log(warning,"FULLFILING BLOCKS");
    //?myposition(X,Y);
    //!goto(I,J,R);
    .log(warning,"CHEGUEIII");
    !get_block(req(0,1,G));
    !get_block(req(0,-1,B));
    !get_block(req(-1,0,R));
    !get_block(req(1,0,F));
    .log(warning,"PPICKED BLOCK");
  .


+!get_block(req(I,J,B)) :
    myposition(X,Y) &
    (thing(ID,JD,dispenser,B) & distance(0,0,ID,JD,1) & direction_increment(DD,ID,JD)) & // direction of the dispenser
    not attached(ID,JD) &
    .my_name(ME)
    <-
    //!pick_blocks(DD, 4, R1, R0);
    !do(request(DD),R0);
    !do(attach(DD),R1);
    if (R1 == success) {
        .log(warning,"I have attached a block ",B);
        .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,BB), L);
        .findall(t(I,J,T),thing(I,J,T,_), LT);
        .concat("[",req(I,J,B),",",myposition(X,Y),",",R0,"/",R1,"]",STR);
        .save_stats("blockAttached",STR);
    } else {
        .log(warning,"Could not request/attach block ",B, "::",R0,"/",R1," my position: (",X,",",Y,"), target (",I,",",J,")");
        .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,BB), L);
        .findall(t(I,J,T),thing(I,J,T,_), LT);
        .concat("[",req(I,J,B),",",myposition(X,Y),",",R0,"/",R1,"]",STR);
        .save_stats("errorOnAttach",STR);
    }
.
//
// +!get_block(req(I,J,B)) :  // In case the agent is far away from B
//      step(S)
//      //direction_increment(DIR,I,J)
//      <-
//      //!goto_nearest_adjacent(B,DIR);
//      //?nearest_walkable(B,X,Y);
//      //!goto(X,Y);
//      //!goto_nearest(B);
//      //?thing(_,_,dispenser,B);
//      //!drop_all_blocks;
//      !do(skip,_);
//      .wait(step(Step) & Step > S); //wait for the next step to continue
//      !goto_nearest_neighbour(B);
//      !get_block(req(I,J,B));
// .

+!get_block(req(I,J,B)) :  // In case the agent is far away from B
     step(S) &
     direction_increment(DIR,I,J) &
     thing(_,_,dispenser,B)
     <-
     !goto_nearest_adjacent(B,DIR);
     //.wait(step(Step) & Step > S); //wait for the next step to continue
     !get_block(req(I,J,B));
.


+!get_block(req(I,J,B)) :  // In case the agent is far away from B
     true
     <-
     !do(skip,_);
     !get_block(req(I,J,B));
.




+!pick_blocks(_, 0, R1, R0):
  true
  <-
    !do(rotate(cw),_);
  .

+!pick_blocks(DIR, QT, R1, R0):
  QT>0
  <-
    !do(request(DIR),R0);
    !do(attach(DIR),R1);
    !do(rotate(cw),_);
    !pick_blocks(DIR, QT-1, R1, R0);
    .
