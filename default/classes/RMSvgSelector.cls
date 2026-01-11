public with sharing class RMSvgSelector extends fflib_SObjectSelector {
    public static RMSvgSelector newInstance() {
        return (RMSvgSelector) Application.Selector.newInstance(RM_Svg__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            RM_Svg__c.Id,
            RM_Svg__c.Name,
            RM_Svg__c.Fill__c,
            RM_Svg__c.Geometry_String__c,
            RM_Svg__c.Label__c,
            RM_Svg__c.Order__c,
            RM_Svg__c.Used_in_all_account_plans__c,
            RM_Svg__c.Used_in_all_relationship_maps__c,
            RM_Svg__c.View_Box__c,
            RM_Svg__c.For_Automation_Use_Only__c,
            RM_Svg__c.Contact_Field_API_Name__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return RM_Svg__c.sObjectType;
    }

    public override String getOrderBy() {
        return RM_Svg__c.Order__c.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<RM_Svg__c> selectById(Set<Id> idSet) {
        return (List<RM_Svg__c>) selectSObjectsById(idSet);
    }

    public List<RM_Svg__c> selectByRelationshipMaps(
        Set<Id> relationshipMapIdSet,
        Boolean hasAccountPlanSetting,
        Id accountPlanId
    ) {
        List<RM_Svg_Map_Association__c> svgsAssocs = Database.query(
            'select RM_Svg__c from RM_Svg_Map_Association__c where Relationship_Map__c in :relationshipMapIdSet'
        );
        Set<Id> svgIdSet = new Set<Id>();

        if (accountPlanId != null) {
            List<RM_Svg_Account_Plan_Association__c> svgAPAssocs = Database.query(
                'select RM_Svg__c from RM_Svg_Account_Plan_Association__c where Account_Plan__c = :accountPlanId'
            );

            for (RM_Svg_Account_Plan_Association__c svgAPAssoc : svgAPAssocs) {
                svgIdSet.add(svgAPAssoc.RM_Svg__c);
            }
        }

        for (RM_Svg_Map_Association__c svgsAssoc : svgsAssocs) {
            svgIdSet.add(svgsAssoc.RM_Svg__c);
        }

        String condition1 = 'Used_in_all_relationship_maps__c = true OR id in :svgIdSet';
        if (hasAccountPlanSetting) {
            condition1 = 'Used_in_all_account_plans__c = true OR id in :svgIdSet';
        }

        return Database.query(newQueryFactory().setCondition(condition1).toSOQL());
    }

    public List<RM_Svg__c> selectByAccountPlans(Set<Id> accountPlanIdSet) {
        List<RM_Svg_Account_Plan_Association__c> svgsAssocs = Database.query(
            'select RM_Svg__c from RM_Svg_Account_Plan_Association__c where Account_Plan__c in :accountPlanIdSet'
        );
        Set<Id> svgIdSet = new Set<Id>();
        for (RM_Svg_Account_Plan_Association__c svgsAssoc : svgsAssocs) {
            svgIdSet.add(svgsAssoc.RM_Svg__c);
        }

        return Database.query(
            newQueryFactory().setCondition('Used_in_all_account_plans__c = true OR id in :svgIdSet').toSOQL()
        );
    }
}