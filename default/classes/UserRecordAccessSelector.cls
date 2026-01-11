public with sharing class UserRecordAccessSelector extends fflib_SObjectSelector {
    public static UserRecordAccessSelector newInstance() {
        return (UserRecordAccessSelector) Application.Selector.newInstance(UserRecordAccess.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            UserRecordAccess.HasAllAccess,
            UserRecordAccess.HasDeleteAccess,
            UserRecordAccess.HasEditAccess,
            UserRecordAccess.HasReadAccess
        };
    }

    public Schema.SObjectType getSObjectType() {
        return UserRecordAccess.sObjectType;
    }

    public override String getOrderBy() {
        return UserRecordAccess.RecordId.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<UserRecordAccess> selectById(Set<Id> ids) {
        return (List<UserRecordAccess>) selectSObjectsById(ids);
    }

    public List<UserRecordAccess> selectByRecordId(Set<Id> recordIds) {
        String userId = UserInfo.getUserId(); //NOPMD - False positive, used in query condition below
        return Database.query(
            newQueryFactory()
                .selectField('RecordId')
                .setCondition('UserId = :userId AND RecordId IN :recordIds')
                .toSOQL()
        );
    }
}