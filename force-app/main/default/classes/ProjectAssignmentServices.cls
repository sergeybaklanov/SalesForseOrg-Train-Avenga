public with sharing class ProjectAssignmentServices {
   public static Map<String, List<Project_Assignment__c>> 
    groupUniqueProjectAssigments(List<Project_Assignment__c> projects){
       
        Set<String> keysProjectDeveloper = new Set<String>();
        Map<String, List<Project_Assignment__c>> result = new Map<String, List<Project_Assignment__c>>();

            for(Project_Assignment__c recordAssignment : projects){
                String key = recordAssignment.Project__c+'-'+recordAssignment.Developer__c;
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
 value - List Of Project_Assignment__c records;*/