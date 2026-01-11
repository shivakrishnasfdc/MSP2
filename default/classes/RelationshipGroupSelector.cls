public with sharing class RelationshipGroupSelector extends fflib_SObjectSelector {
    private static List<Relationship_Group__c> globalGroupCache = null;
    private static Map<Id, List<Relationship_Group__c>> localGroupCache = new Map<Id, List<Relationship_Group__c>>();

    public RelationshipGroupSelector() {
        super(false, true, false);
    }

    public static RelationshipGroupSelector newInstance() {
        return (RelationshipGroupSelector) Application.Selector.newInstance(Relationship_Group__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Relationship_Group__c.Id,
            Relationship_Group__c.Relationship_Group_Type__c,
            Relationship_Group__c.Parent_Relationship_Group__c,
            Relationship_Group__c.Label__c,
            Relationship_Group__c.TempId__c,
            Relationship_Group__c.Layout__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Relationship_Group__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Relationship_Group__c> selectById(Set<Id> ids) {
        return (List<Relationship_Group__c>) selectSObjectsById(ids);
    }

    public List<Relationship_Group__c> selectByIdORTempKey(Set<String> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id IN :ids OR TempId__c IN :ids');
        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group__c> selectAllLocalGroups(Id mapOrAccountPlanId) {
        if (mapOrAccountPlanId == null) {
            return new List<Relationship_Group__c>();
        }

        if (localGroupCache.containsKey(mapOrAccountPlanId)) {
            return localGroupCache.get(mapOrAccountPlanId);
        }

        String condition = mapOrAccountPlanId.getSobjectType() + ' = :mapOrAccountPlanId';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition);

        List<Relationship_Group__c> loacalGroups = Database.query(query.toSOQL());
        localGroupCache.put(mapOrAccountPlanId, loacalGroups);
        return loacalGroups;
    }

    public List<Relationship_Group__c> selectAllGlobalGroups() {
        if (globalGroupCache == null) {
            fflib_QueryFactory query = newQueryFactory()
                .setCondition('pqcrush__Account_Plan__c = null AND pqcrush__Relationship_Map__c = null');
            globalGroupCache = Database.query(query.toSOQL());
        }
        return globalGroupCache;
    }
}