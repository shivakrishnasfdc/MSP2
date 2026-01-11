public with sharing class WhiteSpaceColumns extends AccountPlanWSChildDomain {
    private WhiteSpaceColumns(List<White_Space_Column__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static WhiteSpaceColumns newInstance(List<White_Space_Column__c> sObjectList) {
        return (WhiteSpaceColumns) Application.Domain.newInstance(sObjectList);
    }

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new WhiteSpaceColumns(sObjectList);
        }
    }
}