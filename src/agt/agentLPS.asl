{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).

directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).

direction(w,1).
size(1).
lastmapping(-1).
myposition(0,0).

!start.

+!start: true
	<-
		.wait(step(_));
		!!move;
	.

+!move: 
	lastactionstep(STEP) & 
	step(STEP)
	<-
		.wait (lastactionstep(STEP) & not step(STEP));
		!!move;
	.

+!move: 
	lastActionResult(null) & 
	step(STEP)
	<-
		action(move(w));
		-+lastactionstep(STEP);
		!!move;
	.



+!move: 
	lastActionResult(failed_random) &
	direction(LD,_)  & 
	step(STEP)
	<-
		action(move(LD));
		-+lastactionstep(STEP);
		!!move;
	.

+!move: 
	lastActionResult(failed_path) &
	direction(D,_) 	 & 
	nextDirection(D,ND) &
	size(S) & 
	step(STEP)
	<-	
		-+direction(ND,S);		
		-+size(S+1);
		action(move(ND));
		-+lastactionstep(STEP);
		!!move;
	.

+!move:
	lastActionResult(success) &
	direction(D,0)		 &
	nextDirection(D,ND)  &
	size(S) & 
	step(STEP) 
	<-	
		!mapping(D);
		-+direction(ND,S+1);
		-+size(S+1);
		action(move(ND));
		-+lastactionstep(STEP);
		!!move;
	.
	
+!move: 
	lastActionResult(success) &
	direction(D,N)   & 
	step(STEP)
	<-		
		!mapping(D);
		-+direction(D,N-1);
		action(move(D));
		-+lastactionstep(STEP);
		!!move;
	.

+!mapping(DIRECTION) :  
	directionIncrement(DIRECTION, INCX,  INCY) & 
	step(STEP) & 
	myposition(X,Y)
	<-	
		NX= X+INCX;
		NY= Y+INCY;
		-+myposition(NX,NY);
		if(.my_name(agenta0)) {
			mark(NX, NY, self, step);
			.print(position (DIRECTION,NX, NY));			
		}	
		for (goal(I,J)) {
			!addMap(I,J,NX,NY,goal);
		}
		for (obstacle(I,J)) {
			!addMap(I,J,NX,NY,obstacle);
		}
		for (thing(I,J,dispenser,TYPE)) {
			!addMap(I,J,NX,NY,TYPE);
		}
.

+!addMap(I,J,X,Y,TYPE) :  
	.my_name(AG)  
	<-
		if(AG=agenta0) {
			mark(X+I, Y+J, TYPE, AG);				
		}	
		+map(O,X+I,Y+J,TYPE);
	.