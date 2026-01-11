public with sharing class SObjectServiceImpl {
    public Schema.SobjectType getSObjectType(String sObjectName) {
        if (String.isBlank(sObjectName)) {
            return null;
        }
        if (sObjectName == Account.sObjectType.getDescribe().getName()) {
            return Account.sObjectType;
        } else if (sObjectName == Opportunity.sObjectType.getDescribe().getName()) {
            return Opportunity.sObjectType;
        } else if (sObjectName == Lead.sObjectType.getDescribe().getName()) {
            return Lead.sObjectType;
        } else if (sObjectName == Contact.sObjectType.getDescribe().getName()) {
            return Contact.sObjectType;
        }
        Map<String, Schema.SObjectType> gd = Application.getGlobalDescribe();
        Schema.SObjectType objType = gd.get(sObjectName);
        return objType;
    }

    public Set<Schema.SObjectField> relationshipsFromDescribeMatchingObjectType(
        Schema.DescribeSObjectResult describe,
        Schema.sObjectType objectType
    ) {
        Set<Schema.SObjectField> matchingFields = new Set<Schema.SObjectField>();
        List<Schema.SObjectField> fieldValues = describe.fields.getMap().values();
        for (Schema.SObjectField field : fieldValues) {
            try {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if (fieldDescribe.getType() != Schema.DisplayType.Reference) {
                    continue;
                }
                List<Schema.sObjectType> references = fieldDescribe.getReferenceTo();
                if (references.contains(objectType)) {
                    matchingFields.add(field);
                }
            } catch (Exception e) {
                continue;
            }
        }
        return matchingFields;
    }

    public Set<Schema.SObjectType> getObjectsRelatedTo(Schema.sObjectType objectType) {
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships();

        Set<Schema.SObjectType> result = new Set<Schema.SObjectType>();

        for (Schema.ChildRelationship childRelationship : childRelationships) {
            Schema.SObjectType childSObject = childRelationship.getChildSObject();
            result.add(childSObject);
        }

        return result;
    }

    public Set<Id> getIdsForRelatedObjects(Id recordId, List<Schema.sObjectType> relatedObjectTypes) {
        Set<Id> result = new Set<Id>();
        for (Schema.sObjectType relatedObjectType : relatedObjectTypes) {
            result.addAll(getIdsForRelatedObject(recordId, relatedObjectType));
        }
        return result;
    }

    public Map<Id, Set<Id>> getMapOfObjectIdsRelatedToIdSet(
        Set<Id> recordIds,
        Schema.sObjectType ofType,
        List<Schema.sObjectType> relatedObjectTypes
    ) {
        if (!areFieldsValid(recordIds, ofType, relatedObjectTypes)) {
            return new Map<Id, Set<Id>>();
        }

        Map<Id, Set<Id>> result = new Map<Id, Set<Id>>();
        for (Schema.sObjectType relatedObjectType : relatedObjectTypes) {
            Schema.DescribeSObjectResult relatedDescribe = relatedObjectType.getDescribe();
            Set<Schema.SObjectField> relFieldSet = relationshipsFromDescribeMatchingObjectType(relatedDescribe, ofType);
            if (relFieldSet.isEmpty()) {
                continue;
            }
            List<SObject> queryObjects = queryObjectsForObjDesc(relatedDescribe, relFieldSet, recordIds);
            for (SObject queryObject : queryObjects) {
                for (Schema.SObjectField field : relFieldSet) {
                    Object value = queryObject.get(field);
                    if (value == null) {
                        continue;
                    }
                    if (value instanceof Id) {
                        Id idValue = (Id) value;
                        if (!result.containsKey(idValue)) {
                            result.put(idValue, new Set<Id>());
                        }
                        result.get(idValue).add(queryObject.Id);
                    }
                }
            }
        }
        return result;
    }

    private Boolean areFieldsValid(
        Set<Id> recordIds,
        Schema.sObjectType ofType,
        List<Schema.sObjectType> relatedObjectTypes
    ) {
        if (
            recordIds == null ||
            recordIds.size() == 0 ||
            ofType == null ||
            relatedObjectTypes == null ||
            relatedObjectTypes.size() == 0
        ) {
            return false;
        }
        return true;
    }

    private Set<Id> getIdsForRelatedObject(Id recordId, Schema.sObjectType relatedObjectType) {
        if (recordId == null) {
            return new Set<Id>();
        }

        Schema.SObjectType objectType = recordId.getSObjectType();
        if (objectType == relatedObjectType) {
            return new Set<Id>();
        }

        // Check if the related object type has a relationship to the record id's object type
        Schema.DescribeSobjectResult relatedDescribe = relatedObjectType.getDescribe();
        Set<Schema.SObjectField> relFieldSet = relationshipsFromDescribeMatchingObjectType(relatedDescribe, objectType);

        if (relFieldSet.isEmpty()) {
            return new Set<Id>();
        }
        List<SObject> queryObjects = queryObjectsForObjDesc(relatedDescribe, relFieldSet, new Set<Id>{ recordId });
        Set<Id> idSet = new Map<Id, SObject>(queryObjects).keySet();
        return idSet;
    }

    private List<SObject> queryObjectsForObjDesc(
        Schema.DescribeSobjectResult relatedDescribe,
        Set<Schema.SObjectField> relatedFields,
        Set<Id> recordIds
    ) {
        Set<String> relatedfieldNames = new Set<String>();
        for (Schema.SObjectField field : relatedFields) {
            relatedfieldNames.add(field.getDescribe().getName());
        }

        String querySelect = 'SELECT Id';
        String queryFrom = ' FROM ' + relatedDescribe.getName() + ' WHERE ';
        for (String relatedfieldName : relatedfieldNames) {
            querySelect += ', ' + relatedfieldName;
            queryFrom += relatedfieldName + ' IN :recordIds OR ';
        }
        queryFrom = queryFrom.substring(0, queryFrom.length() - 4);
        String query = querySelect + queryFrom;
        List<SObject> queryResult = Database.query(String.escapeSingleQuotes(query));
        return queryResult;
    }

    public Map<String, FieldMetaData> getDescribeFieldMapsForFields(Schema.SObjectType objType, List<String> fields) {
        if (fields == null || fields.size() <= 0) {
            return new Map<String, FieldMetaData>();
        }

        Map<String, FieldMetaData> result = new Map<String, FieldMetaData>();
        Map<String, Schema.SObjectField> mapFields = objType.getDescribe().fields.getMap();
        Set<String> mapMemberObjectFields = mapFields.keySet();

        for (String field : fields) {
            if (mapMemberObjectFields.contains(field.ToLowerCase())) {
                schema.SobjectField sObjectField = mapFields.get(field);
                Schema.DescribeFieldResult dfr = sObjectField.getDescribe();
                if (dfr.isAccessible()) {
                    result.put(field, new FieldMetaData(Relationship_Map_Member__c.sObjectType, sObjectField));
                }
            }
        }

        return result;
    }

    public Boolean hasRecordTypeEnabled(SObjectType objType) {
        List<Schema.RecordTypeInfo> result = objType.getDescribe().getRecordTypeInfos();
        return result.size() > 1;
    }

    public Id getFirstIdFromSObjectMatchingFields(SObject obj, Set<SObjectField> matchingFields) {
        if (obj == null || matchingFields == null || matchingFields.size() == 0) {
            return null;
        }
        for (SObjectField field : matchingFields) {
            Object value = obj.get(field);
            if (value == null) {
                continue;
            } else if (value instanceof Id) {
                return (Id) value;
            } else if (value instanceof List<SObject>) {
                List<SObject> relatedObjs = (List<SObject>) value;
                if (relatedObjs.size() == 0) {
                    continue;
                }
                return relatedObjs[0].Id;
            }
        }
        return null;
    }

    public List<String> getCustomFields(Schema.SObjectType objType, Boolean getOnlyUpdateableFields) {
        Map<String, SObjectField> fieldsByName = objType.getDescribe().fields.getMap();
        List<String> customFields = new List<String>();

        for (SObjectField field : fieldsByName.values()) {
            Schema.DescribeFieldResult descField = field.getDescribe();
            Boolean validField = descField.isAccessible();
            if (getOnlyUpdateableFields) {
                validField = descField.isUpdateable() && validField;
            }

            if (descField.isCustom() && validField) {
                customFields.add(descField.getName());
            }
        }

        return customFields;
    }
}