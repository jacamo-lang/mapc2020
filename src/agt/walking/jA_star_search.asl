/**
 * Get the next direction \in [n,s,e,w] from origin OX,OY to a target X,Y
 * ?get_direction(0,0,1,2,DIR);
 */
get_direction(OX,OY,X,Y,DIR) :- 
    a_star( s(OX,OY), s(X,Y), Solution, Cost) & Solution = [INI,NEXT|T] & NEXT = op(DIR,_)
.

/* A* implementation */

{ register_function("search.h",2,"h") }

a_star( InitialState, Goal, Solution, Cost) :-
    .set.add_all(Closed,[InitialState]) &
    .queue.create(Open,priority) &
    .queue.add(Open,s(0,0,[op(initial,InitialState)])) &
    a_star_l( Open, Goal, s(_,Cost,SolutionR), Closed) &
    .reverse(SolutionR,Solution)
.

a_star_l( Open, GoalState, s(F,G,[op(Op,GoalState)|Path]), Closed) :-
    .queue.head(Open,s(F,G,[op(Op,GoalState)|Path]))
.

a_star_l( Open, GoalState, Solution, Closed) :-
    .queue.remove(Open,s(F,G,[op(Op,State)|Path])) &
    //.print("exploring ",State," to be explored ", .length(Open)) &
    State \== GoalState &
    .findall(
        s(NF,NG,[ op(NOp,NewState), op(Op,State)|Path]), // new paths
            ( suc(State,NewState,Cost,NOp) &
            not .member(NewState, Closed) &
            .set.add(Closed, NewState) &
            NG = G + Cost & // cost to achieve NewState
            //h(NewState,GoalState,H) &
            //NF = H + NG // cost + heuristic for new state
            NF = search.h(NewState,GoalState) + NG // cost + heuristic for new state
        ),
        Suc
    ) &
    //.print("     ",Suc) &
    .queue.add_all(Open, Suc) &
    a_star_l( Open, GoalState, Solution, Closed)
.

/* State transitions */

suc(s(X,Y),s(X+1,Y),1,e) :- not gps_map(X+1,Y,obstacle,_).
suc(s(X,Y),s(X-1,Y),1,w) :- not gps_map(X-1,Y,obstacle,_).
suc(s(X,Y),s(X,Y-1),1,n) :- not gps_map(X,Y-1,obstacle,_).
suc(s(X,Y),s(X,Y+1),1,s) :- not gps_map(X,Y+1,obstacle,_).

/* Heuristic using euclidean distance */
h(State,Goal,H) :- 
    State = s(X1,Y1) & 
    Goal = s(X2,Y2) & 
    H = math.abs(X2-X1) + math.abs(Y2-Y1)
.
