nextDirection(w,n).
nextDirection(n,e).
nextDirection(e,s).
nextDirection(s,w).

directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).
myposition(0,0).

+!goto(X,Y): 
    myposition(X,Y)
    <- .print("-------> " ,cheguei(X,Y)).
        

+!goto(X,Y): 
    not myposition(X,Y)
    <-
      ?myposition(OX,OY);
      DISTANCEX=math.abs(X-OX);
      DISTANCEY=math.abs(Y-OY);
      
      if (DISTANCEX>DISTANCEY) {
        DESIRABLEX = (X-OX)/DISTANCEX;
        DESIRABLEY = 0;
      }
      else {
        DESIRABLEX = 0;
        DESIRABLEY = (Y-OY)/DISTANCEY;
      } 
      if (not obstacle(DESIRABLEX,DESIRABLEY)) {
        ?directionIncrement(DIRECTION,DESIRABLEX,DESIRABLEY);
        !do(move(DIRECTION),R);   
        if (R=success) {
            !mapping(DIRECTION);    
        }       
      }
      else {
        ?directionIncrement(BLOCKEDDIRECTION,DESIRABLEX,DESIRABLEY);
        ?nextDirection(BLOCKEDDIRECTION,DIRECTION);
        !workaround(DIRECTION); 
      }
      !goto(X,Y);
    .
    
+!workaround(DIRECTION):
    true
    <-  
      if (directionIncrement(DIRECTION, X, Y) &
          obstacle(X,Y)) {
          ?nextDirection(DIRECTION,NEXTDIRECTION);   
          !workaround(NEXTDIRECTION);    
      }
      else {
          !do(move(DIRECTION),R);
          if (R=failed_path) {
            ?nextDirection(DIRECTION,NEXTDIRECTION);   
            !workaround(NEXTDIRECTION,DIRECTIONX,DIRECTIONY);        
          }
          if (R=success) {
            !mapping(DIRECTION);    
          }
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
        ?vision(S);
        mark(NX, NY, self, step,S);

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
    true
    <-
    .my_name(AG);  
     mark(X+I, Y+J, TYPE, AG,0);               
    .
