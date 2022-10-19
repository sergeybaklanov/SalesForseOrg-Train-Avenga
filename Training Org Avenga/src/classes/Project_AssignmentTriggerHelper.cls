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

        for (Project_Assignment__c pasN : pasNew) {
            for (Project_Assignment__c pasO : pasOld) {
                if (!(pasN.Developer__c == pasO.Developer__c && pasN.Project__c == pasO.Project__c)) {
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
        // groupUniqueProjectAssignments return map with Project_Assignment__c grouped by Projects and Developers.
        /* public static Map<String, List<Project_Assignment__c>>
    groupUniqueProjectAssignments(List<Project_Assignment__c> projects){

        Set<String> keysProjectDeveloper = new Set<String>();
        Map<String, List<Project_Assignment__c>> result = new Map<String, List<Project_Assignment__c>>();

            for(Project_Assignment__c recordAssignment : projects){
                String key = recordAssignment.Project__c+'-'+recordAssignment.Developer__c;
                if(result.keySet().contains(key)){
                 result.get(key).add(recordAssignment);
                }
                else {
                    List <Project_Assignment__c> projectAsSListNew = new List <Project_Assignment__c>();
                    projectAsSListNew.add(recordAssignment);
                    result.put(key,projectAsSListNew);
                }
            }
        return result;
    }
    */

        List<Project_Assignment__c> filteredListPas = new List<Project_Assignment__c>();

        for (String key : mapAssignmentsNew.keySet()) {
            if (mapAssignmentsNew.get(key).size() > 1) {

                for (Project_Assignment__c el : mapAssignmentsNew.get(key)) {
                    el.addError(el.Developer__c + '-' + el.Project__c + ' Duplicated Project assignment on the Developer in new list');
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
        /* public static Map<Id, Integer> getDeveloperTotalBillableProjects(Set<Id> developerIds) {
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

        //Separates data from Map and edits field inside Developer record
        List <Developer__c> developers = new List<Developer__c>();
        for (Id key : devAndCountBillableProjects.keySet()) {
            developers.add(new Developer__c(Id = key, Total_Billable_Projects__c = devAndCountBillableProjects.get(key)));
        }
        /* List <Developer__c> developers = [
                 SELECT Id, Total_Billable_Projects__c, (SELECT Id FROM Projects_Assignments__r WHERE Project__r.Is_Billable__c = TRUE)
                 FROM Developer__c
                 WHERE Id IN :developersIds
         ];

         for(Developer__c dev : developers){
             dev.Total_Billable_Projects__c = dev.Projects_Assignments__r.size();
         }
         */
        update developers;
    }
}