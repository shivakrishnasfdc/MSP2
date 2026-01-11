public with sharing class StaticResourcesSelector extends fflib_SObjectSelector {
    public static StaticResourcesSelector newInstance() {
        return (StaticResourcesSelector) Application.Selector.newInstance(StaticResource.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            StaticResource.Id,
            StaticResource.Name,
            StaticResource.NamespacePrefix,
            StaticResource.SystemModStamp
        };
    }

    public Schema.SObjectType getSObjectType() {
        return StaticResource.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<StaticResource> selectById(Set<Id> idSet) {
        if (canQueryStaticResources() == false) {
            return new List<StaticResource>();
        }

        return (List<StaticResource>) selectSObjectsById(idSet);
    }

    public List<StaticResource> selectByName(Set<String> names) {
        if (canQueryStaticResources() == false) {
            return new List<StaticResource>();
        }

        return Database.query(newQueryFactory().setCondition('Name in :names').toSOQL());
    }

    private Boolean canQueryStaticResources() {
        //Users without View Setup and Configuration setting will throw an error trying to access Static Resources
        //so we need to first check if they have access and can query the object
        return Schema.sObjectType.StaticResource.isAccessible() && Schema.sObjectType.StaticResource.isQueryable();
    }
}