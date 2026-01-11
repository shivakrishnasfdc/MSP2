public with sharing class AccountPlanOpportunitySelector extends AccountPlanChildSelector {
    public static final Set<String> HISTORY_FIELDS = new Set<String>{ 'Parent.Opportunity__r.Name' };

    public AccountPlanOpportunitySelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    /******************************
     *      STATIC METHODS
     ******************************/

    public static AccountPlanOpportunitySelector newInstance() {
        return (AccountPlanOpportunitySelector) Application.Selector.newInstance(
            Account_Plan_Opportunity__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account_Plan_Opportunity__c.Id,
            Account_Plan_Opportunity__c.Account_Plan__c,
            Account_Plan_Opportunity__c.Opportunity__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account_Plan_Opportunity__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Account_Plan_Opportunity__c> selectById(Set<Id> ids) {
        return Database.query(newQueryFactory().setCondition('Id IN :ids').toSOQL());
    }

    /**
     * Returns items in accountPlanOpportunitiesList that are duplicates of records already in the system.
     * Records are considered duplicates if they have the same Opportunity__c and Account_Plan__c.
     * @param  accountPlanOpportunitiesList A list of Account_Plan_Opportunity__c objects to check against existing records.
     * @return                              Any of the original Account Plan Opportunity records that are duplicates.
     */
    public List<Account_Plan_Opportunity__c> selectDuplicatesAsSystem(
        List<Account_Plan_Opportunity__c> accountPlanOpportunitiesList
    ) {
        return new SystemSelector().selectDuplicates(this, accountPlanOpportunitiesList);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    private with sharing class SystemSelector {
        public List<Account_Plan_Opportunity__c> selectDuplicates(
            AccountPlanOpportunitySelector selector,
            List<Account_Plan_Opportunity__c> accountPlanOpportunitiesList
        ) {
            Set<Id> accountPlanIds = new Set<Id>();
            Set<Id> opportunityIds = new Set<Id>();
            Map<String, Account_Plan_Opportunity__c> accountPlanOpportunitiesByUniqueKey = new Map<String, Account_Plan_Opportunity__c>();

            for (Account_Plan_Opportunity__c accountPlanOpportunity : accountPlanOpportunitiesList) {
                accountPlanIds.add(accountPlanOpportunity.Account_Plan__c);
                opportunityIds.add(accountPlanOpportunity.Opportunity__c);
                accountPlanOpportunitiesByUniqueKey.put(
                    AccountPlanOpportunities.getUniqueKey(accountPlanOpportunity),
                    accountPlanOpportunity
                );
            }

            List<Account_Plan_Opportunity__c> potentialDuplicates = Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition('Account_Plan__c IN :accountPlanIds ' + 'AND Opportunity__c IN :opportunityIds')
                    .toSOQL()
            );

            Account_Plan_Opportunity__c duplicateAccountPlanOpportunity;
            List<Account_Plan_Opportunity__c> duplicates = new List<Account_Plan_Opportunity__c>();
            for (Account_Plan_Opportunity__c potentialDuplicate : potentialDuplicates) {
                duplicateAccountPlanOpportunity = accountPlanOpportunitiesByUniqueKey.get(
                    AccountPlanOpportunities.getUniqueKey(potentialDuplicate)
                );

                if (
                    duplicateAccountPlanOpportunity != null &&
                    potentialDuplicate.Id != duplicateAccountPlanOpportunity.Id
                ) {
                    duplicates.add(duplicateAccountPlanOpportunity);
                }
            }

            return duplicates;
        }

        public List<Account_Plan__c> selectById(AccountPlanSelector selector, Set<Id> ids) {
            return Database.query(selector.newQueryFactory().setCondition('id in :ids').toSOQL());
        }
    }
}