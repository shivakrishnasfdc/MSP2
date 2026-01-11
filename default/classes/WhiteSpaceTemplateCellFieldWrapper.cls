@SuppressWarnings('PMD.ExcessivePublicCount,PMD.NcssMethodCount')
public with sharing class WhiteSpaceTemplateCellFieldWrapper {
    private static final String OPPORTUNITY_PRODUCT_RELATIONSHIP_FIELD_NAME = Schema.OpportunityLineItem.Product2Id.getDescribe()
        .getName();

    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String displayFieldId { get; set; }
    @AuraEnabled
    public Boolean isManual { get; private set; }
    @AuraEnabled
    public WhiteSpaceTemplateMappingWrapper mapping { get; set; }
    @AuraEnabled
    public String rowRelation { get; private set; }
    @AuraEnabled
    public String columnRelation { get; private set; }
    @AuraEnabled
    public String cellRelation { get; private set; }
    @AuraEnabled
    public List<String> additionalCellRelationFields { get; private set; }
    @AuraEnabled
    public String type { get; private set; }
    @AuraEnabled
    public List<String> accountRelationships { get; private set; }
    @AuraEnabled
    public Boolean canCreateObjects { get; private set; }

    private WhiteSpaceTemplateMappingWrapper rowMapping; //NOPMD
    private WhiteSpaceTemplateMappingWrapper columnMapping; //NOPMD

    public WhiteSpaceTemplateCellFieldWrapper() {
        this.displayFieldId = null;
        this.isManual = true;
        this.mapping = null;
        this.rowRelation = null;
        this.columnRelation = null;
        this.type = null;
        this.canCreateObjects = false;
    }

    public WhiteSpaceTemplateCellFieldWrapper(
        White_Space_Template_Cell_Field__c cellField,
        Map<Id, Mapping__c> cellMappingById,
        WhiteSpaceTemplateMappingWrapper rowData,
        WhiteSpaceTemplateMappingWrapper columnData,
        Boolean canCreateObjects
    ) {
        this(
            cellField,
            cellMappingById != null ? cellMappingById.get(cellField.ValueMapping__c) : null,
            rowData,
            columnData,
            canCreateObjects
        );
    }

    public WhiteSpaceTemplateCellFieldWrapper(
        White_Space_Template_Cell_Field__c cellField,
        Mapping__c cellMapping,
        WhiteSpaceTemplateMappingWrapper rowData,
        WhiteSpaceTemplateMappingWrapper columnData,
        Boolean canCreateObjects
    ) {
        this.id = cellField.Id;
        this.displayFieldId = cellField.DisplayFieldId__c;
        this.type = cellField.DisplayFieldId__c != null ? 'amountType' : 'basicMapping';
        this.isManual = true;
        this.canCreateObjects = canCreateObjects;
        if (cellMapping != null) {
            this.isManual = false;
            this.mapping = new WhiteSpaceTemplateMappingWrapper(cellMapping);
            this.rowMapping = rowData;
            this.columnMapping = columnData;
            this.rowRelation = WhiteSpaceUtils.isPicklistMappingType(rowData)
                ? rowData.valueFieldName
                : findChildRelationshipName(rowData);
            this.columnRelation = WhiteSpaceUtils.isPicklistMappingType(columnData)
                ? columnData.valueFieldName
                : findChildRelationshipName(columnData);
            this.accountRelationships = WhiteSpaceUtils.findChildRelationshipNames(
                Account.getSObjectType().getDescribe().getName(),
                this.mapping.description.getName()
            );
        }
    }

    public WhiteSpaceTemplateCellFieldWrapper(WSRelatedObjectWrapper relationshipWrapper) {
        this.id = relationshipWrapper.objDesc.getName();
        this.displayFieldId = relationshipWrapper.objDesc.getName();
        this.type = 'relatedMapping';
        this.isManual = true;
        this.mapping = new WhiteSpaceTemplateMappingWrapper(relationshipWrapper);
        this.cellRelation = relationshipWrapper.relationshipField.getName();
        this.additionalCellRelationFields = relationshipWrapper.fieldList;
        this.canCreateObjects = false;
        this.accountRelationships = WhiteSpaceUtils.findChildRelationshipNames(
            Account.getSObjectType().getDescribe().getName(),
            this.mapping.description.getName()
        );
    }

    public WhiteSpaceTemplateCellFieldWrapper(WSRelatedObjectWrapper relationshipWrapper, Boolean canCreateObjects) {
        this(relationshipWrapper);
        this.canCreateObjects = canCreateObjects;
    }

    private String findChildRelationshipName(WhiteSpaceTemplateMappingWrapper parent) {
        if (parent == null || parent.description == null) {
            return null;
        }
        List<Schema.ChildRelationship> children = parent.description.getChildRelationships();
        for (Schema.ChildRelationship child : children) {
            Schema.DescribeSObjectResult childType = child.getChildSObject().getDescribe();
            if (mapping.description.getName() == childType.getName()) {
                return child.getField().getDescribe().getName();
            }
        }
        return null;
    }

    public Query getQueryBuilder(
        Set<String> rowObjIds,
        Set<String> columnObjIds,
        Set<String> cellIds,
        Id lookupId,
        Boolean shouldfilterUnrelatedCells
    ) {
        if (!this.canBuildQueryWithRelatedIds(rowObjIds, columnObjIds, cellIds)) {
            return null;
        }

        Query queryBuilder = WhiteSpaceUtils.getQueryFromMapping(this.mapping);

        Set<String> additionalFieldsForAllObjects = new Set<String>();
        if (UserInfo.IsMultiCurrencyOrganization()) {
            additionalFieldsForAllObjects.add('CurrencyIsoCode');
        }

        if (this.hasOpportunityProductRelationship()) {
            Set<Id> productIds = this.isProductType(this.columnMapping)
                ? new Set<Id>((List<Id>) new List<String>(columnObjIds))
                : new Set<Id>((List<Id>) new List<String>(rowObjIds));

            if (productIds.isEmpty()) {
                return null;
            }

            queryBuilder = injectOpportunityProduct(queryBuilder, productIds, additionalFieldsForAllObjects);
        }

        updateQueryWithRelation(queryBuilder, this.rowRelation, this.rowMapping, rowObjIds);
        updateQueryWithRelation(queryBuilder, this.columnRelation, this.columnMapping, columnObjIds);

        if (this.cellRelation != null && cellIds != null && cellIds.size() != 0) {
            queryBuilder.selectField(this.cellRelation);
            if (this.additionalCellRelationFields != null) {
                queryBuilder.selectFields(this.additionalCellRelationFields);
            }
            queryBuilder.lookup(this.cellRelation, new Set<Id>((List<Id>) new List<String>(cellIds)));
        }
        queryBuilder.selectFields(additionalFieldsForAllObjects);

        if (lookupId != null) {
            WhiteSpaceUtils.registerLookup(queryBuilder, this.mapping.objectName, lookupId, shouldfilterUnrelatedCells);
        }
        return queryBuilder;
    }

    public Query injectOpportunityProduct(
        Query queryBuilder,
        Set<Id> productIds,
        Set<String> additionalFieldsForAllObjects
    ) {
        Query oppLineItemsQuery = new Query('OpportunityLineItem', null)
            .selectField('OpportunityId')
            .lookup(OPPORTUNITY_PRODUCT_RELATIONSHIP_FIELD_NAME, productIds);

        Set<String> subQueryFields = new Set<String>{ OPPORTUNITY_PRODUCT_RELATIONSHIP_FIELD_NAME };
        for (String field : this.mapping.getOLIQueryFields()) {
            String toAdd = field.substringAfterLast('.');
            subQueryFields.add(toAdd);
        }
        subQueryFields.addAll(additionalFieldsForAllObjects);

        queryBuilder.allowAppendNamespace = false;
        queryBuilder.addSubquery('OpportunityLineItems', subQueryFields);
        queryBuilder.allowAppendNamespace = true;
        queryBuilder.lookup('Id', oppLineItemsQuery);
        return queryBuilder;
    }

    public Map<String, List<SObject>> getMapForRecordList(
        List<SObject> recordList,
        Map<String, List<String>> relationConversionMap
    ) {
        if (relationConversionMap == null) {
            relationConversionMap = new Map<String, List<String>>();
        }
        Map<String, List<SObject>> resultsMap = new Map<String, List<SObject>>();
        if (this.type == 'relatedMapping') {
            resultsMap = this.mapByCellRelationships(recordList, relationConversionMap);
        } else if (this.hasOpportunityProductRelationship()) {
            if (this.isProductType(this.rowMapping)) {
                resultsMap = this.mapByOpportunityProduct(recordList, this.columnRelation, true, relationConversionMap);
            } else {
                resultsMap = this.mapByOpportunityProduct(recordList, this.rowRelation, false, relationConversionMap);
            }
        } else {
            resultsMap = this.mapByStandardRowAndColumnRelationships(recordList, relationConversionMap);
        }
        return resultsMap;
    }

    private Boolean canBuildQueryWithRelatedIds(Set<String> rowObjIds, Set<String> columnObjIds, Set<String> cellIds) {
        if (this.mapping == null) {
            return false;
        }
        if (!canBuildRowColumnQueryWithRelationMappingAndIds(this.rowRelation, this.rowMapping, rowObjIds)) {
            return false;
        }
        if (!canBuildRowColumnQueryWithRelationMappingAndIds(this.columnRelation, this.columnMapping, columnObjIds)) {
            return false;
        }
        if (this.cellRelation != null && (cellIds == null || cellIds.isEmpty())) {
            return false;
        }
        return true;
    }

    private Boolean canBuildRowColumnQueryWithRelationMappingAndIds(
        String relation,
        WhiteSpaceTemplateMappingWrapper mapping,
        Set<String> objIds
    ) {
        if (relation == null) {
            return true;
        }
        if (WhiteSpaceUtils.isPicklistMappingType(mapping)) {
            return true;
        }
        if (objIds != null && !objIds.isEmpty()) {
            return true;
        }
        return false;
    }

    private void updateQueryWithRelation(
        Query queryBuilder,
        String relation,
        WhitespaceTemplateMappingWrapper mapping,
        Set<String> objIds
    ) {
        if (relation != null) {
            queryBuilder.selectField(relation);
            if (
                WhiteSpaceUtils.isPicklistMappingType(mapping) ||
                WhiteSpaceUtils.isAnyPicklistMappingType(mapping, null)
            ) {
                queryBuilder.addConditionNotNull(relation);
            } else {
                queryBuilder.lookup(relation, new Set<Id>((List<Id>) new List<String>(objIds)));
            }
        }
    }

    private Map<String, List<SObject>> mapByCellRelationships(
        List<SObject> resultItems,
        Map<String, List<String>> relationConversionMap
    ) {
        Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
        if (this.cellRelation == null) {
            return resultMap;
        }
        for (SObject obj : resultItems) {
            String relationKey = String.valueOf(obj.get(this.cellRelation));
            List<String> keyList = relationConversionMap.containsKey(relationKey)
                ? relationConversionMap.get(relationKey)
                : new List<String>{ relationKey };
            for (String key : keyList) {
                if (!resultMap.containsKey(key)) {
                    resultMap.put(key, new List<SObject>());
                }
                List<SObject> groupedRecords = resultMap.get(key);
                groupedRecords.add(obj);
            }
        }
        return resultMap;
    }

    private Map<String, List<SObject>> mapByStandardRowAndColumnRelationships(
        List<SObject> resultItems,
        Map<String, List<String>> relationConversionMap
    ) {
        Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
        if (this.rowRelation == null || this.columnRelation == null) {
            return resultMap;
        }
        Boolean isColPicklist = WhiteSpaceUtils.isPicklistMappingType(this.columnMapping);
        String colFieldName = isColPicklist ? this.columnRelation : this.columnMapping.labelFieldName;
        Boolean isColMultiPicklist = WhiteSpaceUtils.isMultiPicklistMappingType(this.columnMapping, colFieldName);

        Boolean isRowPicklist = WhiteSpaceUtils.isPicklistMappingType(this.rowMapping);
        String rowFieldName = isRowPicklist ? this.rowRelation : this.rowMapping.labelFieldName;
        Boolean isRowMultiPicklist = WhiteSpaceUtils.isMultiPicklistMappingType(this.rowMapping, rowFieldName);

        for (SObject obj : resultItems) {
            String rowKey = String.valueOf(obj.get(this.rowRelation));
            List<String> rowKeyList = getKeyListFromKey(rowKey, relationConversionMap, isRowMultiPicklist);
            String colKey = String.valueOf(obj.get(this.columnRelation));
            List<String> colKeyList = getKeyListFromKey(colKey, relationConversionMap, isColMultiPicklist);
            for (String row : rowKeyList) {
                for (String col : colKeyList) {
                    String key = row + ' - ' + col;
                    if (!resultMap.containsKey(key)) {
                        resultMap.put(key, new List<SObject>());
                    }
                    List<SObject> groupedRecords = resultMap.get(key);
                    groupedRecords.add(obj);
                }
            }
        }
        return resultMap;
    }

    private List<String> getKeyListFromKey(
        String key,
        Map<String, List<String>> conversionMap,
        Boolean isMultiPicklist
    ) {
        return conversionMap.containsKey(key)
            ? conversionMap.get(key)
            : (isMultiPicklist ? key.split(';') : new List<String>{ key });
    }

    private Map<String, List<SObject>> mapByOpportunityProduct(
        List<SObject> resultItems,
        String otherRelationshipName,
        Boolean forRows,
        Map<String, List<String>> relationConversionMap
    ) {
        Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
        for (SObject opportunity : resultItems) {
            String otherKey = String.valueOf(opportunity.get(otherRelationshipName));
            List<String> otherKeyList = relationConversionMap.containsKey(otherKey)
                ? relationConversionMap.get(otherKey)
                : new List<String>{ otherKey };
            SObject[] opportunityLineItems = opportunity.getSObjects('OpportunityLineItems');
            if (opportunityLineItems != null) {
                for (SObject oppLineItem : opportunityLineItems) {
                    String product2Id = String.valueOf(oppLineItem.get(OPPORTUNITY_PRODUCT_RELATIONSHIP_FIELD_NAME));
                    List<String> product2IdList = relationConversionMap.containsKey(product2Id)
                        ? relationConversionMap.get(product2Id)
                        : new List<String>{ product2Id };
                    for (String productId : product2IdList) {
                        for (String secondaryKey : otherKeyList) {
                            String fullKey = forRows
                                ? productId + ' - ' + secondaryKey
                                : secondaryKey + ' - ' + productId;
                            if (!resultMap.containsKey(fullKey)) {
                                resultMap.put(fullKey, new List<SObject>());
                            }
                            List<SObject> opportunitiesForKey = resultMap.get(fullKey);
                            if (!opportunitiesForKey.contains(opportunity)) {
                                opportunitiesForKey.add(opportunity);
                            }
                            resultMap.put(fullKey, opportunitiesForKey);
                        }
                    }
                }
            }
        }
        return resultMap;
    }

    private Boolean hasOpportunityProductRelationship() {
        return this.mapping.description.getSObjectType() == Schema.Opportunity.SObjectType &&
            (this.isProductType(this.rowMapping) || this.isProductType(this.columnMapping));
    }

    private Boolean isProductType(WhiteSpaceTemplateMappingWrapper rowOrColumnMapping) {
        return rowOrColumnMapping?.description.getSObjectType() == Schema.Product2.SObjectType;
    }
}