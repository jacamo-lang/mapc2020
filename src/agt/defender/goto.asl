
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

+!goto_center_goal(X,Y, I, J):
  not goal(0,0) &
  origin(MyMAP) &
  gps_map(ID,JD,goal,MyMAP)    // I know a goal area position
  <-
    !goto(ID,JD, R);
    !goto_center_goal(X,Y, I,J);
  .
