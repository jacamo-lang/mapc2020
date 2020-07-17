{ include("common_exploration.asl") }
{ include("src/agt/STC_Strategy.asl")} //exploration strategy

myposition(0,0).
run_after_sync.
directions(0,[n,w,s,e]).//letter corresponding to the directions
directions(1,[s,e,n,w]).//letter corresponding to the directions

+!update_direction_stc 
   <- !update_direction; //update direction according to STC strategy
      ?current_direction_stc(Dir); 
      ?path_direction(PD) 
      ?directions(PD,DIRECTIONS); 
      .nth(Dir,DIRECTIONS,ND); //STC: update to the next direction
      -+current_direction(ND).
      
+!after_sync(PID) : exploration_strategy(stc) & run_after_sync & not(pending_isme(PID,MX,MY,AG,RX,RY,AX,AY)).    
      
+!after_sync(PID) : exploration_strategy(stc) & run_after_sync & pending_isme(PID,MX,MY,AG,RX,RY,AX,AY) & .my_name(Me)
   <-   
        OMX=AX+RX;
        OMY=AY+RY;  
        OLDORIGINX=OMX-MX;
        OLDORIGINY=OMY-MY;
        ?myposition(X,Y);
        -+last_node(X,Y);
        -+current_moving_step(0);
        !rebase_tree(OLDORIGINX,OLDORIGINY); //stc: modify the beliefs about the three to comply with the new location   //ToDo: share the covered area with the orign agent
        removeTree(Me). //remove the tree build by this agent 
        
        
//rebase_tree: changes the traversed tree to new base coordinates
+!rebase_tree(OldX,OldY) 
   <- .findall(new_parent(X,Y,D,SX,SY),edge(X,Y,D,SX,SY,Map) & .my_name(Me) & .substring(Me,Map), L);   
      !!rebase_tree_list(OldX,OldY,L).
             
+!rebase_tree_list(OldX,OldY,[]).                                       
+!rebase_tree_list(OldX,OldY,[new_parent(X,Y,D,SX,SY)|T]): adapt_coordinate(OldX+X,NX) & adapt_coordinate(OldY+Y,NY) & adapt_coordinate(OldX+SX,NSX) & adapt_coordinate(OldY+SY,NSY) &
                                                           (NX==NSX|NY==NSY) & //rebase only straight lines
                                                           vision(V) & (NX mod V==0) & (NY mod V==0) & (NSX mod V==0) & (NSY mod V==0)  //rebase only edges that fit in the vision range
   <- //.print("fez rebase de (",X,",",Y,",",D,",",SX,",",SY,") para (",NX,",",NY,",",D,",",NSX,",",NSY,") Old: (", OldX,",",OldY,")");
      !do_set_edge(NX,NY,D,NSX,NSY);
      !mark_new_path(NX,NY,NSX,NSY);
      !rebase_tree_list(OldX,OldY,T). 
           
+!rebase_tree_list(OldX,OldY,[new_parent(X,Y,D,SX,SY)|T]): adapt_coordinate(OldX+X,NX) & adapt_coordinate(OldY+Y,NY) & adapt_coordinate(OldX+SX,NSX) & adapt_coordinate(OldY+SY,NSY)
   <- //.print("ignored rebase de (",X,",",Y,",",D,",",SX,",",SY,") para (",NX,",",NY,",",D,",",NSX,",",NSY,") Old: (", OldX,",",OldY,")");
      !mark_new_path_vision(NX,NY,NSX,NSY);
      !rebase_tree_list(OldX,OldY,T).         
      
      
//STC: mark the path between the coordinates (X,Y) and (SX,SY)
+!mark_new_path(X,Y,SX,SY) : X<SX & X*SX>=0 & vision(S) & .my_name(Me)  
   <- .concat(Me,"(",X,",",Y,")",Hint);               
      mark(X, Y, self, Me,S);
      mark(X, Y, path, Hint,1);
      !mark_new_path(X+1,Y,SX,SY).
      
+!mark_new_path(X,Y,SX,SY) : X>SX & X*SX>0 & vision(S) & .my_name(Me)
   <- .concat(Me,"(",X,",",Y,")",Hint);               
      mark(X, Y, self, Me,S);
      mark(X, Y, path, Hint,1);
      !mark_new_path(X-1,Y,SX,SY).      
      
+!mark_new_path(X,Y,SX,SY) : Y<SY & Y*SY>=0 & vision(S) & .my_name(Me)
   <- .concat(Me,"(",X,",",Y,")",Hint);               
      mark(X, Y, self, Me,S);
      mark(X, Y, path, Hint,1);
      !mark_new_path(X,Y+1,SX,SY).
      
+!mark_new_path(X,Y,SX,SY) : Y>SY & Y*SY>0 & vision(S) & .my_name(Me)
   <- .concat(Me,"(",X,",",Y,")",Hint);               
      mark(X, Y, self, Me,S);
      mark(X, Y, path, Hint,1);
      !mark_new_path(X,Y-1,SX,SY).
        
+!mark_new_path(X,Y,SX,SY).           

//STC: mark the path between the coordinates (X,Y) and (SX,SY)
+!mark_new_path_vision(X,Y,SX,SY) : X<SX & X*SX>=0 & vision(S) & .my_name(Me) 
   <- !do_mark_new_path_vision(X,Y,SX,SY); 
      !mark_new_path_vision(X+1,Y,SX,SY).
      
+!mark_new_path_vision(X,Y,SX,SY) : X>SX & X*SX>0 & vision(S) & .my_name(Me)
   <- !do_mark_new_path_vision(X,Y,SX,SY); 
      !mark_new_path_vision(X-1,Y,SX,SY).      
      
+!mark_new_path_vision(X,Y,SX,SY) : Y<SY & Y*SY>=0 & vision(S) & .my_name(Me)
   <- !do_mark_new_path_vision(X,Y,SX,SY); 
      !mark_new_path_vision(X,Y+1,SX,SY).
      
+!mark_new_path_vision(X,Y,SX,SY) : Y>SY & Y*SY>0 & vision(S) & .my_name(Me)
   <- !do_mark_new_path_vision(X,Y,SX,SY); 
      !mark_new_path_vision(X,Y-1,SX,SY).              
      
+!mark_new_path_vision(X,Y,SX,SY).

+!do_mark_new_path_vision(X,Y,SX,SY) : origin(O) & gps_map(X,Y,_,MapId) & .substring(O,MapId). //do not overwrite a marked point
+!do_mark_new_path_vision(X,Y,SX,SY) : vision(S) & .my_name(Me) 
   <- markVision(X,Y,S).  
