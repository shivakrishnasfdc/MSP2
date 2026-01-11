@SuppressWarnings('PMD.NcssMethodCount,PMD.AvoidDeeplyNestedIfStmts,PMD.CyclomaticComplexity,PMD.ApexSOQLInjection')
public with sharing class WhiteSpaceTemplateController {
    private static final String CONTACT_OBJ = 'Contact';
    @AuraEnabled
    public static List<SObjectMetadata> getSuggestedContactObject() {
        Map<String, Schema.SObjectType> gd = Application.getGlobalDescribe();
        Set<SObjectMetadata> objects = new Set<SObjectMetadata>();
        Schema.SObjectType obj = gd.get(CONTACT_OBJ);
        if (obj != null) {
            DescribeSObjectResult objDescribe = obj.getDescribe();
            if (shouldAddObjectType(objDescribe, true)) {
                objects.add(new SObjectMetadata(objDescribe));
            }
        }
        List<sObjectMetadata> objList = new List<sObjectMetadata>(objects);
        objList.sort();
        return objList;
    }
    @AuraEnabled
    public static List<SObjectMetadata> getObjects() {
        Map<String, Schema.SObjectType> gd = Application.getGlobalDescribe();
        Set<SObjectMetadata> objects = new Set<SObjectMetadata>();
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();
        List<String> objectNames = SettingService.getObjectNameListFromFilterString(settings?.WS_Object_Filter__c);
        if (objectNames.size() > 0) {
            for (String objectName : objectNames) {
                Schema.SObjectType obj = gd.get(objectName);
                if (obj == null) {
                    continue;
                }
                DescribeSObjectResult objDescribe = obj.getDescribe();
                if (shouldAddObjectType(objDescribe, true)) {
                    objects.add(new SObjectMetadata(objDescribe));
                }
            }
        } else if (!exceedsLimit('FieldPermissions') && !exceedsLimit('ObjectPermissions')) {
            Set<String> objectTypes = gd.keySet();
            Set<AggregateResult> objectSet = new Set<AggregateResult>();
            List<AggregateResult> objPerms = (List<AggregateResult>) new Query('ObjectPermissions', null)
                .selectField('SObjectType')
                .addConditionIn('SObjectType', objectTypes)
                .groupBy('SObjectType')
                .orderBy('SObjectType')
                .toSObjectList();
            objectSet.addAll(objPerms);
            List<AggregateResult> fieldPerms = (List<AggregateResult>) new Query('FieldPermissions', null)
                .selectField('SObjectType')
                .addConditionIn('SObjectType', objectTypes)
                .groupBy('SObjectType')
                .orderBy('SObjectType')
                .toSObjectList();
            objectSet.addAll(fieldPerms);
            for (AggregateResult perm : objectSet) {
                String objTypeName = (String) perm.get('SobjectType');
                Schema.SObjectType obj = gd.get(objTypeName);
                if (obj == null) {
                    continue;
                }
                DescribeSObjectResult objDescribe = obj.getDescribe();
                if (shouldAddObjectType(objDescribe)) {
                    objects.add(new SObjectMetadata(objDescribe));
                }
            }
            objects.add(new sObjectMetadata(User.sObjectType.getDescribe()));
        } else {
            for (Schema.SObjectType obj : gd.values()) {
                DescribeSObjectResult objDescribe = obj.getDescribe();
                if (shouldAddObjectType(objDescribe)) {
                    objects.add(new SObjectMetadata(objDescribe));
                }
            }
            objects.add(new sObjectMetadata(User.sObjectType.getDescribe()));
        }
        List<sObjectMetadata> objList = new List<sObjectMetadata>(objects);
        objList.sort();
        return objList;
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldMetadata> getFields(String sObjectApiName) {
        List<FieldMetadata> fields = new List<FieldMetadata>();
        Schema.SobjectType sobjectType = UTIL_Describe.getSObjectType(sobjectApiName);
        Schema.DescribeSobjectResult sobjectDescribe = sobjectType.getDescribe();
        for (Schema.SobjectField field : sobjectDescribe.fields.getMap().values()) {
            try {
                fields.add(new FieldMetadata(sobjectType, field));
            } catch (Exception e) {
                continue;
            }
        }
        fields.sort();
        return fields;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues(String objectName, String fieldName) {
        return UtilityForSObject.getPicklistSelectOptionsMap(objectName, fieldName);
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getRelatedObjectValues(String objectName, String fieldName) {
        Schema.DescribeFieldResult relFieldDesc = UTIL_Describe.getFieldDescribe(objectName, fieldName.toLowerCase());
        Schema.SObjectType relObjType = (Schema.SObjectType) UtilityForList.first(relFieldDesc.getReferenceTo());
        String nameField = UTIL_Describe.getNameField(relObjType.getDescribe().getName());
        List<SObject> objList = DynamicObjectQueryService.querySObjectListWithTypeAndFields(
            relObjType,
            new Set<String>{ nameField },
            nameField
        );
        List<Map<String, String>> selectOptions = new List<Map<String, String>>();
        for (SObject obj : objList) {
            selectOptions.add(new Map<String, String>{ 'label' => (String) obj.get(nameField), 'value' => obj.Id });
        }
        return selectOptions;
    }

    @AuraEnabled(cacheable=true)
    public static List<White_Space__c> getRelatedWhiteSpaces(Id templateId) {
        return WhiteSpaceSelector.newInstance().selectByTemplateId(templateId);
    }

    @AuraEnabled
    public static WhiteSpaceTemplateWrapper createWhiteSpaceTemplate(WhiteSpaceTemplateWrapper templateWrapper) {
        validateTemplate(templateWrapper);

        fflib_ISObjectUnitOfWork uow = Application.WsTemplateUnitOfWork.newInstance();
        Mapping__c rowMapping = registerMapping(uow, templateWrapper.rowConfiguration.mapping);
        Mapping__c columnMapping = registerMapping(uow, templateWrapper.columnConfiguration.mapping);

        White_Space_Template__c template = new White_Space_Template__c(
            name = templateWrapper.name,
            RowMapping__c = rowMapping.id,
            ColumnMapping__c = columnMapping.id,
            hasDependentPicklistColumns__c = templateWrapper.columnConfiguration.usePicklistDependency,
            hasDependentPicklistRows__c = templateWrapper.rowConfiguration.usePicklistDependency
        );
        uow.registerRelationship(template, White_Space_Template__c.RowMapping__c, rowMapping);
        uow.registerRelationship(template, White_Space_Template__c.ColumnMapping__c, columnMapping);
        uow.registerNew(template);

        registerTemplateCellFields(uow, template, templateWrapper);
        uow.commitWork();
        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper(template);
        return wrapper;
    }

    @AuraEnabled
    public static WhiteSpaceTemplateWrapper updateWhiteSpaceTemplate(WhiteSpaceTemplateWrapper templateWrapper) {
        validateTemplate(templateWrapper);

        fflib_ISObjectUnitOfWork uow = Application.WsTemplateUnitOfWork.newInstance();
        Mapping__c rowMapping = registerMapping(uow, templateWrapper.rowConfiguration.mapping);
        Mapping__c columnMapping = registerMapping(uow, templateWrapper.columnConfiguration.mapping);

        White_Space_Template__c template = new White_Space_Template__c(
            Id = templateWrapper.id,
            name = templateWrapper.name,
            RowMapping__c = rowMapping.id,
            ColumnMapping__c = columnMapping.id,
            hasDependentPicklistColumns__c = templateWrapper.columnConfiguration.usePicklistDependency,
            hasDependentPicklistRows__c = templateWrapper.rowConfiguration.usePicklistDependency
        );
        uow.registerRelationship(template, White_Space_Template__c.RowMapping__c, rowMapping);
        uow.registerRelationship(template, White_Space_Template__c.ColumnMapping__c, columnMapping);
        uow.registerDirty(template);

        List<White_Space_Template_Cell_Field__c> existingCellFields = WhiteSpaceTemplateCellFieldSelector.newInstance()
            .selectByWhiteSpaceTemplateId(new Set<Id>{ templateWrapper.id });

        if (!existingCellFields.isEmpty()) {
            Set<Id> idsToKeep = new Set<Id>();
            List<WhiteSpaceTemplateCellFieldWrapper> dynamicFields = new List<WhiteSpaceTemplateCellFieldWrapper>();
            if (templateWrapper.amountTypeFields != null && !templateWrapper.amountTypeFields.isEmpty()) {
                dynamicFields.addAll(templateWrapper.amountTypeFields.values());
            }
            if (templateWrapper.basicFields != null && !templateWrapper.basicFields.isEmpty()) {
                dynamicFields.addAll(templateWrapper.basicFields);
            }
            for (WhiteSpaceTemplateCellFieldWrapper field : dynamicFields) {
                if (field.id != null) {
                    idsToKeep.add(field.id);
                }
            }

            Map<Id, White_Space_Amount_Type__c> activeAmountTypes = new Map<Id, White_Space_Amount_Type__c>(
                WhiteSpaceAmountTypeSelector.newInstance().selectAll()
            );

            for (White_Space_Template_Cell_Field__c field : existingCellFields) {
                if (field.DisplayFieldId__c == null) {
                    if (!idsToKeep.contains(field.id)) {
                        uow.registerDeleted(field);
                    }
                } else {
                    // Delete amount type cell fields only if they are active
                    if (!idsToKeep.contains(field.id) && activeAmountTypes.containsKey(field.DisplayFieldId__c)) {
                        uow.registerDeleted(field);
                    }
                }
            }
        }

        registerTemplateCellFields(uow, template, templateWrapper);
        uow.commitWork();
        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper(template);
        return wrapper;
    }

    private static void registerTemplateCellFields(
        fflib_ISObjectUnitOfWork uow,
        White_Space_Template__c template,
        WhiteSpaceTemplateWrapper templateWrapper
    ) {
        List<WhiteSpaceTemplateCellFieldWrapper> dynamicFields = new List<WhiteSpaceTemplateCellFieldWrapper>();
        if (templateWrapper.amountTypeFields != null && !templateWrapper.amountTypeFields.isEmpty()) {
            dynamicFields.addAll(templateWrapper.amountTypeFields.values());
        }
        if (templateWrapper.basicFields != null && !templateWrapper.basicFields.isEmpty()) {
            dynamicFields.addAll(templateWrapper.basicFields);
        }

        for (WhiteSpaceTemplateCellFieldWrapper fieldWrapper : dynamicFields) {
            validateCellFieldMapping(fieldWrapper);
            Mapping__c mapping = registerMapping(uow, fieldWrapper.mapping);

            White_Space_Template_Cell_Field__c field = new White_Space_Template_Cell_Field__c(
                Id = fieldWrapper.id,
                DisplayFieldId__c = fieldWrapper.displayFieldId,
                WhitespaceTemplate__c = template.id,
                ValueMapping__c = mapping.id
            );

            if (fieldWrapper.id == null) {
                uow.registerRelationship(field, White_Space_Template_Cell_Field__c.WhitespaceTemplate__c, template);
            }

            uow.registerRelationship(field, White_Space_Template_Cell_Field__c.ValueMapping__c, mapping);

            if (field.id != null) {
                uow.registerDirty(field);
            } else {
                uow.registerNew(field);
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<White_Space_Amount_Type__c> getWhiteSpaceAmountTypes() {
        List<White_Space_Amount_Type__c> amountTypes = new List<White_Space_Amount_Type__c>();
        amountTypes = WhiteSpaceAmountTypeSelector.newInstance().selectAll();
        return amountTypes;
    }

    private static void validateTemplate(WhiteSpaceTemplateWrapper templateWrapper) {
        if (templateWrapper == null) {
            throw new AuraHandledException('Missing required template parameter');
        }

        if (String.isBlank(templateWrapper.name)) {
            throw new AuraHandledException('Please provide a name for this template');
        }

        if (templateWrapper.rowConfiguration?.mapping == null || templateWrapper.columnConfiguration?.mapping == null) {
            throw new AuraHandledException('column and row configurations must be populated.');
        }

        validateRowOrColumnMapping(templateWrapper.rowConfiguration.mapping);
        validateRowOrColumnMapping(templateWrapper.columnConfiguration.mapping);
    }

    private static void validateRowOrColumnMapping(WhiteSpaceTemplateMappingWrapper mappingWrapper) {
        validateMappingObjectType(mappingWrapper.objectName);
        if (WhiteSpaceUtils.isPicklistMappingType(mappingWrapper)) {
            validateMappingField(mappingWrapper.objectName, mappingWrapper.valueFieldName);
        } else {
            validateMappingField(mappingWrapper.objectName, mappingWrapper.labelFieldName);
        }
    }

    private static void validateCellFieldMapping(WhiteSpaceTemplateCellFieldWrapper fieldWrapper) {
        if (fieldWrapper.displayFieldId != null) {
            validateAmountTypeMapping(fieldWrapper.mapping);
        } else {
            validateBasicMapping(fieldWrapper.mapping);
        }
    }

    private static void validateAmountTypeMapping(WhiteSpaceTemplateMappingWrapper mappingWrapper) {
        validateMappingObjectType(mappingWrapper.objectName);
        validateMappingField(mappingWrapper.objectName, mappingWrapper.labelFieldName);
        validateMappingField(mappingWrapper.objectName, mappingWrapper.valueFieldName);
    }

    private static void validateBasicMapping(WhiteSpaceTemplateMappingWrapper mappingWrapper) {
        validateMappingObjectType(mappingWrapper.objectName);
        validateMappingField(mappingWrapper.objectName, mappingWrapper.labelFieldName);
    }

    private static void validateMappingObjectType(String objectName) {
        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Target object cannot be empty');
        }

        if (UTIL_Describe.getSObjectType(objectName) == null) {
            throw new AuraHandledException(objectName + ' is not a valid object.');
        }
    }

    private static void validateMappingField(String objectName, String fieldName) {
        if (String.isBlank(fieldName)) {
            throw new AuraHandledException('Required field cannot be empty');
        }

        if (fieldName.contains('.')) {
            String subObjName = fieldName.substringBefore('.');
            if (objectName != 'Opportunity' || subObjName != 'OpportunityLineItem') {
                throw new AuraHandledException(
                    subObjName +
                    ' is not a valid related object to the ' +
                    objectName +
                    ' object.'
                );
            }
            String subFieldName = fieldName.substringAfter('.');
            if (!UTIL_Describe.isValidField(subObjName, subFieldName)) {
                throw new AuraHandledException(
                    subFieldName +
                    ' is not a valid field for the ' +
                    subObjName +
                    ' object.'
                );
            }
        } else if (!UTIL_Describe.isValidField(objectName, fieldName)) {
            throw new AuraHandledException(fieldName + ' is not a valid field for the ' + objectName + ' object.');
        }
    }

    private static Mapping__c registerMapping(
        fflib_ISObjectUnitOfWork uow,
        WhiteSpaceTemplateMappingWrapper mappingWrapper
    ) {
        Mapping__c newMapping = new Mapping__c(
            Id = mappingWrapper.id,
            Name = mappingWrapper.name,
            ObjectType__c = mappingWrapper.objectName,
            DisplayLabelField__c = mappingWrapper.labelFieldName,
            ParentField__c = mappingWrapper.parentIdFieldName,
            GroupResults__c = mappingWrapper?.groupResults != null ? mappingWrapper.groupResults : false,
            ValueField__c = mappingWrapper.valueFieldName
        );
        if (mappingWrapper.id != null) {
            uow.registerDirty(newMapping);
            List<Mapping_Condition_Group__c> conditionGroups = MappingConditionGroupSelector.newInstance()
                .selectByMappingId(new Set<Id>{ mappingWrapper.id });
            uow.registerDeleted(conditionGroups);
        } else {
            uow.registerNew(newMapping);
        }

        if (mappingWrapper.conditions != null && !mappingWrapper.conditions.singleConditions.isEmpty()) {
            Mapping_Condition_Group__c newCondGroup = new Mapping_Condition_Group__c(
                Operator__c = mappingWrapper.conditions.operator
            );
            uow.registerNew(newCondGroup, Mapping_Condition_Group__c.Mapping__c, newMapping);
            for (MappingConditionWrapper mcw : mappingWrapper.conditions.singleConditions) {
                Mapping_Condition__c cond = new Mapping_Condition__c(
                    Field__c = mcw.singleCondition.Field__c,
                    Operator__c = mcw.singleCondition.Operator__c,
                    Value__c = mcw.singleCondition.Value__c
                );
                uow.registerNew(cond, Mapping_Condition__c.Condition_Group__c, newCondGroup);
            }
        }
        return newMapping;
    }

    private static Boolean exceedsLimit(String table) {
        Integer queryRowLimit = Limits.getLimitQueryRows();
        Integer queryCount = Database.countQuery('SELECT count() FROM ' + table + ' limit :queryRowLimit');
        return queryCount == queryRowLimit;
    }

    private static Boolean shouldAddObjectType(Schema.DescribeSObjectResult describe) {
        return shouldAddObjectType(describe, false);
    }

    private static Boolean shouldAddObjectType(Schema.DescribeSObjectResult describe, Boolean skipSearchCheck) {
        if (describe.getSobjectType() == OpportunityLineItem.SObjectType) {
            return true;
        }
        return describe.isAccessible() &&
            describe.isQueryable() &&
            (describe.isSearchable() || skipSearchCheck) &&
            !describe.isCustomSetting();
    }
}