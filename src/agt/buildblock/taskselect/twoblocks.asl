choosetask(task(NAME,REWARD,DEADLINE,L)) :-
      task(NAME,REWARD,DEADLINE,L) &
      L=[req(_,_,TYPE),req(_,_,TYPE)|[]] &
      gps_map(_,_,TYPE,"agenta1") .
//    task(NAME,REWARD,DEADLINE,L) & ( 
//    L=[req(X0,Y0,TYPE),req(X1+1,Y1,TYPE)|[]] |
//    L=[req(X0,Y0,TYPE),req(X1-1,Y1,TYPE)|[]] |
//    L=[req(X0,Y0,TYPE),req(X1,Y1+1,TYPE)|[]] |
//    L=[req(X0,Y0,TYPE),req(X1,Y1-1,TYPE)|[]] ).
//    & 
//    not (task(_,RC,DC,LC) & ( 
//    L=[req(X2,Y2,TYPE),req(X3+1,Y3,TYPE)|[]] |
//    L=[req(X2,Y2,TYPE),req(X3-1,Y3,TYPE)|[]] |
//    L=[req(X2,Y2,TYPE),req(X3,Y3+1,TYPE)|[]] |
//    L=[req(X2,Y2,TYPE),req(X3,Y3-1,TYPE)|[]] )&
//    DEADLINE < DC).
