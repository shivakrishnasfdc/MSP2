@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class WhiteSpaceUtilsImpl {
    private static final List<String> EXCLUDE_CELL_RELATED_OBJECT_TYPES = new List<String>{
        WS_Data_Type_Association__c.getSObjectType().getDescribe().getName(),
        White_Space_Amount_Type_Association__c.getSObjectType().getDescribe().getName()
    };

    public Integer getTotalCount(WhiteSpaceTemplateMappingWrapper mapping) {
        Integer count;
        if (isPicklistMappingType(mapping)) {
            List<SelectOption> picklistOptions = UtilityForSObject.getPicklistSelectOptions(
                mapping.objectName,
                mapping.valueFieldName
            );
            count = picklistOptions.size();
        } else if (isGroupMappingType(mapping)) {
            count = getGroupedTotalCount(mapping, null);
        } else {
            Query mappingQuery = new Query(mapping.objectName, null);
            registerConditions(mappingQuery, mapping);
            mappingQuery.count('Id', 'totalCount');
            AggregateResult result = mappingQuery.aggregate()[0];
            count = (Integer) result.get('totalCount');
        }
        return count;
    }

    public Integer getTotalCountWithLookup(WhiteSpaceTemplateMappingWrapper mapping, String lookupRecordId) {
        Integer count = 0;
        if (isGroupMappingType(mapping)) {
            count = getGroupedTotalCount(mapping, lookupRecordId);
        } else {
            Query mappingQuery = new Query(mapping.objectName, null);
            Id id = Id.valueOf(lookupRecordId);
            if (id != null) {
                registerLookup(mappingQuery, mapping.objectName, id);
            }
            registerConditions(mappingQuery, mapping);
            mappingQuery.count('Id', 'totalCount');
            AggregateResult result = mappingQuery.aggregate()[0];
            count = (Integer) result.get('totalCount');
        }
        return count;
    }

    public List<SObject> getResults(WhiteSpaceTemplateMappingWrapper mapping) {
        return getQueryFromMapping(mapping).run();
    }

    public List<SObject> getResults(WhiteSpaceTemplateMappingWrapper mapping, Id lookupRecordId) {
        Query mappingQuery = getQueryFromMapping(mapping);
        if (lookupRecordId != null) {
            registerLookup(mappingQuery, mapping.objectName, lookupRecordId);
        }
        return mappingQuery.run();
    }

    public Query getQueryFromMapping(WhiteSpaceTemplateMappingWrapper mapping) {
        return getQueryFromMapping(mapping, null);
    }

    public Query getQueryFromMapping(WhiteSpaceTemplateMappingWrapper mapping, Id lookupRecordId) {
        Query mappingQuery = new Query(mapping.description.getSObjectType(), null);
        mappingQuery.allowAppendNamespace = false;
        mappingQuery.selectFields(mapping.getQueryFields());
        mappingQuery.allowAppendNamespace = true;
        if (mapping.labelFieldInfo.isSortable && mapping.labelFieldInfo.sobjectApiName == mapping.objectName) {
            mappingQuery.orderBy(mapping.labelFieldName);
        }
        registerConditions(mappingQuery, mapping);

        if (lookupRecordId != null) {
            registerLookup(mappingQuery, mapping.objectName, lookupRecordId);
        }
        return mappingQuery;
    }

    public List<String> findChildRelationshipNames(String parentObjectName, String childObjectName) {
        List<Schema.ChildRelationship> children = UTIL_Describe.getObjectDescribe(parentObjectName)
            .getChildRelationships();
        List<String> relationships = new List<String>();
        for (Schema.ChildRelationship child : children) {
            Schema.DescribeSObjectResult childType = child.getChildSObject().getDescribe();
            if (childObjectName == childType.getName()) {
                relationships.add(child.getField().getDescribe().getName());
            }
        }
        return relationships;
    }

    public void registerConditions(Query queryObj, WhiteSpaceTemplateMappingWrapper mapping) {
        if (mapping.conditions != null) {
            List<Query.Condition> conditions = new List<Query.Condition>();
            for (MappingConditionWrapper singConditionWrapper : mapping.conditions.singleConditions) {
                Mapping_Condition__c cond = singConditionWrapper.singleCondition;
                Object value = getValueFromType(mapping.objectName, cond.Field__c, cond.Value__c);
                Query.Condition queryCondition = createQueryCondition(cond.Field__c, cond.Operator__c, value);
                conditions.add(queryCondition);
            }
            Query.Condition conditionGroup;
            if (mapping.conditions.operator != null && mapping.conditions.operator.toUpperCase() == 'OR') {
                conditionGroup = Query.doOr(conditions);
            } else if (mapping.conditions.operator != null && mapping.conditions.operator.toUpperCase() != 'AND') {
                conditionGroup = generateConditionForCustomCondition(
                    conditions,
                    mapping.conditions.operator.toUpperCase()
                );
            } else {
                conditionGroup = Query.doAnd(conditions);
            }
            queryObj.addCondition(conditionGroup);
        }
    }

    public Query.Condition generateConditionForCustomCondition(List<Query.Condition> conditions, String operator) {
        operator = operator.replaceAll('AND', '+');
        operator = operator.replaceAll('OR', '-');

        String postfixString = infixToPostfix(operator);
        Query.Condition resultCondition = evaluatePostfix(postfixString, conditions);

        return resultCondition;
    }

    public String infixToPostfix(String infix) {
        String str = infix.replace(' ', '');
        Stack st = new Stack();
        String postfix = '';

        for (String stringCharacters : str.split('')) {
            if (stringCharacters.isAlpha()) {
                postfix += stringCharacters;
            } else if (stringCharacters == '(') {
                st.push('(');
            } else if (stringCharacters == ')') {
                while (!st.isEmpty() && !st.peek().equals('(')) {
                    postfix += st.pop();
                }
                st.pop();
            } else {
                while (!st.isEmpty() && !st.peek().equals('(')) {
                    postfix += st.pop();
                }
                st.push(stringCharacters);
            }
        }

        while (!st.isEmpty()) {
            postfix += st.pop();
        }

        return postfix;
    }

    public Query.Condition evaluatePostfix(String postfix, List<Query.Condition> conditions) {
        Stack values = new Stack();
        for (String character : postfix.split('')) {
            if (character.isAlpha()) {
                values.push(conditions[character.charAt(0) - 65]);
            } else {
                Query.Condition rightOperand = (Query.Condition) values.pop();
                Query.Condition leftOperand = (Query.Condition) values.pop();

                Query.Condition result;
                switch on character {
                    when '+' {
                        result = leftOperand.doAnd(rightOperand);
                    }
                    when '-' {
                        result = leftOperand.doOr(rightOperand);
                    }
                }
                values.push(result);
            }
        }
        return (Query.Condition) values.pop();
    }

    public void registerLookup(Query queryObj, String objectName, Id lookupRecordId) {
        registerLookup(queryObj, objectName, lookupRecordId, true);
    }

    public void registerLookup(Query queryObj, String objectName, Id lookupRecordId, Boolean filterNoRelationships) {
        if (queryObj == null || objectName == null || lookupRecordId == null) {
            return;
        }
        Schema.SobjectType parentObjectType = lookupRecordId.getSobjectType();
        String parentObjectName = parentObjectType.getDescribe().getName();
        List<String> lookupFieldNames = findChildRelationshipNames(parentObjectName, objectName);
        if (parentObjectName != objectName && lookupFieldNames.size() == 0 && !filterNoRelationships) {
            return;
        }
        Query.Condition condition = Query.conditionEq('Id', lookupRecordId);
        for (String fieldName : lookupFieldNames) {
            condition = condition.doOr(Query.conditionEq(fieldName, lookupRecordId));
        }
        queryObj.addCondition(condition);
    }

    public Query.Condition createQueryCondition(String lh, String operator, Object rh) {
        operator = operator.toUpperCase();
        switch on operator {
            when 'EQUALS' {
                return Query.conditionEq(lh, rh);
            }
            when 'NOT_EQUAL_TO' {
                return Query.conditionNotEq(lh, rh);
            }
            when 'GREATER_THAN' {
                return Query.conditionGt(lh, rh);
            }
            when 'GREATER_THAN_OR_EQUAL_TO' {
                return Query.conditionGe(lh, rh);
            }
            when 'LESS_THAN' {
                return Query.conditionLt(lh, rh);
            }
            when 'LESS_THAN_OR_EQUAL_TO' {
                return Query.conditionLe(lh, rh);
            }
            when 'IS_IN' {
                return Query.conditionIn(lh, rh);
            }
            when 'IS_NOT_IN' {
                return Query.conditionNotIn(lh, rh);
            }
            when 'IS_LIKE' {
                return Query.conditionLike(lh, rh);
            }
            when 'IS_NOT_LIKE' {
                return Query.conditionNotLike(lh, rh);
            }
            when else {
                return null;
            }
        }
    }

    public Object getValueFromType(String objectName, String fieldName, String originalValue) {
        String fieldType = UTIL_Describe.getFieldType(objectName, fieldName);
        Object val = originalValue;
        if (isNumberField(fieldType)) {
            val = Decimal.valueOf(originalValue);
        } else if (isDateField(fieldType)) {
            val = Date.valueOf(originalValue);
        } else if (isDateTimeField(fieldType)) {
            val = DateTime.ValueofGmt(originalValue.replace('T', ' '));
        } else if (isBooleanField(fieldType)) {
            val = Boolean.valueOf(originalValue);
        }
        return val;
    }

    public Boolean isNumberField(String objectName, String fieldName) {
        String fieldType = UTIL_Describe.getFieldType(objectName, fieldName);
        return isNumberField(fieldType);
    }

    public Boolean isNumberField(String fieldType) {
        if (fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'INTEGER' || fieldType == 'PERCENT') {
            return true;
        }
        return false;
    }

    public Boolean isDateField(String objectName, String fieldName) {
        String fieldType = UTIL_Describe.getFieldType(objectName, fieldName);
        return isDateField(fieldType);
    }

    public Boolean isDateField(String fieldType) {
        return fieldType == 'DATE' ? true : false;
    }

    public Boolean isDateTimeField(String objectName, String fieldName) {
        String fieldType = UTIL_Describe.getFieldType(objectName, fieldName);
        return isDateTimeField(fieldType);
    }

    public Boolean isDateTimeField(String fieldType) {
        return fieldType == 'DATETIME' ? true : false;
    }

    public Boolean isBooleanField(String objectName, String fieldName) {
        String fieldType = UTIL_Describe.getFieldType(objectName, fieldName);
        return isBooleanField(fieldType);
    }

    public Boolean isBooleanField(String fieldType) {
        return fieldType == 'BOOLEAN' ? true : false;
    }

    public Boolean isPicklistMappingType(WhiteSpaceTemplateMappingWrapper headerMapping) {
        return String.isEmpty(headerMapping.labelFieldName) && String.isNotEmpty(headerMapping.valueFieldName);
    }

    public Boolean isPicklistMappingType(Mapping__c headerMapping) {
        return String.isEmpty(headerMapping.DisplayLabelField__c) && String.isNotEmpty(headerMapping.ValueField__c);
    }

    public Boolean isPicklistMappingType(WhiteSpaceTemplateWrapper.HeaderConfiguration headerConfiguration) {
        return headerConfiguration.type == WhiteSpaceTemplateWrapper.PICKLIST_TYPE;
    }

    public Boolean isMultiPicklistMappingType(WhiteSpaceTemplateMappingWrapper headerMapping, String labelField) {
        if (labelField == null) {
            labelField = headerMapping.labelFieldName;
        }
        Schema.SObjectType oType = Application.getGlobalDescribe().get(headerMapping.objectName);
        Schema.SObjectField fType = oType.getDescribe().fields.getMap().get(labelField);
        Boolean isMultiPicklist = fType.getDescribe().getType() == Schema.DisplayType.MultiPicklist;
        return isMultiPicklist;
    }

    public Boolean isAnyPicklistMappingType(WhiteSpaceTemplateMappingWrapper headerMapping, String labelField) {
        if (headerMapping == null) {
            return false;
        }
        if (labelField == null) {
            labelField = headerMapping.labelFieldName;
        }
        if (labelField == null) {
            return false;
        }
        Schema.SObjectType oType = Application.getGlobalDescribe().get(headerMapping.objectName);
        if (oType == null) {
            return false;
        }
        Schema.SObjectField fType = oType.getDescribe().fields.getMap().get(labelField);
        if (fType == null) {
            return false;
        }
        Schema.DisplayType dt = fType.getDescribe().getType();
        return dt == Schema.DisplayType.MULTIPICKLIST || dt == Schema.DisplayType.PICKLIST;
    }

    public Boolean isGroupMappingType(WhiteSpaceTemplateMappingWrapper headerMapping) {
        return headerMapping != null && headerMapping.groupResults;
    }

    public Boolean isGroupMappingType(Mapping__c headerMapping) {
        return headerMapping != null && headerMapping.GroupResults__c;
    }

    public Boolean isGroupMappingType(WhiteSpaceTemplateWrapper.HeaderConfiguration headerConfiguration) {
        return isGroupMappingType(headerConfiguration?.mapping);
    }

    public List<String> getControllingFieldValuesForPicklistValue(
        String objectApiName,
        String dependFieldApiName,
        String dependValueApiName
    ) {
        List<String> validControllingFieldValues = new List<String>();
        Schema.SObjectField fieldToken = UTIL_Describe.getFieldDescribe(objectApiName, dependFieldApiName)
            .getSObjectField();
        Map<Object, List<PicklistService.PicklistWrapper>> dependentPicklistValues = PicklistService.getDependentPicklistValues(
            fieldToken
        );
        for (Object controllingFieldName : dependentPicklistValues.keySet()) {
            String controllingFieldNameString = String.valueOf(controllingFieldName);
            if (validControllingFieldValues.contains(controllingFieldNameString)) {
                continue;
            }
            List<PicklistService.PicklistWrapper> picklistValues = dependentPicklistValues.get(controllingFieldName);
            for (PicklistService.PicklistWrapper entry : picklistValues) {
                String value = entry.value;
                if (value == dependValueApiName) {
                    validControllingFieldValues.add(controllingFieldNameString);
                    break;
                }
            }
        }
        return validControllingFieldValues;
    }

    public Map<String, Map<String, List<SObject>>> getCellDataMap(
        Set<String> cellIds,
        Set<String> rowObjIds,
        Set<String> columnObjIds,
        Id cellFilterLookupId,
        Boolean shouldfilterUnrelatedCells,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedCellFields,
        List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields,
        List<WhiteSpaceTemplateCellFieldWrapper> basicFields,
        Set<String> selectFields,
        Map<String, List<String>> relationConversionMap
    ) {
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds = new Map<String, Map<String, List<SObject>>>();

        if (amountTypeFields != null) {
            for (WhiteSpaceTemplateCellFieldWrapper field : amountTypeFields) {
                List<SObject> results = queryObjectsForWrapper(
                    field,
                    null,
                    rowObjIds,
                    columnObjIds,
                    cellFilterLookupId,
                    shouldfilterUnrelatedCells,
                    selectFields
                );
                Map<String, List<SObject>> resultsMap = field.getMapForRecordList(results, relationConversionMap);
                fillMap(fieldDataByRelatedIds, resultsMap, field);
            }
        }

        if (basicFields != null) {
            for (WhiteSpaceTemplateCellFieldWrapper field : basicFields) {
                List<SObject> results = queryObjectsForWrapper(
                    field,
                    null,
                    rowObjIds,
                    columnObjIds,
                    cellFilterLookupId,
                    shouldfilterUnrelatedCells,
                    selectFields
                );
                Map<String, List<SObject>> resultsMap = field.getMapForRecordList(results, relationConversionMap);
                fillMap(fieldDataByRelatedIds, resultsMap, field);
            }
        }
        if (relatedCellFields != null) {
            for (WhiteSpaceTemplateCellFieldWrapper relObj : relatedCellFields) {
                List<SObject> results = queryObjectsForWrapper(relObj, cellIds, null, null, null, false, null);
                Map<String, List<SObject>> resultsMap = relObj.getMapForRecordList(results, relationConversionMap);
                fillMap(fieldDataByRelatedIds, resultsMap, relObj);
            }
        }

        return fieldDataByRelatedIds;
    }

    public List<WSRelatedObjectWrapper> getWSRelatedObjectWrappers() {
        Map<String, Cell_Relationship_Configuration__c> configMap = getCellRelationConfigMap();
        List<WSRelatedObjectWrapper> relatedObjects = new List<WSRelatedObjectWrapper>();
        List<Schema.ChildRelationship> children = pqcrush__White_Space_Cell__c.getSObjectType()
            .getDescribe()
            .getChildRelationships();
        for (Schema.ChildRelationship child : children) {
            Schema.DescribeFieldResult relationshipDfr = child.getField().getDescribe();
            if (relationshipDfr.isCustom()) {
                DescribeSObjectResult childDor = child.getChildSObject().getDescribe();
                if (EXCLUDE_CELL_RELATED_OBJECT_TYPES.contains(childDor.getName())) {
                    continue;
                }
                if (childDor.getName() == 'LookedUpFromActivity') {
                    childDor = Task.getSObjectType().getDescribe();
                }
                relatedObjects.add(
                    new WSRelatedObjectWrapper(childDor, relationshipDfr, configMap.get(childDor.getName()))
                );
            }
        }
        return relatedObjects;
    }

    private Integer getGroupedTotalCount(WhiteSpaceTemplateMappingWrapper mapping, String lookupRecordId) {
        Query mappingQuery = new Query(mapping.objectName, null);
        registerConditions(mappingQuery, mapping);
        Id id = lookupRecordId != null ? Id.valueOf(lookupRecordId) : null;
        if (id != null) {
            registerLookup(mappingQuery, mapping.objectName, id);
        }
        String fieldName = mapping.labelFieldName;
        if (
            Application.getGlobalDescribe()
                .get(mapping.objectName)
                .getDescribe()
                .fields.getMap()
                .get(fieldName)
                .getDescribe()
                .isGroupable()
        ) {
            mappingQuery.count('Id', 'totalCount');
            mappingQuery.groupBy(fieldName);
            List<AggregateResult> groupList = mappingQuery.aggregate();
            return groupList.size();
        } else {
            mappingQuery.selectField(fieldName);
            List<SObject> groupList = mappingQuery.run();
            Set<Object> unique = new Set<Object>();
            for (SObject rec : groupList) {
                List<Object> valueList = String.valueOf(rec.get(fieldName))?.split(';');
                if (valueList != null) {
                    unique.addAll(valueList);
                } else {
                    unique.add(null);
                }
            }
            return unique.size();
        }
    }

    private List<SObject> queryObjectsForWrapper(
        WhiteSpaceTemplateCellFieldWrapper wrapper,
        Set<String> cellIds,
        Set<String> rowObjIds,
        Set<String> columnObjIds,
        Id cellFilterLookupId,
        Boolean shouldfilterUnrelatedCells,
        Set<String> selectFields
    ) {
        Query queryBuilder = wrapper.getQueryBuilder(
            rowObjIds,
            columnObjIds,
            cellIds,
            cellFilterLookupId,
            shouldfilterUnrelatedCells
        );
        if (queryBuilder == null) {
            return new List<SObject>();
        }
        if (selectFields != null) {
            queryBuilder.selectFields(selectFields);
        }
        String queryString = queryBuilder.toQueryString();
        String objName = wrapper.mapping.objectName;
        List<SObject> results = new List<SObject>();
        if (Schema.getGlobalDescribe().get(objName).getDescribe().isAccessible()) {
            results = Database.query(queryString);
        }
        return results;
    }

    private Map<String, Cell_Relationship_Configuration__c> getCellRelationConfigMap() {
        List<Cell_Relationship_Configuration__c> configs = WSCellRelationshipConfigSelector.newInstance().selectAll();
        Map<String, Cell_Relationship_Configuration__c> configMap = new Map<String, Cell_Relationship_Configuration__c>();
        for (Cell_Relationship_Configuration__c config : configs) {
            configMap.put(config.Object_API_Name__c, config);
        }
        return configMap;
    }

    private void fillMap(
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds,
        Map<String, List<SObject>> resultsMap,
        WhiteSpaceTemplateCellFieldWrapper field
    ) {
        for (String key : resultsMap.keySet()) {
            List<SObject> matchingRecords = resultsMap.get(key);
            Map<String, List<SObject>> dataByFieldId = fieldDataByRelatedIds.get(key);
            if (dataByFieldId == null) {
                dataByFieldId = new Map<String, List<SObject>>();
            }
            dataByFieldId.put(field.id, matchingRecords);
            fieldDataByRelatedIds.put(key, dataByFieldId);
        }
    }
}