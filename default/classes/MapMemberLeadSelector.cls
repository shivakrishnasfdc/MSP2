public with sharing class MapMemberLeadSelector extends fflib_SObjectSelector {
    public MapMemberLeadSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    public static MapMemberLeadSelector newInstance() {
        return (MapMemberLeadSelector) Application.Selector.newInstance(Map_Member_Lead__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Map_Member_Lead__c.Id,
            Map_Member_Lead__c.Relationship_Map__c,
            Map_Member_Lead__c.Lead__c,
            Map_Member_Lead__c.Influence__c,
            Map_Member_Lead__c.Support__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Map_Member_Lead__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Map_Member_Lead__c> selectById(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Map_Member_Lead__c>();
        }
        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedLeads();

        return Database.query(queryFactory.setCondition('Id IN :ids').toSOQL());
    }

    public List<Map_Member_Lead__c> selectByLeadId(Set<Id> ids) {
        if (ids == null || ids.size() == 0) {
            return new List<Map_Member_Lead__c>();
        }
        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedLeads();

        return Database.query(queryFactory.setCondition('Lead__c IN :ids').toSOQL());
    }

    /**
     * Returns a list of Map_Member_Lead__c records that correspond to the given
     * set of relationship Map Ids
     * @param mapIds The relationship maps
     * @return List<Map_Member_Lead__c> The relationship map members
     */
    public List<Map_Member_Lead__c> selectByRelationshipMaps(Set<Id> mapIds) {
        if (mapIds == null || mapIds.size() <= 0) {
            return new List<Map_Member_Lead__c>();
        }

        Set<String> queryFields = getLeadFieds();

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedLeads()
            .selectFields(queryFields)
            .setCondition('pqcrush__Relationship_Map__c IN :mapIds AND pqcrush__Lead__c IN (SELECT Id FROM Lead)');

        return Database.query(queryFactory.toSOQL());
    }

    public List<Map_Member_Lead__c> selectConvertedLeadsByRelationshipMaps(Set<Id> mapIds) {
        if (mapIds == null || mapIds.size() <= 0) {
            return new List<Map_Member_Lead__c>();
        }

        Set<String> queryFields = getLeadFieds();

        fflib_QueryFactory queryFactory = getQueryFactoryWithRelatedLeads()
            .selectFields(queryFields)
            .setCondition(
                'pqcrush__Relationship_Map__c IN :mapIds AND pqcrush__Lead__r.ConvertedContactId != NULL AND pqcrush__Lead__c IN (SELECT Id FROM Lead)'
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
            .configureQueryFactoryFields(queryFactory, Map_Member_Lead__c.Lead__c.getDescribe().getRelationshipName());

        return queryFactory;
    }
}