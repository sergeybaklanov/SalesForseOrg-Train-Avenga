/**
 * Created by User on 18.10.2022.
 */

public with sharing class Project_AssignmentTriggerHelper {
    public static void beforeInsert(List<Project_Assignment__c> pas) {
        preventDuplicate(pas);
    }
    public static void beforeUpdate(List<Project_Assignment__c> pas) {
        preventDuplicate(pas);
    }
    public static void afterInsert(List<Project_Assignment__c> pas) {
        recalculateTotalBillableProjects(pas);
    }

    public static void preventDuplicate(List<Project_Assignment__c> pas) {

        Map<String, List<Project_Assignment__c>> mapAssignmentsNew = ProjectAssignmentServices.groupUniqueProjectAssignments(pas);
        List<Project_Assignment__c> filteredListPas = new List<Project_Assignment__c>();
        for (String key : mapAssignmentsNew.keySet()) {
            if (mapAssignmentsNew.get(key).size() > 1) {
                for (Project_Assignment__c el : mapAssignmentsNew.get(key)) {
                    el.addError('Duplicated Project assignment on the Developer in new list');
                }
            } else {
                filteredListPas.addAll(mapAssignmentsNew.get(key));
            }
        }
        if (filteredListPas.isEmpty()) {
            return ;
        }

        Set<Id> developerIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();

        for (Project_Assignment__c pa : filteredListPas) {
            developerIds.add(pa.Developer__c);
            projectIds.add(pa.Project__c);
        }
        List<Project_Assignment__c> lPasOld = [
                SELECT Developer__c, Project__c
                FROM Project_Assignment__c
                WHERE Developer__c IN :developerIds
                AND Project__c IN :projectIds
        ];

        for (Project_Assignment__c paNew : filteredListPas) {
            for (Project_Assignment__c paOld : lPasOld) {
                if (paOld.Project__c == paNew.Project__c && paOld.Developer__c == paNew.Developer__c) {
                    paNew.addError('Duplicated Project assignment on the Developer');
                }
            }
        }
    }

    public static void recalculateTotalBillableProjects(List<Project_Assignment__c> pas) {

        Set <Id> developersIds = new Set<Id>();
        for (Project_Assignment__c pa : pas) {
            developersIds.add(pa.Developer__c);
        }

        List <Developer__c> developers = [
                SELECT Id, Total_Billable_Projects__c, (SELECT Id FROM Projects_Assignments__r WHERE Project__r.Is_Billable__c = TRUE)
                FROM Developer__c
                WHERE Id IN :developersIds
        ];

        for(Developer__c dev : developers){
            dev.Total_Billable_Projects__c = dev.Projects_Assignments__r.size();
        }
        update  developers;
    }
}