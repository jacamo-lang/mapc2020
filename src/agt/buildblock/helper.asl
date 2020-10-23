//{ include("buildblock/builderstrategies/onetypebyhelper.asl") }
//{ include("buildblock/hirehelpers/firstfree.asl") }

/* EVERY PRINT IS A FUNCTION TO BE DEVELOPED */

+!bring(TYPE,QBLOCKS,X,Y)[source(AGBM)] :  true
    <-
        +serving(AGBM);        
        for (.range(C, 1,QBLOCKS)) {
        	!do(rotate(ccw),RET);	
        	!get_block(TYPE);
        }
        for (.range(C, 1,QBLOCKS)) {
        	!do(rotate(cw),RET);	
        }
        +availableblocks(TYPE,QBLOCKS);
        ?myposition(X0,Y0);
        .print(myposition(X0,Y0)," ==> ", end(X,Y));
        !goto(X,Y,RET);
        .send(AGBM,tell,available(TYPE));
    .   

+!attach(DX,DY,TYPE)[source(AGBM)] : true
    <-
        .print("--- PUT THE BLOCK IN POSITION ---");        
        .send(AGBM,tell,atposition(DX,DY,TYPE));
        /* WHEN THE HELPER IS WORKING CHANGE IT TO ACTION DO */
        .print("DO --->",connect(AGBM,X,Y));
        .send(AGBM,untell,atposition(DX,DY,TYPE));
        ?availableblocks(TYPE,QBLOCKS);
        -availableblocks(TYPE,QBLOCKS);
        +availableblocks(TYPE,QBLOCKS-1);
    .

+!taskisover
    :true
    <-
        true;
    .
