/**
 * Simulate MAPC scenario
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("test_walking.bb") }
{ include("test_walking_helpers.asl") }
{ include("walking/goto_A_star.asl") }

@test_goto_A_star[test]
+!test_goto_A_star :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    makeArtifact("rp", "localPositionSystem.rp.rp", [70,0], RpId);
    focus(RpId);
    for ( gps_map(I,J,O,MapId) ) {
        setGpsMapForTests(I,J,O,MapId)[artifact_id(RpId)];
    }

    !add_test_plans_do(MIN_I);

    !build_map(MIN_I);

    !test_goto_surrounding_objects(MIN_I);
    !test_goto_nearest_objects(MIN_I);
    !test_goto_far_position(MIN_I);
    !test_goto_obstacle(MIN_I);
    !test_goto_nearest_blocked_neighbour(MIN_I);
    !test_goto_nearest_objects_loaded(MIN_I);
.

/*
 * Test goto(X,Y)
 * Expected result:
 [test_goto]                   2            gg@gg1                                                     -4
 [test_goto]                                 g^g                                  ##                   -3
 [test_goto]                                  ^          #                    ##                       -2
 [test_goto]                                  ^         ##                  #       #                  -1
 [test_goto]             >>>v        ##       ^          #                       #                     0
 [test_goto]                v  ##  #####      ^                                 ###  #   #  #          1
 [test_goto]                >v##########  ##  ^                               #####                    2
 [test_goto]                 v#####  #### #   ^                #            ######                     3
 [test_goto]            ###  >v####  ####     ^     # 2            0         ###                       4
 [test_goto]           #####  v      ######   ^#      #                      ### #   #                 5
 [test_goto]          ######  v   #   #### ## @<<<<< ###t  #     #           ##                        6
 [test_goto]          ######  >>v# # #####       ##^## #                                  #            7
 [test_goto]            ###     >v# ### ## #  #  ##^#           #                                      8
 [test_goto]                     >>>v#####     ####^         #t                    #                   9
 [test_goto]                        >v#   ## ######^          #                                        10
 [test_goto]                         >>>>>>v#   ##>^                  #       ###                      11
 [test_goto]                               >v##>>>^                           ##                       12
 [test_goto]                                @>>^                 0        1     #    #                 13
*/
+!test_goto_surrounding_objects(MIN_I)
    <-
    // Test a simple path in which the euclidean distance can be achieved just avoiding obstacles
    !check_performance(test_goto(0,0,19,13,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(32,R0_1);
    !assert_equals(32,R1_1);

    // Test a path in which there the euclidean distance cannot be achieved
    !check_performance(test_goto(20,13,21,6,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(8,R0_2);
    !assert_equals(18,R1_2);

    // Test a straight line path occupying a goal terrain
    !check_performance(test_goto(21,5,21,-4,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(9,R0_3);
    !assert_equals(9,R1_3);

    //!print_map;
.

/*
 * Test goto(X,Y)
 * Expected result:
 [test_goto] #                    @>>>>>>>>>>>>>v                    1g            #                   -6
 [test_goto]                      ^          gggv                                                      -5
 [test_goto]                   >>>^         gggg@>>v                                                   -4
 [test_goto]               >>>>^             ggg   v                              ##                   -3
 [test_goto]               ^                  @    v     #                    ##                       -2
 [test_goto]               ^                  ^    v    ##                  #       #                  -1
 [test_goto]             >>^         ##       ^<<< >>v   #                       #                     0
 [test_goto]                   ##  #####         ^   v                          ###  #   #  #          1
 [test_goto]                  ##########  ##     ^<< v                        #####                    2
 [test_goto]                  #####  #### #        ^<<         #            ######                     3
 [test_goto]            ###    ####  ####           #^<            0         ###                       4
*/
+!test_goto_nearest_objects(MIN_I)
    <-
    // Go from 0,0 to 20,12: min_distance = 32 steps
    //!build_map(MIN_I);

    ?nearest(taskboard,X1,Y1);
    ?nearest_neighbour(X1,Y1,X_1,Y_1);
    !check_performance(test_goto(0,0,X_1,Y_1,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(15,R0_1);
    !assert_equals(15,R1_1);

    ?nearest(b1,X2,Y2);
    ?nearest_neighbour(X2,Y2,X_2,Y_2);
    !check_performance(test_goto(X_1+1,Y_1,X_2,Y_2,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(13,R0_2);
    !assert_equals(13,R1_2);

    ?nearest(b2,X3,Y3);
    ?nearest_neighbour(X3,Y3,X_3,Y_3);
    !check_performance(test_goto(X_2+1,Y_2,X_3,Y_3,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(12,R0_3);
    !assert_equals(12,R1_3);

    ?nearest(goal,X_4,Y_4);
    !check_performance(test_goto(X_3+1,Y_3,X_4,Y_4,MIN_I,R0_4,R1_4,_),1,_);
    !assert_equals(14,R0_4);
    !assert_equals(14,R1_4);

    //!print_map;
.

/*
* Test goto(X,Y)
* Expected result:
 [test_goto]           ##          0                      2          # ##@>v                 ##        -32
 [test_goto]                                                          ####^>>v   #                     -31
 [test_goto]                   1                                     #####^< v                       1 -30
 [test_goto]         2                                                 ##  ^ >>v           2           -29
 [test_goto]                   #             g                           ##^   v                     # -28
 [test_goto]                                ggg                          >>^   v                       -27
 [test_goto]                               ggggg                         ^     >v                      -26
 [test_goto]                                ggg       ######          >>>^      v                      -25
 [test_goto]       # #                       g        ######      >>>>^#        v        # #           -24
 [test_goto]           #                               #####    >>^          #  v            #         -23
 [test_goto]           #                                     >>>^   #           v  #         #         -22
 [test_goto]                                                 ^                  v                      -21
 [test_goto]    #      #                              >>>>>>>^                  v     #      #         -20
 [test_goto]       ##                                 ^                         v        ##            -19
 [test_goto]      ####  #                         >>>>^                         v    #  ####           -18
 [test_goto]      ####                            ^                             v       ####           -17
 [test_goto]       ##        ##             >>>>>>^                             v     #  ##            -16
 [test_goto]                ####0          >^                                   v                      -15
 [test_goto]                ####           ^                                    v                      -14
 [test_goto]                 ##        >>>>^                                    v                      -13
 [test_goto]                           ^                                        v                      -12
 [test_goto]                    2      ^                                        v                      -11
 [test_goto]                           ^                              g         v #                    -10
 [test_goto]                           ^                             ggg        v                      -9
 [test_goto]                           ^                            ggggg  1    v                      -8
 [test_goto]                   #       ^                             ggg        v                      -7
 [test_goto] #                     t   ^      g                      1g         v  #                   -6
 [test_goto]                           ^     ggg                                v                      -5
 [test_goto]                   2       ^    ggggg1                              v                      -4
 [test_goto]                           ^     ggg                                >v##                   -3
 [test_goto]                           ^      g          #                    ## >>v                   -2
 [test_goto]                     >>>>>>^                ##                  #      v#                  -1
 [test_goto]             >>>>>>>>^   ##                  #                       # v                   0
 [test_goto]                   ##  #####                                        ###v #   #  #          1
 [test_goto]                  ##########  ##                                  #####v                   2
 [test_goto]                  #####  #### #                    #            ###### v                   3
 [test_goto]            ###    ####  ####           # 2            0         ###   v                   4
 [test_goto]           #####     >>>v######    #      #                      ### # >v#                 5
 [test_goto]          ######    >^# >@#### ##        ###t  #     #           ##     v                  6
 [test_goto]          ######    ^# # #####       ## ## #                            v     #            7
 [test_goto]            ###     ^<# ### ## #  #  ## #           #                   v                  8
 [test_goto]                     ^<<<#####     ####          #t                    #v                  9
 [test_goto]                        ^<#   ## ######           #                     v                  10
 [test_goto]                         ^      #   ##                    #       ###   v                  11
 [test_goto]                         ^       ##                               ##    v                  12
 [test_goto]                         ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<1     #   v#                 13
 [test_goto]                                                           ##^<   ##    >v                 14
 [test_goto]                                                    #     ####^<<<<<<<<<<@                 15
*/
+!test_goto_far_position(MIN_I)
    <-
    // Test a simple path in which the euclidean distance can be achieved just avoiding obstacles
    !check_performance(test_goto(0,0,48,-32,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(80,R0_1);
    !assert_equals(84,R1_1);

    !check_performance(test_goto(49,-32,60,15,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(58,R0_2);
    !assert_equals(58,R1_2);

    !check_performance(test_goto(59,15,12,6,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(56,R0_3);
    !assert_equals(68,R1_3);

    //!print_map;
.

+!test_goto_obstacle(MIN_I)
    <-
    !build_map(MIN_I);

    // Going to a X,Y which is an obstacle should return no_route
    !check_performance(test_goto(0,0,10,1,MIN_I,R0_1,R1_1,R2_1),1,_);
    !assert_equals(no_route,R2_1);

    // Coming from an obstacle in the middle of other obstacles should return no_route
    !check_performance(test_goto(6,2,1,2,MIN_I,R0_2,R1_2,R2_2),1,_);
    !assert_equals(no_route,R2_2);

    // Coming from an obstacle in to a valid X,Y should return some route
    !check_performance(test_goto(1,4,1,9,MIN_I,R0_3,R1_3,R2_3),1,_);
    !assert_equals(5,R0_3);
    !assert_equals(9,R1_3);

    // Going to a valid X,Y with obstacles all around should return no_route
    !check_performance(test_goto(1,11,9,7,MIN_I,R0_4,R1_4,R2_4),1,_);
    !assert_equals(no_route,R2_4);

    //!print_map;
.

+!test_goto_nearest_objects_loaded(MIN_I)
    <-
    //!build_map(MIN_I);

    +attached(0,1);
    
    -+myposition(53,-25);
    ?nearest(goal,X_1,Y_1);
    !check_performance(test_goto(53,-25,X_1,Y_1,MIN_I,R0_1,R1_1,_),1,_);
    !assert_equals(23,R0_1);
    !assert_equals(23,R1_1);

    ?nearest(b2,X2,Y2);
    ?nearest_neighbour(X2,Y2,X_2,Y_2);
    !check_performance(test_goto(X_1,Y_1,X_2,Y_2,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(29,R0_2);
    !assert_equals(29,R1_2);

    ?nearest(b1,X3,Y3);
    ?nearest_neighbour(X3,Y3,X_3,Y_3);
    !check_performance(test_goto(X_2,Y_2,X_3,Y_3,MIN_I,R0_3,R1_3,_),1,_);
    !assert_equals(11,R0_3);
    !assert_equals(11,R1_3);

    //!print_map;
.

+!test_goto_nearest_blocked_neighbour(MIN_I)
    <-
    ?nearest(b0,X2,Y2);
    ?nearest_neighbour(X2,Y2,X_2,Y_2);
    !check_performance(test_goto(0,-15,X_2,Y_2,MIN_I,R0_2,R1_2,_),1,_);
    !assert_equals(8,R0_2);
    !assert_equals(12,R1_2);
    .log(warning,"TODO: Replace heuristic on nearest_neighbour/4 from euclidean distance to A* solution - see common_walking.asl");

    //!print_map;
.
