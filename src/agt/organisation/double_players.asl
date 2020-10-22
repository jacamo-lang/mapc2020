/**
 * This lib offers plans to handle double players organisations
 */
 
+!create_double_org(OrgName,GoalList)
    <-
    makeArtifact(OrgName,"ora4mas.light.LightOrgBoard",[],OIa);
    focus(OIa);
    createGroup(double_group,Gid);
    focus(Gid);
    adoptRole(master);
    
    createScheme(s,Sid);
    focus(Sid);
    addScheme(s);
    
    for (.member(g(G,D),GoalList)) {
        addGoal(G,D);   
    }
    
    debug(inspector_gui(on))[artifact_id(Sid)];
.

+!invite_helper(Helper)
    <-
    .send(Helper,achieve,adopt_role(helper,double_group));
.

+!add_obligation(Player,Goal)
    <-
    addNorm(obligation,Player,Goal);
.

+!adopt_role(Role,Group) 
    <-
    lookupArtifact(Group,Aid);
    focus(Aid);
    adoptRole(Role);
.
