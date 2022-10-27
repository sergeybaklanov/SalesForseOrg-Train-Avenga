/**
 * Created by User on 20.10.2022.
 */

@IsTest
private class ItCompanyDAOTest {

   static final Integer countCreateDev =10;
   static final Integer countCreateProj =10;
   static final Integer countCreateClients =10;


    @TestSetup
    public static void createData() {
        List<Developer__c> listDev = TestDataFactory.createDevelopers(countCreateDev);
        List<Project__c> listProj = TestDataFactory.createProjects(countCreateProj, true, 100, true);
        List<Project_Assignment__c> listProjAssign = TestDataFactory.createDevelopersProjectAssignment(listDev, listProj);
        List<Client__c> listClients = TestDataFactory.createClients(countCreateClients);
    }

//    get developer ids who has assigned less then into 5
//    billable projects (use Developer__c.Total_Billable_Projects__c field))
    @IsTest
    static void getAvailableDeveloperIdsTest() {
        Integer count = 2;

        List<Developer__c> listDev = TestDataFactory.createDevelopers(count);
        List<Project__c> listProj = TestDataFactory.createProjects(count, true, 100, true);
        List<Project_Assignment__c> listProjAssign = TestDataFactory.createDevelopersProjectAssignment(listDev, listProj);

        Test.startTest();
        Set<Id> devIds = ItCompanyDAO.getAvailableDeveloperIds();
        Test.stopTest();
        System.assert(devIds.size() == count);


    }

    //get developer ids who has assigned into 0 projects
    @IsTest
    static void getUnassignedDeveloperIdsTest() {
        List<Developer__c> listDev = TestDataFactory.createDevelopers(1);

        Test.startTest();

        Set<Id>  devIds= ItCompanyDao.getUnassignedDeveloperIds();

        Test.stopTest();

        System.assert(devIds.size()==listDev.size());

        for (Developer__c dev : listDev) {
            System.assert(devIds.contains(dev.Id));
        }
    }

    //get Client__c records with LIMIT and OFFSET
    @IsTest
    static void getClientsTest(){

        Integer limitNumber= 2;
        Integer offsetNumber = 2;

        Test.startTest();

        List <Client__c> listResult = ItCompanyDAO.getClients(limitNumber,offsetNumber);

        Test.stopTest();

        System.assert(listResult.size()==limitNumber);
    }


    //dynamic query. If any of params is null - do not add respective condition to query.
    @IsTest
    static void getDevelopersZeroTest(){

        Integer limitNumber= 0;
        Integer offsetNumber = 50;

        List <Developer__c> developers = [SELECT Id, Name FROM Developer__c];
        Set<Id> developersIds = (new Map<Id,Developer__c> (developers)).keySet();

        Test.startTest();

        List <Developer__c> listResult = ItCompanyDAO.getDevelopers(developersIds,limitNumber,offsetNumber);

        Test.stopTest();

        System.assert(listResult.size()==0);
    }


    @IsTest
    static void getDevelopersTest() {

        Integer limitNumber= 8;
        Integer offsetNumber = 3;

        List <Developer__c> developers = [SELECT Id, Name FROM Developer__c];
        Set<Id> developersIds = (new Map<Id,Developer__c> (developers)).keySet();

        Test.startTest();

        List <Developer__c> listResult = ItCompanyDAO.getDevelopers(developersIds,limitNumber,offsetNumber);

        Test.stopTest();

        List<Developer__c> expectedResult = new List<Developer__c>();

        for (Integer i = offsetNumber; i <offsetNumber+limitNumber&&i<developers.size() ; i++) {
            expectedResult.add(developers[i]);
        }

        Boolean testResult =true;

        if(expectedResult.size()==listResult.size()){
            for (Integer i = 0; i < expectedResult.size(); i++) {
                if(listResult.contains(expectedResult[i])==false)
                {
                    testResult=false;
                    break;
                }
            }
        } else {
            testResult =false;
        }

        System.assert(testResult);
       // System.assert(expectedResult.size()<=limitNumber);
    }

    //return map, where key = client id,value = number of active projects
    @IsTest
    static void getClientTotalActiveProjectsTest() {
        Integer num=5;

        List <Client__c> listClients = [SELECT Id FROM Client__c LIMIT :num];
        List<Project__c> listProjects = [SELECT Id FROM Project__c WHERE Active__c=TRUE LIMIT :num];

        for (Integer i = 0; i < num; i++) {
            listProjects[i].Client__c=listClients[i].Id;
        }

        update listProjects;

        Set<Id> clientsIds = (new Map<Id,Client__c>(listClients)).keySet();

        Test.startTest();

        Map<Id, Integer> resultMap = ItCompanyDAO.getClientTotalActiveProjects(clientsIds);

        Test.stopTest();

        for(Id key : resultMap.keySet()){
            System.assert(resultMap.get(key)==1);
        }
    }

    //return map, where key = developer id, value = number of billable assigned projects
    @IsTest
    static void getDeveloperTotalBillableProjectsTest(){
        Integer numProgOnDeveloper = 5;


        List <Developer__c> developers = [SELECT Id,Total_Billable_Projects__c FROM Developer__c LIMIT 2];
        Set<Id> developersIds = (new Map<Id,Developer__c> (developers).keySet());

        List<Project__c> listProj = TestDataFactory.createProjects(numProgOnDeveloper, true, 100, true);
        List<Project_Assignment__c> listProjAssign = TestDataFactory.createDevelopersProjectAssignment(developers, listProj);

        Test.startTest();

        Map<Id,Integer> mapResults = ItCompanyDao.getDeveloperTotalBillableProjects(developersIds);

        Test.stopTest();

        System.assert(developersIds.size()==mapResults.size());

        for (Id key : mapResults.keySet()) {
            System.assert(mapResults.get(key)==numProgOnDeveloper+countCreateProj);
        }
    }
}