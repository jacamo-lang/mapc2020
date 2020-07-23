/**
 * Test goals for agent Weak Individualist
 */

{ include("agentWeakIndividualist.asl") }
{ include("tester_agent.asl") }

!execute_test_plans.

/**
 * Test rule that gives euclidean distance between two points
 */
@[atomic,test]
+!testDistance :
    distance(0,0,3,3,D0) &
    distance(-30,-20,4,4,D1) &
    distance(-0,10,-9,8.9,D2) &
    distance(0.7,-17,4,-19,D3)
    <-
    !assert_equals(D0,6);
    !assert_equals(D1,58);
    !assert_equals(D2,10.1);
    !assert_equals(D3,5.3);
.

/**
 * Considering the goal area has 13 units as a diamond
 * The agent may consider it as a cross with 5 units
 * When the agent knows two edges of the goal area
 * it can tell where is the center
 */
@[atomic,test]
+!testGoalCenter :
    true
    <-
    .abolish(map(_,_,_,_));
    .abolish(goalCenter(_,_));
    +map(0,19,-4,goal)[source(self)];
    +map(0,20,-5,goal)[source(self)];
    +map(0,20,-4,goal)[source(self)];
    +map(0,20,-3,goal)[source(self)];
    +map(0,21,-6,goal)[source(self)];
    +map(0,21,-5,goal)[source(self)];
    +map(0,21,-4,goal)[source(self)];
    +map(0,21,-3,goal)[source(self)];
    +map(0,21,-2,goal)[source(self)];
    +map(0,22,-5,goal)[source(self)];
    +map(0,22,-4,goal)[source(self)];
    +map(0,22,-3,goal)[source(self)];
    +map(0,23,-4,goal)[source(self)];
    ?map(_,X,Y,goalCenter);
    !assert_equals(X,21);
    !assert_equals(Y,-4);
.

/**
 * Test nearest rule which uses myposition and map(_X,Y,thing)
 * to return the nearest thing regarding the reference (myposition)
 */
@[atomic,test]
+!testNearest :
    true
    <-
    .abolish(map(_,_,_,_));
    .abolish(myposition(_,_));
    +map(0,5,5,goal)[source(self)];
    +map(0,-5,-5,goal)[source(self)];
    +map(0,-5,-4,goal)[source(self)];
    +map(0,4,2,goal)[source(self)];
    +myposition(0,0);
    ?nearest(goal,X,Y);
    !assert_equals(4,X);
    !assert_equals(2,Y);
.

/*
 * Nearest neighbour is the nearest adjacent position
 * of a given point (X,Y) in relation to myposition(X,Y)
 */
@[atomic,test]
+!testNearestNeighbour :
    true
    <-
    .abolish(myposition(_,_));
    +myposition(12,12);
    ?nearest_neighbour(10,10,X,Y);
    !assert_equals(10,X);
    !assert_equals(11,Y);
.

/*
 * Test get block which request/attach a block
 * It is actually returning error since the simulator is not on
 */
@[atomic,test]
+!testAddGoalCenterBB :
    true
    <-
    .abolish(map(_,_,_,_));
    !assert_false(map(_,_,_,goalCenter));
    +map(ag,10,12,goalCenter);
    !assert_true(map(_,_,_,goalCenter));
.

/*
 * Test if the agent got the right rotation
 */
@[atomic,test]
+!testSetRightPosition :
    true
    <-
    /**
     * Add mock plan for !do(rotate()) since it needs external library
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
    !assert_true(attached(0,-1));
.

/**
 * Test got new task
 */
 @[test]
 +!testGotNewTask :
    true
    <-
    .abolish(accepted(_));
    .abolish(myposition(_,_));
    .abolish(map(_,_,_,_));
    .abolish(task(_,_,_,_));
    +step(450);
    -+myposition(0,0);
    +map(_,10,10,taskboard);            // I know a taskboard position
    +map(_,15,15,b2);
    +map(_,20,20,goal);                 // I know a goal area position
    +goal(0,0);                         // To submit a task it has to be on a goal area

    /**
     * Mock plan to goto since it uses external lib
     */
    .add_plan({ +!goto(X,Y)
        <-
        -+myposition(X,Y);
    }, self, begin);

    /**
     * Add mock plan for !do(submit()) since it needs external library
     */
    .add_plan({ +!do(submit(T),success) <- .print("mock submit") }, self, begin);

    +task(task22,503,1,[req(0,1,b2)]);
.

/**
 * Test got new task
 */
 @[atomic,test]
 +!test_task_shortest_path :
    true
    <-
    .abolish(myposition(_,_));
    .abolish(map(_,_,_,_));
    +myposition(0,0);
    +map(_,0,5,taskboard);
    +map(_,0,-10,tstB);
    +map(_,0,10,goal);
    ?task_shortest_path(tstB,D);
    !assert_equals(D,40);
.

/**
 * Test if statement with equals and unification
 */
 @[atomic,test]
 +!test_if_equals_and_unify :
    true
    <-
    R=success;

    // Try equals
    if (R == success) {
        !force_pass;
    } else {
        !force_failure;
    }
    if (R == something_else) {
        !force_failure;
    } else {
        !force_pass;
    }

    // Try unification
    if (R = success) {
        !force_pass;
    } else {
        !force_failure;
    }
    if (R = something_else) {
        !force_failure;
    } else {
        !force_pass;
    }
.
