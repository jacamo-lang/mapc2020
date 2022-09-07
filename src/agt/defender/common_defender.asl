center_goal_small(X,Y,small) :-
    (goal(X-1,Y)) & (goal(X+1,Y)) & (goal(X,Y+1)) & (goal(X,Y-1)) &
    (not goal(X-1,Y-1)) & (not goal(X-1,Y+1)) &
    (not goal(X+1,Y-1)) & (not goal(X+1,Y+1))
    .
center_goal_big(X,Y,big) :-
    (goal(X-1,Y)) & (goal(X+1,Y)) & (goal(X,Y+1)) & (goal(X,Y-1)) &
    (goal(X-1,Y-1)) & (goal(X-1,Y+1)) &
    (goal(X+1,Y-1)) & (goal(X+1,Y+1))
    .

position_defenser(X,Y,XM,YM) :- position_n(X,Y,XM,YM)  | position_nw(X,Y,XM,YM) |
                                position_sw(X,Y,XM,YM) | position_w(X,Y,XM,YM)  |
                                position_s(X,Y,XM,YM)  | position_ne(X,Y,XM,YM) |
                                position_se(X,Y,XM,YM) | position_e(X,Y,XM,YM).
position_n(X,Y,0,-1)   :- (X>=-1 & X<=1 & Y<=-1) | Y<=-2.
position_w(X,Y,-1,0)   :- (X<=-1 & Y>=-1 & Y<=1) | X<=-2.
position_nw(X,Y,-1,-1) :- (X>=-3 & X<=-1 & Y>=-2 & Y<=-1).
position_sw(X,Y,-1,1)  :- (X<=3 & X>=1 & Y>=-2 & Y<=-1).
position_s(X,Y,0,1)    :- (X>=-1 & X<=1 & Y>=1)  | Y>=2.
position_e(X,Y,1,0)    :- (X>=1 & Y>=-1 & Y<=1)  | X>=2.
position_ne(X,Y,1,-1)  :- (X>=-3 & X<=-1 & Y<=2 & Y>=1).
position_se(X,Y,1,1)   :- (X<=3 & X>=1 & Y<=2 & Y>=1).

center_goal(X,Y,TYPE) :- center_goal_small(X,Y,TYPE) | center_goal_big(X,Y,TYPE).

is_defending(A,B):-
  thing(A,B,entity,TEAM) &
  team(TEAM) &
  goal(A,B)
  .

can_full_fill(DIR):-
  thing(X, Y, dispenser, B) &
  nearest_adjacent(B,X,Y,DIR) &
  is_walkable(X,Y)
  .

can_full_fill:-
  can_full_fill(n)
  // can_full_fill(s) &
  // can_full_fill(e) &
  // can_full_fill(w)
  .
