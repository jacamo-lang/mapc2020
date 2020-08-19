{ include("buildblock/builderstrategies/onetypebyhelper.asl") }
{ include("buildblock/hirehelpers/firstfree.asl") }
{ include("buildblock/taskselect/rewardbyblock.asl") }

//-- build list a summarized list of blocks by quantity --
countblocks([],[]).
countblocks([req(_,_,TYPE)|T],R):-countblocks(T,PR) & count(PR,TYPE,R). 

count([],TYPE,[block(TYPE,1)]).
count([block(TYPE, QUANTITY)|T],TYPE,[block(TYPE,QUANTITY+1)|T]).
count([block(TYPEL,QUANTITY)|T],TYPE,[block(TYPEL,QUANTITY)|R]):-count(T,TYPE,R).
//--------------------------------------------------------

//--- find more distant member in X and Y ----------------
highX(L,math.abs(X)):- .member(req(X,_,_),L) &
             not (.member(req(X1,_,_),L) & math.abs(X)<math.abs(X1)).

highY(L,math.abs(Y)):- .member(req(_,Y,_),L) &  
             not (.member(req(_,Y1,_),L) & math.abs(Y)<math.abs(Y1)).
//-------------------------------------------------------

helpersquantity(3). //number of helpers to hire

!preload.

+!preload
    :true
    <-  
        .wait(name(_));
        !hire;
    .

+!gotask 
    : choosetask(task(NAME,REWARD,DEADLINE,L)) //taskcommitment strategy

    <-
        !deliveryqueue(L,DQ); //build a queue for deliver blocks of structure
        !deliveryrequest(DQ); //Define a quantity of agents and the content of transportation
        !buildstructure(DQ); //Build the structure
        !releasehelpers; //release occupied agent because the task is over
 .
 
+!deliveryqueue(L,R)
    :  highX(L,HX) & highY(L,HY) 
    <-
        !buildeliveryqueue(L,1,HX+HY,R);
    .

+!buildeliveryqueue(L,P,H,R)
    :  P<=H & .member(req(X,Y,TYPE),L) & math.abs(Y)+math.abs(X)=P 
    <-
        .delete(req(X,Y,TYPE),L,UPDATEDL);      
        !buildeliveryqueue(UPDATEDL,P,H,PR);
        R=[req(X,Y,TYPE)|PR];
    .
    
+!buildeliveryqueue(L,P,H,R)
    :  P<=H  
    <-
        !buildeliveryqueue(L,P+1,H,R);
    .

+!buildeliveryqueue(L,P,H,R)
    :  P>H  
    <-
        R=[];
    .
    
+!buildstructure([req(X,Y,TYPE)|L]) : true
    <-
        .wait(available(TYPE)[source(AGH)]);
        ?myposition(X0,Y0);
        .send(AGH,achieve,attach(X0+X,Y0+Y,TYPE));
        .wait(atposition(X0+X,Y0+Y,TYPE)[source(AGH)]);
        
        /* WHEN THE HELPER IS WORKING CHANGE IT TO ACTION DO */
        .print("DO --->",connect(AGH,X,Y)); 
        !buildstructure(L);
    .

+!buildstructure([]) 
    <-
        true
    .   
    
+!releasehelpers 
    : true
    <-
      for(occupied(AGH)) {
        -occupied(AGH);
        .send(AGH,achieve,taskisover);
      }
    .
