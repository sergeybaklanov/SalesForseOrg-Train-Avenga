/**
 * Created by User on 28.10.2022.
 */


public with sharing class SalaryRaiseSchedule implements Schedulable {

    public void execute(SchedulableContext param1) {
        SalaryRaiseBatch uca = new SalaryRaiseBatch();
        Id batchId = Database.executeBatch(uca);
    }
}