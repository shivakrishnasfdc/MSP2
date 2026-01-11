@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class WhiteSpaceTileWrapper {
    @AuraEnabled
    public Id id { get; set; }

    @AuraEnabled
    public Id headerAmountTypeId { get; private set; }

    @AuraEnabled
    public String headerColor { get; private set; }

    @AuraEnabled
    public String headerText { get; private set; }

    @AuraEnabled
    public WS_Highlight__c highlight { get; private set; }

    @AuraEnabled
    public List<WSDataTypeValue> dataTypeValues { get; private set; }

    @AuraEnabled
    public List<WhiteSpaceDisplayFieldWrapper> displayFields { get; set; }

    public WhiteSpaceTileWrapper() {
    }

    @testVisible
    private WhiteSpaceTileWrapper(
        Id id,
        String headerColor,
        String headerText,
        Id headerAmountTypeId,
        WS_Highlight__c highlight,
        List<WSDataTypeValue> dataTypeValues,
        List<WhiteSpaceDisplayFieldWrapper> displayFields
    ) {
        this.id = id;
        this.headerColor = headerColor;
        this.headerText = headerText;
        this.headerAmountTypeId = headerAmountTypeId;
        this.highlight = highlight;
        this.dataTypeValues = dataTypeValues;
        this.displayFields = new List<WhiteSpaceDisplayFieldWrapper>();
        for (WhiteSpaceDisplayFieldWrapper field : displayFields) {
            if (field != null) {
                this.displayFields.add(field);
            }
        }
    }

    public static WhiteSpaceTileWrapper createFor(
        White_Space_Cell__c cell,
        List<White_Space_Amount_Type__c> amountTypes,
        List<WS_Data_Type__c> dataTypes,
        Map<String, List<SObject>> relatedData,
        List<White_Space_Amount_Type_Association__c> associations,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects
    ) {
        List<WhiteSpaceDisplayFieldWrapper> displayFields = buildDisplayFieldsFrom(
            cell,
            amountTypes,
            associations,
            relatedData,
            relatedFields,
            relatedObjects
        );

        String headerColor = null;
        String headerText = null;
        Id headerAmountTypeId = null;
        if (cell.Primary_Amount_Type__c != null) {
            for (White_Space_Amount_Type__c at : amountTypes) {
                if (at.Id == cell.Primary_Amount_Type__c) {
                    headerColor = at.Color_RGB__c;
                    headerText = at.Name;
                    headerAmountTypeId = at.Id;
                }
            }
        }

        return new WhiteSpaceTileWrapper(
            cell.id,
            headerColor,
            headerText,
            headerAmountTypeId,
            cell.Highlight__r,
            getDataTypeValues(dataTypes, cell),
            displayFields
        );
    }

    public static WhiteSpaceTileWrapper createFor(
        White_Space_Cell__c cell,
        List<White_Space_Amount_Type__c> amountTypes,
        List<WS_Data_Type__c> dataTypes,
        Map<String, List<SObject>> relatedMap,
        List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects
    ) {
        return createFor(
            cell,
            amountTypes,
            dataTypes,
            relatedMap,
            amountTypeFields,
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            relatedFields,
            relatedObjects,
            null
        );
    }

    public static WhiteSpaceTileWrapper createFor(
        White_Space_Cell__c cell,
        List<White_Space_Amount_Type__c> amountTypes,
        List<WS_Data_Type__c> dataTypes,
        Map<String, List<SObject>> relatedMap,
        List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields,
        List<WhiteSpaceTemplateCellFieldWrapper> basicFields,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects,
        Set<String> productIdSet
    ) {
        List<WhiteSpaceDisplayFieldWrapper> displayFields = buildDisplayFieldsFrom(
            cell,
            amountTypes,
            relatedMap,
            amountTypeFields,
            basicFields,
            relatedFields,
            relatedObjects,
            productIdSet
        );
        return new WhiteSpaceTileWrapper(
            cell.id,
            null,
            null,
            null,
            cell.Highlight__r,
            getDataTypeValues(dataTypes, cell),
            displayFields
        );
    }

    public White_Space_Cell__c toSObjectCell() {
        String infoText = null;
        Id primaryAmountType = null;
        if (this.displayFields == null) {
            this.displayFields = new List<WhiteSpaceDisplayFieldWrapper>();
        }
        for (WhiteSpaceDisplayFieldWrapper df : this.displayFields) {
            if (df.isInfoField == true && df.data != null && df.data.size() > 0) {
                //is info field and has valid data
                infoText = String.valueOf(df.data[0].value);
            }
            if (df.isPrimary != null && df.isPrimary) {
                primaryAmountType = df.id;
            }
        }
        return new White_Space_Cell__c(Id = this.id, Info__c = infoText, Primary_Amount_Type__c = primaryAmountType);
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private static List<WSDataTypeValue> getDataTypeValues(List<WS_Data_Type__c> dataTypes, White_Space_Cell__c cell) {
        if (dataTypes == null || dataTypes.size() <= 0) {
            return new List<WSDataTypeValue>();
        }

        Map<Id, WS_Data_Type__c> dataTypeById = new Map<Id, WS_Data_Type__c>(dataTypes);

        List<WSDataTypeValue> dataTypeValues = new List<WSDataTypeValue>();
        if (cell.Cross_Sell_Data_Type_Associations__r != null && cell.Cross_Sell_Data_Type_Associations__r.size() > 0) {
            for (WS_Data_Type_Association__c dataAssoc : cell.Cross_Sell_Data_Type_Associations__r) {
                WS_Data_Type__c dt = dataTypeById.get(dataAssoc.WS_Data_Type__c);
                if (dt != null) {
                    dataTypeValues.add(
                        new WSDataTypeValue(dataAssoc.Id, dt.Id, dt.Label__c, dataAssoc.WS_Data_Value__c, dt.Color__c)
                    );
                }
            }
        }

        return dataTypeValues;
    }

    private static List<WhiteSpaceDisplayFieldWrapper> buildDisplayFieldsFrom(
        White_Space_Cell__c cell,
        List<White_Space_Amount_Type__c> amountTypes,
        List<White_Space_Amount_Type_Association__c> associations,
        Map<String, List<SObject>> relatedMap,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects
    ) {
        List<WhiteSpaceDisplayFieldWrapper> displayFields = new List<WhiteSpaceDisplayFieldWrapper>();
        displayFields.add(WhiteSpaceDisplayFieldWrapper.infoFieldWrapper(cell));

        if (amountTypes != null) {
            //using direct method rather than Collection class to group the associations because it is more performant and this work is being done inside a loop
            Map<Id, List<White_Space_Amount_Type_Association__c>> associationsByAmountType = mapAssociationsByAmountType(
                associations
            );
            for (White_Space_Amount_Type__c amountType : amountTypes) {
                WhiteSpaceDisplayFieldWrapper newField = WhiteSpaceDisplayFieldWrapper.createFor(
                    amountType,
                    associationsByAmountType.get(amountType.Id),
                    cell.Primary_Amount_Type__c == amountType.Id
                );
                displayFields.add(newField);
            }
        }

        Map<String, WSRelatedObjectWrapper> relObjWrapMap = new Map<String, WSRelatedObjectWrapper>();
        for (WSRelatedObjectWrapper wrapper : relatedObjects) {
            relObjWrapMap.put(wrapper.objDesc.getName(), wrapper);
        }
        for (WhiteSpaceTemplateCellFieldWrapper relatedWrapper : relatedFields) {
            List<SObject> data = relatedMap != null ? relatedMap.get(relatedWrapper.id) : new List<SObject>();
            WhiteSpaceDisplayFieldWrapper newField = WhiteSpaceDisplayFieldWrapper.createFor(
                relObjWrapMap.get(relatedWrapper.id),
                relatedWrapper,
                data
            );
            displayFields.add(newField);
        }
        displayFields.sort();
        return displayFields;
    }

    private static List<WhiteSpaceDisplayFieldWrapper> buildDisplayFieldsFrom(
        White_Space_Cell__c cell,
        List<White_Space_Amount_Type__c> amountTypes,
        Map<String, List<SObject>> relatedMap,
        List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields,
        List<WhiteSpaceTemplateCellFieldWrapper> basicFields,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects,
        Set<String> productIdSet
    ) {
        List<WhiteSpaceDisplayFieldWrapper> displayFields = new List<WhiteSpaceDisplayFieldWrapper>();
        displayFields.add(WhiteSpaceDisplayFieldWrapper.infoFieldWrapper(cell));

        if (amountTypes != null && amountTypes.size() > 0) {
            Map<Id, White_Space_Amount_Type__c> amountTypeMap = new Map<Id, White_Space_Amount_Type__c>(amountTypes);
            for (WhiteSpaceTemplateCellFieldWrapper field : amountTypeFields) {
                White_Space_Amount_Type__c amtType = amountTypeMap.get(field.displayFieldId);
                if (amtType == null) {
                    continue;
                }
                List<SObject> data = relatedMap != null ? relatedMap.get(field.id) : new List<SObject>();
                WhiteSpaceDisplayFieldWrapper newField = WhiteSpaceDisplayFieldWrapper.createFor(
                    amtType,
                    field,
                    data,
                    productIdSet
                );
                displayFields.add(newField);
            }
        }

        for (WhiteSpaceTemplateCellFieldWrapper field : basicFields) {
            List<SObject> data = relatedMap != null ? relatedMap.get(field.id) : new List<SObject>();
            WhiteSpaceDisplayFieldWrapper newField = WhiteSpaceDisplayFieldWrapper.createFor(field, data);
            displayFields.add(newField);
        }

        Map<String, WSRelatedObjectWrapper> relObjWrapMap = new Map<String, WSRelatedObjectWrapper>();
        for (WSRelatedObjectWrapper wrapper : relatedObjects) {
            relObjWrapMap.put(wrapper.objDesc.getName(), wrapper);
        }
        for (WhiteSpaceTemplateCellFieldWrapper relatedWrapper : relatedFields) {
            List<SObject> data = relatedMap != null ? relatedMap.get(relatedWrapper.id) : new List<SObject>();
            WhiteSpaceDisplayFieldWrapper newField = WhiteSpaceDisplayFieldWrapper.createFor(
                relObjWrapMap.get(relatedWrapper.id),
                relatedWrapper,
                data
            );
            displayFields.add(newField);
        }
        displayFields.sort();
        return displayFields;
    }

    private static Map<Id, List<White_Space_Amount_Type_Association__c>> mapAssociationsByAmountType(
        List<White_Space_Amount_Type_Association__c> assocations
    ) {
        Map<Id, List<White_Space_Amount_Type_Association__c>> associationsByAmountType = new Map<Id, List<White_Space_Amount_Type_Association__c>>();
        for (White_Space_Amount_Type_Association__c association : assocations) {
            List<White_Space_Amount_Type_Association__c> assocationList = associationsByAmountType.get(
                association.White_Space_Amount_Type__c
            );
            if (assocationList == null) {
                assocationList = new List<White_Space_Amount_Type_Association__c>();
            }
            assocationList.add(association);
            associationsByAmountType.put(association.White_Space_Amount_Type__c, assocationList);
        }
        return associationsByAmountType;
    }
}