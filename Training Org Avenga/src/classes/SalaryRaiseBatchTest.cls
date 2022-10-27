

@IsTest
private class SalaryRaiseBatchTest {
    static final Integer countCreateDev = 5;
    static final Integer countCreateProj = 5;

    @TestSetup
    public static void createData() {
        List<Developer__c> listDev = TestDataFactory.createDevelopers(countCreateDev);
        List<Project__c> listProj = TestDataFactory.createProjects(countCreateProj, true, 100, true);
        List<Project_Assignment__c> listProjAssign = TestDataFactory.createDevelopersProjectAssignment(listDev, listProj);
    }

    @IsTest
    static void testSalaryRaise() {
        List<Developer__c> developers = [SELECT Id FROM Developer__c];
        for (Integer i = 0; i < developers.size(); i++) {
            developers[i].Salary__c = 500;
            if (i < 2) {
                developers[i].LastRaiseDate__c = Date.today().addMonths(-5);
            } else {
                developers[i].LastRaiseDate__c = Date.today().addMonths(-7);
            }
        }
        update developers;

        Test.startTest();

        SalaryRaiseBatch salaryRaiseBatch = new SalaryRaiseBatch();
        Id batchId = Database.executeBatch(salaryRaiseBatch);

        Test.stopTest();

        List<Developer__c> developersAfterRaise = [
                SELECT Id,Salary__c
                FROM Developer__c
                WHERE LastRaiseDate__c = :Date.today()
        ];
        System.assert(developersAfterRaise.size() == 3);
        for (Developer__c dev : developersAfterRaise) {
            System.assert(dev.Salary__c == 1000);
        }
    }
}