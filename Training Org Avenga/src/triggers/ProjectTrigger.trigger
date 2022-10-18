/**
 * Created by User on 18.10.2022.
 */

trigger ProjectTrigger on Project__c (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            Project_TriggerHelper.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}