/**
 * Simulate MAPC scenario
 */

{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("walking/goto_A_star.asl") }

step(500).
gps_map(-12,-6,obstacle,"agenta0").
gps_map(-9,-20,obstacle,"agenta0").
gps_map(-7,-18,obstacle,"agenta0").
gps_map(-7,-17,obstacle,"agenta0").
gps_map(-6,-24,obstacle,"agenta0").
gps_map(-6,-19,obstacle,"agenta0").
gps_map(-6,-18,obstacle,"agenta0").
gps_map(-6,-17,obstacle,"agenta0").
gps_map(-6,-16,obstacle,"agenta0").
gps_map(-5,-19,obstacle,"agenta0").
gps_map(-5,-18,obstacle,"agenta0").
gps_map(-5,-17,obstacle,"agenta0").
gps_map(-5,-16,obstacle,"agenta0").
gps_map(-4,-29,b2,"agenta0").
gps_map(-4,-24,obstacle,"agenta0").
gps_map(-4,-18,obstacle,"agenta0").
gps_map(-4,-17,obstacle,"agenta0").
gps_map(-3,6,obstacle,"agenta0").
gps_map(-3,7,obstacle,"agenta0").
gps_map(-2,-32,obstacle,"agenta0").
gps_map(-2,-23,obstacle,"agenta0").
gps_map(-2,-22,obstacle,"agenta0").
gps_map(-2,-20,obstacle,"agenta0").
gps_map(-2,5,obstacle,"agenta0").
gps_map(-2,6,obstacle,"agenta0").
gps_map(-2,7,obstacle,"agenta0").
gps_map(-1,-32,obstacle,"agenta0").
gps_map(-1,-18,obstacle,"agenta0").
gps_map(-1,4,obstacle,"agenta0").
gps_map(-1,5,obstacle,"agenta0").
gps_map(-1,6,obstacle,"agenta0").
gps_map(-1,7,obstacle,"agenta0").
gps_map(-1,8,obstacle,"agenta0").
gps_map(0,4,obstacle,"agenta0").
gps_map(0,5,obstacle,"agenta0").
gps_map(0,6,obstacle,"agenta0").
gps_map(0,7,obstacle,"agenta0").
gps_map(0,8,obstacle,"agenta0").
gps_map(1,4,obstacle,"agenta0").
gps_map(1,5,obstacle,"agenta0").
gps_map(1,6,obstacle,"agenta0").
gps_map(1,7,obstacle,"agenta0").
gps_map(1,8,obstacle,"agenta0").
gps_map(2,5,obstacle,"agenta0").
gps_map(2,6,obstacle,"agenta0").
gps_map(2,7,obstacle,"agenta0").
gps_map(3,-15,obstacle,"agenta0").
gps_map(3,-14,obstacle,"agenta0").
gps_map(4,-16,obstacle,"agenta0").
gps_map(4,-15,obstacle,"agenta0").
gps_map(4,-14,obstacle,"agenta0").
gps_map(4,-13,obstacle,"agenta0").
gps_map(5,-16,obstacle,"agenta0").
gps_map(5,-15,obstacle,"agenta0").
gps_map(5,-14,obstacle,"agenta0").
gps_map(5,-13,obstacle,"agenta0").
gps_map(5,2,obstacle,"agenta0").
gps_map(5,3,obstacle,"agenta0").
gps_map(6,-30,b1,"agenta0").
gps_map(6,-28,obstacle,"agenta0").
gps_map(6,-15,obstacle,"agenta0").
gps_map(6,-14,obstacle,"agenta0").
gps_map(6,-7,obstacle,"agenta0").
gps_map(6,-4,b2,"agenta0").
gps_map(6,1,obstacle,"agenta0").
gps_map(6,2,obstacle,"agenta0").
gps_map(6,3,obstacle,"agenta0").
gps_map(6,4,obstacle,"agenta0").
gps_map(7,-15,b0,"agenta0").
gps_map(7,-11,b2,"agenta0").
gps_map(7,1,obstacle,"agenta0").
gps_map(7,2,obstacle,"agenta0").
gps_map(7,3,obstacle,"agenta0").
gps_map(7,4,obstacle,"agenta0").
gps_map(8,2,obstacle,"agenta0").
gps_map(8,3,obstacle,"agenta0").
gps_map(8,4,obstacle,"agenta0").
gps_map(8,7,obstacle,"agenta0").
gps_map(9,2,obstacle,"agenta0").
gps_map(9,3,obstacle,"agenta0").
gps_map(9,4,obstacle,"agenta0").
gps_map(9,6,obstacle,"agenta0").
gps_map(9,8,obstacle,"agenta0").
gps_map(10,-32,b0,"agenta0").
gps_map(10,-6,taskboard,"agenta0").
gps_map(10,1,obstacle,"agenta0").
gps_map(10,2,obstacle,"agenta0").
gps_map(10,7,obstacle,"agenta0").
gps_map(11,1,obstacle,"agenta0").
gps_map(11,2,obstacle,"agenta0").
gps_map(11,8,obstacle,"agenta0").
gps_map(12,0,obstacle,"agenta0").
gps_map(12,1,obstacle,"agenta0").
gps_map(12,2,obstacle,"agenta0").
gps_map(12,3,obstacle,"agenta0").
gps_map(12,4,obstacle,"agenta0").
gps_map(12,5,obstacle,"agenta0").
gps_map(12,7,obstacle,"agenta0").
gps_map(12,8,obstacle,"agenta0").
gps_map(12,9,obstacle,"agenta0").
gps_map(13,0,obstacle,"agenta0").
gps_map(13,1,obstacle,"agenta0").
gps_map(13,2,obstacle,"agenta0").
gps_map(13,3,obstacle,"agenta0").
gps_map(13,4,obstacle,"agenta0").
gps_map(13,5,obstacle,"agenta0").
gps_map(13,6,obstacle,"agenta0").
gps_map(13,7,obstacle,"agenta0").
gps_map(13,8,obstacle,"agenta0").
gps_map(13,9,obstacle,"agenta0").
gps_map(13,10,obstacle,"agenta0").
gps_map(14,1,obstacle,"agenta0").
gps_map(14,2,obstacle,"agenta0").
gps_map(14,3,obstacle,"agenta0").
gps_map(14,4,obstacle,"agenta0").
gps_map(14,5,obstacle,"agenta0").
gps_map(14,6,obstacle,"agenta0").
gps_map(14,7,obstacle,"agenta0").
gps_map(14,9,obstacle,"agenta0").
gps_map(15,3,obstacle,"agenta0").
gps_map(15,4,obstacle,"agenta0").
gps_map(15,5,obstacle,"agenta0").
gps_map(15,6,obstacle,"agenta0").
gps_map(15,7,obstacle,"agenta0").
gps_map(15,8,obstacle,"agenta0").
gps_map(15,9,obstacle,"agenta0").
gps_map(16,5,obstacle,"agenta0").
gps_map(16,6,obstacle,"agenta0").
gps_map(16,7,obstacle,"agenta0").
gps_map(16,8,obstacle,"agenta0").
gps_map(16,9,obstacle,"agenta0").
gps_map(17,2,obstacle,"agenta0").
gps_map(17,3,obstacle,"agenta0").
gps_map(17,5,obstacle,"agenta0").
gps_map(17,10,obstacle,"agenta0").
gps_map(18,-26,goal,"agenta0").
gps_map(18,2,obstacle,"agenta0").
gps_map(18,6,obstacle,"agenta0").
gps_map(18,8,obstacle,"agenta0").
gps_map(18,10,obstacle,"agenta0").
gps_map(19,-27,goal,"agenta0").
gps_map(19,-26,goal,"agenta0").
gps_map(19,-25,goal,"agenta0").
gps_map(19,-4,goal,"agenta0").
gps_map(19,6,obstacle,"agenta0").
gps_map(19,11,obstacle,"agenta0").
gps_map(20,-28,goal,"agenta0").
gps_map(20,-27,goal,"agenta0").
gps_map(20,-26,goal,"agenta0").
gps_map(20,-25,goal,"agenta0").
gps_map(20,-24,goal,"agenta0").
gps_map(20,-5,goal,"agenta0").
gps_map(20,-4,goal,"agenta0").
gps_map(20,-3,goal,"agenta0").
gps_map(20,10,obstacle,"agenta0").
gps_map(20,12,obstacle,"agenta0").
gps_map(21,-27,goal,"agenta0").
gps_map(21,-26,goal,"agenta0").
gps_map(21,-25,goal,"agenta0").
gps_map(21,-6,goal,"agenta0").
gps_map(21,-5,goal,"agenta0").
gps_map(21,-4,goal,"agenta0").
gps_map(21,-3,goal,"agenta0").
gps_map(21,-2,goal,"agenta0").
gps_map(21,8,obstacle,"agenta0").
gps_map(21,10,obstacle,"agenta0").
gps_map(21,12,obstacle,"agenta0").
gps_map(22,-26,goal,"agenta0").
gps_map(22,-5,goal,"agenta0").
gps_map(22,-4,goal,"agenta0").
gps_map(22,-3,goal,"agenta0").
gps_map(22,5,obstacle,"agenta0").
gps_map(22,9,obstacle,"agenta0").
gps_map(22,10,obstacle,"agenta0").
gps_map(23,-4,goal,"agenta0").
gps_map(23,9,obstacle,"agenta0").
gps_map(23,10,obstacle,"agenta0").
gps_map(23,11,obstacle,"agenta0").
gps_map(24,-4,b1,"agenta0").
gps_map(24,7,obstacle,"agenta0").
gps_map(24,8,obstacle,"agenta0").
gps_map(24,9,obstacle,"agenta0").
gps_map(24,10,obstacle,"agenta0").
gps_map(24,11,obstacle,"agenta0").
gps_map(25,7,obstacle,"agenta0").
gps_map(25,8,obstacle,"agenta0").
gps_map(25,9,obstacle,"agenta0").
gps_map(25,10,obstacle,"agenta0").
gps_map(27,4,obstacle,"agenta0").
gps_map(27,7,obstacle,"agenta0").
gps_map(27,8,obstacle,"agenta0").
gps_map(28,6,obstacle,"agenta0").
gps_map(28,7,obstacle,"agenta0").
gps_map(29,-25,obstacle,"agenta0").
gps_map(29,-24,obstacle,"agenta0").
gps_map(29,4,b2,"agenta0").
gps_map(29,5,obstacle,"agenta0").
gps_map(29,6,obstacle,"agenta0").
gps_map(30,-25,obstacle,"agenta0").
gps_map(30,-24,obstacle,"agenta0").
gps_map(30,-23,obstacle,"agenta0").
gps_map(30,6,obstacle,"agenta0").
gps_map(30,7,obstacle,"agenta0").
gps_map(31,-25,obstacle,"agenta0").
gps_map(31,-24,obstacle,"agenta0").
gps_map(31,-23,obstacle,"agenta0").
gps_map(31,-1,obstacle,"agenta0").
gps_map(31,6,taskboard,"agenta0").
gps_map(32,-25,obstacle,"agenta0").
gps_map(32,-24,obstacle,"agenta0").
gps_map(32,-23,obstacle,"agenta0").
gps_map(32,-2,obstacle,"agenta0").
gps_map(32,-1,obstacle,"agenta0").
gps_map(32,0,obstacle,"agenta0").
gps_map(33,-32,b2,"agenta0").
gps_map(33,-25,obstacle,"agenta0").
gps_map(33,-24,obstacle,"agenta0").
gps_map(33,-23,obstacle,"agenta0").
gps_map(34,-25,obstacle,"agenta0").
gps_map(34,-24,obstacle,"agenta0").
gps_map(34,-23,obstacle,"agenta0").
gps_map(34,6,obstacle,"agenta0").
gps_map(36,9,obstacle,"agenta0").
gps_map(37,9,taskboard,"agenta0").
gps_map(37,10,obstacle,"agenta0").
gps_map(38,3,obstacle,"agenta0").
gps_map(39,8,obstacle,"agenta0").
gps_map(39,15,obstacle,"agenta0").
gps_map(40,6,obstacle,"agenta0").
gps_map(40,13,b0,"agenta0").
gps_map(42,4,b0,"agenta0").
gps_map(43,-22,obstacle,"agenta0").
gps_map(43,-8,goal,"agenta0").
gps_map(44,-32,obstacle,"agenta0").
gps_map(44,-30,obstacle,"agenta0").
gps_map(44,-9,goal,"agenta0").
gps_map(44,-8,goal,"agenta0").
gps_map(44,-7,goal,"agenta0").
gps_map(44,-6,b1,"agenta0").
gps_map(45,-33,b1,"agenta0").
gps_map(45,-31,obstacle,"agenta0").
gps_map(45,-30,obstacle,"agenta0").
gps_map(45,-10,goal,"agenta0").
gps_map(45,-9,goal,"agenta0").
gps_map(45,-8,goal,"agenta0").
gps_map(45,-7,goal,"agenta0").
gps_map(45,-6,goal,"agenta0").
gps_map(45,11,obstacle,"agenta0").
gps_map(45,15,obstacle,"agenta0").
gps_map(46,-32,obstacle,"agenta0").
gps_map(46,-31,obstacle,"agenta0").
gps_map(46,-30,obstacle,"agenta0").
gps_map(46,-29,obstacle,"agenta0").
gps_map(46,-24,obstacle,"agenta0").
gps_map(46,-9,goal,"agenta0").
gps_map(46,-8,goal,"agenta0").
gps_map(46,-7,goal,"agenta0").
gps_map(46,14,obstacle,"agenta0").
gps_map(46,15,obstacle,"agenta0").
gps_map(47,-32,obstacle,"agenta0").
gps_map(47,-31,obstacle,"agenta0").
gps_map(47,-30,obstacle,"agenta0").
gps_map(47,-29,obstacle,"agenta0").
gps_map(47,-8,goal,"agenta0").
gps_map(47,14,obstacle,"agenta0").
gps_map(47,15,obstacle,"agenta0").
gps_map(48,-33,obstacle,"agenta0").
gps_map(48,-31,obstacle,"agenta0").
gps_map(48,-30,obstacle,"agenta0").
gps_map(48,-28,obstacle,"agenta0").
gps_map(48,15,obstacle,"agenta0").
gps_map(49,-28,obstacle,"agenta0").
gps_map(49,13,b1,"agenta0").
gps_map(50,-8,b1,"agenta0").
gps_map(51,-1,obstacle,"agenta0").
gps_map(51,3,obstacle,"agenta0").
gps_map(52,-23,obstacle,"agenta0").
gps_map(52,3,obstacle,"agenta0").
gps_map(52,4,obstacle,"agenta0").
gps_map(52,5,obstacle,"agenta0").
gps_map(52,6,obstacle,"agenta0").
gps_map(53,-2,obstacle,"agenta0").
gps_map(53,2,obstacle,"agenta0").
gps_map(53,3,obstacle,"agenta0").
gps_map(53,4,obstacle,"agenta0").
gps_map(53,5,obstacle,"agenta0").
gps_map(53,6,obstacle,"agenta0").
gps_map(53,11,obstacle,"agenta0").
gps_map(53,12,obstacle,"agenta0").
gps_map(53,14,obstacle,"agenta0").
gps_map(54,-2,obstacle,"agenta0").
gps_map(54,2,obstacle,"agenta0").
gps_map(54,3,obstacle,"agenta0").
gps_map(54,4,obstacle,"agenta0").
gps_map(54,5,obstacle,"agenta0").
gps_map(54,11,obstacle,"agenta0").
gps_map(54,12,obstacle,"agenta0").
gps_map(54,14,obstacle,"agenta0").
gps_map(55,1,obstacle,"agenta0").
gps_map(55,2,obstacle,"agenta0").
gps_map(55,3,obstacle,"agenta0").
gps_map(55,11,obstacle,"agenta0").
gps_map(55,13,obstacle,"agenta0").
gps_map(55,15,b0,"agenta0").
gps_map(56,-31,obstacle,"agenta0").
gps_map(56,0,obstacle,"agenta0").
gps_map(56,1,obstacle,"agenta0").
gps_map(56,2,obstacle,"agenta0").
gps_map(56,3,obstacle,"agenta0").
gps_map(56,5,obstacle,"agenta0").
gps_map(57,-33,obstacle,"agenta0").
gps_map(57,-10,obstacle,"agenta0").
gps_map(57,-3,obstacle,"agenta0").
gps_map(57,1,obstacle,"agenta0").
gps_map(57,2,obstacle,"agenta0").
gps_map(58,-22,obstacle,"agenta0").
gps_map(58,-6,obstacle,"agenta0").
gps_map(58,-3,obstacle,"agenta0").
gps_map(58,9,obstacle,"agenta0").
gps_map(59,-1,obstacle,"agenta0").
gps_map(60,-18,obstacle,"agenta0").
gps_map(60,1,obstacle,"agenta0").
gps_map(60,5,obstacle,"agenta0").
gps_map(60,13,obstacle,"agenta0").
gps_map(61,-20,obstacle,"agenta0").
gps_map(61,-16,obstacle,"agenta0").
gps_map(63,-18,obstacle,"agenta0").
gps_map(63,-17,obstacle,"agenta0").
gps_map(64,-24,obstacle,"agenta0").
gps_map(64,-19,obstacle,"agenta0").
gps_map(64,-18,obstacle,"agenta0").
gps_map(64,-17,obstacle,"agenta0").
gps_map(64,-16,obstacle,"agenta0").
gps_map(64,1,obstacle,"agenta0").
gps_map(65,-19,obstacle,"agenta0").
gps_map(65,-18,obstacle,"agenta0").
gps_map(65,-17,obstacle,"agenta0").
gps_map(65,-16,obstacle,"agenta0").
gps_map(65,7,obstacle,"agenta0").
gps_map(66,-29,b2,"agenta0").
gps_map(66,-24,obstacle,"agenta0").
gps_map(66,-18,obstacle,"agenta0").
gps_map(66,-17,obstacle,"agenta0").
gps_map(67,1,obstacle,"agenta0").
gps_map(68,-32,obstacle,"agenta0").
gps_map(68,-23,obstacle,"agenta0").
gps_map(68,-22,obstacle,"agenta0").
gps_map(68,-20,obstacle,"agenta0").
gps_map(69,-32,obstacle,"agenta0").
gps_map(76,-30,b1,"agenta0").
gps_map(76,-28,obstacle,"agenta0").
vision(5).

@test_goto[test]
+!test_goto :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I)
    <-
    makeArtifact("rp", "localPositionSystem.rp.rp", [70,0], RpId);
    focus(RpId);
    for ( gps_map(I,J,O,MapId) ) {
        setGpsMapForTests(I,J,O,MapId)[artifact_id(RpId)];
    }

    .add_plan({
        +!do(move(DIR),success) :
            myposition(OX,OY) &
            directionIncrement(DIR,I,J) &
            walked_steps(S)
            <-
            -+walked_steps(S+1);
            !update_line(OX,OY,MIN_I,DIR);
    }, self, begin);

    !build_map;

    !test_goto_surrounding_objects(MIN_I);
    !test_goto_nearest_objects(MIN_I);
    !test_goto_far_position(MIN_I);
    !test_goto_obstacle(MIN_I);
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
    !check_performance(test_goto(0,0,19,13,MIN_I,R0_1,R1_1),1,_);
    !assert_equals(32,R0_1);
    !assert_equals(32,R1_1);

    // Test a path in which there the euclidean distance cannot be achieved
    !check_performance(test_goto(20,13,21,6,MIN_I,R0_2,R1_2),1,_);
    !assert_equals(8,R0_2);
    !assert_equals(18,R1_2);

    // Test a straight line path occupying a goal terrain
    !check_performance(test_goto(21,5,21,-4,MIN_I,R0_3,R1_3),1,_);
    !assert_equals(9,R0_3);
    !assert_equals(9,R1_3);

    !print_map;
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
    //!build_map;

    ?nearest(taskboard,X1,Y1);
    ?nearest_neighbour(X1,Y1,X_1,Y_1);
    !check_performance(test_goto(0,0,X_1,Y_1,MIN_I,R0_1,R1_1),1,_);
    !assert_equals(15,R0_1);
    !assert_equals(15,R1_1);

    ?nearest(b1,X2,Y2);
    ?nearest_neighbour(X2,Y2,X_2,Y_2);
    !check_performance(test_goto(X_1+1,Y_1,X_2,Y_2,MIN_I,R0_2,R1_2),1,_);
    !assert_equals(13,R0_2);
    !assert_equals(13,R1_2);

    ?nearest(b2,X3,Y3);
    ?nearest_neighbour(X3,Y3,X_3,Y_3);
    !check_performance(test_goto(X_2+1,Y_2,X_3,Y_3,MIN_I,R0_3,R1_3),1,_);
    !assert_equals(12,R0_3);
    !assert_equals(12,R1_3);

    ?nearest(goal,X_4,Y_4);
    !check_performance(test_goto(X_3+1,Y_3,X_4,Y_4,MIN_I,R0_4,R1_4),1,_);
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
    !check_performance(test_goto(0,0,48,-32,MIN_I,R0_1,R1_1),1,_);
    !assert_equals(80,R0_1);
    !assert_equals(84,R1_1);

    !check_performance(test_goto(49,-32,60,15,MIN_I,R0_2,R1_2),1,_);
    !assert_equals(58,R0_2);
    !assert_equals(58,R1_2);

    !check_performance(test_goto(59,15,12,6,MIN_I,R0_3,R1_3),1,_);
    !assert_equals(56,R0_3);
    !assert_equals(68,R1_3);

    !print_map;
.

+!test_goto_obstacle(MIN_I)
    <-
    !build_map;

    !goto(10,1,RET);

    !assert_equals(no_route,RET);
.

+!test_goto(X0,Y0,X1,Y1,MIN_I,R0,R1)
    <-
    -+myposition(X0,Y0);
    !update_line(X0,Y0,MIN_I,"H");
    -+walked_steps(0);
    !goto(X1,Y1,RET);
    !update_line(X1,Y1,MIN_I,"@");
    ?distance(X0,Y0,X1,Y1,R0);
    ?walked_steps(R1);
.

+!build_map
    <-
    .findall(I,gps_map(I,J,O,_),LI);
    .min(LI,MIN_I);
    .max(LI,MAX_I);
    .findall(J,gps_map(I,J,O,_),LJ);
    .min(LJ,MIN_J);
    .max(LJ,MAX_J);
    //.log(info,"i:",MIN_I,":",MAX_I);
    //.log(info,"j:",MIN_J,":",MAX_J);
    for ( .range(J,MIN_J,MAX_J) ) {
        .concat("                                                                                          ",J,C);
        +line(J,C);
    }
    for ( gps_map(I,J,O,_) ) {
        !update_line(I,J,MIN_I,O);
    }
.

+!update_line(I,J,MIN_I,O) :
    line(J,L)
    <-
    -line(J,L);
    .substring( L, R0, 0, I - MIN_I);
    //.log(info,gps_map(I,J,O,_),":",I - MIN_I,":'",R0,"'");
    .length(L,LL);
    .substring( L, R1, I - MIN_I + 1, LL);
    //.log(info,gps_map(I,J,O,_),":",I + 1 - MIN_I,":",LL,":",R1);
    if (.member(O,[b0,b1,b2])) {
        // If it is a dispenser just print the block identification
        .substring(O,R,1,2);
        .concat(R0,R,R1,RF);

    } else {
        if (O == obstacle) {
            .concat(R0,"#",R1,RF);
        } elif (O == s) {
            .concat(R0,"v",R1,RF);
        } elif (O == n) {
            .concat(R0,"^",R1,RF);
        } elif (O == e) {
            .concat(R0,">",R1,RF);
        } elif (O == w) {
            .concat(R0,"<",R1,RF);
        } else {
            // For other objects print the first letter
            .substring(O,R,0,1);
            .concat(R0,R,R1,RF);
        }
    }
    +line(J,RF);
.

+!print_map :
    .findall(J,gps_map(I,J,O,_),LJ) &
    .min(LJ,MIN_J) &
    .max(LJ,MAX_J)
    <-
    for ( .range(J,MIN_J,MAX_J) ) {
        ?line(J,RF);
        .log(info,RF);
    }
.
