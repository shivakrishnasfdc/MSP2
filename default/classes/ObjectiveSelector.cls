public with sharing class ObjectiveSelector extends AccountPlanChildSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static ObjectiveSelector newInstance() {
        return (ObjectiveSelector) Application.Selector.newInstance(Objective__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Objective__c.Id,
            Objective__c.Name,
            Objective__c.Account_Plan__c,
            Objective__c.Description__c,
            Objective__c.Stage__c,
            Objective__c.Stage_Override__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Objective__c.sObjectType;
    }

    public override String getOrderBy() {
        return Objective__c.CreatedDate.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Objective__c> selectById(Set<Id> ids) {
        return Database.query(newQueryFactory().setCondition('Id IN :ids').toSOQL());
    }

    public List<Objective__c> selectByIdAsSystem(Set<Id> ids) {
        return new SystemSelector().selectById(this, ids);
    }

    public List<Objective__c> selectByAccountPlanId(Set<Id> accountPlanIds) {
        fflib_QueryFactory queryFactory = newQueryFactory();

        fflib_SObjectSelector accountPlanSelector = new AccountPlanSelector();
        accountPlanSelector.configureQueryFactoryFields(queryFactory, 'Account_Plan__r');

        return Database.query(queryFactory.setCondition('Account_Plan__c IN :accountPlanIds').toSOQL());
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    private with sharing class SystemSelector {
        public List<Objective__c> selectById(ObjectiveSelector selector, Set<Id> ids) {
            return Database.query(selector.newQueryFactory(false, false, true).setCondition('Id IN :ids').toSOQL());
        }
    }
}