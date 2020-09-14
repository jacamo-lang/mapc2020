/**
 * Get the next direction \in [n,s,e,w] from origin OX,OY to a target X,Y
 * ?get_direction(0,0,1,2,DIR);
 */
get_direction(OX,OY,X,Y,DIR) :- search( [p([s(OX,OY)],Actions)], s(X,Y), Solution) & Solution = [DIR|T]
    //& .log(warning,"Next direction: ",DIR)
.

/**
 * Blind search algorithm
 * Sample execution: ?search( [p(0,[s(0,0)],Actions)], s(3,3), _);
 * It is asking a path to go from X,Y = 0,0 to X,Y = 3,3, considering X increases to east (e) and Y increases to north (n)
 * Expected result: Sorted actions: [e,e,e,n,n,n|_1981] Path:[s(0,0),s(1,0),s(2,0),s(3,0),s(3,1),s(3,2)]
 */
search( [p([GoalState|Path],Actions) | _], GoalState, RevActions) :-
    true & .reverse(Actions, RevActions) //& .reverse(Path, RevPath) & .log(warning,"Sorted actions: ",RevActions," Path:",RevPath)
.
search( [p([State|Path],PrevActions)|Open], GoalState, Solution) :-
    State \== GoalState & //.log(warning,"  ** ",State," ",PrevActions) &
    .findall(
        p([NewState,State|Path],[Action|PrevActions]),
        (transition(State,Action,NewState) & not .member(NewState, [State|Path])),
        Sucs) &
    .concat(Open,Sucs,LT) &
    //.log(warning," open nodes #",.length(LT)) & .log(warning," new open = ",LT) &
    search(LT, GoalState, Solution)
.

/**
 * Transition is defined as transition(State,Action,NewState), i.e.,
 * from a given State, doing a certain Action, its achieves NewState
 */
transition( s(X,Y),e,s(X+1,Y) ) :- not gps_map(X+1,Y,obstacle,_).
transition( s(X,Y),w,s(X-1,Y) ) :- not gps_map(X-1,Y,obstacle,_).
transition( s(X,Y),n,s(X,Y-1) ) :- not gps_map(X,Y-1,obstacle,_).
transition( s(X,Y),s,s(X,Y+1) ) :- not gps_map(X,Y+1,obstacle,_).
