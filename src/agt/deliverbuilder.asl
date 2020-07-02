task(task1,410,154,[req(0,1,b2),req(1,1,b1),req(-1,0,b2),req(-1,-1,b0),req(0,-1,b2),req(-1,1,b0),req(1,-1,b2),req(-2,2,b0),req(-1,2,b2),req(0,2,b0),req(1,2,b2),req(2,2,b0),req(1,0,b2)]).
task(task15,410,154,[req(0,1,b2),req(0,2,b1),req(0,3,b2),req(0,4,b0)]).
task(task0,119,16,[req((-2),2,b2),req((-1),2,b2),req(0,1,b2),req(0,2,b1)]).
task(task1,199,9,[req(0,1,b2),req(0,2,b1),req(0,3,b2)]).
task(task10,292,1,[req(0,1,b1)]).
task(task11,362,4,[req(0,1,b2),req(1,1,b1)]).
task(task12,405,16,[req(0,1,b1),req(1,1,b2)]).
task(task13,421,73,[req(0,1,b1),req(0,2,b2),req(0,3,b2)]).
task(task14,446,142,[req(0,1,b2),req(0,2,b0),req(1,2,b2),req(1,3,b1)]).
task(task15,410,154,[req(0,1,b2),req(0,2,b1),req(0,3,b2),req(0,4,b0)]).
task(task2,177,9,[req((-1),1,b0),req((-1),2,b0),req(0,1,b0)]).
//----------------------------------------
countblocks([],[]).
countblocks([req(_,_,TYPE)|T],R):-countblocks(T,PR) & count(PR,TYPE,R). 

count([],TYPE,[block(TYPE,1)]).
count([block(TYPE, QUANTITY)|T],TYPE,[block(TYPE,QUANTITY+1)|T]).
count([block(TYPEL,QUANTITY)|T],TYPE,[block(TYPEL,QUANTITY)|R]):-count(T,TYPE,R).
//-----------------------------------------

highX(L,math.abs(X)):- .member(req(X,_,_),L) &
			 not (.member(req(X1,_,_),L) & math.abs(X)<math.abs(X1)).

highY(L,math.abs(Y)):- .member(req(_,Y,_),L) &  
			 not (.member(req(_,Y1,_),L) & math.abs(Y)<math.abs(Y1)).

//-----------------------------------------
 !start.
 
 +!start 
 	: true 
 	<-
 		for (task(_,_,_,L)) {
 			.print(L);        	
        	!deliveryqueue(L,DQ);
        	.print(DQ);
            !deliveryrequest(DQ);
            .print ("------------------------------");
        }
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

+!deliveryrequest(L)
	: true
 	<-
		?countblocks(L,QB);
		for ( .member(block(TYPE, QUANTITY),QB) ) {
		  QAGENTS=math.ceil(QUANTITY/4);
		  QBLOCKS=math.ceil(QUANTITY/QAGENTS);
		  for(.range(I,1,QAGENTS)) {
		  	.print(demand (QBLOCKS,TYPE));	
		  }
     	}	
     .
 	
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
