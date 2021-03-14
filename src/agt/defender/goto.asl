
+!goto_center_goal(X,Y, I, J):
  goal(0,0)
  <-
    // Find Center
    for (goal(I,J)) {
      if (center_goal(I,J)) {
        ?myposition(K,L);
        !goto(K+I,L+J,R);
        !goto_center_goal(X,Y, K+I,L+J);
      }
    }
  .

+!goto_center_goal(X,Y, I, J):
  goal(0,0) &
  center_goal(I,J)
  .

// +!goto_center_goal(X,Y, I, J):
//   not goal(0,0) &
//   thing(A,B,entity,TEAM) &
//   team(TEAM) &
//   goal(A,B) &
//   origin(MyMAP) &
//   gps_map(ID,JD,goal,MyMAP)    // I know a goal area position
//   <-
//     .log(warning,"TERIA QUE ENVIAR AAAAA=================================");
//     !goto_center_goal(X,Y, I,J);
//   .
//
// +!goto_center_goal(X,Y, I, J):
//   not goal(0,0) &
//   not thing(_,_,entity,TEAM) &
//   not team(TEAM) &
//   origin(MyMAP) &
//   gps_map(ID,JD,goal,MyMAP)    // I know a goal area position
//   <-
//     !goto(ID,JD, R);
//     !goto_center_goal(X,Y, I,J);
//
+!goto_center_goal(X,Y, I, J):
  not goal(0,0) &
  thing(A,B,entity,TEAM) &
  team(TEAM) &
  goal(A,B)
  //center_goal(A,B)
  <-
    .log(warning,"====================>>>>>DESISTA PQ JA TEM ALGUEMMMMM");
    //!goto_center_goal(X,Y, I,J);
    -perform_defender;
    -goto_center_goal;
    +exploring;
  .

//
// +!goto_center_goal(X,Y, I, J):
//   not goal(0,0) &
//   not (thing(A,B,entity,TEAM) &
//   team(TEAM) & goal(A,B) & center_goal(A,B)) &
//   origin(MyMAP) &
//   (thing(ID,JD,goal,MyMAP) & distance(0,0,ID,JD,L) & (L < 4))
//   <-
//     .log(warning,"====================>>>>>NAO TEM NINGUEM");
//     !goto(ID,JD, R);
//     !goto_center_goal(X,Y, I,J);
//

+!goto_XY_A(X,Y)
    <-
    !goto(X,Y,RET);
    if (RET \== success & myposition(XP,YP)) {
        if(RET == no_route){
            !do(skip,R); //ToDo: check whether skipping is the better action here (couldn't it move to a neighbour point to find a route?)
            // A .fail would be the best option but it could cause a plan failure in the beginning/middle of perform task resulting in not successful performance
        }
        .log(warning,"No success on: ",goto(X,Y,RET)," ",myposition(XP,YP));
    } else {
        //Try again
        //!goto_XY(X,Y);
        .log(warning,"Ja Elvis: ",goto(X,Y,RET)," ",myposition(XP,YP));
    }
.

+!goto_center_goal(X,Y, I, J):
  not goal(0,0) &
  not (thing(A,B,entity,TEAM) &
  team(TEAM) &
  goal(A,B)) &
  (goal(K,L) & distance(0,0,K,L,D) & D < 6)
  <-
    //!goto_nearest_neighbour(goal);
    //!goto(ID-1,JD, R);
    //==?nearest_walkable(goal,K,L);
    .log(warning,"====================>>>>>NORMAL CENTRO");
    //!goto_nearest_neighbour(goal);
    //?nearest_walkable(goal,A,B);
    //?nearest_neighbour(A,B,K,L);
    //?nearest_neighbour(ID,JD,IN,JN);
    ?myposition(O,P);
    !goto_XY_A(O+K,P+L);
    !goto_center_goal(X,Y, I,J);
  .

+!goto_center_goal(X,Y, I, J):
  not goal(0,0) &
  //origin(MyMAP) &
  //gps_map(ID,JD,goal,MyMAP) &   // I know a goal area position
  nearest_walkable(goal,ID,JD) &
  nearest_neighbour(ID,JD, K,L) &
  nearest_neighbour(K,L, O,P) &
  not goal(O,P)
  <-
    //!goto_nearest_neighbour(goal);
    //!goto(ID-1,JD, R);
    //==?nearest_walkable(goal,K,L);
    .log(warning,"====================>>>>>NORMAL APPROCH");
    //!goto_nearest_neighbour(goal);
    //?nearest_walkable(goal,A,B);
    //?nearest_neighbour(A,B,K,L);
    //not ()
    //?nearest_neighbour(ID,JD,IN,JN);
    !goto_XY_A(O,P);
    !goto_center_goal(X,Y, I,J);
  .
