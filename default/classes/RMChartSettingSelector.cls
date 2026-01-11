public with sharing class RMChartSettingSelector extends fflib_SObjectSelector {
    public static RMChartSettingSelector newInstance() {
        return (RMChartSettingSelector) Application.Selector.newInstance(RM_Chart_Setting__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            RM_Chart_Setting__c.Id,
            RM_Chart_Setting__c.Show_Parents__c,
            RM_Chart_Setting__c.Card_Style__c,
            RM_Chart_Setting__c.Display_Style__c,
            RM_Chart_Setting__c.Show_Overview__c,
            RM_Chart_Setting__c.Enable_Drag_Select__c,
            RM_Chart_Setting__c.Auto_Layout__c,
            RM_Chart_Setting__c.Is_Badge_Global_Scope__c,
            RM_Chart_Setting__c.Is_Group_Global_Scope__c,
            RM_Chart_Setting__c.Is_Influence_Support_Global_Scope__c,
            RM_Chart_Setting__c.Is_Relationship_Line_Global_Scope__c,
            RM_Chart_Setting__c.Is_Reports_To_Global_Scope__c,
            RM_Chart_Setting__c.Show_Empty_Fields__c,
            RM_Chart_Setting__c.Relationship_Line_Opacity__c,
            RM_Chart_Setting__c.Reports_To_Line_Opacity__c,
            RM_Chart_Setting__c.Relationship_Map__c,
            RM_Chart_Setting__c.Read_Only__c,
            RM_Chart_Setting__c.Account_Plan__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return RM_Chart_Setting__c.sObjectType;
    }

    // Order by last modified date so that we use the last one
    public override String getOrderBy() {
        return RM_Chart_Setting__c.LastModifiedDate.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<RM_Chart_Setting__c> selectById(Set<Id> ids) {
        return (List<RM_Chart_Setting__c>) selectSObjectsById(ids);
    }

    public List<RM_Chart_Setting__c> selectByObjectId(Set<Id> objectId) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Account_Plan__c IN :objectId OR Relationship_Map__c IN :objectId');
        return Database.query(query.toSOQL());
    }
}