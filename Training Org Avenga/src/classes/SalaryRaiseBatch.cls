/**
 * Created by User on 27.10.2022.
 */

public with sharing class SalaryRaiseBatch implements Database.Batchable<SObject> {
    public Integer recordProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        Date lastRaiseSalaryDate = Date.today().addMonths(-6);
        return Database.getQueryLocator('SELECT Id FROM Developer__c WHERE  LastRaiseDate__c<=:lastRaiseSalaryDate');
    }

    public void execute(Database.BatchableContext param1, List<Developer__c> listDev) {

        Set<Id> idsDev = (new Map<Id, Developer__c>(listDev)).keySet();
        List<Developer__c> developers = [
                SELECT Id,Salary__c, (
                        SELECT Id
                        FROM Projects_Assignments__r
                        WHERE Project__r.Active__c = TRUE AND Project__r.Is_Billable__c = TRUE
                )
                FROM Developer__c
                WHERE Id IN :idsDev
        ];
        List<Developer__c> devSalaryToUpdate = new List<Developer__c>();
        for (Developer__c dev : developers) {
            if (!dev.Projects_Assignments__r.isEmpty()) {
                dev.Salary__c += dev.Projects_Assignments__r.size() * 100;
                dev.LastRaiseDate__c=Date.today();
                devSalaryToUpdate.add(dev);
            }
        }
        update devSalaryToUpdate;
    }

    public void finish(Database.BatchableContext param1) {
    }
}