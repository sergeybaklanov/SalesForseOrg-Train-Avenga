/**
 * Created by User on 20.10.2022.
 */

@IsTest
public class TestDataFactory {

    //Create Developers
    public static List<Developer__c> createDevelopers(Integer numDevelopers) {
        List<Developer__c> listDev = new List<Developer__c>();
        for (Integer i = 0; i < numDevelopers; i++) {
            listDev.add(new Developer__c(Name = 'Developer ' + i, Total_Billable_Projects__c = 0));
        }
        insert listDev;

        return listDev;
    }

    //Create Projects
    public static List<Project__c> createProjects(Integer numProjects, Boolean billable, Integer budget, Boolean active) {

        List<Project__c> listProj = new List<Project__c>();
        for (Integer i = 0; i < numProjects; i++) {
            listProj.add(new Project__c(Name = 'Project' + i, Is_Billable__c = billable, Project_Budget__c = budget, Active__c = active));
        }

        insert listProj;

        return listProj;
    }
    //Create  unics project assignment for all developers on all projects
    public static List<Project_Assignment__c> createDevelopersProjectAssignment(List<Developer__c> listDev, List<Project__c> listProj) {

        List<Project_Assignment__c> listProjAssign = new List<Project_Assignment__c>();
        for (Integer i = 0; i < listDev.size(); i++) {
            for (Integer j = 0; j < listProj.size(); j++) {
                listProjAssign.add(new Project_Assignment__c(Developer__c = listDev[i].Id, Project__c = listProj[j].Id));
            }
        }
        insert listProjAssign;

        return listProjAssign;
    }

    public static List<Client__c> createClients(Integer numClients) {
        List<Client__c> listClients = new List<Client__c>();
        for (Integer i = 0; i < numClients; i++) {
            listClients.add(new Client__c(Name = 'Client ' + i));
        }
        insert listClients;

        return listClients;
    }
}