{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

directions([n,s,w,e]).

@step[atomic]	
+step( S ): directions(LDIRECTIONS)
	<-
		.nth(math.floor(math.random(4)),LDIRECTIONS,D);
		action(move(D));
	.	