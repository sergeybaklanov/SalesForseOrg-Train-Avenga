/**
 * Created by User on 20.10.2022.
 */

@IsTest
private class ItCompanyServicesTest {

    static final Integer countCreateDev = 10;
    static final Integer countCreateProj = 10;
    static final Integer countCreateClients = 10;

    @TestSetup
    public static void createData() {
        List<Developer__c> listDev = TestDataFactory.createDevelopers(countCreateDev);
        List<Project__c> listProj = TestDataFactory.createProjects(countCreateProj, true, 100, true);
        List<Project_Assignment__c> listProjAssign = TestDataFactory.createDevelopersProjectAssignment(listDev, listProj);
        List<Client__c> listClients = TestDataFactory.createClients(countCreateClients);
    }

    @IsTest
    static void createProjectTest() {

        Client__c client = [SELECT Id FROM Client__c LIMIT :1];

        Test.startTest();
        Database.SaveResult saveResults = ItCompanyServices.createProject(client.Id);
        Test.stopTest();

        System.assert(saveResults.isSuccess());

    }

    // ?
    @IsTest
    static void createProjectAssignmentTest() {

        List<Developer__c> developer = TestDataFactory.createDevelopers(1);
        List<Project__c> project = TestDataFactory.createProjects(1, true, 100, true);

        Integer sizePABefore = [SELECT Id FROM Project_Assignment__c].size();

        Test.startTest();

        ItCompanyServices.createProjectAssignment(project[0].Id, developer[0].Id);

        Test.stopTest();

        Integer sizePAAfter = [SELECT Id FROM Project_Assignment__c].size();
        System.assert((sizePAAfter-sizePABefore)==1);
    }

    @IsTest
    static void makeProjectBillableTest() {
        List<Project__c> project = TestDataFactory.createProjects(1, false, 100, true);

        Test.startTest();
        ItCompanyServices.makeProjectBillable(project[0].Id);
        Test.stopTest();

        Project__c resultProject = [SELECT Is_Billable__c FROM Project__c WHERE  Id=:project[0].Id];

        System.assert(resultProject.Is_Billable__c==true);

    }

    @IsTest
    static void deactivateProjectsTest() {

        List<Project__c> listProj = [SELECT Id FROM Project__c WHERE Active__c = TRUE];
        Set<Id> projectIds = (new Map<Id, Project__c> (listProj).keySet());

        Test.startTest();
        ItCompanyServices.deactivateProjects(projectIds);
        Test.stopTest();

        List <Project_Assignment__c> listPrAs = [SELECT Id FROM Project_Assignment__c WHERE Project__c IN :projectIds];

        System.assert(listPrAs.isEmpty());

        for (Project__c p : [SELECT Id,Active__c FROM Project__c WHERE Id IN :projectIds]) {
            System.assert(p.Active__c == false);
        }
    }

    @IsTest
    static void createDeveloperAndAssignTest() {

        List<Project__c> listProj = TestDataFactory.createProjects(5, true, 100, true);
        Set<Id> projectIds = (new Map<Id, Project__c> (listProj).keySet());

        Test.startTest();
        List<Database.SaveResult> saveResults = ItCompanyServices.createDeveloperAndAssign('Machata', projectIds);
        Test.stopTest();

        for (Integer i = 0; i < saveResults.size(); i++) {
            System.assert(saveResults[i].isSuccess());
        }
    }
}