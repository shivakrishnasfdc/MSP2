public with sharing class RMSvgNodeAssociationSelector extends fflib_SObjectSelector {
    public static RMSvgNodeAssociationSelector newInstance() {
        return (RMSvgNodeAssociationSelector) Application.Selector.newInstance(RM_Svg_Node_Association__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            RM_Svg_Node_Association__c.Id,
            RM_Svg_Node_Association__c.Key__c,
            RM_Svg_Node_Association__c.RM_Svg__c,
            RM_Svg_Node_Association__c.Account_Plan__c,
            RM_Svg_Node_Association__c.Relationship_Map__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return RM_Svg_Node_Association__c.sObjectType;
    }

    public override String getOrderBy() {
        return 'pqcrush__RM_Svg__r.pqcrush__Order__c ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<RM_Svg_Node_Association__c> selectById(Set<Id> ids) {
        return (List<RM_Svg_Node_Association__c>) selectSObjectsById(ids);
    }

    public List<RM_Svg_Node_Association__c> selectByKeysGlobalForSvgs(List<RM_Svg__c> svgs, Set<String> keys) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'pqcrush__Account_Plan__c = null AND pqcrush__Relationship_Map__c = null AND Key__c in :keys AND pqcrush__RM_Svg__c in : svgs'
            );
        return Database.query(query.toSOQL());
    }

    public List<RM_Svg_Node_Association__c> selectByKeysLocalForSvgs(
        Id mapOrAccountPlanId,
        List<RM_Svg__c> svgs,
        Set<String> keys
    ) {
        if (mapOrAccountPlanId == null) {
            return new List<RM_Svg_Node_Association__c>();
        }

        String condition =
            mapOrAccountPlanId.getSobjectType() +
            ' = :mapOrAccountPlanId AND Key__c in :keys AND pqcrush__RM_Svg__c in : svgs';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition);
        return Database.query(query.toSOQL());
    }

    public List<RM_Svg_Node_Association__c> selectByKeysGlobal(Set<String> keys) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'pqcrush__Account_Plan__c = null AND pqcrush__Relationship_Map__c = null AND Key__c in :keys'
            );
        return Database.query(query.toSOQL());
    }

    public List<RM_Svg_Node_Association__c> selectByKeysLocal(Id mapOrAccountPlanId, Set<String> keys) {
        if (mapOrAccountPlanId == null) {
            return new List<RM_Svg_Node_Association__c>();
        }

        String condition = mapOrAccountPlanId.getSobjectType() + ' = :mapOrAccountPlanId AND Key__c in :keys';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition);
        return Database.query(query.toSOQL());
    }

    public List<RM_Svg_Node_Association__c> selectByKeysGlobalWithAutomation(Set<String> keys, Boolean automation) {
        fflib_QueryFactory query = newQueryFactory();

        fflib_SObjectSelector rmsvgSelector = new RMSvgSelector();
        rmsvgSelector.configureQueryFactoryFields(query, 'RM_Svg__r');

        return Database.query(
            query.setCondition(
                    '(pqcrush__Account_Plan__c = null AND pqcrush__Relationship_Map__c = null AND Key__c in :keys) AND RM_Svg__r.For_Automation_Use_Only__c = :automation'
                )
                .toSOQL()
        );
    }

    public List<RM_Svg_Node_Association__c> selectByKeysLocalWithAutomation(
        Id mapOrAccountPlanId,
        Set<String> keys,
        Boolean automation
    ) {
        if (mapOrAccountPlanId == null) {
            return new List<RM_Svg_Node_Association__c>();
        }

        String condition = '(' + mapOrAccountPlanId.getSobjectType() + ' = :mapOrAccountPlanId AND Key__c in :keys)';

        fflib_QueryFactory query = newQueryFactory();

        fflib_SObjectSelector rmsvgSelector = new RMSvgSelector();
        rmsvgSelector.configureQueryFactoryFields(query, 'RM_Svg__r');

        return Database.query(
            query.setCondition(condition + ' AND RM_Svg__r.For_Automation_Use_Only__c = :automation').toSOQL()
        );
    }
}