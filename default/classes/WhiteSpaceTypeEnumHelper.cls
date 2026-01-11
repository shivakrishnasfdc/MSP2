public with sharing class WhiteSpaceTypeEnumHelper {
    public static WhiteSpaceTypeEnum getTypeFrom(White_Space__c whiteSpace, White_Space_Template__c template) {
        return whiteSpace.White_Space_Template__c == null ? WhiteSpaceTypeEnum.FREE_FORM : getTypeFrom(template);
    }

    public static WhiteSpaceTypeEnum getTypeFrom(White_Space_Template__c template) {
        WhiteSpaceTypeEnum type = null;
        if (template != null) {
            if (template.isLegacy__c) {
                type = WhiteSpaceTypeEnum.LEGACY_TEMPLATE;
            } else if (template.hasDependentPicklistColumns__c || template.hasDependentPicklistRows__c) {
                type = WhiteSpaceTypeEnum.DEPENDENT_PICKLIST;
            } else {
                type = WhiteSpaceTypeEnum.TEMPLATE;
            }
        }
        return type;
    }
}