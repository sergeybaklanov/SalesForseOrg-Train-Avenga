/**
 * Created by User on 18.10.2022.
 */

public with sharing class Project_AssignmentTriggerHelper {

    public static void beforeInsert(List<Project_Assignment__c> pas) {
        preventDuplicate(pas);
    }
    public static void beforeUpdate(List<Project_Assignment__c> pasNew, List<Project_Assignment__c> pasOld) {
        checkPAFieldOnChanges(pasNew,pasOld);
    }
    public static void afterInsert(List<Project_Assignment__c> pas) {
        recalculateTotalBillableProjects(pas);
    }

    private static void checkPAFieldOnChanges(List<Project_Assignment__c> pasNew, List<Project_Assignment__c> pasOld) {
        List<Project_Assignment__c> filterChangedPass = new List<Project_Assignment__c>();
        Map<Id,Project_Assignment__c> oldMap = new Map<Id,Project_Assignment__c>();
        for(Project_Assignment__c pa : pasOld){
            oldMap.put(pa.Id,pa);
        }

        for (Project_Assignment__c pasN : pasNew) {
            if(oldMap.containsKey(pasN.Id)){
                if (!(pasN.Developer__c == oldMap.get(pasN.Id).Developer__c && pasN.Project__c == oldMap.get(pasN.Id).Project__c)) {
                    filterChangedPass.add(pasN);
                }
            }
        }
        if(filterChangedPass.isEmpty()){
            return ;
        }
        preventDuplicate(filterChangedPass);
        //Check:
        /*
        Project_Assignment__c element = [SELECT Id, Developer__c,Project__c FROM Project_Assignment__c WHERE Id='a037Q000002xdUDQAY'];
        System.debug('Before update Project Id = '+element.Project__c);

        element.Project__c='a027Q0000039BbBQAU';
//element.Project__c='a027Q00000392ujQAA';

        System.debug('After update Project Id = '+element.Project__c);

        System.debug('Before update PA ID = '+element.Id);
        update element;
        System.debug('After update PA ID = '+element.Id);

         */
    }


    private static void preventDuplicate(List<Project_Assignment__c> pas) {

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
                    paNew.addError('Developer already has assignment on this project');
                }
            }
        }
    }

    //Check: List<Project_Assignment__c> myList = new List<Project_Assignment__c>{
    //        new Project_Assignment__c(Developer__c='a017Q00001BJglHQAT', Project__c='a027Q00000390cwQAA'),
    //        new Project_Assignment__c(Developer__c='a017Q00001BJglHQAT', Project__c='a027Q00000390cwQAA'),
    //        new Project_Assignment__c(Developer__c='a017Q000019jnnwQAA', Project__c='a027Q00000390cwQAA')
    //};
    //insert myList;


    //Recalculation  Total_Billable_Projects__c field in Developers records based on project Assignments list.
    private static void recalculateTotalBillableProjects(List<Project_Assignment__c> pas) {

        //Gets Developers_Id from list of project Assignments
        Set <Id> developersIds = new Set<Id>();
        for (Project_Assignment__c pa : pas) {
            developersIds.add(pa.Developer__c);
        }

        //This method return map, where key = developer id, value = number of billable assigned projects.
        Map<Id, Integer> devAndCountBillableProjects = ItCompanyDAO.getDeveloperTotalBillableProjects(developersIds);

        //Separates data from Map and edits field inside Developer record
        List <Developer__c> developers = new List<Developer__c>();
        for (Id key : devAndCountBillableProjects.keySet()) {
            developers.add(new Developer__c(Id = key, Total_Billable_Projects__c = devAndCountBillableProjects.get(key)));
        }

        update developers;
    }
}