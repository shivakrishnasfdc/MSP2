public with sharing class RelationshipMapMemberSelector extends fflib_SObjectSelector {
    public static final Set<String> HISTORY_FIELDS = new Set<String>{ 'Parent.Contact__r.Name' };
    public RelationshipMapMemberSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    public static RelationshipMapMemberSelector newInstance() {
        return (RelationshipMapMemberSelector) Application.Selector.newInstance(Relationship_Map_Member__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Relationship_Map_Member__c.Id,
            Relationship_Map_Member__c.Relationship_Map__c,
            Relationship_Map_Member__c.Contact__c,
            Relationship_Map_Member__c.InfluenceId__c,
            Relationship_Map_Member__c.SupportId__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Relationship_Map_Member__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Relationship_Map_Member__c> selectById(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Relationship_Map_Member__c>();
        }

        Set<String> queryFields = new Set<String>{ 'pqcrush__Contact__r.Title', 'pqcrush__Relationship_Map__r.Name' };

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedContacts().selectFields(queryFields);

        return Database.query(queryFactory.setCondition('Id IN :ids').toSOQL());
    }

    public List<Relationship_Map_Member__c> selectByContactId(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Relationship_Map_Member__c>();
        }

        Set<String> queryFields = new Set<String>{ 'pqcrush__Contact__r.Title', 'pqcrush__Relationship_Map__r.Name' };

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedContacts().selectFields(queryFields);

        return Database.query(queryFactory.setCondition('Contact__c IN :ids').toSOQL());
    }

    public List<Relationship_Map_Member__c> selectByIdOrContactIdAndMapId(
        Set<Id> ids,
        Id mapId,
        Set<String> queryFields,
        Set<String> contactFields
    ) {
        if (ids == null || ids.size() == 0) {
            return new List<Relationship_Map_Member__c>();
        }
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        if (contactFields != null) {
            for (String contactField : contactFields) {
                queryFields.add('pqcrush__Contact__r.' + contactField);
            }
        }

        queryFields.add('pqcrush__Relationship_Map__r.Name');

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedContacts();

        return Database.query(
            queryFactory
                .selectFields(queryFields)
                .setCondition('(Id IN :ids OR Contact__c in :ids) AND pqcrush__Relationship_Map__c = :mapId')
                .toSOQL()
        );
    }

    public List<Relationship_Map_Member__c> selectByMapIds(Set<Id> mapIds) {
        return selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(mapIds, null, null);
    }

    /**
     * Returns a list of Relationship_Map_Member__c records that correspond to the given
     * set of relationship Map Ids
     * @param mapIds The relationship maps
     * @return List<Relationship_Map_Member__c> The relationship map members
     */
    public List<Relationship_Map_Member__c> selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
        Set<Id> mapIds,
        Set<String> queryFields,
        Set<String> contactFields
    ) {
        if (mapIds == null || mapIds.size() == 0) {
            return new List<Relationship_Map_Member__c>();
        }
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        if (contactFields != null) {
            for (String contactField : contactFields) {
                queryFields.add('pqcrush__Contact__r.' + contactField);
            }
        }
        queryFields.add('pqcrush__Relationship_Map__r.Name');
        queryFields.add('CreatedDate');
        

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedContacts()
            .selectFields(queryFields)
            .setCondition(
                'pqcrush__Relationship_Map__c IN :mapIds AND pqcrush__Contact__c IN (SELECT Id FROM Contact)'
            );
        system.debug('queryFactory.toSOQL(): '+queryFactory.toSOQL());
        return Database.query(queryFactory.toSOQL());
    }

    /**
     * Returns items in teamMembers that are duplicates of records already in the system.
     * Records are considered duplicates if they have the same Contact__c and Relationship_Map__c.
     * @param  members A list of Relationship_Map_Member__c objects to check against existing records.
     * @return              Any of the original member records that are duplicates.
     */
    public List<Relationship_Map_Member__c> selectDuplicatesAsSystem(List<Relationship_Map_Member__c> members) {
        return new SystemSelector().selectDuplicates(this, members);
    }

    /**
     * Returns a list of Relationship_Map_Member__c records along with their history information
     * that correspond to the given set of Account Plan Ids
     * @param accountPlanIds The Ids of the plans of the relationship maps that the returned members belong to
     * @param extraFields The extra fields to select on the history records
     * @return List<Relationship_Map_Member__c> The relationship map members with history
     */
    public List<Relationship_Map_Member__c> selectByAccountPlanIdsWithHistory(
        Set<Id> accountPlanIds,
        Set<String> extraFields
    ) {
        try {
            fflib_QueryFactory queryFactory = newQueryFactory();
            FFLibHelper.subSelectHistories(queryFactory, extraFields);

            return Database.query(
                queryFactory.setCondition(
                        '(pqcrush__Relationship_Map__c IN (SELECT Id FROM pqcrush__Relationship_Map__c WHERE pqcrush__pq_AccountPlanId__c IN :accountPlanIds)) AND pqcrush__contact__c IN (SELECT Id FROM Contact)'
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

    private fflib_QueryFactory getQueryFactoryWithRelatedContacts() {
        fflib_QueryFactory memberQueryFactory = newQueryFactory();

        fflib_SObjectSelector inflSelector = new InfluenceSelector();
        inflSelector.configureQueryFactoryFields(memberQueryFactory, 'InfluenceId__r');

        fflib_SObjectSelector suppSelector = new SupportSelector();
        suppSelector.configureQueryFactoryFields(memberQueryFactory, 'SupportId__r');

        ContactSelector.newInstance()
            .configureQueryFactoryFields(
                memberQueryFactory,
                Relationship_Map_Member__c.Contact__c.getDescribe().getRelationshipName()
            );

        return memberQueryFactory.selectField('pqcrush__Contact__r.ReportsToId');
    }

    private with sharing class SystemSelector {
        public List<Relationship_Map_Member__c> selectDuplicates(
            RelationshipMapMemberSelector selector,
            List<Relationship_Map_Member__c> members
        ) {
            Boolean assertCRUD = false;
            Boolean enforceFLS = false;
            Boolean includeSelectorFields = true;
            Set<Id> mapIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Map<String, Relationship_Map_Member__c> membersByUniqueKey = new Map<String, Relationship_Map_Member__c>();

            for (Relationship_Map_Member__c member : members) {
                mapIds.add(member.Relationship_Map__c);
                contactIds.add(member.Contact__c);
                membersByUniqueKey.put(RelationshipMapMembers.getUniqueKey(member), member);
            }

            List<Relationship_Map_Member__c> potentialDuplicates = Database.query(
                selector.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields)
                    .setCondition('Contact__c in :contactIds AND Relationship_Map__c in :mapIds')
                    .toSOQL()
            );

            List<Relationship_Map_Member__c> duplicates = new List<Relationship_Map_Member__c>();

            for (Relationship_Map_Member__c potentialDuplicate : potentialDuplicates) {
                Relationship_Map_Member__c duplicateMember = membersByUniqueKey.get(
                    RelationshipMapMembers.getUniqueKey(potentialDuplicate)
                );

                if (duplicateMember != null && potentialDuplicate.Id != duplicateMember.Id) {
                    duplicates.add(duplicateMember);
                }
            }

            return duplicates;
        }
    }
}