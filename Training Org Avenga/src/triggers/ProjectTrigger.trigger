/**
 * Created by User on 18.10.2022.
 */

// Total Billable Projects of the Developer should be recalculated each time
// a new Project Assignment is created or Is Billable field is changed on the Project.
trigger ProjectTrigger on Project__c (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            ProjectTriggerHelper.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}