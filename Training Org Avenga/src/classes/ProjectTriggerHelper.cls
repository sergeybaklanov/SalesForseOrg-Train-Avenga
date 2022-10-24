
/**
 * Created by User on 18.10.2022.
 */

public with sharing class ProjectTriggerHelper {
    // Filter records in which checkbox Billable was changed
    public static void afterUpdate(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap) {

        Set<Id> projectsWithChangedCheckboxBillable = new Set<Id>();

        for (Id key : newMap.keySet()) {
            if (oldMap.get(key).Is_Billable__c != newMap.get(key).Is_Billable__c) {
                projectsWithChangedCheckboxBillable.add(key);
            }
        }

        if(projectsWithChangedCheckboxBillable.isEmpty())  return;

        updateTotalBillableProjects(projectsWithChangedCheckboxBillable);
    }

    // Update Developers records field with number of Total Billable Projects
    private static void updateTotalBillableProjects(Set<Id> idProjectSet) {
        List<Project_Assignment__c> pas = [SELECT Developer__c FROM Project_Assignment__c WHERE Project__c IN :idProjectSet];

        // Get set with all developers from list
        Set <Id> developersIds = new Set<Id>();
        for (Project_Assignment__c pa : pas) {
            developersIds.add(pa.Developer__c);
        }

        //Fills List with records of Developers for update.
        List <Developer__c> developersToUpdate = new List<Developer__c>();
        //Map, where key = developer id, value = number of billable assigned projects
        Map<Id, Integer> totalBillableProjectField = ItCompanyDAO.getDeveloperTotalBillableProjects(developersIds);

        for (Id devId : totalBillableProjectField.keySet()) {
            developersToUpdate.add(new Developer__c(Id = devId, Total_Billable_Projects__c = totalBillableProjectField.get(devId)));
        }
        update developersToUpdate;
    }
}