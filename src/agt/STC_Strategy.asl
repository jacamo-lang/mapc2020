field_size(70). //size of the field
current_moving_step(99). //current step to the next cell ([0...vision]) - starts with 99 to force finding an initial direction
forward. //moving to forward (becomes false when moving backwards)
last_node(-1,-1). //last visited node 

path_direction(0).
directions(0,[n,w,s,e]).//letter corresponding to the directions
directions(1,[s,e,n,w]).//letter corresponding to the directions
current_direction_stc(0).
counter_direction(0,2). //counter direction of north is south
counter_direction(1,3).
counter_direction(2,0).
counter_direction(3,1).

approach_factor(4).//highest -> closer

//direction goes from East (directions[3])] to North (directions[0]) 
+current_direction_stc(CD) : CD > 3 
    <- -+ current_direction_stc(0).


//a movement is not taken into account when it fails
 +lastAction(move) : exploration_strategy(stc) &
                     lastActionResult(success)  & current_moving_step(C) & lastActionParams([D])
   <- -+direction(D,1); //for compatibility with agentGPS      
      -+current_moving_step(C+1).
       



field_center(C) :-  field_size(S) & C=S div 2. 
//adapt a coordinate A to to a new value B that fits with the field size
//adapt_coordinate(A,B) :- field_size(S) & field_center(C) & (A>=C) & B=A-S.
//adapt_coordinate(A,B) :- field_size(S) & field_center(C) & (A<C*-1) & B=A+S.
adapt_coordinate(A,B) :- B=A.


+myposition(X,Y): exploration_strategy(stc) & adapt_coordinate(X,XX) & adapt_coordinate(Y,YY) & (X\==XX | Y\==YY)  
   <- -+myposition(XX,YY).
   
//+myposition(X,Y) :  last_node(LX,LY) <- .print("... position (", X, ",", Y,") Last Node: (", LX, ",", LY,")").


//obstacle_direction(D) : check for obstacles in the direction D    
obstacle_direction(0) :- (obstacle(0,Y)|thing(0,Y,entity,A)) & Y<0 & vision(CZ) & Y>= CZ*-1. //north
obstacle_direction(2) :- (obstacle(0,Y)|thing(0,Y,entity,A)) & Y>0 & vision(CZ) & Y<= (CZ). //south
obstacle_direction(1) :- (obstacle(X,0)|thing(X,0,entity,A)) & X<0 & vision(CZ) & X>= CZ*-1. //east
obstacle_direction(3) :- (obstacle(X,0)|thing(X,0,entity,A)) & X>0 & vision(CZ) & X<= (CZ). //west



//free_direction(X,Y,D): check for a free path in the direction D (s.t. D={0,1,2,3} and 0=north, 1=west, 2=south, 3=east)
free_direction(X,Y,0) :- vision(CS)&
                         not(obstacle_direction(0))& //no obstacle ahead 
                         not(parent(_,_,2,X,Y))&     //do not back to the predecessor
                         not(last_node(X,Y-CS))&     //do not back to previous node
                         (not(parent(X,Y,0,_,_))|(X==0&Y-5==0))& //do not go to a visited successor node
                         not(parent(_,_,_,X,Y-CS))&
                         not(teammate_agent(0)). //there is not a teammate in the intended direction                                                 
free_direction(X,Y,1) :- vision(CS)&not(obstacle_direction(1))&not(parent(_,_,3,X,Y))&not(last_node(X-CS,Y))&(not(parent(X,Y,1,_,_))|(X-5==0&Y==0))&not(parent(_,_,_,X-CS,Y))&not(teammate_agent(1)). //west
free_direction(X,Y,2) :- vision(CS)&not(obstacle_direction(2))&not(parent(_,_,0,X,Y))&not(last_node(X,Y+CS))&(not(parent(X,Y,2,_,_))|(X==0&Y+5==0))&not(parent(_,_,_,X,Y+CS))&not(teammate_agent(2)). //south
free_direction(X,Y,3) :- vision(CS)&not(obstacle_direction(3))&not(parent(_,_,1,X,Y))&not(last_node(X+CS,Y))&(not(parent(X,Y,3,_,_))|(X+5==0&Y==0))&not(parent(_,_,_,X+CS,Y))&not(teammate_agent(3)). //east




//teammate_agent(D): there is an agent of the same team in the direction D (s.t. D={0,1,2,3} and 0=north, 1=west, 2=south, 3=east)
teammate_agent(0) :- approach_factor(A)&vision(CS)&team(T)&thing(_,W,entity,Team)&W<0&W>=(CS-A)*-1.
teammate_agent(1) :- approach_factor(A)&vision(CS)&team(T)&thing(W,_,entity,Team)&W<0&W>=(CS-A)*-1.
teammate_agent(2) :- approach_factor(A)&vision(CS)&team(T)&thing(_,W,entity,Team)&W>0&W<=(CS-A).
teammate_agent(3) :- approach_factor(A)&vision(CS)&team(T)&thing(W,_,entity,Team)&W>0&W<=(CS-A).

//next direction to go from the coordinates (X,Y)
next_direction(X,Y,ND) :- step(S) & S <= 5 & (free_direction(X,Y,ND)).
next_direction(X,Y,ND) :- step(S) & S > 5 & 
                          (D = math.floor(math.random(4)) & (free_direction(X,Y,D)) & D>=0 & D<=4 & ND=D) |
                          ((free_direction(X,Y,DD)) & ND=DD) .
next_direction(X,Y,-1) :- not(free_direction(X,Y,_)).                          


parent(X,Y,D,XX,YY) :- edge(X,Y,D,XX,YY,Map) & origin(O) & .substring(O,Map). //using substring as a workaround since Map is a string (e.g. "agenta0") while Me is a term (e.g. agentaO) 


ancestor(X,Y,XX,YY):- parent(X,Y,_,XX,YY).
ancestor(X,Y,XX,YY):- parent(X,Y,_,V,W)& ancestor(V,W,XX,YY).

cycle(X,Y,XX,YY) :- false.

+lastActionResult(failed_path) : exploration_strategy(stc) &
                                 lastAction(move) & lastActionParams([D]) & (failed_move_count(D,Count)|not(failed_move_count(D,Count))&Count=0)
   <- -+failed_move_count(D,Count+1).
+lastActionResult(success): exploration_strategy(stc) & failed_move_count(_,_) 
   <- .abolish(failed_move_count(_,_)).   



//At the beginning, there is not a free direction - do nothing
+!update_direction: exploration_strategy(stc) & 
                    myposition(0,0) & next_direction(X,Y,-1) & not(parent(_,_,_,_,_))
   <- -+current_moving_step(0).

//At the beginning, go to the first free direction
+!update_direction: exploration_strategy(stc) & 
                    myposition(0,0) & next_direction(X,Y,D) & not(parent(_,_,_,_,_))
   <- -+current_moving_step(0); 
      -+current_direction_stc(D).
   

//if the agent is out of the vision range, try to move to it (useful when an agent enters in the map).
//if the X axis is not in the vision range, try to left
+!update_direction: exploration_strategy(stc) &
                    myposition(X,Y) & 
                    current_moving_step(MS) & vision(CS) & 
                    MS>=CS & ((X mod CS)\==0) & //free_direction(X,Y,ND) & (ND==1|ND==3)                       
                    free_direction(X,Y,ND) & ND=1
                    & last_node(LX,LY) 
   <- //.print("01. Moved from (", LX, ",", LY, ") to (", X,",",Y,"). Next direction: ", ND);
      -+last_adapting_direction(ND);       
      -+current_direction_stc(ND).
            
+!update_direction: exploration_strategy(stc) &
                    myposition(X,Y) & 
                    current_moving_step(MS) & vision(CS) & 
                    MS>=CS & ((Y mod CS)\==0) //& free_direction(X,Y,ND) & (ND==0|ND==2)                       
                    & free_direction(X,Y,ND) & ND=0
                    & last_node(LX,LY)
   <- //.print("02. Moved from (", LX, ",", LY, ") to (", X,",",Y,"). Next direction: ", ND);      
      -+current_direction_stc(ND).
      
+!update_direction: exploration_strategy(stc) &
                    myposition(X,Y) & 
                    current_moving_step(MS) & vision(CS) & 
                    MS>=CS & ((X mod CS)\==0|(Y mod CS)\==0) //& free_direction(X,Y,ND) & (ND==0|ND==2)                       
                    & not((obstacle_direction(ND)))
                    & last_node(LX,LY)
   <- //.print("03. Moved from (", LX, ",", LY, ") to (", X,",",Y,"). Next direction: ", ND);      
      -+current_direction_stc(ND). 


//the agent has reached the next node and there is a free path from there in the direction (ND)     
+!update_direction: exploration_strategy(stc) &
                    myposition(X,Y) & 
                    current_direction_stc(CD) &
                    current_moving_step(MS) & vision(CS) & (MS >= CS & ((X mod CS)==0 & (Y mod CS)==0))  & //the agent has reached the border of the cell                     
                    next_direction(X,Y,ND) & ND>-1 & forward & //the agent has a free-obstacle direction ahead
                    last_node(LX,LY) 
   <- //.print("1. Moved from (", LX, ",", LY, ") to (", X,",",Y,"). Next direction: ", ND);      
      !do_set_edge(LX,LY,CD,X,Y);
      //!update_notorigin_teammates(LX,LY,CD,X,Y);  //update the spanning tree in the origin agent
      -+last_node(X,Y); //the current position becomes the last visited node            
      -+current_moving_step(0); 
      -+current_direction_stc(ND);
      .
   

//the agent has (i) reached the next cell and there is no place to go or (ii) is blocked: back to the predecessor node 
+!update_direction: myposition(X,Y) &
                    current_direction_stc(CD) & 
                    current_moving_step(MS) & vision(CS) & (MS >= CS & ((X mod CS)==0 & (Y mod CS)==0) & //the agent has reached the border of the cell 
                    next_direction(X,Y,ND)&ND==-1) &//| //there is not free-obstacle direction ahead
                    path_direction(PD)&directions(PD,DIRECTIONS) & 
                    counter_direction(CD,D) &
                    last_node(LX,LY) & 
                    (X\==LX | Y\==LY) //not arrived to the predecessor
   <- .nth(D,DIRECTIONS,Dir);  //check the counter-diretion     
      //.print("2. No direction from,  (",X,",",Y,"). Back to the predecessor (", LX,",",LY,"). Direction: ", D);
      !do_set_edge(LX,LY,CD,X,Y);
      !do_set_edge(X,Y,-1,X,Y);
      -forward;      
      -+current_moving_step(0);    
      -+current_direction_stc(D). 
      
      
//the agent has (i) reached the next cell and there is no place to go or (ii) is blocked: back to the predecessor node 
+!update_direction: exploration_strategy(stc) &
                    myposition(X,Y) &
                    current_direction_stc(CD) & 
                    lastActionResult(failed_path) & //the agent is blocked by an obstacle o                     
                    path_direction(PD)&directions(PD,DIRECTIONS) & 
                    counter_direction(CD,D) &
                    last_node(LX,LY) & 
                    (X\==LX | Y\==LY) //not arrived to the predecessor
   <- .nth(D,DIRECTIONS,Dir);  //check the counter-diretion     
      //.print("2b. No direction from,  (",X,",",Y,"). Back to the predecessor (", LX,",",LY,"). Direction: ", D);
      -forward;      
      -+current_moving_step(0);    
      -+current_direction_stc(D).       
  
//the agent has reached the predecessor node and goes to the next unvisited node
+!update_direction: exploration_strategy(stc) &
                    myposition(X,Y) & path_direction(PD) & directions(PD,DIRECTIONS) & //counter_directions(COUNTER_DIRECTIONS) &
                    last_node(LX,LY) &  X==LX & Y==LY & //the last visited node is the current node (i.e. the agent has reached the predecessor) 
                    next_direction(X,Y,ND)& ND>-1 //there is a free-obstacle direction ahead
   <- //.print("3. Arrived to the precedessor ( ",X,",",Y,"). Moving forward. Direction: ", ND);
      -+last_node(X,Y); //the current position becomes the last visited node
      +forward;            
      -+current_moving_step(0);
      -+current_direction_stc(ND).
    
//arrived to the previous node and there is not another unvisited node
+!update_direction: exploration_strategy(stc) &
                    myposition(X,Y) & path_direction(PathDir) & directions(PathDir,DIRECTIONS) & //counter_directions(COUNTER_DIRECTIONS) &
                    last_node(LX,LY) & X==LX & Y==LY & //the last visited node is the current node (i.e. the agent has reached the predecessor) 
                    parent(PX,PY,PD,X,Y) & counter_direction(PD,ND) //nowhere to go - back to the predecessor
   <- //.print("4. Arrived to the predecessor (",X,",",Y,"). Nowhere to go. Back to predecessor (",PX,",",PY,"). Direction: ", ND );
      -+last_node(PX,PY); //the current position becomes the last visited node        
      -+current_moving_step(0);
      -+current_direction_stc(ND).      
 
 
 
 
 
+!update_direction: exploration_strategy(stc).  
 

+!do_set_edge(LX,LY,CD,X,Y): (cycle(LX,LY,X,Y)).      
       
+!do_set_edge(LX,LY,CD,X,Y):  origin(OL) & not(parent(X,Y,_,LX,LY)) & vision(V) &  (LX mod V==0) & (LY mod V==0) & (X mod V==0) & (Y mod V==0) & LX\==-1 & LY\==-1 & not(cycle(LX,LY,X,Y))  
   <- setEdge(LX,LY,CD,X,Y,OL).  
     
+!do_set_edge(LX,LY,CD,X,Y).

