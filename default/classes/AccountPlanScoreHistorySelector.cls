public with sharing class AccountPlanScoreHistorySelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static AccountPlanScoreHistorySelector newInstance() {
        return (AccountPlanScoreHistorySelector) Application.Selector.newInstance(
            pq_Account_Plan_Score_History__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Account_Plan_Score_History__c.Id,
            pq_Account_Plan_Score_History__c.Account_Plan__c,
            pq_Account_Plan_Score_History__c.Score__c,
            pq_Account_Plan_Score_History__c.Year_Week__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Account_Plan_Score_History__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Account_Plan_Score_History__c.pqcrush__Year_Week__c.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Account_Plan_Score_History__c> selectById(Set<Id> ids) {
        return (List<pq_Account_Plan_Score_History__c>) selectSObjectsById(ids);
    }

    public List<pq_Account_Plan_Score_History__c> selectByYearWeek(Decimal yearWeek) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        return Database.query(queryFactory.setCondition('Year_Week__c = :yearWeek').toSOQL());
    }

    public List<pq_Account_Plan_Score_History__c> selectByAccountPlansAfterDate(Set<Id> accountPlanIds, DateTime dt) {
        fflib_QueryFactory queryFactory = newQueryFactory();

        fflib_SObjectSelector accountPlanSelector = new AccountPlanSelector();
        accountPlanSelector.configureQueryFactoryFields(queryFactory, 'Account_Plan__r');

        return Database.query(
            queryFactory.setCondition('LastModifiedDate > :dt AND pqcrush__Account_Plan__c IN :accountPlanIds').toSOQL()
        );
    }
}