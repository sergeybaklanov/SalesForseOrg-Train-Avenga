
/**
 * Created by User on 18.10.2022.
 */

public with sharing class Project_TriggerHelper {
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
        /*
         public static Map<Id, Integer> getDeveloperTotalBillableProjects(Set<Id> developerIds) {
        List<Developer__c>developers = [
                SELECT Id, (SELECT Id FROM Projects_Assignments__r WHERE Project__r.Is_Billable__c = TRUE)
                FROM Developer__c
                WHERE Id IN :developerIds
        ];
        Map<Id, Integer> result = new Map<Id, Integer>();
        for (Developer__c developer : developers) {
            result.put(developer.Id, developer.Projects_Assignments__r.size());
        }
        return result;
    }
         */
        for (Id devId : totalBillableProjectField.keySet()) {
            developersToUpdate.add(new Developer__c(Id = devId, Total_Billable_Projects__c = totalBillableProjectField.get(devId)));
        }
        update developersToUpdate;
    }
}