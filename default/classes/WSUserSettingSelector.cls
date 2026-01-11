public with sharing class WSUserSettingSelector extends fflib_SObjectSelector {
    public static WSUserSettingSelector newInstance() {
        return (WSUserSettingSelector) Application.Selector.newInstance(WS_User_Setting__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WS_User_Setting__c.Id,
            WS_User_Setting__c.Row_Filters__c,
            WS_User_Setting__c.Column_Filters__c,
            WS_User_Setting__c.Amount_Type_Filters__c,
            WS_User_Setting__c.White_Space__c,
            WS_User_Setting__c.User__c,
            WS_User_Setting__c.Highlight_Filters__c,
            WS_User_Setting__c.Show_Empty_Columns__c,
            WS_User_Setting__c.Show_Empty_Rows__c,
            WS_User_Setting__c.Show_Populated_Columns__c,
            WS_User_Setting__c.Show_Populated_Rows__c,
            WS_User_Setting__c.Show_Unhighlighted__c,
            WS_User_Setting__c.Zoom_Index__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return WS_User_Setting__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<WS_User_Setting__c> selectById(Set<ID> idSet) {
        return (List<WS_User_Setting__c>) selectSObjectsById(idSet);
    }

    public List<WS_User_Setting__c> selectByWhitespaceId(Id whitespaceId) {
        Id userId = UserInfo.getUserId(); //NOPMD - False positive, used in query condition below
        fflib_QueryFactory query = newQueryFactory();
        return Database.query(query.setCondition('White_Space__c = :whitespaceId AND User__c = :userId').toSOQL());
    }
}