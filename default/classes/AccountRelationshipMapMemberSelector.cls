public with sharing class AccountRelationshipMapMemberSelector extends fflib_SObjectSelector {
    public static final Set<String> HISTORY_FIELDS = new Set<String>{ 'Parent.Account__r.Name' };
    public AccountRelationshipMapMemberSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    public static AccountRelationshipMapMemberSelector newInstance() {
        return (AccountRelationshipMapMemberSelector) Application.Selector.newInstance(Account_Map_Member__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account_Map_Member__c.Id,
            Account_Map_Member__c.Account_Relationship_Map__c,
            Account_Map_Member__c.Account__c,
            Account_Map_Member__c.Local_Influence__c,
            Account_Map_Member__c.Local_Support__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account_Map_Member__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Account_Map_Member__c> selectById(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Account_Map_Member__c>();
        }

        Set<String> queryFields = new Set<String>{ 'pqcrush__Account__r.Name', 'pqcrush__Relationship_Map__r.Name' };

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedAccounts().selectFields(queryFields);

        return Database.query(queryFactory.setCondition('Id IN :ids').toSOQL());
    }

    public List<Account_Map_Member__c> selectByContactId(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Account_Map_Member__c>();
        }

        Set<String> queryFields = new Set<String>{ 'pqcrush__Account__r.Name', 'pqcrush__Relationship_Map__r.Name' };

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedAccounts().selectFields(queryFields);

        return Database.query(queryFactory.setCondition('Account__c IN :ids').toSOQL());
    }

    public List<Account_Map_Member__c> selectByIdOrContactIdAndMapId(
        Set<Id> ids,
        Id mapId,
        Set<String> queryFields,
        Set<String> accountFields
    ) {
        if (ids == null || ids.size() == 0) {
            return new List<Account_Map_Member__c>();
        }
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        if (accountFields != null) {
            for (String accountField : accountFields) {
                queryFields.add('pqcrush__Account__r.' + accountField);
            }
        }

        queryFields.add('pqcrush__Relationship_Map__r.Name');

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedAccounts();

        return Database.query(
            queryFactory
                .selectFields(queryFields)
                .setCondition('(Id IN :ids OR Account__c in :ids) AND pqcrush__Relationship_Map__c = :mapId')
                .toSOQL()
        );
    }

    public List<Account_Map_Member__c> selectByMapIds(Set<Id> mapIds) {
        return selectByRelationshipMapIdsAndSelectFieldsWithYourAccounts(mapIds, null, null);
    }

    /**
     * Returns a list of Account_Map_Member__c records that correspond to the given
     * set of relationship Map Ids
     * @param mapIds The relationship maps
     * @return List<Account_Map_Member__c> The relationship map members
     */
    public List<Account_Map_Member__c> selectByRelationshipMapIdsAndSelectFieldsWithYourAccounts(
        Set<Id> mapIds,
        Set<String> queryFields,
        Set<String> accountFields
    ) {
        if (mapIds == null || mapIds.size() == 0) {
            return new List<Account_Map_Member__c>();
        }
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        if (accountFields != null) {
            for (String accountField : accountFields) {
                queryFields.add('pqcrush__Account__r.' + accountField);
            }
        }
        queryFields.add('pqcrush__Account_Relationship_Map__r.Name');

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedAccounts()
            .selectFields(queryFields)
            .setCondition(
                'pqcrush__Account_Relationship_Map__c IN :mapIds AND pqcrush__Account__c IN (SELECT Id FROM Account)'
            );
            System.debug('queryFactory.toSOQL():::'+queryFactory.toSOQL());

        return Database.query(queryFactory.toSOQL());
    }

    /**
     * Returns items in teamMembers that are duplicates of records already in the system.
     * Records are considered duplicates if they have the same Account__c and Account_Relationship_Map__c.
     * @param  members A list of Account_Map_Member__c objects to check against existing records.
     * @return              Any of the original member records that are duplicates.
     */
    public List<Account_Map_Member__c> selectDuplicatesAsSystem(List<Account_Map_Member__c> members) {
        return new SystemSelector().selectDuplicates(this, members);
    }

    /**
     * Returns a list of Account_Map_Member__c records along with their history information
     * that correspond to the given set of Account Plan Ids
     * @param accountPlanIds The Ids of the plans of the relationship maps that the returned members belong to
     * @param extraFields The extra fields to select on the history records
     * @return List<Account_Map_Member__c> The relationship map members with history
     */
    public List<Account_Map_Member__c> selectByAccountPlanIdsWithHistory(
        Set<Id> accountPlanIds,
        Set<String> extraFields
    ) {
        try {
            fflib_QueryFactory queryFactory = newQueryFactory();
            FFLibHelper.subSelectHistories(queryFactory, extraFields);

            return Database.query(
                queryFactory.setCondition(
                        '(pqcrush__Account_Relationship_Map__c IN (SELECT Id FROM pqcrush__Account_Relationship_Map__c WHERE pqcrush__Account_Plan_Id__c IN :accountPlanIds)) AND pqcrush__Account__c IN (SELECT Id FROM Account)'
                    )
                    .toSOQL()
            );
        } catch (Exception e) {
            return new List<SObject>();
        }
    }

    /******************************
     *        PRIVATE METHODS
     ******************************/

    private fflib_QueryFactory getQueryFactoryWithRelatedAccounts() {
        fflib_QueryFactory memberQueryFactory = newQueryFactory();

        fflib_SObjectSelector inflSelector = new InfluenceSelector();
        inflSelector.configureQueryFactoryFields(memberQueryFactory, 'Local_Influence__r');

        fflib_SObjectSelector suppSelector = new SupportSelector();
        suppSelector.configureQueryFactoryFields(memberQueryFactory, 'Local_Support__r');

        AccountSelector.newInstance()
            .configureQueryFactoryFields(
                memberQueryFactory,
                Account_Map_Member__c.Account__c.getDescribe().getRelationshipName()
            );

        return memberQueryFactory.selectField('pqcrush__Account__r.ParentId');
    }

    private without sharing class SystemSelector {
        public List<Account_Map_Member__c> selectDuplicates(
            AccountRelationshipMapMemberSelector selector,
            List<Account_Map_Member__c> members
        ) {
            Boolean assertCRUD = false;
            Boolean enforceFLS = false;
            Boolean includeSelectorFields = true;
            Set<Id> mapIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Map<String, Account_Map_Member__c> membersByUniqueKey = new Map<String, Account_Map_Member__c>();

            for (Account_Map_Member__c member : members) {
                mapIds.add(member.Account_Relationship_Map__c);
                accountIds.add(member.Account__c);
                membersByUniqueKey.put(getUniqueKey(member), member);
            }

            List<Account_Map_Member__c> potentialDuplicates = Database.query(
                selector.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields)
                    .setCondition('Account__c in :accountIds AND Account_Relationship_Map__c in :mapIds')
                    .toSOQL()
            );

            List<Account_Map_Member__c> duplicates = new List<Account_Map_Member__c>();

            for (Account_Map_Member__c potentialDuplicate : potentialDuplicates) {
                Account_Map_Member__c duplicateMember = membersByUniqueKey.get(
                    getUniqueKey(potentialDuplicate)
                );

                if (duplicateMember != null && potentialDuplicate.Id != duplicateMember.Id) {
                    duplicates.add(duplicateMember);
                }
            }

            return duplicates;
        }
    }


    public static String getUniqueKey(Account_Map_Member__c member) {
        return String.valueOf(member.Account_Relationship_Map__c) + String.valueOf(member.Account__c);
    }
}