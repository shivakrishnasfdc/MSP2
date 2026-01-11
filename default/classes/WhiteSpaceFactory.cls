public with sharing class WhiteSpaceFactory {
    public WhiteSpaceAbstract makeWhiteSpaceAbstract(White_Space__c whiteSpaceInfo, White_Space_Template__c template) {
        WhiteSpaceTypeEnum type = WhiteSpaceTypeEnumHelper.getTypeFrom(whiteSpaceInfo, template);
        WhiteSpaceAbstract newWhiteSpaceResult = null;

        if (type.equals(WhiteSpaceTypeEnum.TEMPLATE)) {
            newWhiteSpaceResult = new WhiteSpaceFromTemplate(whiteSpaceInfo, template);
        } else if (type.equals(WhiteSpaceTypeEnum.FREE_FORM)) {
            newWhiteSpaceResult = new WhiteSpaceFreeForm(whiteSpaceInfo);
        } else if (type.equals(WhiteSpaceTypeEnum.LEGACY_TEMPLATE)) {
            newWhiteSpaceResult = new WhiteSpaceFromLegacyTemplate(whiteSpaceInfo, template);
        } else if (type.equals(WhiteSpaceTypeEnum.DEPENDENT_PICKLIST)) {
            newWhiteSpaceResult = new WhiteSpaceFromDependentPicklistTemplate(whiteSpaceInfo, template);
        }

        return newWhiteSpaceResult.build();
    }
}