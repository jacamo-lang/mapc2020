/************************* master ******************************** */
+!deliveryrequest([req(_,_,TYPE)|_],X,Y)
    : true
    <-
     	?helper(AGH);
    	.send(AGH,achieve,bring(TYPE,2,X,Y));        
     .