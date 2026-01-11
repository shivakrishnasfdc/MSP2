public with sharing class ObjectiveOpportunitySelector extends AccountPlanChildSelector {
    public static final Set<String> HISTORY_FIELDS = new Set<String>{ 'Parent.Opportunity__r.Name' };

    public ObjectiveOpportunitySelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    /******************************
     *      STATIC METHODS
     ******************************/

    public static ObjectiveOpportunitySelector newInstance() {
        return (ObjectiveOpportunitySelector) Application.Selector.newInstance(Objective_Opportunity__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Objective_Opportunity__c.Id,
            Objective_Opportunity__c.Objective__c,
            Objective_Opportunity__c.Opportunity__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Objective_Opportunity__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Objective_Opportunity__c> selectById(Set<Id> ids) {
        return Database.query(newQueryFactory().setCondition('Id IN :ids').toSOQL());
    }

    public override List<SObject> selectByAccountPlanIdWithHistory(Set<Id> accountPlanIds, Set<String> extraFields) {
        try {
            fflib_QueryFactory queryFactory = newQueryFactory();
            FFLibHelper.subSelectHistories(queryFactory, extraFields);

            return Database.query(
                queryFactory.setCondition('Objective__r.Account_Plan__c IN :accountPlanIds').toSOQL()
            );
        } catch (Exception e) {
            return new List<SObject>();
        }
    }

    /**
     * Returns items in objectiveOpportunitiesList that are duplicates of records already in the system.
     * Records are considered duplicates if they have the same Opportunity__c and Objective__c.
     * @param  objectiveOpportunitiesList A list of Objective_Opportunity__c objects to check against existing records.
     * @return                            Any of the original Objective Opportunity records that are duplicates.
     */
    public List<Objective_Opportunity__c> selectDuplicatesAsSystem(
        List<Objective_Opportunity__c> objectiveOpportunitiesList
    ) {
        return new SystemSelector().selectDuplicates(this, objectiveOpportunitiesList);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    private with sharing class SystemSelector {
        public List<Objective_Opportunity__c> selectDuplicates(
            ObjectiveOpportunitySelector selector,
            List<Objective_Opportunity__c> objectiveOpportunitiesList
        ) {
            Set<Id> objectiveIds = new Set<Id>();
            Set<Id> opportunityIds = new Set<Id>();
            Map<String, Objective_Opportunity__c> objectiveOpportunitiesByUniqueKey = new Map<String, Objective_Opportunity__c>();

            for (Objective_Opportunity__c objectiveOpportunity : objectiveOpportunitiesList) {
                objectiveIds.add(objectiveOpportunity.Objective__c);
                opportunityIds.add(objectiveOpportunity.Opportunity__c);
                objectiveOpportunitiesByUniqueKey.put(
                    ObjectiveOpportunities.getUniqueKey(objectiveOpportunity),
                    objectiveOpportunity
                );
            }

            List<Objective_Opportunity__c> potentialDuplicates = Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition('Objective__c IN :objectiveIds ' + 'AND Opportunity__c IN :opportunityIds')
                    .toSOQL()
            );

            Objective_Opportunity__c duplicateObjectiveOpportunity;
            List<Objective_Opportunity__c> duplicates = new List<Objective_Opportunity__c>();
            for (Objective_Opportunity__c potentialDuplicate : potentialDuplicates) {
                duplicateObjectiveOpportunity = objectiveOpportunitiesByUniqueKey.get(
                    ObjectiveOpportunities.getUniqueKey(potentialDuplicate)
                );

                if (
                    duplicateObjectiveOpportunity != null &&
                    potentialDuplicate.Id != duplicateObjectiveOpportunity.Id
                ) {
                    duplicates.add(duplicateObjectiveOpportunity);
                }
            }

            return duplicates;
        }
    }
}