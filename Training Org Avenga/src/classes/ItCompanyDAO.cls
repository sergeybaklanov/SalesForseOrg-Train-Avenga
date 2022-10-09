public with sharing class ItCompanyDAO {

 /*   getAvailableDeveloperIds |	Set<Id>	| -	|get developer ids who has assigned less then into 5
    billable projects (use Developer__c.Total_Billable_Projects__c field))
  */
    public static Set<Id> getAvailableDeveloperIds(){

        Set<Id> ids = new Set<Id>();
        
        List<Developer__c> listDevelopers = 
        [SELECT Id FROM Developer__c WHERE Developer__c.Total_Billable_Projects__c < 5];
            for(Developer__c developer : listDevelopers){
                ids.add(developer.Id);
            }
        return ids; 
    }

   // Task : getUnassignedDeveloperIds |	Set<Id>	| -	| get developer ids who has assigned into 0 projects
    public static Set<Id> getUnassignedDeveloperIds(){

        //Creating List of developers without any related projects
        List<Developer__c> listAllDevelopers = [SELECT Id, Name FROM Developer__c
        WHERE Id NOT IN (SELECT Developer__c FROM Project_Assignment__c)];

        return  (new Map<Id,Developer__c>(listAllDevelopers)).keySet();
    }
}

/*Method name	| Result type  |	Input parameters |	Description

getClients |	List<Client__c>	| Integer limitNumber, Integer offsetNumber	| get Client__c records
 with LIMIT and OFFSET

getDevelopers |	List<Developer__c>	| Set<Id> developerId, Integer limitNumber, Integer offsetNumber	|
dynamic query. If any of params is null - do not add respective condition to query.

getClientTotalActiveProjects	| Map<Id, Integer>	| Set<Id> clientIds	| return map, where key = client id, 
value = number of active projects.

getDeveloperTotalBillableProjects |	Map<Id, Integer>	| Set<Id> developerIds	| return map, where key = developer id, 
value = number of billable assigned projects.
*/