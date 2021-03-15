+!go_defender(I,J,TYPE)
  <-
    !goto_center_goal(_,_,I,J,TYPE)
  .
//Finding Center of goal
+!goto_center_goal(X,Y,I,J,T):
  goal(0,0)
  <-
    // Find Center
    for (goal(I,J)) {
      if (center_goal(I,J,T)) {
        ?myposition(K,L);
        !goto(K+I,L+J,R);
        !goto_center_goal(X,Y, K+I,L+J,T);
      }
    }
  .

//In center of goal
+!goto_center_goal(X,Y, I, J,T):
  goal(0,0) &
  center_goal(I,J,T)
  .

//There is somebody in this gol, come back to defense
+!goto_center_goal(X,Y, I, J,T):
  not goal(0,0) &
  is_defending(A,B) &
  nearest_walkable(goal,ID,JD)
  <-
    //.log(warning,"====================>>>>>DESISTA PQ JA TEM ALGUEMMMMM");
    -perform_defender;
    -goto_center_goal;
    //!goto(0,0,R);
    !goto_XY(K,L);
    +exploring;
  .

// Going to center of goal because there is nobody
+!goto_center_goal(X,Y, I, J,T):
  not goal(0,0) &
  not is_defending(A,B) &
  (goal(K,L) & distance(0,0,K,L,D) & D < 6)
  <-
    //.log(warning,"====================>>>>>NORMAL CENTRO");
    ?myposition(O,P);
    !goto_XY_A(O+K,P+L);
    !goto_center_goal(X,Y, I,J,T);
  .

// Make aproch from goal area in not goal location
+!goto_center_goal(X,Y, I, J,T):
  not goal(0,0) &
  nearest_walkable(goal,ID,JD) &
  nearest_neighbour(ID,JD, K,L) &
  nearest_neighbour(K,L, O,P) &
  not goal(O,P)
  <-
    //.log(warning,"====================>>>>>NORMAL APPROCH");
    !goto_XY_A(O,P);
    !goto_center_goal(X,Y, I,J,T);
  .



//Return even if don't achive the especific location
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
        //Don't Try again
        .log(warning,"Ja Elvis: ",goto(X,Y,RET)," ",myposition(XP,YP));
    }
.
