/************************* master ******************************** */
+!deliveryrequest(L)
	: true
 	<-
 		?myposition(X,Y);
 		?countblocks(L,QB);
		for ( .member(block(TYPE, QUANTITY),QB) ) {
		  QAGENTS=math.ceil(QUANTITY/4);
		  QBLOCKS=math.ceil(QUANTITY/QAGENTS);
		  for(.range(I,1,QAGENTS)) {
		  	?(helper(AGH) & not occupied(AGH));
		  	.send(AGH,achieve,bring(TYPE,QBLOCKS,X,Y));
		  	+occupied(AGH);
		  }		  
     	}
     .
     
+!free[source(AGH)]
	: true
	<-
		-occupied(AGH);
	.
	
/************************* helper ******************************** */
+availableblocks(TYPE,0) : serving(AGBM)
	<-
		.send(AGBM,untell,available(TYPE));
		.send(AGBM,achieve,free);
	.	
/***************************************************************** */