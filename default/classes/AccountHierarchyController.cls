public without sharing class AccountHierarchyController {
    
    @AuraEnabled
    public static void updateCustomHierarchy(Boolean isHierarchy,Id recordId){
        pqcrush__Account_Plan__c acplan = new pqcrush__Account_Plan__c();
        acplan.pqcrush__isCustomHierarchy__c = isHierarchy;
        acplan.Id =  recordId;
        System.debug('==acplan=='+acplan);
        Database.update(acplan,true,Accesslevel.USER_MODE);
    }   

    @AuraEnabled
    public static Id getAccountRelationshipMapId(Id accountPlanId){
        return [select id from pqcrush__Account_Relationship_Map__c where pqcrush__Account_Plan_Id__c=:accountPlanId LIMIT 1][0]?.Id;
    }  
//Account Data
    @AuraEnabled
    public static Id getAccountId(Id recordId){
        String sobjectName = recordId.getSObjectType().getDescribe().getName();
        if(sobjectName == 'pqcrush__Account_Plan__c'){
            return [select pqcrush__Account__c from pqcrush__Account_Plan__c where  Id=:recordId LIMIT 1][0]?.pqcrush__Account__c;
        }
        else if(sobjectName == 'pqcrush__pq_Master_Account_Plan__c'){
            return [select pqcrush__Account__c from pqcrush__pq_Master_Account_Plan__c where  Id=:recordId LIMIT 1][0]?.pqcrush__Account__c;
        }
        else{
            return recordId;
        }
        
    }
}

// Id ac =Id.valueOf('a02Oz00081YYMIA2');
// System.debug(AccountHierarchyC00ontroller.getAccountRelationshipMapId(ac));