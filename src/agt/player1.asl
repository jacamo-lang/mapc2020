/**
 * Player1 is launched by playground.jcm
 */

{ include("test_walking_helpers.asl") }
{ include("walking/goto_A_star.asl") }

!start.

+!start :
    .findall(I,gps_map(I,J,O,_),LI) &
    .min(LI,MIN_I) // MIN_I informs the more negative I to know how far is from zero
    <-
    makeArtifact("rp_test_weakind", "localPositionSystem.rp.rp", [70,0], RpId);
    focus(RpId);
    for ( gps_map(I,J,O,MapId) ) {
        setGpsMapForTests(I,J,O,MapId)[artifact_id(RpId)];
    }

    !add_test_plans_do(MIN_I);
    !add_test_plans_sincMap;
    
    !build_map(MIN_I);
    
    !test_goto(7,-14,19,-4,MIN_I,R0_1,R1_1,_);
    
    !print_map;
    
    .stopMAS(100);
.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
