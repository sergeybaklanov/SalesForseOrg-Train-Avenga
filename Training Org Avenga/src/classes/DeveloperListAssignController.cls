/**
 * Created by User on 25.10.2022.
 */

public with sharing class DeveloperListAssignController {
    @AuraEnabled
    public static List<Project_Assignment__c> getProjectsAssignments(Id recordId) {
        List<Project_Assignment__c> listProjectAssignments = [
                SELECT Id,Name,CreatedDate,Project__r.Name,Project__r.Active__c,Project__r.Is_Billable__c
                FROM Project_Assignment__c
                WHERE Developer__c = :recordId
        ];
        return listProjectAssignments;
    }

    @AuraEnabled
    public static void makeSync(Id recordId) {
        try {
            DeveloperCallout.makeGetRequest(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}