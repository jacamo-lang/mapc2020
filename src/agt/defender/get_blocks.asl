+!fill_blocks: .count(attached(_,_)) == 4.

+!fill_blocks:
  .findall(not attached(I,J), not attached(I,J),LA) &
  .count(attached(_,_)) \== 4
  <-
    for (.member(not attached(I,J),LA) & directionIncrement(D,I,J)) {
      !check_block_dir(D,R);
    };
    !fill_blocks;
  .

+!check_block_dir(DIR,R):
  true
  <-
  !check_if_neighbour(DIR,R1);
  if (R1 \== success) {
    !check_if_can(DIR,R);
    if (R \==success){
      !do(skip,_);
      //!goto_nearest(goal);
      //-check_block_dir;
      //-perform_defender;
      //+exploring;
    }
  }
.

+!check_if_neighbour(DIR,success):
    direction_increment(DIR,I,J) &
    thing(I,J,block,B) &
    not attached(I,J)
    <-
      !do(attach(DIR),R1);
      if (R \==success){
        !do(skip,_)
      }
    .
+!check_if_neighbour(DIR,failure).

+!check_if_can(DIR,R):
    thing(_,_,dispenser,B) &
    nearest_adjacent(B,X,Y,DIR) &
    is_walkable(X,Y)
    <-
      //.log(warning,"Indo perto do dispenser");
      !goto(X,Y,R);
      ?direction_increment(DIR,I,J);
      !get_block(req(I,J,B),R);
    .

+!check_if_can(DIR,false).


+!get_block(req(I,J,B),R1) :
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
        //.findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,BB), L);
        //.findall(t(I,J,T),thing(I,J,T,_), LT);
        //.concat("[",req(I,J,B),",",myposition(X,Y),",",R0,"/",R1,"]",STR);
        //.save_stats("blockAttached",STR);
    } else {
        .log(warning,"Could not request/attach block ",B, "::",R0,"/",R1," my position: (",X,",",Y,"), target (",I,",",J,")");
        .findall(a(IB,JB,BB),attached(IB,JB) & thing(IB,JB,BB), L);
        .findall(t(I,J,T),thing(I,J,T,_), LT);
        .concat("[",req(I,J,B),",",myposition(X,Y),",",R0,"/",R1,"]",STR);
        .save_stats("errorOnAttach",STR);
    }
.

+!get_block(req(I,J,B),R) :  // In case the agent is far away from B
     step(S) &
     direction_increment(DIR,I,J)
     <-
     !goto_nearest_adjacent(B,DIR);
     //.wait(step(Step) & Step > S); //wait for the next step to continue
     !get_block(req(I,J,B),R);
.
