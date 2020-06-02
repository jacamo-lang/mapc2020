{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("action.asl") }
{ include("taskmanager.asl") }
{ include("src/agt/meeting.asl")} //exploration strategy

buildscene(SIZE, SIZE, _, _,[]).

buildscene(START, SIZE, LINESIZE, [m(X0,Y0,TYPE)|TAIL],SCENEOUTPUT):-
        X0= START div LINESIZE &
        Y0= START mod LINESIZE &
        buildscene(START+1,SIZE, LINESIZE, TAIL,SCNOUT) &
        SCENEOUTPUT=[m(X0,Y0,TYPE)|SCNOUT].

buildscene(START, SIZE, LINESIZE, [m(X0,Y0,TYPE)|TAIL],SCENEOUTPUT):-
        XT=START div LINESIZE &
        YT= START mod LINESIZE  & 
        not (X0= XT & Y0= YT) &                 
        buildscene(START+1,SIZE, LINESIZE, [m(X0,Y0,TYPE)|TAIL],SCNOUT) &
        SCENEOUTPUT=[m(XT,YT,empty)|SCNOUT].

checkscene ([m(X0,Y0,goal)|T]):-goal(-X0,-Y0) & checkscene (T).
checkscene ([m(X0,Y0,obst)|T]):-obstacle(-X0,-Y0) & checkscene (T).
checkscene ([m(X0,Y0,TYPE)|T]):-thing(-X0,-Y0,_,TYPE) & checkscene (T).
checkscene ([m(X0,Y0,empty)|T]):- not (  goal(-X0,-Y0) |
                                         obstacle(-X0,-Y0) | 
                                         thing(-X0,-Y0,_,_) ) &
                                         checkscene (T).
checkscene ([]):-true.


newpid(PID):-(PID=math.random(1000000) & not pid(PID)) | newpid(PID).

pertinence(XR,YR,X,Y):- ((XR<0  & X>=XR) |
                        (XR>=0 & X<=XR)) &
                        ((YR<0  & Y>=YR) |
                        (YR>=0 & Y<=YR)). 

originlead(agenta0).

nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).

directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).

size(1).
lastmapping(-1).
myposition(0,0).

!start.

+!start: 
	true
    <-
        .wait(step(_));
        ?name(NAME);        
        +origin(NAME);
        !!move (w,0,1)[critical_section(action), priority(1)];
    .


+disabled(true):
	true
	<-
		.print("recharging...");
		!!recharge[critical_section(action), priority(2)];
	.

+!recharge:
	true
	<-
		!do(skip,R);
	.
	
+!move(D,S,LENGTH): 
	true
	<-
	  if (S=LENGTH) {
      	?nextDirection(D,ND);
        NS=0;
        NL=LENGTH+1;
      } 
      else {
      	ND=D;
      	NS=S+1;
      	NL=LENGTH;
      }
      !do(move(ND),R);
      
      if (R=failed_path) {
    	?nextDirection(ND,NND);   
        !!move(NND,0,NL)[critical_section(action), priority(1)];
      }
      if (R=success) {
      	!mapping(ND);
      	!!move(ND,NS,NL)[critical_section(action), priority(1)];
      }     
	.

+!mapping(DIRECTION) :  
    directionIncrement(DIRECTION, INCX,  INCY) & 
    step(STEP) & 
    myposition(X,Y)
    <-  
        NX= X+INCX;
        NY= Y+INCY;
        -+myposition(NX,NY);
        if(origin(OL) & originlead(OL)) {
            unmark(X,Y); 
            ?vision(S)
            mark(NX, NY, self, step,S);
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
        for (thing(I,J,entity,TEAM) & 
             team(TEAM)) {
            !sincMap(I,J);
        }       
.



+!addMap(I,J,X,Y,TYPE) :  
    .my_name(AG) & origin(O)  
    <-
        if(origin(OL) & originlead(OL)) {
            mark(X+I, Y+J, TYPE, AG,0, O); //The last parameter is the map identifier              
        }   
        +map(O,X+I,Y+J,TYPE);
    .
