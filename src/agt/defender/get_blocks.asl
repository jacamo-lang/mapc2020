
+!fill_blocks(B):
  step(S)
  <-
    .log(warning,"FULLFILING BLOCKS");
    //?myposition(X,Y);
    //!goto(I,J,R);
    .log(warning,"CHEGUEIII");
    !defines_places;
    //!get_block(4);
    .log(warning,"PPICKED BLOCK");
  .

+!defines_places:
  .findall(not attached(I,J), not attached(I,J),LA)
  <-
    for (.member(not attached(I,J),LA) & directionIncrement(D,I,J)) {
        !check_if_can(D,R);
        if (R \== success) {
          -perform_defender;
          //-defines_places;
          +exploring;
        }
    }
  .

+!check_if_can(DIR,R):
    thing(_,_,dispenser,B) &
    nearest_adjacent(B,X,Y,DIR) &
    is_walkable(X,Y)
    <-
      .log(warning,"Indo perto do dispenser");
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

+!get_block(req(I,J,B),R) :  // In case the agent is far away from B
     step(S) &
     direction_increment(DIR,I,J)
     <-
     !goto_nearest_adjacent(B,DIR);
     //.wait(step(Step) & Step > S); //wait for the next step to continue
     !get_block(req(I,J,B),R);
.

+!get_block(1,0,QT):
    QT > 0 &
    direction_increment(DIR,1,0) &
    thing(_,_,dispenser,B) &
    nearest_adjacent(B,X,Y,DIR) &
    is_walkable(X,Y) &
    not(attached(1,0))
    <-
      !get_block(req(1,0,B),QT);
    .
+!get_block(0,1,QT):
    QT > 0 &
    direction_increment(DIR,0,1) &
    thing(_,_,dispenser,B) &
    nearest_adjacent(B,X,Y,DIR) &
    is_walkable(X,Y) &
    not(attached(0,1))
    <-
      !get_block(req(0,1,B));
    .
+!get_block(-1,0,QT):
    QT > 0 &
    direction_increment(DIR,-1,0) &
    thing(_,_,dispenser,B) &
    nearest_adjacent(B,X,Y,DIR) &
    is_walkable(X,Y) &
    not(attached(-1,0))
    <-
      !get_block(req(-1,0,B),QT);
    .
+!get_block(0,-1,QT):
    QT > 0 &
    direction_increment(DIR,0,-1) &
    thing(_,_,dispenser,B) &
    nearest_adjacent(B,X,Y,DIR) &
    is_walkable(X,Y) &
    not(attached(0,-1))
    <-
      !get_block(req(0,-1,B),QT);
    .
+!get_block(QT):
  QT > 0
  <-
    !get_block(I,J,QT);
  .
+!get_block(0).
//
// +!get_block(QT):
//     QT > 0
//     <-
//       !get_block(I,J,QT).
// +!get_block(0).

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
