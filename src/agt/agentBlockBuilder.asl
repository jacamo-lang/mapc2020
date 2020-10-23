{ include("agentBase.asl") }
{ include("buildblock/master.asl")}
{ include("buildblock/helper.asl")}
{ include("buildblock/commons/get_block.asl") }

//{ include("buildblock/commons/common_task.asl") }
//{ include("buildblock/commons/goto.asl") }
{ include("walking/goto_iaA_star.asl") }
{ include("origin_workaround.asl") }
@ato[atomic] //%%%%%%%%%%%isso definitivamente não é bom !!!!!!!!!!!!!!!!!!! %%%%%%
+task(NAME,REWARD,DEADLINE,L) 
    : not taskcommited & 
      readytobuild & 
      choosetask(task(NAME,REWARD,DEADLINE,L))
    <-  
        -exploring;
        +taskcommited;        
        !gotask[critical_section(action), priority(1)];                
       // -taskcommited;     
       // +exploring;
    .