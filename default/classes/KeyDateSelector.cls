public with sharing class KeyDateSelector extends AccountPlanChildSelector {
    public KeyDateSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    /******************************
     *      STATIC METHODS
     ******************************/

    public static KeyDateSelector newInstance() {
        return (KeyDateSelector) Application.Selector.newInstance(Key_Date__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Key_Date__c.Id,
            Key_Date__c.Name,
            Key_Date__c.Account_Plan__c,
            Key_Date__c.Date__c,
            Key_Date__c.Reminder__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Key_Date__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Key_Date__c> selectById(Set<Id> ids) {
        return (List<Key_Date__c>) selectSObjectsById(ids);
    }

    public List<Key_Date__c> selectWithRemindersBetween(Date fromDate, Date toDate) {
        return Database.query(
            newQueryFactory()
                .setCondition('Reminder__c != NULL AND Date__c >= :fromDate AND Date__c < :toDate')
                .toSOQL()
        );
    }

    public List<Key_Date__c> selectWithRemindersBetweenAsSystem(Date fromDate, Date toDate) {
        return new SystemSelector().selectWithRemindersBetween(this, fromDate, toDate);
    }

    /**
     * Returns a list of Key_Date__c records that correspond to the given
     * set of Account Plan Ids
     * @param accountPlanIds The account plans
     * @return List<Key_Date__c> The key dates
     */
    public List<Key_Date__c> selectByAccountPlanId(Set<Id> accountPlanIds) {
        return Database.query(newQueryFactory().setCondition('Account_Plan__c IN :accountPlanIds').toSOQL());
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    private with sharing class SystemSelector {
        public List<Key_Date__c> selectWithRemindersBetween(KeyDateSelector selector, Date fromDate, Date toDate) {
            return Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition('Reminder__c != NULL AND Date__c >= :fromDate AND Date__c < :toDate')
                    .toSOQL()
            );
        }
    }
}