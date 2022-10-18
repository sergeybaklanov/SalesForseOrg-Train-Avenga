/**
 * Created by User on 18.10.2022.
 */

trigger TestTrigger on Test_Object__c (after insert ,after update,before update ) {
    if(Trigger.isInsert) {
        if (Trigger.isBefore) {
            for (Test_Object__c objBefore : Trigger.old) {
                objBefore.Name = 'Other';
            }
        }
        if (Trigger.isAfter) {
            for (Test_Object__c old : Trigger.old) {
                for (Test_Object__c newN : Trigger.new) {
                    System.debug('Old name = ' + old.Name + ' New name = ' + newN);
                }
            }
        }
    }
}