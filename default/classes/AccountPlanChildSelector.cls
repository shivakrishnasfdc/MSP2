public abstract with sharing class AccountPlanChildSelector extends fflib_SObjectSelector {
    public AccountPlanChildSelector() {
        super();
    }

    public AccountPlanChildSelector(Boolean includeFieldSet, Boolean enforceOLS, Boolean enforceFLS) {
        super(includeFieldSet, enforceOLS, enforceFLS);
    }

    /**
     * Returns a list of SObject records with field history that correspond to the given
     * set of Account Plan Ids
     * @param accountPlanIds The account plans
     * @return List<SObject> The related objects
     */
    public List<SObject> selectByAccountPlanIdWithHistory(Set<Id> accountPlanIds) {
        return selectByAccountPlanIdWithHistory(accountPlanIds, new Set<String>());
    }

    /**
     * Returns a list of SObject records with field history that correspond to the given
     * set of Account Plan Ids
     * @param accountPlanIds The account plans
     * @param extraFields.   Extra fields being queried from the history object
     * @return List<SObject> The related objects
     */
    public virtual List<SObject> selectByAccountPlanIdWithHistory(Set<Id> accountPlanIds, Set<String> extraFields) {
        try {
            fflib_QueryFactory queryFactory = newQueryFactory();
            FFLibHelper.subSelectHistories(queryFactory, extraFields);

            return Database.query(queryFactory.setCondition('Account_Plan__c IN :accountPlanIds').toSOQL());
        } catch (Exception e) {
            return new List<SObject>();
        }
    }
}