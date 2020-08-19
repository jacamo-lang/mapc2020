choosetask(task(NAME,REWARD,DEADLINE,L)) :-
    task(NAME,REWARD,DEADLINE,L) & 
    .length(L,SL) & 
    not (task(_,RC,DC,LC) &
         .length(LC,SLC)  &
         REWARD/SL < RC/SLC).
