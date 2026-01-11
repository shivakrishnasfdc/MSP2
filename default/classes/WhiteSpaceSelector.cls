public with sharing class WhiteSpaceSelector extends fflib_SObjectSelector {
    public static WhiteSpaceSelector newInstance() {
        return (WhiteSpaceSelector) Application.Selector.newInstance(White_Space__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space__c.Id,
            White_Space__c.Name,
            White_Space__c.Account_Plan__c,
            White_Space__c.White_Space_Template__c,
            White_Space__c.AreColumnsFiltered__c,
            White_Space__c.AreRowsFiltered__c,
            White_Space__c.AreCellsFiltered__c,
            White_Space__c.AreUnrelatedCellsFiltered__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space__c> selectById(Set<ID> idSet) {
        return (List<White_Space__c>) selectSObjectsById(idSet);
    }
    public List<White_Space__c> selectByTemplateId(Id templateId) {
        fflib_QueryFactory query = newQueryFactory();
        return Database.query(query.setCondition('White_Space_Template__c = :templateId').toSOQL());
    }

    public List<White_Space__c> selectWithGridDataById(Set<ID> idSet) {
        fflib_QueryFactory query = newWhitespaceQueryFactory();

        return Database.query(query.setCondition('Id IN :idSet').toSOQL());
    }

    public List<White_Space__c> selectWithGridDataByAccountPlanId(Set<ID> accountPlanIds) {
        fflib_QueryFactory query = newWhitespaceQueryFactory();

        return Database.query(query.setCondition('Account_Plan__c IN :accountPlanIds').toSOQL());
    }

    public White_Space__c selectFirstWithGridDataByAccountPlanId(Id accountPlanId) {
        fflib_QueryFactory query = newWhitespaceQueryFactory();
        query.setCondition('Account_Plan__c = :accountPlanId');
        query.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        query.setLimit(1);

        List<White_Space__c> queryResults = Database.query(query.toSOQL());
        return (White_Space__c) UtilityForList.first(queryResults);
    }

    public List<White_Space__c> selectFirstByAccountPlanId(Id accountPlanId) {
        fflib_QueryFactory query = newQueryFactory();
        List<White_Space__c> queryResults = Database.query(
            query.setCondition('Account_Plan__c = :accountPlanId').toSOQL()
        );
        return queryResults;
    }

    public White_Space__c selectById(Id whiteSpaceId) {
        fflib_QueryFactory query = newWhitespaceQueryFactory();
        List<White_Space__c> queryResults = Database.query(
            query.setCondition('Id = :whiteSpaceId').setLimit(1).toSOQL()
        );
        return (White_Space__c) UtilityForList.first(queryResults);
    }

    private fflib_QueryFactory newWhitespaceQueryFactory() {
        fflib_QueryFactory query = newQueryFactory();
        new WhiteSpaceTemplateSelector()
            .configureQueryFactoryFields(
                query,
                White_Space__c.White_Space_Template__c.getDescribe().getRelationshipName()
            );
        new AccountPlanSelector()
            .configureQueryFactoryFields(query, White_Space__c.Account_Plan__c.getDescribe().getRelationshipName());

        new WhiteSpaceRowSelector().addQueryFactorySubselect(query);
        new WhiteSpaceColumnSelector().addQueryFactorySubselect(query);

        return query;
    }
}