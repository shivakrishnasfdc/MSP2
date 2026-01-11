@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class WhiteSpaceTemplateMappingWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String objectName { get; set; }
    @AuraEnabled
    public String objectLabel { get; private set; }
    @AuraEnabled
    public String objectLabelPlural { get; private set; }
    @AuraEnabled
    public String labelFieldName { get; set; }
    @AuraEnabled
    public String valueFieldName { get; set; }
    @AuraEnabled
    public String parentIdFieldName { get; set; }
    @AuraEnabled
    public Boolean groupResults { get; set; }
    @AuraEnabled
    public ConditionModel conditions { get; set; }
    @AuraEnabled
    public Boolean isObjectCreateable { get; set; }

    @AuraEnabled
    public FieldMetaData valueFieldInfo { get; private set; }

    @AuraEnabled
    public FieldMetaData labelFieldInfo { get; private set; }

    public DescribeSObjectResult description { get; private set; }

    public WhiteSpaceTemplateMappingWrapper() {
        this(null, null);
    }

    public WhiteSpaceTemplateMappingWrapper(String objectName, String labelField, String valueField) {
        if (objectName == null) {
            return;
        }
        this.objectName = objectName;
        this.labelFieldName = labelField;
        this.valueFieldName = valueField;
        this.groupResults = false;
        setupAutomaticFields();
    }

    public WhiteSpaceTemplateMappingWrapper(Mapping__c mapping) {
        this(
            mapping,
            mapping.Condition_Groups__r != null
                ? mapping.Condition_Groups__r
                : MappingConditionGroupSelector.newInstance().selectByMappingId(new Set<Id>{ mapping.Id })
        );
    }

    public WhiteSpaceTemplateMappingWrapper(Mapping__c mapping, List<Mapping_Condition_Group__c> conditionGroups) {
        if (mapping == null) {
            return;
        }
        this.id = mapping.id;
        this.name = mapping.Name;
        this.objectName = mapping.ObjectType__c;
        this.labelFieldName = mapping.DisplayLabelField__c;
        this.valueFieldName = mapping.ValueField__c;
        this.parentIdFieldName = mapping.ParentField__c;
        this.groupResults = mapping.GroupResults__c;
        this.conditions = buildConditions(mapping, conditionGroups);
        setupAutomaticFields();
    }

    public WhiteSpaceTemplateMappingWrapper(WSRelatedObjectWrapper relationshipWrapper) {
        this.objectName = relationshipWrapper.objDesc.getName();
        this.labelFieldName = relationshipWrapper.labelFieldName;
        this.valueFieldName = relationshipWrapper.labelFieldName;
        setupAutomaticFields(relationshipWrapper);
        this.labelFieldInfo = this.valueFieldInfo;
    }

    private void setupAutomaticFields() {
        this.description = UTIL_Describe.getObjectDescribe(this.objectName);
        this.objectLabel = UTIL_Describe.getObjectLabel(this.objectName);
        this.objectLabelPlural = UTIL_Describe.getObjectLabelPlural(this.objectName);
        this.isObjectCreateable = this.description.isCreateable();

        if (String.isNotBlank(this.valueFieldName)) {
            if (this.valueFieldName.contains('.')) {
                String subObjName = this.valueFieldName.substringBefore('.');
                String subFieldName = this.valueFieldName.substringAfter('.');
                this.valueFieldInfo = new FieldMetadata(subObjName, subFieldName);
            } else {
                this.valueFieldInfo = new FieldMetadata(this.objectName, this.valueFieldName);
            }
        }
        if (String.isNotBlank(this.labelFieldName)) {
            if (this.labelFieldName.contains('.')) {
                String subObjName = this.labelFieldName.substringBefore('.');
                String subFieldName = this.labelFieldName.substringAfter('.');
                this.labelFieldInfo = new FieldMetadata(subObjName, subFieldName);
            } else {
                this.labelFieldInfo = new FieldMetadata(this.objectName, this.labelFieldName);
            }
        }
    }

    private void setupAutomaticFields(WSRelatedObjectWrapper relationshipWrapper) {
        this.description = relationshipWrapper.objDesc;
        this.objectLabel = relationshipWrapper.objDesc.getLabel();
        this.objectLabelPlural = relationshipWrapper.objDesc.getLabelPlural();
        this.isObjectCreateable = this.description.isCreateable();

        if (relationshipWrapper.objDesc != null && relationshipWrapper.labelFieldDesc != null) {
            this.valueFieldInfo = new FieldMetadata(
                relationshipWrapper.objDesc.getSObjectType(),
                relationshipWrapper.labelFieldDesc.getSobjectField()
            );
        }
    }

    private static ConditionModel buildConditions(
        Mapping__c mapping,
        List<Mapping_Condition_Group__c> conditionGroups
    ) {
        if (!conditionGroups.isEmpty()) {
            Mapping_Condition_Group__c root = (Mapping_Condition_Group__c) new Collection(conditionGroups)
                .find(Mapping_Condition_Group__c.Parent_Condition_Group__c, '==', null);
            root = root != null ? root : conditionGroups[0];
            ConditionModel model = new ConditionModel();
            model.singleConditions = new List<MappingConditionWrapper>();
            model.operator = root.Operator__c;
            List<Mapping_Condition__c> mappingConditions = MappingConditionSelector.newInstance()
                .selectByConditionGroupId(new Set<Id>{ root.id });
            for (Mapping_Condition__c mappingCondition : mappingConditions) {
                model.singleConditions.add(new MappingConditionWrapper(mappingCondition, mapping.ObjectType__c));
            }

            return model;
        }
        return null;
    }

    public List<String> getQueryFields() {
        List<String> queryFields = new List<String>();
        if (String.isNotBlank(this.labelFieldName) && !this.labelFieldName.startsWith('OpportunityLineItem.')) {
            queryFields.add(this.labelFieldName);
        }
        if (String.isNotBlank(this.valueFieldName) && !this.valueFieldName.startsWith('OpportunityLineItem.')) {
            queryFields.add(this.valueFieldName);
        }
        if (String.isNotBlank(this.parentIdFieldName) && !this.parentIdFieldName.startsWith('OpportunityLineItem.')) {
            queryFields.add(this.parentIdFieldName);
        }
        return queryFields;
    }

    public List<String> getOLIQueryFields() {
        List<String> queryFields = new List<String>();
        if (String.isNotBlank(this.labelFieldName) && this.labelFieldName.startsWith('OpportunityLineItem.')) {
            queryFields.add(this.labelFieldName);
        }
        if (String.isNotBlank(this.valueFieldName) && this.valueFieldName.startsWith('OpportunityLineItem.')) {
            queryFields.add(this.valueFieldName);
        }
        if (String.isNotBlank(this.parentIdFieldName) && this.parentIdFieldName.startsWith('OpportunityLineItem.')) {
            queryFields.add(this.parentIdFieldName);
        }
        return queryFields;
    }
}