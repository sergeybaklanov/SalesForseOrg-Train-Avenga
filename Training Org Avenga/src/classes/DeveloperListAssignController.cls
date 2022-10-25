/**
 * Created by User on 25.10.2022.
 */

public with sharing class DeveloperListAssignController {
    @AuraEnabled
    public static List<Project_Assignment__c> getProjectsAssignments(Id recordId) {
        List<Project_Assignment__c> listProjectAssignments = [
                SELECT Id,Name,CreatedDate,Project__r.Name
                FROM Project_Assignment__c
                WHERE Developer__c = :recordId
        ];
        return listProjectAssignments;
    }

}