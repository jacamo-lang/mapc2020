
!make_defender.

+!make_defender :
   .my_name(NAME) &
   .substring(NAME,NUMBER,6) &
   NUMBER == "1" & // only one agent creates the artifact (agenta1 of agentb1)
   .substring(NAME,TEAM,5,6) &
   .concat("artDEFENDER",TEAM,ArtDEFENDER)
   <-
   .log(warning,"Making and focusing on artifact ",ArtDEFENDER);
   makeArtifact(ArtDEFENDER,"localPositionSystem.rp.rp",[90,0],ArtId);
   focusWhenAvailable(ArtDEFENDER);
.

+!make_defender :
   .my_name(NAME) &
   .substring(NAME,TEAM,5,6) &
   .concat("artDEFENDER",TEAM,ArtDEFENDER)
   <-
   .log(warning,"Focusing on artifact ",ArtDEFENDER);
   focusWhenAvailable(ArtDEFENDER);
.
