public with sharing class DynamicObjectQueryServiceImpl {
    public SObject querySObjectWithTypeAndId(String sObjType, Id recordId, Set<String> selectFields) {
        return (SObject) UtilityForList.first(
            querySObjectsWithTypeAndIds(sObjType, new List<Id>{ recordId }, selectFields)
        );
    }

    public List<SObject> querySObjectListWithTypeAndFields(
        String sObjTypeString,
        Set<String> selectFields,
        String sortField
    ) {
        Schema.SObjectType sObjType = Application.getGlobalDescribe().get(sObjTypeString);
        return querySObjectListWithTypeAndFields(sObjType, selectFields, sortField);
    }

    public List<SObject> querySObjectListWithTypeAndFields(
        Schema.SObjectType sObjType,
        Set<String> selectFields,
        String sortField
    ) {
        if (selectFields == null) {
            selectFields = new Set<String>();
        }
        Integer queryRowLimit = Limits.getLimitQueryRows();
        selectFields.add('Id');
        Query objectQuery = new Query(sObjType, null).setLimit(queryRowLimit);
        if (sortField != null) {
            selectFields.add(sortField);
            objectQuery.orderBy(sortField);
        }
        objectQuery.selectFields(selectFields);
        return objectQuery.toSObjectList();
    }

    public List<SObject> querySObjectListWithIdsAndFields(List<Id> idList, Set<String> selectFields) {
        if (idList == null || idList.size() == 0) {
            return new List<SObject>();
        }
        String objType = idList.get(0).getSObjectType().getDescribe().getName();
        return querySObjectsWithTypeAndIds(objType, idList, selectFields);
    }

    public List<SObject> queryRecentlyViewedExcludingIds(String objectName, List<String> excludedIds) {
        if (!Schema.sObjectType.RecentlyViewed.isAccessible()) {
            return null;
        }

        String queryString = 'SELECT Id, Name, Type FROM RecentlyViewed WHERE Type = :objectName AND Id NOT IN :excludedIds ORDER BY LastViewedDate DESC LIMIT 5';
        return Database.query(queryString);
    }

    public List<SObject> searchSObjectsWithTypeAndFieldsExcludingIds(
        String objectName,
        String searchTerm,
        String objNameField,
        String displayFieldName,
        List<String> excludedIds
    ) {
        searchTerm = String.escapeSingleQuotes(searchTerm) + '*';

        String returnFields = '(Id, ' + objNameField;
        String orderByField = objNameField;
        if (String.isNotBlank(displayFieldName) && displayFieldName != objNameField) {
            returnFields += ', ' + displayFieldName;
            orderByField = displayFieldName;
        }
        if(!fflib_SecurityUtils.checkObjectValidAndIsAccessable(objectName) || 
        !fflib_SecurityUtils.checkFieldValidAndIsAccessable(objectName, displayFieldName) || !fflib_SecurityUtils.checkFieldValidAndIsAccessable(objectName, objNameField)) {
            return null;
        }
        List<List<SObject>> searchResults = Search.query(
            'FIND :searchTerm ' +
                'IN ALL FIELDS ' +
                'RETURNING ' +
                objectName +
                returnFields +
                ' WHERE id NOT IN :excludedIds WITH SECURITY_ENFORCED ORDER BY ' +
                orderByField +
                ') LIMIT 20'
        );

        return searchResults.size() > 0 ? searchResults[0] : null;
    }

    public List<RecentlyViewed> queryRecentlyViewedWithLookupTypes(List<InputLookupTypeObject> types) {
        if (!Schema.sObjectType.RecentlyViewed.isAccessible()) {
            return null;
        }
        List<String> typeNames = new List<String>();
        for (InputLookupTypeObject type : types) {
            typeNames.add(type.objType);
        }

        String queryString = 'SELECT Id, Name, Type FROM RecentlyViewed WHERE Type IN :typeNames ORDER BY LastViewedDate DESC LIMIT 5';
        return Database.query(queryString);
    }

    public List<SObject> searchSObjectsWithLookupTypes(List<InputLookupTypeObject> types, String searchTerm) {
        String betterSearch = '*' + String.escapeSingleQuotes(searchTerm) + '*'; //NOPMD - False positive, used in SOSL query
        String soslString = 'FIND :betterSearch ' + 'IN ALL FIELDS ' + 'RETURNING ';
        for (InputLookupTypeObject type : types) {
            soslString += type.getSoslReturningStatement() + ', ';
        }
        soslString = soslString.removeEnd(', ');
        soslString += ' LIMIT ' + (10 * types.size());
        
        List<List<SObject>> searchResults = Search.query(soslString);
        List<SObject> flatResults = new List<SObject>();
        for (List<SObject> results : searchResults) {
            flatResults.addAll(results);
        }

        return flatResults;
    }

    public List<SObject> querySObjectsWithTypeAndIds(
        Schema.SObjectType objType,
        Set<Schema.SObjectField> selectFields,
        Set<Id> recordIds
    ) {
        Query objectQuery = new Query(objType, null).byId(recordIds).selectField('Id');
        objectQuery.selectFields(selectFields);
        return objectQuery.toSObjectList();
    }

    public List<SObject> querySObjectsWithTypeAndIdsMatchingRecords(
        Schema.SObjectType objType,
        Set<Schema.SObjectField> selectFields,
        Set<Id> recordIds
    ) {
        Query mapQuery = new Query(objType, null).selectField('Id').orderBy('CreatedDate', 'DESC');

        if (selectFields.size() > 0) {
            for (Schema.SObjectField rel : selectFields) {
                mapQuery.addConditionIn(rel, recordIds);
            }
            List<SObject> resultList = mapQuery.toSObjectList();
            return resultList;
        }

        return new List<SObject>();
    }

    private List<SObject> querySObjectsWithTypeAndIds(String sObjType, List<Id> recordIds, Set<String> selectFields) {
        if (recordIds == null || recordIds.size() == 0) {
            return new List<SObject>();
        }
        if (selectFields == null) {
            selectFields = new Set<String>();
        }
        selectFields.add('Id');
        Query objectQuery = new Query(sObjType, null).byId(recordIds).selectFields(selectFields);
        return objectQuery.toSObjectList();
    }
}