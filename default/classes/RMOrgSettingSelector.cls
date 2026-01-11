public with sharing class RMOrgSettingSelector extends fflib_SObjectSelector {
    public static RMOrgSettingSelector newInstance() {
        return (RMOrgSettingSelector) Application.Selector.newInstance(RM_Org_Setting__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            RM_Org_Setting__c.Id,
            RM_Org_Setting__c.Type__c,
            RM_Org_Setting__c.Auto_Layout__c,
            RM_Org_Setting__c.Card_Style__c,
            RM_Org_Setting__c.Create_New_Contact__c,
            RM_Org_Setting__c.Display_Style__c,
            RM_Org_Setting__c.Enable_Drag_Select__c,
            RM_Org_Setting__c.Show_Chart_Settings__c,
            RM_Org_Setting__c.Show_Clone_Relationship_Map__c,
            RM_Org_Setting__c.Is_Group_Global_Scope__c,
            RM_Org_Setting__c.Is_Badge_Global_Scope__c,
            RM_Org_Setting__c.Is_Influence_Support_Global_Scope__c,
            RM_Org_Setting__c.Is_Relationship_Line_Global_Scope__c,
            RM_Org_Setting__c.Is_Reports_To_Global_Scope__c,
            RM_Org_Setting__c.Lead_Tab__c,
            RM_Org_Setting__c.Relationship_Line_Opacity__c,
            RM_Org_Setting__c.Reports_To_Line_Opacity__c,
            RM_Org_Setting__c.Prolifiq_Extended_Tools_URL__c,
            RM_Org_Setting__c.Show_Auto_Manual_Toggle__c,
            RM_Org_Setting__c.Show_Empty_Fields__c,
            RM_Org_Setting__c.Show_Overview__c,
            RM_Org_Setting__c.Show_Parents__c,
            RM_Org_Setting__c.Enable_Contact_Context_Menu__c,
            RM_Org_Setting__c.Enable_Map_Member_Context_Menu__c,
            RM_Org_Setting__c.Enable_Omni_Viewer_Context_Menu__c,
            RM_Org_Setting__c.Enable_Group_Selection_Context_Menu__c,
            RM_Org_Setting__c.Enable_Suggested_Contacts_For_RM__c,
            RM_Org_Setting__c.Enable_Sugg_Con_For_RMSettings__c,
            RM_Org_Setting__c.Operator__c,
            RM_Org_Setting__c.User_Tab__c,
            RM_Org_Setting__c.pqcrush__contact_limit__c,
            RM_Org_Setting__c.rm_contact_limit__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return RM_Org_Setting__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<RM_Org_Setting__c> selectById(Set<Id> ids) {
        return (List<RM_Org_Setting__c>) selectSObjectsById(ids);
    }

    public List<RM_Org_Setting__c> selectByType(String type) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Type__c = :type');
        return Database.query(query.toSOQL());
    }
}