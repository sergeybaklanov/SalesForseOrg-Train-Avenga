public with sharing class ItCompanyDAO {

    /*   getAvailableDeveloperIds |	Set<Id>	| -	|get developer ids who has assigned less then into 5
       billable projects (use Developer__c.Total_Billable_Projects__c field))
     */
    public static Set<Id> getAvailableDeveloperIds() {

        Set<Id> ids = new Set<Id>();

        List<Developer__c> listDevelopers = [SELECT Id FROM Developer__c WHERE Developer__c.Total_Billable_Projects__c < 5];
        for (Developer__c developer : listDevelopers) {
            ids.add(developer.Id);
        }
        return ids;
    }
    //----------------------------------------------------------------------------------------------------------------------


    // Task : getUnassignedDeveloperIds |	Set<Id>	| -	| get developer ids who has assigned into 0 projects
    public static Set<Id> getUnassignedDeveloperIds() {

        //Creating List of developers without any related projects
        List<Developer__c> listAllDevelopers = [
                SELECT Id, Name
                FROM Developer__c
                WHERE Id NOT IN (SELECT Developer__c FROM Project_Assignment__c)
        ];

        return (new Map<Id, Developer__c>(listAllDevelopers)).keySet();
    }
    //----------------------------------------------------------------------------------------------------------------------

    /*getClients |	List<Client__c>	| Integer limitNumber, Integer offsetNumber	| get Client__c records
 with LIMIT and OFFSET*/
    public static List<Client__c> getClients(Integer limitNumber, Integer offsetNumber) {
        List<Client__c> listOfClients = [SELECT Id,Name FROM Client__c LIMIT :limitNumber OFFSET :offsetNumber];
        return listOfClients;
    }
    //----------------------------------------------------------------------------------------------------------------------

    /*getDevelopers |	List<Developer__c>	| Set<Id> developerId, Integer limitNumber, Integer offsetNumber	|
dynamic query. If any of params is null - do not add respective condition to query.*/
    public static List<Developer__c> getDevelopers(Set<Id> developerId, Integer limitNumber, Integer offsetNumber) {

        String dynamicQuery = 'SELECT Id,Name FROM Developer__c WHERE Id IN :developerId ';
        if (limitNumber != null) {
            dynamicQuery += 'LIMIT :limitNumber ';
        }
        if (offsetNumber != null) {
            dynamicQuery += 'OFFSET :offsetNumber ';
        }

        return Database.query(dynamicQuery);
    }
    //----------------------------------------------------------------------------------------------------------------------

    /* getClientTotalActiveProjects	| Map<Id, Integer>	| Set<Id> clientIds	| return map, where key = client id,
             value = number of active projects.*/
    public static Map<Id, Integer> getClientTotalActiveProjects(Set<Id> clientIds) {


        List<Client__c> allClientsIds = [
                SELECT Id, (SELECT Id FROM Projects__r WHERE Active__c = TRUE)
                FROM Client__c
                WHERE Id IN :clientIds
        ];
        Map<Id, Integer> result = new Map<Id, Integer>();
        for (Client__c client : allClientsIds) {
            result.put(client.Id, client.Projects__r.size());
        }
        return result;
    }

//    List<Client__c>startMap  =[SELECT Id FROM Client__c LIMIT 5];
//    Set<Id> resultIds = (new Map<Id,SObject>(startMap)).keySet();
//
//    System.debug(ItCompanyDAO.getClientTotalActiveProjects(resultIds));

/*
Method name	| Result type  |	Input parameters |	Description
getDeveloperTotalBillableProjects |	Map<Id, Integer>	| Set<Id> developerIds	| return map, where key = developer id,
value = number of billable assigned projects.*/

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

//    List<Developer__c>startMap = [SELECT Id FROM Developer__c LIMIT 3];
//    Set<Id> resultIds = (new Map<Id, SObject>(startMap)).keySet();
//
//    System.debug(ItCompanyDAO.getDeveloperTotalBillableProjects(resultIds));
}