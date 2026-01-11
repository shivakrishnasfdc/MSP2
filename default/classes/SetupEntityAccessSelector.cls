public with sharing class SetupEntityAccessSelector extends fflib_SObjectSelector {
    public static SetupEntityAccessSelector newInstance() {
        return (SetupEntityAccessSelector) Application.Selector.newInstance(SetupEntityAccess.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ SetupEntityAccess.Id, SetupEntityAccess.SetupEntityId };
    }

    public Schema.SObjectType getSObjectType() {
        return SetupEntityAccess.sObjectType;
    }

    public override String getOrderBy() {
        return SetupEntityAccess.Id.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<SetupEntityAccess> selectById(Set<Id> idSet) {
        return (List<SetupEntityAccess>) selectSObjectsById(idSet);
    }

    public List<SetupEntityAccess> selectBySetupEntityForCurrentUser(Set<Id> setupEntityIds) {
        Id userId = UserInfo.getUserId(); //NOPMD - False positive, used in query condition

        return Database.query(
            newQueryFactory()
                .setCondition(
                    'SetupEntityId IN :setupEntityIds ' +
                    'AND ParentId IN ( ' +
                    '    SELECT PermissionSetId ' +
                    '    FROM PermissionSetAssignment ' +
                    '    WHERE AssigneeId = :userId ' +
                    ')'
                )
                .toSOQL()
        );
    }
}