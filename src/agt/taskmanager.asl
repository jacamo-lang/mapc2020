// Agent sample_agent in project gerenciadordetarefa

/* Initial beliefs and rules */
splitbycs([X[critical_section(CS), priority(P)]|T],RETURN):-
	splitbycs(T,R) &
	classifyintention(X[critical_section(CS), priority(P)],R,RETURN).

splitbycs([X[critical_section(CS), priority(P)]|[]],RETURN):-
	classifyintention(X[critical_section(CS), priority(P)],[],RETURN).

splitbycs([],[]).

classifyintention(X[critical_section(CS), priority(P)],[],RETURN):-
				RETURN=[[X[critical_section(CS), priority(P)]]].
				
classifyintention(X[critical_section(CS), priority(P)],
				  [[Y[critical_section(CS), priority(P1)]|INTENTIONS]|T],
				  [[X[critical_section(CS), priority(P)],
				  	Y[critical_section(CS), priority(P1)]|INTENTIONS]|T]).

classifyintention(X[critical_section(CS), priority(P)],
				  [[Y[critical_section(TCS), priority(P1)]|INTENTIONS]|T],
				  [[Y[critical_section(TCS), priority(P1)]|INTENTIONS]|R]):-
				CS\==TCS &			
				classifyintention(X[critical_section(CS), priority(P)],T,R).

highpriority(INTENTIONS,INTENTION[critical_section(CS), priority(P)]):-
			.member(INTENTION[priority(P)],INTENTIONS) &
			not (.member(IT[priority(PIT)],INTENTIONS) & PIT>P).	

/* Initial goals */


/* Plans */

+!taskmanager:
	true
	<-
		.findall(I[critical_section(CS), priority(P)],
				 .intend(I[critical_section(CS), priority(P)]),
				 INTENTIONS);
		for ( .member(INTENTION,INTENTIONS) ) {			
			.suspend(INTENTION);
		}				 	 
		?splitbycs(INTENTIONS, INTENTIONSBYCS);
		for ( .member(INTENTIONSCS,INTENTIONSBYCS) ) {
        	?highpriority(INTENTIONSCS,INTENTION);
			.resume(INTENTION);
    	}
	.

^!X[critical_section(_), priority(_),state(STATE)]: 
	STATE=pending | STATE=finished  
	<- 
		!!taskmanager;
    .
