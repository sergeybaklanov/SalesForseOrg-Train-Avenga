/**
 * Created by User on 20.10.2022.
 */

@IsTest
private class ProjectTriggerTest {
    static final Integer countCreateDev =10;
    static final Integer countCreateProj =10;


    @TestSetup
    public static void createData() {
        List<Developer__c> listDev = TestDataFactory.createDevelopers(countCreateDev);
        List<Project__c> listProj = TestDataFactory.createProjects(countCreateProj, true, 100, true);
        List<Project_Assignment__c> listProjAssign = TestDataFactory.createDevelopersProjectAssignment(listDev, listProj);
    }

    //+
    @IsTest
    static void updateDevelopersFieldTotalBillableProjects() {

        Integer numEl =4;
//Before Update
        List<Developer__c> listDev = [SELECT Id, Total_Billable_Projects__c FROM Developer__c LIMIT :numEl];
        Map <Id,Developer__c> devIds = new Map<Id,Developer__c>(listDev);

        List<Project__c> listProj = [SELECT Id, Is_Billable__c FROM Project__c LIMIT :numEl];

        for(Project__c el : listProj){
            el.Is_Billable__c=false;
        }

        Test.startTest();

        update listProj;

        Test.stopTest();

        //After Update
        List<Developer__c> resListDev = [SELECT Id, Total_Billable_Projects__c FROM Developer__c WHERE Id IN :devIds.keySet()];

        for(Developer__c key: resListDev){
            System.assert(key.Total_Billable_Projects__c==(devIds.get(key.Id).Total_Billable_Projects__c-numEl));
        }
    }

}