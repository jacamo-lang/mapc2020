/**
 * Player1 is launched by playground.jcm
 */

{ include("test_walking_helpers.asl") }
{ include("walking/rotate_jA_star.asl") }

+!start
    <-
    -+myposition(0,0);
    -+origin(mymap); 

    ?get_rotation(b(1,0,b0),b(0,1,b0),D0);
    .log(warning,"Rotate a block from 3 o'clock to 6 o'clock got ",D0);
    
    ?get_rotation(b(1,0,b0),b(-1,0,b0),D1);
    .log(warning,"Rotate a block from 3 o'clock to 9 o'clock got ",D1); 

    ?get_rotation(b(0,-1,b0),b(-1,0,b0),D2);
    .log(warning,"Rotate a block from 12 o'clock to 9 o'clock got ",D2); 

    -+gps_map(0,-1,obstacle,mymap);
    ?get_rotation(b(1,0,b0),b(-1,0,b0),D3);
    .log(warning,"Rotate a block from 3 o'clock to 9 o'clock, but 12 o'clock is an obstacle got ",D3); 

    ?get_rotation(b(1,0,b0),b(0,-1,b0),D4);
    .log(warning,"Rotate a block from 3 o'clock to 12 o'clock, but 12 o'clock is an obstacle got ",D4); 
.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
