/**
 * Created by User on 20.10.2022.
 */

@IsTest
private class Project_AssignmentTriggerTest {

    static final Integer countCreateDev = 10;
    static final Integer countCreateProj = 10;

    @TestSetup
    public static void createData() {
        List<Developer__c> listDev = TestDataFactory.createDevelopers(countCreateDev);
        List<Project__c> listProj = TestDataFactory.createProjects(countCreateProj, true, 100, true);
        List<Project_Assignment__c> listProjAssign = TestDataFactory.createDevelopersProjectAssignment(listDev, listProj);
    }

    @IsTest
    static void assignBillableProject() {

        Integer numEl = 4;
        //Before Update
        List<Developer__c> listDev = [SELECT Id, Total_Billable_Projects__c FROM Developer__c LIMIT :numEl];
        List<Project__c> listProj = TestDataFactory.createProjects(numEl, true, 100, true);

        Map <Id, Developer__c> devIds = new Map<Id, Developer__c>(listDev);

        //Assign projects on developer
        List<Project_Assignment__c> listProjAssign = new List<Project_Assignment__c>();
        for (Integer i = 0; i < listDev.size(); i++) {
            for (Integer j = 0; j < listProj.size(); j++) {
                listProjAssign.add(new Project_Assignment__c(Developer__c = listDev[i].Id, Project__c = listProj[j].Id));
            }
        }

        Test.startTest();
        insert listProjAssign;
        Test.stopTest();

        //After Update
        List<Developer__c> resListDev = [SELECT Id, Total_Billable_Projects__c FROM Developer__c WHERE Id IN :devIds.keySet()];

        for (Developer__c key : resListDev) {
            System.assert(key.Total_Billable_Projects__c == (devIds.get(key.Id).Total_Billable_Projects__c + numEl));
        }
    }

    @IsTest
    static void insertDuplicateProjectAssignments() {

        List<Project_Assignment__c> listProjAssign = [SELECT Developer__c, Project__c FROM Project_Assignment__c LIMIT 3];

        //Create clone developers
        List<Project_Assignment__c> lAssignments = new List<Project_Assignment__c>();
        for (Project_Assignment__c proj : listProjAssign) {
            lAssignments.add(new Project_Assignment__c(Developer__c = proj.Developer__c, Project__c = proj.Project__c));
        }

        Test.startTest();

        Database.SaveResult [] result = Database.insert(lAssignments, false);

        Test.stopTest();

        for (Integer i = 0; i < result.size(); i++) {
            System.assert(!result[i].isSuccess());
            System.assert(result[i].getErrors().size() > 0);
            System.assertEquals('Developer already has assignment on this project',
                    result[i].getErrors()[0].getMessage());
        }
    }

    @IsTest
    static void updateDuplicateProjectAssignments() {

        List<Project_Assignment__c> listProjAssign = [SELECT Developer__c, Project__c FROM Project_Assignment__c LIMIT 2];

        listProjAssign[1].Developer__c = listProjAssign[0].Developer__c;
        listProjAssign[1].Project__c = listProjAssign[0].Project__c;

        List<Project_Assignment__c> listToUpdate = new List<Project_Assignment__c>{
                listProjAssign[1]
        };

        Test.startTest();

        Database.SaveResult [] result = Database.update(listToUpdate, false);

        Test.stopTest();

            System.assert(!result[0].isSuccess());
            System.assert(result[0].getErrors().size() > 0);
            System.assertEquals('Developer already has assignment on this project',
                    result[0].getErrors()[0].getMessage());

    }
}