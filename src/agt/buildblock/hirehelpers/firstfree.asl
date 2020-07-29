/***************************** master ****************************** */
+!hire(Q)
  :true
  <-
  	+helpersquantity(Q);
  	.broadcast(tell, hiring);  	
  .
 
 @hiring[atomic]
+!hireme[source(AGH)]
	: helpersquantity(Q) & Q>0
	<-
		-+helpersquantity(Q-1);
		+helper(AGH);
		.send(AGH,tell,hired);
	.

+helpersquantity(0)
	: true
	<-
		.broadcast(untell, hiring);
		+readytobuild;
	.
	
/***************************** helper **************************** */
+hiring[source(AGM)]
	: not hired[source(_)]	
	<-
		.send(AGM,achieve,hireme);
	.