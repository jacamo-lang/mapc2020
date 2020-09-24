/**
 * Get the next direction \in [n,s,e,w] from origin OX,OY to a target X,Y
 * ?get_direction(0,0,1,2,DIR);
 */
get_direction(OX,OY,X,Y,DIR) :- .set.add_all(Closed,[]) &
    search( [p([s(OX,OY,_)])], s(X,Y,_), Solution, Closed) &
    Solution = p(Sol) & .reverse(Sol,RevSol) & RevSol = [H|T] & H = s(OX,OY,DIR)
    //& .log(warning,"Next direction: ",DIR)
.

/**
 * Blind search algorithm
 * Sample execution: ?search( [p(0,[s(0,0)],Actions)], s(3,3), RevActions); .log(warning,RevActions)
 * It is asking a path to go from X,Y = 0,0 to X,Y = 3,3, considering X increases to east (e) and Y increases to north (n)
 * Expected result:
 */
search( [p([GoalState|Path]) | _], GoalState, p([GoalState|Path]), Closed).

search( [p([State|Path])|Open], GoalState, Solution, Closed) :-
    State \== GoalState &
    .findall(
         p([NewState, State|Path]), // new paths
           ( suc(State,NewState) &
         not .member(NewState, [State|Path]) & // turn closed off, otherwise it is too fast
         not .member(NewState, Closed) &
         .set.add(Closed, NewState)
       ),
       Suc
    ) &
    .concat( Open, Suc, NewOpen) &
    //.print("open nodes #",.length(NewOpen)) & //," new open = ",NewOpen) &
    search( NewOpen, GoalState, Solution, Closed).

suc(s(X,Y,e),s(X+1,Y,_)) :- not gps_map(X+1,Y,obstacle,_).
suc(s(X,Y,w),s(X-1,Y,_)) :- not gps_map(X-1,Y,obstacle,_).
suc(s(X,Y,n),s(X,Y-1,_)) :- not gps_map(X,Y-1,obstacle,_).
suc(s(X,Y,s),s(X,Y+1,_)) :- not gps_map(X,Y+1,obstacle,_).
