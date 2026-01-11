public with sharing class WhiteSpaceTemplatePickerController {
    @AuraEnabled
    public static List<TemplateInfo> getTemplateList() {
        List<TemplateInfo> templates = new List<TemplateInfo>();
        for (White_Space_Template__c temp : WhiteSpaceTemplateSelector.newInstance().selectAllWithRowColumnMappings()) {
            try {
                TemplateInfo templateInfo = new TemplateInfo(temp);
                templates.add(templateInfo);
            } catch (Exception e) {
                continue;
            }
        }
        return templates;
    }

    @AuraEnabled
    public static WhiteSpaceTemplateWrapper getTemplateWrapper(Id templateId) {
        try {
            White_Space_Template__c template = WhiteSpaceTemplateSelector.newInstance()
                .selectById(new Set<Id>{ templateId })[0];
            return new WhiteSpaceTemplateWrapper(template);
        } catch (Exception e) {
            Application.throwAuraHandledException(e);
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getHeaderTotals(
        WhiteSpaceTemplateMappingWrapper columnMapping,
        WhiteSpaceTemplateMappingWrapper rowMapping
    ) {
        return new Map<String, Integer>{
            'columnTotal' => WhiteSpaceUtils.getTotalCount(columnMapping),
            'rowTotal' => WhiteSpaceUtils.getTotalCount(rowMapping)
        };
    }

    public class TemplateInfo {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String columnName;
        @AuraEnabled
        public String rowName;

        @TestVisible
        private TemplateInfo(White_Space_Template__c template) {
            this.id = template.id;
            this.name = template.name;
            this.columnName = String.isBlank(template.Column_Object_Name__c)
                ? getHeaderDisplayValueForMapping(template.ColumnMapping__r)
                : UTIL_Describe.getObjectLabelPlural(template.Column_Object_Name__c);
            this.rowName = String.isBlank(template.Row_Object_Name__c)
                ? getHeaderDisplayValueForMapping(template.RowMapping__r)
                : UTIL_Describe.getObjectLabelPlural(template.Row_Object_Name__c);
        }
    }

    private static String getHeaderDisplayValueForMapping(Mapping__c mapping) {
        String returnValue = '';
        if (WhiteSpaceUtils.isPicklistMappingType(mapping)) {
            returnValue = UTIL_Describe.getFieldLabelSafe(mapping.ObjectType__c, mapping.ValueField__c);
        } else {
            returnValue = UTIL_Describe.getObjectLabelPlural(mapping.ObjectType__c);
        }
        return returnValue;
    }
}