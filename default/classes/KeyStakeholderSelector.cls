public with sharing class KeyStakeholderSelector extends AccountPlanChildSelector {
    public static final Set<String> HISTORY_FIELDS = new Set<String>{ 'Parent.Contact__r.Name' };

    public KeyStakeholderSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    /******************************
     *      STATIC METHODS
     ******************************/

    public static KeyStakeholderSelector newInstance() {
        return (KeyStakeholderSelector) Application.Selector.newInstance(Key_Stakeholder__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Key_Stakeholder__c.Id,
            Key_Stakeholder__c.Account_Plan__c,
            Key_Stakeholder__c.Contact__c,
            Key_Stakeholder__c.ContactFirstName__c,
            Key_Stakeholder__c.ContactLastName__c,
            Key_Stakeholder__c.ReportsToId__c,
            Key_Stakeholder__c.InfluenceId__c,
            Key_Stakeholder__c.SupportId__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Key_Stakeholder__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Key_Stakeholder__c> selectById(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Key_Stakeholder__c>();
        }

        Set<String> queryFields = new Set<String>{
            'pqcrush__Contact__r.Title',
            'pqcrush__Account_Plan__r.Name',
            'pqcrush__Account_Plan__r.Status__c'
        };

        fflib_QueryFactory keyStakeholderQueryFactory = getQueryFactoryWithRelatedContacts().selectFields(queryFields);

        return Database.query(keyStakeholderQueryFactory.setCondition('Id IN :ids').toSOQL());
    }

    public List<Key_Stakeholder__c> selectByContactId(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Key_Stakeholder__c>();
        }

        Set<String> queryFields = new Set<String>{
            'pqcrush__Contact__r.Title',
            'pqcrush__Account_Plan__r.Name',
            'pqcrush__Account_Plan__r.Status__c'
        };

        fflib_QueryFactory keyStakeholderQueryFactory = getQueryFactoryWithRelatedContacts().selectFields(queryFields);

        return Database.query(keyStakeholderQueryFactory.setCondition('Contact__c IN :ids').toSOQL());
    }

    public List<Key_Stakeholder__c> selectByIdOrContactIdAndPlanId(
        Set<Id> ids,
        Id planId,
        Set<String> queryFields,
        Set<String> contactFields
    ) {
        fflib_QueryFactory keyStakeholderQueryFactory = getQueryFactoryWithRelatedContacts();

        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        if (contactFields != null) {
            for (String contactField : contactFields) {
                queryFields.add('pqcrush__contact__c.' + contactField);
            }
        }

        queryFields.add('pqcrush__Account_Plan__r.Name');
        queryFields.add('pqcrush__Account_Plan__r.Status__c');

        return Database.query(
            keyStakeholderQueryFactory
                .selectFields(queryFields)
                .setCondition('(Id IN :ids OR Contact__c in :ids) AND Account_Plan__c = :planId')
                .toSOQL()
        );
    }

    public override List<SObject> selectByAccountPlanIdWithHistory(Set<Id> accountPlanIds, Set<String> extraFields) {
        try {
            fflib_QueryFactory queryFactory = newQueryFactory();
            FFLibHelper.subSelectHistories(queryFactory, extraFields);

            return Database.query(
                queryFactory.setCondition(
                        'Account_Plan__c IN :accountPlanIds AND pqcrush__contact__c IN (SELECT Id FROM Contact)'
                    )
                    .toSOQL()
            );
        } catch (Exception e) {
            return new List<SObject>();
        }
    }

    /**
     * Returns a list of Key_Stakeholder__c records that correspond to the given
     * set of Account Plan Ids
     * @param accountPlanIds The account plans
     * @return List<Key_Stakeholder__c> The key stakeholders
     */
    public List<Key_Stakeholder__c> selectByAccountPlanId(Set<Id> accountPlanIds) {
        fflib_QueryFactory keyStakeholderQueryFactory = getQueryFactoryWithRelatedContacts();

        return Database.query(keyStakeholderQueryFactory.setCondition('Account_Plan__c IN :accountPlanIds').toSOQL());
    }

    /**
     * Returns a list of Key_Stakeholder__c records that correspond to the given
     * set of Account Plan Ids
     * @param accountPlanIds The account plans
     * @return List<Key_Stakeholder__c> The key stakeholders
     */
    public List<Key_Stakeholder__c> selectByAccountPlanIdForYourContactsAndSelectFields(
        Set<Id> accountPlanIds,
        Set<String> queryFields,
        Set<String> contactFields
    ) {
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        if (contactFields != null) {
            for (String contactField : contactFields) {
                queryFields.add('pqcrush__contact__c.' + contactField);
            }
        }

        queryFields.add('pqcrush__Account_Plan__r.Name');
        queryFields.add('pqcrush__Account_Plan__r.Status__c');

        fflib_QueryFactory keyStakeholderQueryFactory = getQueryFactoryWithRelatedContacts();

        return Database.query(
            keyStakeholderQueryFactory
                .selectFields(queryFields)
                .setCondition('Account_Plan__c IN :accountPlanIds AND pqcrush__contact__c IN (SELECT Id FROM Contact)')
                .toSOQL()
        );
    }

    /**
     * Returns items in teamMembers that are duplicates of records already in the system.
     * Records are considered duplicates if they have the same Contact__c and Account_Plan__c.
     * @param  stakeholders A list of Key_Stakeholder__c objects to check against existing records.
     * @return              Any of the original keyStakeholder records that are duplicates.
     */
    public List<Key_Stakeholder__c> selectDuplicatesAsSystem(List<Key_Stakeholder__c> stakeholders) {
        return new SystemSelector().selectDuplicates(this, stakeholders);
    }

    /******************************
     *        PRIVATE METHODS
     ******************************/

    private fflib_QueryFactory getQueryFactoryWithRelatedContacts() {
        fflib_QueryFactory keyStakeholderQueryFactory = newQueryFactory();

        fflib_SObjectSelector inflSelector = new InfluenceSelector();
        inflSelector.configureQueryFactoryFields(keyStakeholderQueryFactory, 'InfluenceId__r');

        fflib_SObjectSelector suppSelector = new SupportSelector();
        suppSelector.configureQueryFactoryFields(keyStakeholderQueryFactory, 'SupportId__r');

        ContactSelector.newInstance()
            .configureQueryFactoryFields(
                keyStakeholderQueryFactory,
                Key_Stakeholder__c.Contact__c.getDescribe().getRelationshipName()
            );

        return keyStakeholderQueryFactory.selectField('pqcrush__Contact__r.ReportsToId');
    }

    private with sharing class SystemSelector {
        public List<Key_Stakeholder__c> selectDuplicates(
            KeyStakeholderSelector selector,
            List<Key_Stakeholder__c> stakeholders
        ) {
            Set<Id> accountPlanIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Map<String, Key_Stakeholder__c> stakeholdersByUniqueKey = new Map<String, Key_Stakeholder__c>();

            for (Key_Stakeholder__c keyStakeholder : stakeholders) {
                accountPlanIds.add(keyStakeholder.Account_Plan__c);
                contactIds.add(keyStakeholder.Contact__c);
                stakeholdersByUniqueKey.put(KeyStakeholders.getUniqueKey(keyStakeholder), keyStakeholder);
            }

            List<Key_Stakeholder__c> potentialDuplicates = Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition('Contact__c in :contactIds ' + 'AND Account_Plan__c in :accountPlanIds')
                    .toSOQL()
            );

            List<Key_Stakeholder__c> duplicates = new List<Key_Stakeholder__c>();

            for (Key_Stakeholder__c potentialDuplicate : potentialDuplicates) {
                Key_Stakeholder__c duplicateStakeholder = stakeholdersByUniqueKey.get(
                    KeyStakeholders.getUniqueKey(potentialDuplicate)
                );

                if (duplicateStakeholder != null && potentialDuplicate.Id != duplicateStakeholder.Id) {
                    duplicates.add(duplicateStakeholder);
                }
            }

            return duplicates;
        }
    }
}