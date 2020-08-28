/**
 * Test goals for agent Weak Individualist
 */

{ include("agentWeakIndividualist.asl") }
{ include("$jasonJar/test/jason/inc/tester_agent.asl") }

!execute_test_plans.

/*
 * Test if the agent got the right rotation
 */
@testSetRightPosition[atomic,test]
+!testSetRightPosition
    <-
    /**
     * Add mock plan for !do(rotate(D)) since it needs external library
     */
    .add_plan({ +!do(rotate(D),success) :
        attached(I,J) & rotate(D,I,J,II,JJ)
        <-
        -+attached(II,JJ);
    }, self, begin);

    /**
     * Perform tests
     */
    +attached(0,1); // I have a block at 6 o'clock
    !setRightPosition(req(0,1,tstB));  // The block must be at 6 o'clock
    !assert_true(attached(0,1));
    !setRightPosition(req(-1,0,tstB)); // The block must be at 9 o'clock
    !assert_true(attached(-1,0));
    !setRightPosition(req(1,0,tstB));  // The block must be at 3 o'clock
    !assert_true(attached(1,0));
    !setRightPosition(req(0,-1,tstB)); // The block must be at 12 o'clock
    .log(warning,"TODO: Fix testSetRightPosition");
    //!assert_true(attached(0,-1));
.

/**
 * Test got new task
 */
 //@testGotNewTask[test]
 +!testGotNewTask
    <-
    .log(warning,"TODO: Fix testGotNewTask");

    .abolish(accepted(_));
    .abolish(myposition(_,_));
    .abolish(attached(_,_));
    .abolish(gps_map(_,_,_,_));
    .abolish(task(_,_,_,_));
    .abolish(thing(_,_,_,_));
    +step(450);             // Give enough steps in order to be feasible in the deadline
    -+myposition(0,0);
    +gps_map(10,10,taskboard,_);            // I know a taskboard position
    +gps_map(15,15,b2,_);
    +gps_map(20,20,goal,_);                 // I know a goal area position
    +goal(0,0);                         // To submit a task it has to be on a goal area

    /**
     * Mock plan to goto since it uses external lib
     */
    .add_plan({ +!goto(X,Y) : step(S)
        <-
        -+step(S+1);
        -+myposition(X,Y);
        if (not thing(1,0,taskboard,_)) {
            +thing(1,0,taskboard,_);    // this on the first call of goto
        } if (not thing(1,0,dispenser,b2)) {
            +thing(1,0,dispenser,b2);   // only do this on the second call of goto
        }
    }, self, begin);

    /**
     * Add mock plan for !do(A) since it needs external library
     */
    .add_plan({ +!do(A,success) <- .print("mock ",A) }, self, begin);
    .add_plan({ +!do(attach(D),success) : directionIncrement(D,I,J) <-
        .print("mock ",attach(B));
        +attached(I,J);
    }, self, begin);

    /**
     * Add mock plan for !do(rotate(D)) since it needs external library
     */
    .add_plan({ +!do(rotate(D),success) :
        attached(I,J) & rotate(D,I,J,II,JJ)
        <-
        .print("mock ",rotate(D));
        -+attached(II,JJ);
    }, self, begin);

    +task(task22,503,1,[req(0,1,b2)]);
.
