public with sharing class ItCompanyServices {
    public static Database.SaveResult createProject(Id clientId) {

        Database.SaveResult saveResult = Database.insert(new Project__c(Client__c = clientId));

        return saveResult;
    }
        //__________________________________________________________________________________________________________________
    public static void createProjectAssignment(Id projectId, Id developerId) {
        try {
            insert (new Project_Assignment__c(Project__c = projectId, Developer__c = developerId));
        } catch (DmlException e) {
            System.debug('Error = ' + e);
        }
    }
        //__________________________________________________________________________________________________________________
    public static void makeProjectBillable(Id projectId) {
        Project__c project = new Project__c(Id = projectId);
        project.Is_Billable__c = true;
        project.Project_Budget__c = 20;
        try {
            update project;
        } catch (DmlException e) {
            System.debug('Error = ' + e);
        }

    }
        //__________________________________________________________________________________________________________________
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
//    Set<Id> projectIds  = new Set<Id>{'a027Q0000039ApN','a027Q0000039AqA','a027Q0000039AqF','a027Q0000039AqK'};
//
//    ItCompanyServices.deactivateProjects(projectIds);
        //__________________________________________________________________________________________________________________
    public static List<Database.SaveResult> createDeveloperAndAssign(String devName, Set<Id> projectIds) {
        Developer__c developer = new Developer__c(Name = devName);
        Database.SaveResult developerInsert = Database.insert (developer,false);

        Id developerId = developer.Id;

        List <Project_Assignment__c> listNewProjectAssignments = new List<Project_Assignment__c>();

        for (Id projectId : projectIds) {
            Project_Assignment__c assignment = new Project_Assignment__c(
                    Developer__c = developerId,
                    Project__c = projectId);
            listNewProjectAssignments.add(assignment);
        }

        List<Database.SaveResult> projectAssignmentInsert = Database.insert(listNewProjectAssignments);
       // projectAssignmentInsert.add(0, developerInsert);

        return projectAssignmentInsert;
    }

    //Checking
    // Set<Id> projectIds  = new Set<Id>{'a027Q0000039AqyQAE'};
    //
    //ItCompanyServices.createDeveloperAndAssign('NewDew',projectIds);


}
/*
Method name                 |Result type	            |Input parameters                   |	Description
+ createProject	            | Database.SaveResult	    |Id clientId	                    | create project
+ createProjectAssignment     |void	                    |Id projectId, Id developerId	    |create project assignment
+ makeProjectBillable         |	void                    |	Id projectId	                |update project with IsBillable__c = true
+deactivateProjects          |	void	                |Set<Id> projectIds	                |update project with Active__c = false, delete all project assignments
+createDeveloperAndAssign *	|List<Database.SaveResult>	|String devName, Set<Id> projectIds|	create Developer record and assign projects to it
 */