//{ include("buildblock/builderstrategies/onetypebyhelper.asl") }
//{ include("buildblock/hirehelpers/firstfree.asl") }

/* EVERY PRINT IS A FUNCTION TO BE DEVELOPED */

+!bring(TYPE,QBLOCKS,X,Y)[source(AGBM)] :  true
    <-
        +serving(AGBM);
        .print("--- GO TO THE DISPENSER AND GET BLOCKS---");
        +availableblocks(TYPE,QBLOCKS);
        .print("--- GOTO THE BUILD MASTER --->");       
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
