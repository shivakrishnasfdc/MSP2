public with sharing class CustomPermissionSelector extends fflib_SObjectSelector {
    public static CustomPermissionSelector newInstance() {
        return (CustomPermissionSelector) Application.Selector.newInstance(CustomPermission.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ CustomPermission.Id, CustomPermission.DeveloperName };
    }

    public Schema.SObjectType getSObjectType() {
        return CustomPermission.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<CustomPermission> selectById(Set<Id> idSet) {
        return (List<CustomPermission>) selectSObjectsById(idSet);
    }

    public List<CustomPermission> selectByNamespacePrefix(String namespacePrefix) {
        return Database.query(newQueryFactory().setCondition('NamespacePrefix = :namespacePrefix').toSOQL());
    }
}