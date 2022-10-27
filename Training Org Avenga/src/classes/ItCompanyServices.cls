public with sharing class ItCompanyServices {
//    + createProject | Database.SaveResult	  |Id clientId	| create project

    public static Database.SaveResult createProject(Id clientId) {

        Database.SaveResult saveResult = Database.insert(new Project__c(Client__c = clientId));

        return saveResult;
    }
    //__________________________________________________________________________________________________________________

    //+ createProjectAssignment   |void |Id projectId, Id developerId   |create project assignment
    public static void createProjectAssignment(Id projectId, Id developerId) {
        try {
            insert (new Project_Assignment__c(Project__c = projectId, Developer__c = developerId));
        } catch (DmlException e) {
            System.debug('Error = ' + e);
        }
    }
    //__________________________________________________________________________________________________________________

    //+ makeProjectBillable  |	void   |	Id projectId  |update project with IsBillable__c = true
    public static void makeProjectBillable(Id projectId) {

        Project__c project = new Project__c(Id = projectId);

        project.Is_Billable__c = true;
        project.Project_Budget__c = 1;

        try {
            update project;
        } catch (DmlException e) {
            System.debug('Error = ' + e);
        }
    }
    //__________________________________________________________________________________________________________________

    //+deactivateProjects  |	void |Set<Id> projectIds |update project with Active__c = false, delete all project assignments
    public static void deactivateProjects(Set<Id> projectIds) {
        List <Project__c> listProjects = new List<Project__c>();

        for (Id projectId : projectIds) {
            Project__c project = new Project__c(Id = projectId);
            project.Active__c = false;
            listProjects.add(project);
        }

        List<Project_Assignment__c> listProjectAssignments = [SELECT Id FROM Project_Assignment__c WHERE Project__c IN :projectIds];

        try {
            update listProjects;
            delete listProjectAssignments;
        } catch (DmlException e) {
            System.debug('Error = ' + e);
        }
    }
    //For check
/*//    List <Project__c> projectsIds =[SELECT Id FROM Project__c WHERE Client__r.Name = 'ClientDML'];
//    Set <Id> ids = (new Map<Id, Project__c>(projectsIds)).keySet();
//
//    ItCompanyServices.deactivateProjects(ids);
    */
    //__________________________________________________________________________________________________________________

    // +createDeveloperAndAssign |List<Database.SaveResult>	|String devName, Set<Id> projectIds| create Developer record and assign projects to it

    public static List<Database.SaveResult> createDeveloperAndAssign(String devName, Set<Id> projectIds) {
        Developer__c developer = new Developer__c(Name = devName);
        Database.SaveResult developerInsert = Database.insert (developer, false);

        Id developerId = developer.Id;

        List <Project_Assignment__c> listNewProjectAssignments = new List<Project_Assignment__c>();

        for (Id projectId : projectIds) {
            Project_Assignment__c assignment = new Project_Assignment__c(
                    Developer__c = developerId,
                    Project__c = projectId);
            listNewProjectAssignments.add(assignment);
        }

        List<Database.SaveResult> saveResults = Database.insert(listNewProjectAssignments);
        // projectAssignmentInsert.add(0, developerInsert);

        return saveResults;
    }

//Check:
/*    List <Project__c> projectsIds =[SELECT Id FROM Project__c WHERE Client__r.Name = 'ClientDML'];
//    Set <Id> ids = (new Map<Id,Project__c>(projectsIds)).keySet();
//
  ItCompanyServices.createDeveloperAndAssign('DeveloperDML',ids);*/
}