//The system should prevent duplicate Project Assignments (with the same Developer and Project).

trigger Project_AssignmentTrigger on Project_Assignment__c (before insert, before update, after insert ) {
    if (Trigger.isBefore) {

        if (Trigger.isInsert) {
            Project_AssignmentTriggerHelper.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            Project_AssignmentTriggerHelper.beforeUpdate(Trigger.new,Trigger.old);
        }

    }
   // Total Billable Projects of the Developer should be recalculated each time
    // a new Project Assignment is created or // Is Billable field is changed on the Project. - Project Trigger
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            Project_AssignmentTriggerHelper.afterInsert(Trigger.new);
        }
    }
}