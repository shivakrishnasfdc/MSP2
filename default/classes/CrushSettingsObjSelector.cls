public with sharing class CrushSettingsObjSelector extends fflib_SObjectSelector {
    public static CrushSettingsObjSelector newInstance() {
        return (CrushSettingsObjSelector) Application.Selector.newInstance(Crush_Settings_Obj__c.sObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Crush_Settings_Obj__c.Id,
            Crush_Settings_Obj__c.Name,
            Crush_Settings_Obj__c.LastModifiedDate,
            Crush_Settings_Obj__c.Account_Plan_Transfer__c,
            Crush_Settings_Obj__c.Account_Plan_Transfer_User__c,
            Crush_Settings_Obj__c.Allow_Add_Tasks_From_Objective_Component__c,
            Crush_Settings_Obj__c.Enable_Objective_Stage_Based_On_Tasks__c,
            Crush_Settings_Obj__c.Auto_Create_Relationship_Maps__c,
            Crush_Settings_Obj__c.Auto_Create_Stakeholder_Maps__c,
            Crush_Settings_Obj__c.Can_Create_Objects_In_Cross_Sell__c,
            Crush_Settings_Obj__c.Contacts_Ancestry_Levels__c,
            Crush_Settings_Obj__c.Enable_Notifications__c,
            Crush_Settings_Obj__c.Goal_Updated__c,
            Crush_Settings_Obj__c.Key_Date_Updated__c,
            Crush_Settings_Obj__c.Key_Stakeholder_Updated__c,
            Crush_Settings_Obj__c.Objective_High_Color__c,
            Crush_Settings_Obj__c.Objective_Low_Color__c,
            Crush_Settings_Obj__c.Objective_Low_Middle_Boundary__c,
            Crush_Settings_Obj__c.Objective_Middle_Color__c,
            Crush_Settings_Obj__c.Objective_Middle_High_Boundary__c,
            Crush_Settings_Obj__c.Objective_Task_High_Color__c,
            Crush_Settings_Obj__c.Objective_Task_Low_Color__c,
            Crush_Settings_Obj__c.Objective_Task_Low_Middle_Boundary__c,
            Crush_Settings_Obj__c.Objective_Task_Middle_Color__c,
            Crush_Settings_Obj__c.Objective_Task_Middle_High_Boundary__c,
            Crush_Settings_Obj__c.Objectives_Updated__c,
            Crush_Settings_Obj__c.Opportunities_Added__c,
            Crush_Settings_Obj__c.Org_Chart_Default_Fields__c,
            Crush_Settings_Obj__c.Plan_Overview_Updated__c,
            Crush_Settings_Obj__c.Relationship_Map_Default_Fields__c,
            Crush_Settings_Obj__c.Score_High_Color__c,
            Crush_Settings_Obj__c.Score_Low_Color__c,
            Crush_Settings_Obj__c.Score_Low_Mid_Boundary__c,
            Crush_Settings_Obj__c.Score_Mid_Color__c,
            Crush_Settings_Obj__c.Score_Mid_High_Boundary__c,
            Crush_Settings_Obj__c.Status_Updated__c,
            Crush_Settings_Obj__c.Support_Colors_Long__c,
            Crush_Settings_Obj__c.SWOT_Analysis_Updated__c,
            Crush_Settings_Obj__c.Team_Member_Added_Removed__c,
            Crush_Settings_Obj__c.Team_Member_Permission_Updated__c,
            Crush_Settings_Obj__c.Type__c,
            Crush_Settings_Obj__c.Use_System_Create_Task_Modal__c,
            Crush_Settings_Obj__c.User__c,
            Crush_Settings_Obj__c.Use_Account_Team_Permissions__c,
            Crush_Settings_Obj__c.Use_Default_Account_Plan_Score__c,
            Crush_Settings_Obj__c.Use_Percentage_Account_Plan_Score__c,
            Crush_Settings_Obj__c.Task_Objects_Related_To_Account__c,
            Crush_Settings_Obj__c.Task_Objects_Related_To_Account_Plan__c,
            Crush_Settings_Obj__c.Task_Objects_Related_Exclusions__c,
            CRUSH_Settings_Obj__c.WS_Object_Filter__c,
            CRUSH_Settings_Obj__c.Disabled_Objective_Sort_Button__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Crush_Settings_Obj__c.sObjectType;
    }

    public override String getOrderBy() {
        return Crush_Settings_Obj__c.LastModifiedDate.getDescribe().getName() + ' DESC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Crush_Settings_Obj__c> selectOrgSettingsObj() {
        return new SystemSelector().selectOrgSettingsObj(this);
    }

    public List<Crush_Settings_Obj__c> selectUserSettingsObj(Id userId) {
        return new SystemSelector().selectUserSettingsObj(this, userId);
    }

    /******************************
     *   PRIVATE SYSTEM SELECTOR
     ******************************/

    private with sharing class SystemSelector {
        public List<Crush_Settings_Obj__c> selectOrgSettingsObj(CrushSettingsObjSelector selector) {
            return Database.query(
                selector.newQueryFactory(false, false, true).setCondition('Type__c = \'Org\'').setLimit(1).toSOQL()
            );
        }

        public List<Crush_Settings_Obj__c> selectUserSettingsObj(CrushSettingsObjSelector selector, Id userId) {
            return Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition('Type__c = \'User\' AND User__c = :userId')
                    .setLimit(1)
                    .toSOQL()
            );
        }
    }
}