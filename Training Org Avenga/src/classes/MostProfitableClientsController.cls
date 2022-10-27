/**
 * Created by User on 23.10.2022.
 */

public class MostProfitableClientsController {

    @AuraEnabled
    public static List <Client__c> getMostProfitableClients(Integer limitClients) {
        return [
                SELECT Id,Name,Email__c,Total_Active_Projects__c,Budget__c
                FROM Client__c
                WHERE Budget__c != NULL
                ORDER BY Budget__c DESC
                LIMIT :limitClients
        ];
    }
}