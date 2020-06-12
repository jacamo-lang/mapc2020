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

!start.

/* Plans */

+!start : 
    true 
    <-  
        //ao criar uma nova intention lembrar 
        //de adicionar as anotações 
        //critical_section -> rotulo da secao critica
        //priority(2) -> prioridade quanto maior mais prioritario
        !!intention(1)[critical_section(1), priority(2)];
        !!intention(2)[critical_section(1), priority(10)];
        !!intention(3)[critical_section(2), priority(5)];
        !!intention(4)[critical_section(2), priority(2)];
    .

+!intention(X)[critical_section(CS), priority(P)] :
    true 
    <- 
        .wait (1000);
        .print(task(X)[critical_section(CS), priority(P)]);
    .

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
    STATE=started | STATE=finished  
    <- 
        .print("-->",X[state(STATE)]);
        !!taskmanager;
    .

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
