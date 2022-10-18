
//The system should prevent duplicate Project Assignments (with the same Developer and Project).

trigger Project_AssignmentTrigger on Project_Assignment__c (before insert, before update, after insert ) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Project_AssignmentTriggerHelper.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            Project_AssignmentTriggerHelper.beforeUpdate(Trigger.new);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            Project_AssignmentTriggerHelper.afterInsert(Trigger.new);
        }
    }
}