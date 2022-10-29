/**
 * Created by User on 29.10.2022.
 */

public with sharing class DeveloperCallout {

    public static void makeGetRequest(Id recordId) {

        Http http = new Http();

        HttpRequest request = new HttpRequest();

        request.setMethod('GET');
        request.setHeader('objectName', 'Developer');
        request.setHeader('recordId', recordId);
        request.setEndpoint('https://avenga-school.herokuapp.com/retrieve-record');

        HttpResponse response = http.send(request);

        System.debug(response.getStatusCode());
        System.debug(response.getBody());

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(result);

            Developer__c developer = new Developer__c(Id = recordId);
            developer.Name = (String) result.get('name');
            developer.Total_Billable_Projects__c = (Integer) result.get('totalBillableProjects');
            developer.Last_Sync_Date__c = Datetime.now();
            System.debug('Developer= ' + developer);

            update developer;
        } else {
            throw new DeveloperCalloutException(response.getStatusCode()+' Error in DeveloperCallout');
        }
    }

    public class DeveloperCalloutException extends Exception {

    }
}