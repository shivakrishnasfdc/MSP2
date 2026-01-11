public with sharing class MapMemberUserSelector extends fflib_SObjectSelector {
    public MapMemberUserSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    public static MapMemberUserSelector newInstance() {
        return (MapMemberUserSelector) Application.Selector.newInstance(Map_Member_User__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Map_Member_User__c.Id,
            Map_Member_User__c.Account_Plan__c,
            Map_Member_User__c.Email__c,
            Map_Member_User__c.FullName__c,
            Map_Member_User__c.FirstName__c,
            Map_Member_User__c.LastName__c,
            Map_Member_User__c.ManagerId__c,
            Map_Member_User__c.Relationship_Map__c,
            Map_Member_User__c.Title__c,
            Map_Member_User__c.User__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Map_Member_User__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Map_Member_User__c> selectById(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Map_Member_User__c>();
        }
        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedUsers();

        return Database.query(queryFactory.setCondition('Id IN :ids').toSOQL());
    }

    public List<Map_Member_User__c> selectByObjectIdsWithYourUsersAndFields(
        Set<Id> mapOrAccountPlanIds,
        Set<String> queryFields,
        Set<String> userFields
    ) {
        if (mapOrAccountPlanIds == null) {
            return new List<Map_Member_User__c>();
        }

        if (queryFields == null) {
            queryFields = new Set<String>();
        }

        if (userFields != null) {
            for (String userField : userFields) {
                queryFields.add('pqcrush__User__c.' + userField);
            }
        }

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedUsers()
            .selectFields(queryFields)
            .setCondition(
                '(pqcrush__Account_Plan__c IN :mapOrAccountPlanIds OR pqcrush__Relationship_Map__c IN :mapOrAccountPlanIds) AND (pqcrush__User__c IN (SELECT Id FROM User))'
            );

        return Database.query(queryFactory.toSOQL());
    }

    /**
     * Returns items that are duplicates of records already in the system.
     * Records are considered duplicates if they have the same User__c and Relationship_Map__c.
     * @param  members A list of Map_Member_User__c objects to check against existing records.
     * @return              Any of the original member records that are duplicates.
     */
    public List<Map_Member_User__c> selectDuplicatesAsSystem(List<Map_Member_User__c> members) {
        return new SystemSelector().selectDuplicates(this, members);
    }

    /******************************
     *        PRIVATE METHODS
     ******************************/

    private fflib_QueryFactory getQueryFactoryWithRelatedUsers() {
        fflib_QueryFactory memberUserQueryFactory = newQueryFactory();

        UsersSelector.newInstance()
            .configureQueryFactoryFields(
                memberUserQueryFactory,
                Map_Member_User__c.User__c.getDescribe().getRelationshipName()
            );

        return memberUserQueryFactory.selectField('pqcrush__User__r.ManagerId');
    }

    private with sharing class SystemSelector {
        public List<Map_Member_User__c> selectDuplicates(
            MapMemberUserSelector selector,
            List<Map_Member_User__c> members
        ) {
            Set<Id> mapIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Map<String, Map_Member_User__c> membersByUniqueKey = new Map<String, Map_Member_User__c>();

            for (Map_Member_User__c member : members) {
                mapIds.add(member.Relationship_Map__c);
                userIds.add(member.User__c);
                membersByUniqueKey.put(MapMemberUsers.getUniqueKey(member), member);
            }

            List<Map_Member_User__c> potentialDuplicates = Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition('User__c in :userIds AND Relationship_Map__c in :mapIds')
                    .toSOQL()
            );

            List<Map_Member_User__c> duplicates = new List<Map_Member_User__c>();

            for (Map_Member_User__c potentialDuplicate : potentialDuplicates) {
                Map_Member_User__c duplicateMember = membersByUniqueKey.get(
                    MapMemberUsers.getUniqueKey(potentialDuplicate)
                );

                if (duplicateMember != null && potentialDuplicate.Id != duplicateMember.Id) {
                    duplicates.add(duplicateMember);
                }
            }

            return duplicates;
        }
    }
}