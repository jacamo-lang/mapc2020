{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).

direction(w,1).
lastDirection(w).
size(1).

+!move(failed_path): direction(D,_)  
	<-	
		?nextDirection(D,ND);
		?size(S);
		action(move(ND));
		-+lastDirection(ND);
		-+direction(ND,S);		
		-+size(S+1);
	.

+!move(R): R=success & direction(D,1) 
	<-	
		action(move(D));
		?nextDirection(D,ND);
		?size(S);
		-+lastDirection(D);
		-+direction(ND,S+1);
		-+size(S+1);
	.
	
+!move(success): direction(D,N)  
	<-		
		action(move(D));
		-+lastDirection(D);
		-+direction(D,N-1);
	.

+!move(X):  lastDirection(LD) 
	<-
		action(move(LD));
	.
	
@lastActionResult[atomic]		
+lastActionResult(X) : true
	<-	
		!move(X);
	.