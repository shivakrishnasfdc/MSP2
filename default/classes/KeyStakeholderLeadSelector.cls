public with sharing class KeyStakeholderLeadSelector extends fflib_SObjectSelector {
    public KeyStakeholderLeadSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    public static KeyStakeholderLeadSelector newInstance() {
        return (KeyStakeholderLeadSelector) Application.Selector.newInstance(Key_Stakeholder_Lead__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Key_Stakeholder_Lead__c.Id,
            Key_Stakeholder_Lead__c.Account_Plan__c,
            Key_Stakeholder_Lead__c.Lead__c,
            Key_Stakeholder_Lead__c.Influence__c,
            Key_Stakeholder_Lead__c.Support__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Key_Stakeholder_Lead__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Key_Stakeholder_Lead__c> selectById(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Key_Stakeholder_Lead__c>();
        }
        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedLeads();

        return Database.query(queryFactory.setCondition('Id IN :ids').toSOQL());
    }

    public List<Key_Stakeholder_Lead__c> selectByLeadId(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Key_Stakeholder_Lead__c>();
        }
        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedLeads();

        return Database.query(queryFactory.setCondition('Lead__c IN :ids').toSOQL());
    }

    /**
     * Returns a list of Key_Stakeholder_Lead__c records that correspond to the given
     * set of relationship Map Ids
     * @param accountPlanIds The relationship maps
     * @return List<Key_Stakeholder_Lead__c> The relationship map members
     */
    public List<Key_Stakeholder_Lead__c> selectByAccountPlans(Set<Id> accountPlanIds) {
        if (accountPlanIds == null || accountPlanIds.size() <= 0) {
            return new List<Key_Stakeholder_Lead__c>();
        }

        Set<String> queryFields = getLeadFieds();

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedLeads()
            .selectFields(queryFields)
            .setCondition('pqcrush__Account_Plan__c IN :accountPlanIds AND pqcrush__Lead__c IN (SELECT Id FROM Lead)');

        return Database.query(queryFactory.toSOQL());
    }

    public List<Key_Stakeholder_Lead__c> selectConvertedLeadsByAccountPlans(Set<Id> accountPlanIds) {
        if (accountPlanIds == null || accountPlanIds.size() <= 0) {
            return new List<Key_Stakeholder_Lead__c>();
        }

        Set<String> queryFields = getLeadFieds();

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedLeads()
            .selectFields(queryFields)
            .setCondition(
                'pqcrush__Account_Plan__c IN :accountPlanIds AND pqcrush__Lead__r.ConvertedContactId != NULL AND pqcrush__Lead__c IN (SELECT Id FROM Lead)'
            );

        return Database.query(queryFactory.toSOQL());
    }

    /******************************
     *        PRIVATE METHODS
     ******************************/

    private Set<String> getLeadFieds() {
        Set<String> result = new Set<String>();
        if (Schema.sObjectType.Lead.fields.Email.isAccessible()) {
            result.add('pqcrush__Lead__r.Email');
        }

        if (Schema.sObjectType.Lead.fields.Title.isAccessible()) {
            result.add('pqcrush__Lead__r.Title');
        }

        result.add('pqcrush__Lead__r.Company');
        result.add('pqcrush__Lead__r.FirstName');
        result.add('pqcrush__Lead__r.LastName');
        result.add('pqcrush__Lead__r.ConvertedContactId');

        return result;
    }

    private fflib_QueryFactory getQueryFactoryWithRelatedLeads() {
        fflib_QueryFactory queryFactory = newQueryFactory();

        LeadSelector.newInstance()
            .configureQueryFactoryFields(
                queryFactory,
                Key_Stakeholder_Lead__c.Lead__c.getDescribe().getRelationshipName()
            );

        return queryFactory;
    }
}