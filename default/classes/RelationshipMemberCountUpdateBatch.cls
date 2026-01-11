public with sharing class RelationshipMemberCountUpdateBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String status = 'Open';
        String query = 'SELECT Id,pqcrush__Relationship_Members_Count__c FROM pqcrush__Account_Plan__c WHERE pqcrush__Status__c =: status '+status;
        String qry = query.removeEnd(status); 
        return Database.getQueryLocator(String.escapeSingleQuotes(qry));
    }

    public void execute(Database.BatchableContext bc, List<Sobject> scope){
        
        List<Id> accPlanIds = new List<Id>();
        for (sObject obj : scope) {
            accPlanIds.add((Id)obj.get('Id'));
        }
            
        if(accPlanIds.size()>0 && pqcrush__Relationship_Map__c.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.pqcrush__Relationship_Map__c.fields.pqcrush__Map_Member_Count__c.isAccessible()){
           
            List<pqcrush__Account_Plan__c> accountPlansToUpdate = new List<pqcrush__Account_Plan__c>();
            
            for (AggregateResult aggr : [SELECT pqcrush__pq_AccountPlanId__c, SUM(pqcrush__Map_Member_Count__c) cnt 
                                         FROM pqcrush__Relationship_Map__c 
                                         WHERE pqcrush__pq_AccountPlanId__c IN :accPlanIds 
                                         GROUP BY pqcrush__pq_AccountPlanId__c]) {
                                             
                                             pqcrush__Account_Plan__c accountPlan = new pqcrush__Account_Plan__c();
                                             accountPlan.Id = (Id)aggr.get('pqcrush__pq_AccountPlanId__c');
                                             accountPlan.pqcrush__Relationship_Members_Count__c = (Decimal)aggr.get('cnt');
                                             accountPlansToUpdate.add(accountPlan);                             
                                             
                                         }
            
            if (!accountPlansToUpdate.isEmpty() && Schema.sObjectType.pqcrush__Account_Plan__c.isUpdateable() && Schema.sObjectType.pqcrush__Account_Plan__c.fields.pqcrush__Relationship_Members_Count__c.isUpdateable()) {
                try {
                		Database.update(accountPlansToUpdate,true,Accesslevel.USER_MODE);
                    } catch (Exception e) {
                   		System.debug('Error on updating relationship map member count: ' + e.getMessage()); // NOPMD
                	}
            }
            
        }
    }
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc){
        
    }

}