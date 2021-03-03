
{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
{ include("test_walking_helpers.asl") }
{ include("walking/common_walking.asl") }
{ include("walking/rotate_jA_star.asl") }

@[test,atomic]
+!test_get_rotation
    <-
    -+myposition(0,0);
    -+origin(mymap);
    -+vision(5);

    .log(warning,"Rotate a block from 3 o'clock to 6 o'clock");
    ?get_rotation(b(1,0,b0),b(0,1,b0),D0);
    !assert_equals(cw,D0);

    .log(warning,"Rotate a block from 3 o'clock to 9 o'clock");
    ?get_rotation(b(1,0,b0),b(-1,0,b0),D1);
    !assert_equals(ccw,D1); // by default it goes ccw (after one rotation on ccw it will return ccw again)

    .log(warning,"Rotate a block from 12 o'clock to 9 o'clock");
    ?get_rotation(b(0,-1,b0),b(-1,0,b0),D2);
    !assert_equals(ccw,D2);

    .log(warning,"Rotate a block from 3 o'clock to 9 o'clock, but 12 o'clock is an obstacle.");
    +gps_map(0,-1,obstacle,mymap);
    !update_thing_from_gps_map;
    ?get_rotation(b(1,0,b0),b(-1,0,b0),D3);
    !assert_equals(cw,D3); // could not use default, but cw is also a solution

    .log(warning,"Rotate a block from 3 o'clock to 12 o'clock, but 12 o'clock is an obstacle.");
    ?get_rotation(b(1,0,b0),b(0,-1,b0),D4);
    !assert_equals(no_rotation,D4); // there is no solution

    +gps_map(0,1,obstacle,mymap);
    !update_thing_from_gps_map;
    .log(warning,"Rotate a block from 3 o'clock to 9 o'clock, but 12 and 6 o'clock are obstacles.");
    ?get_rotation(b(1,0,b0),b(-1,0,b0),D5);
    !assert_equals(no_rotation,D5); // there is no solution

    .abolish(thing(_,_,_,_));
    .abolish(gps_map(_,_,_,_));
    .abolish(myposition(_,_));
    .abolish(origin(_));
    .abolish(vision(_));
.

@[test,atomic]
+!test_get_rotation_thing
    <-
    +thing(0,0,entity,a);
    +thing(1,0,block,b0);
    +attached(1,0);
    .log(warning,"Rotate a block from 3 o'clock to 6 o'clock");
    !list_vision;
    ?get_rotation(b(1,0,b0),b(0,1,b0),D0);
    !assert_equals(cw,D0);

    .log(warning,"Rotate a block from 3 o'clock to 9 o'clock");
    ?get_rotation(b(1,0,b0),b(-1,0,b0),D1);
    !assert_equals(ccw,D1); // by default it goes ccw (after one rotation on ccw it will return ccw again)

    -thing(1,0,block,b0);
    -attached(1,0);
    +thing(0,-1,block,b0);
    +attached(0,-1);
    .log(warning,"Rotate a block from 12 o'clock to 9 o'clock");
    !list_vision;
    ?get_rotation(b(0,-1,b0),b(-1,0,b0),D2);
    !assert_equals(ccw,D2);

    -thing(0,-1,block,b0);
    -attached(0,-1);
    +thing(0,-1,obstacle,_);
    +thing(1,0,block,b0);
    +attached(1,0);
    .log(warning,"Rotate a block from 3 o'clock to 9 o'clock, but 12 o'clock is an obstacle.");
    !list_vision;
    ?get_rotation(b(1,0,b0),b(-1,0,b0),D3);
    !assert_equals(cw,D3); // could not use default, but cw is also a solution

    .log(warning,"Rotate a block from 3 o'clock to 12 o'clock, but 12 o'clock is an obstacle.");
    ?get_rotation(b(1,0,b0),b(0,-1,b0),D4);
    !assert_equals(no_rotation,D4); // there is no solution

    +thing(0,1,obstacle,_);
    .log(warning,"Rotate a block from 3 o'clock to 9 o'clock, but 12 and 6 o'clock are obstacles.");
    !list_vision;
    ?get_rotation(b(1,0,b0),b(-1,0,b0),D5);
    !assert_equals(no_rotation,D5); // there is no solution

    .abolish(thing(_,_,_,_));
    .abolish(attached(_,_));
.
