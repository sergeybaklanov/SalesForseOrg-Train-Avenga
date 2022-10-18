public with sharing class ProjectAssignmentServices {

   public static Map<String, List<Project_Assignment__c>> 
    groupUniqueProjectAssignments(List<Project_Assignment__c> projects){
       
        Set<String> keysProjectDeveloper = new Set<String>();
        Map<String, List<Project_Assignment__c>> result = new Map<String, List<Project_Assignment__c>>();

            for(Project_Assignment__c recordAssignment : projects){
                String key = recordAssignment.Project__c+'-'+recordAssignment.Developer__c;
                //String key = recordAssignment.Project__r.Name+'-'+recordAssignment.Developer__r.Name;
                if(result.keySet().contains(key)){
                 result.get(key).add(recordAssignment);
                }
                else {
                    List <Project_Assignment__c> projectAsSListNew = new List <Project_Assignment__c>();
                    projectAsSListNew.add(recordAssignment);
                    result.put(key,projectAsSListNew);
                }
            }
        return result;
    }
}
 
/*Create method groupUniqueProjectAssigments which should return map with Project_Assignment__c grouped 
by Projects and Developers.

Input parameter: List<Project_Assignment__c> projects

Result: Map<String, List<Project_Assignment__c>> - 
key is string representing Project_Assignment__c.Project__c + '-' + Project_Assignment__c.Developer__c,
 value - List Of Project_Assignment__c records;
 ---------------------------------------------------------------------------------

List<Project_Assignment__c> projects = [SELECT Id,Name,Project__c,Developer__c,Project__r.Name,Developer__r.Name FROM Project_Assignment__c];

Map<String, List<Project_Assignment__c>> result=
        ProjectAssignmentServices.groupUniqueProjectAssigments(projects);

Set<String> keys = result.keySet();
for(String key : keys){
    System.debug('ProjectName - DeveloperName = '+key);
   for(Project_Assignment__c project : result.get(key)){
       System.debug('ProjectName = '+project.Name);
   }
}
}*/