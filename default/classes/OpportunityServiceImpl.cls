public with sharing class OpportunityServiceImpl {
    
    public static void createOpportunityPlan(List<Opportunity> newList) {
        List<pqcrush__PQ_Opportunity_Plan__c> oppPlanList = new List<pqcrush__PQ_Opportunity_Plan__c>();
        //String originValue = System.label.Contact_Origin_Value_RMM;
        List<pqcrush__pq_Opportunity_Manager_Setting__c> oppSetting = [Select Id,pqcrush__Create_Opportunity_Plan__c,pqcrush__Opportunity_Setting_Name__c FROM pqcrush__pq_Opportunity_Manager_Setting__c WHERE pqcrush__Opportunity_Setting_Name__c='Opportunity Manager Setting' WITH SECURITY_ENFORCED LIMIT 1];
        if(oppSetting.size() > 0 && oppSetting[0].pqcrush__Create_Opportunity_Plan__c == true){
            for(Opportunity opp : newList){
                pqcrush__PQ_Opportunity_Plan__c oppPlan = new pqcrush__PQ_Opportunity_Plan__c();
                oppPlan.pqcrush__Opportunity__c = opp.Id;
                oppPlan.Name = opp.Name;
                oppPlanList.add(oppPlan);
            }
            if(oppPlanList.size() > 0){
                Database.Insert(oppPlanList, false,Accesslevel.USER_MODE);
            }
        }
    }

}