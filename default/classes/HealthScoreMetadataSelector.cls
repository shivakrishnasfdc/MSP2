public with sharing class HealthScoreMetadataSelector extends fflib_SObjectSelector {
    public HealthScoreMetadataSelector() {
        super(false, true, false);
    }

    public static HealthScoreMetadataSelector newInstance() {
        return (HealthScoreMetadataSelector) Application.Selector.newInstance(PQ_AP_Score__mdt.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PQ_AP_Score__mdt.Id,
            PQ_AP_Score__mdt.Count_BP_Low__c,
            PQ_AP_Score__mdt.Count_BP_Mid__c,
            PQ_AP_Score__mdt.Count_BP_High__c,
            PQ_AP_Score__mdt.Date_Field_API_Name__c,
            PQ_AP_Score__mdt.DeveloperName,
            PQ_AP_Score__mdt.Label,
            PQ_AP_Score__mdt.Score_Field_API_Name__c,
            PQ_AP_Score__mdt.Score_Label__c,
            PQ_AP_Score__mdt.Score_Object__c,
            PQ_AP_Score__mdt.Score_BP_Low__c,
            PQ_AP_Score__mdt.Score_BP_Mid__c,
            PQ_AP_Score__mdt.Score_BP_High__c,
            PQ_AP_Score__mdt.Time_BP_Low__c,
            PQ_AP_Score__mdt.Time_BP_Mid__c,
            PQ_AP_Score__mdt.Time_BP_High__c,
            PQ_AP_Score__mdt.Time_BP_Mult_Low__c,
            PQ_AP_Score__mdt.Time_BP_Mult_Mid__c,
            PQ_AP_Score__mdt.Time_BP_Mult_High__c,
            PQ_AP_Score__mdt.Threshold_Limit__c,
            PQ_AP_Score__mdt.Category_Point_Total__c,
            PQ_AP_Score__mdt.Use_Time_Decay__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return PQ_AP_Score__mdt.sObjectType;
    }

    public List<PQ_AP_Score__mdt> selectEnabled() {
        fflib_QueryFactory query = newQueryFactory().setCondition('Score_Object__c = true');
        return Database.query(query.toSOQL());
    }
}