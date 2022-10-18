
/**
 * Created by User on 18.10.2022.
 */

public with sharing class Project_TriggerHelper {
    public static void afterUpdate(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap) {

        Set<Id> projectsWithChangedFieldTBP = new Set<Id>();

        for (Id key : newMap.keySet()) {
            if (oldMap.get(key).Is_Billable__c!= newMap.get(key).Is_Billable__c) {
                projectsWithChangedFieldTBP.add(key);
            }
        }
        updateTotalBillableProjects(projectsWithChangedFieldTBP);
    }
    public static void updateTotalBillableProjects(Set<Id> idProjectSet) {
        List<Project_Assignment__c> pas = [SELECT Developer__c FROM Project_Assignment__c WHERE Project__c IN :idProjectSet];

        Set <Id> developersIds = new Set<Id>();
        for (Project_Assignment__c pa : pas) {
            developersIds.add(pa.Developer__c);
        }
        List <Developer__c> developersToUpdate = new List<Developer__c>();

        Map<Id, Integer> totalBillableProjectField = ItCompanyDAO.getDeveloperTotalBillableProjects(developersIds);
        for (Id devId : totalBillableProjectField.keySet()) {
            developersToUpdate.add(new Developer__c(Id = devId, Total_Billable_Projects__c = totalBillableProjectField.get(devId)));
        }
        update developersToUpdate;
    }
}