@SuppressWarnings('PMD.ExcessivePublicCount,PMD.EmptyStatementBlock')
public with sharing class WhiteSpaceTemplateWrapper {
    public static final String PICKLIST_TYPE = 'picklistvalues';
    public static final String RECORD_TYPE = 'records';
    public static final String FREE_FORM = 'freeform';

    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public Boolean isLegacyTemplate { get; set; }
    @AuraEnabled
    public Boolean hasDependentPicklistColumns { get; set; }
    @AuraEnabled
    public Boolean hasDependentPicklistRows { get; set; }
    @AuraEnabled
    public Map<Id, WhiteSpaceTemplateCellFieldWrapper> amountTypeFields { get; set; }
    @AuraEnabled
    public List<WhiteSpaceTemplateCellFieldWrapper> basicFields { get; set; }
    @AuraEnabled
    public HeaderConfiguration columnConfiguration { get; set; }
    @AuraEnabled
    public HeaderConfiguration rowConfiguration { get; set; }

    public WhiteSpaceTemplateWrapper() {
        this(null);
    }

    public WhiteSpaceTemplateWrapper(White_Space_Template__c wsTemplate) {
        if (wsTemplate == null) {
            return;
        }
        this.id = wsTemplate.Id;
        this.name = wsTemplate.Name;
        this.hasDependentPicklistColumns = wsTemplate.hasDependentPicklistColumns__c;
        this.hasDependentPicklistRows = wsTemplate.hasDependentPicklistRows__c;
        this.isLegacyTemplate = wsTemplate.isLegacy__c;

        Crush_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();

        if (this.isLegacyTemplate) {
            setupLegacyMappings(wsTemplate, orgSettings);
        } else {
            setupMappings(wsTemplate, orgSettings);
        }
    }

    public void setupLegacyMappings(White_Space_Template__c wsTemplate, Crush_Settings_Obj__c orgSettings) {
        WhiteSpaceTemplateMappingWrapper rowMapping = new WhiteSpaceTemplateMappingWrapper(
            wsTemplate.Row_Object_Name__c,
            wsTemplate.Row_Label_Field_Name__c,
            wsTemplate.Row_Label_Field_Name__c
        );
        this.rowConfiguration = new HeaderConfiguration(rowMapping, false);
        WhiteSpaceTemplateMappingWrapper columnMapping = new WhiteSpaceTemplateMappingWrapper(
            wsTemplate.Column_Object_Name__c,
            wsTemplate.Column_Label_Field_Name__c,
            wsTemplate.Column_Label_Field_Name__c
        );
        this.columnConfiguration = new HeaderConfiguration(columnMapping, false);
        this.amountTypeFields = new Map<Id, WhiteSpaceTemplateCellFieldWrapper>();
    }

    public void setupMappings(White_Space_Template__c wsTemplate, Crush_Settings_Obj__c orgSettings) {
        Map<Id, White_Space_Amount_Type__c> inactiveAmountTypes = new Map<Id, White_Space_Amount_Type__c>(
            WhiteSpaceAmountTypeSelector.newInstance().selectInactive()
        );

        List<White_Space_Template_Cell_Field__c> cellFields = WhiteSpaceTemplateCellFieldSelector.newInstance()
            .selectByWhiteSpaceTemplateIdExcludingDisplayFieldIds(new Set<Id>{ this.id }, inactiveAmountTypes.keySet());

        Set<Id> mappingIds = new Set<Id>(
            (Set<Id>) Collection.getUniqueValues(cellFields, White_Space_Template_Cell_Field__c.ValueMapping__c)
        );
        mappingIds.add(wsTemplate.RowMapping__c);
        mappingIds.add(wsTemplate.ColumnMapping__c);
        List<Mapping__c> allMappings = MappingSelector.newInstance().selectByIdWithConditionGroups(mappingIds);
        Map<Id, Mapping__c> mappingsById = new Map<Id, Mapping__c>(allMappings);
        Mapping__c rowMap = mappingsById.get(wsTemplate.RowMapping__c);
        this.rowConfiguration = rowMap != null ? new HeaderConfiguration(rowMap, this.hasDependentPicklistRows) : null;
        Mapping__c colMap = mappingsById.get(wsTemplate.ColumnMapping__c);
        this.columnConfiguration = colMap != null
            ? new HeaderConfiguration(colMap, this.hasDependentPicklistColumns)
            : null;
        this.amountTypeFields = new Map<Id, WhiteSpaceTemplateCellFieldWrapper>();
        this.basicFields = new List<WhiteSpaceTemplateCellFieldWrapper>();

        for (White_Space_Template_Cell_Field__c field : cellFields) {
            WhiteSpaceTemplateCellFieldWrapper cellWrapper = new WhiteSpaceTemplateCellFieldWrapper(
                field,
                mappingsById,
                this.rowConfiguration.mapping,
                this.columnConfiguration.mapping,
                orgSettings.Can_Create_Objects_In_Cross_Sell__c
            );
            if (field.DisplayFieldId__c != null) {
                this.amountTypeFields.put(field.DisplayFieldId__c, cellWrapper);
            } else {
                this.basicFields.add(cellWrapper);
            }
        }
    }

    public class HeaderConfiguration {
        @AuraEnabled
        public Boolean usePicklistDependency { get; set; }
        @AuraEnabled
        public WhiteSpaceTemplateMappingWrapper mapping { get; set; }
        @AuraEnabled
        public String type {
            get {
                if (mapping != null) {
                    return WhiteSpaceUtils.isPicklistMappingType(mapping) ? PICKLIST_TYPE : RECORD_TYPE;
                }
                return FREE_FORM;
            }
        }

        public HeaderConfiguration() {
        }

        public HeaderConfiguration(Mapping__c mapping, Boolean usePicklistDependency) {
            this(new WhiteSpaceTemplateMappingWrapper(mapping), usePicklistDependency);
        }

        public HeaderConfiguration(WhiteSpaceTemplateMappingWrapper mapping, Boolean usePicklistDependency) {
            this.usePicklistDependency = usePicklistDependency;
            this.mapping = mapping;
        }
    }
}