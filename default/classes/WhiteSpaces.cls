public with sharing class WhiteSpaces extends AccountPlanChildDomain {
    private WhiteSpaces(List<White_Space__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static WhiteSpaces newInstance(List<White_Space__c> sObjectList) {
        return (WhiteSpaces) Application.Domain.newInstance(sObjectList);
    }

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new WhiteSpaces(sObjectList);
        }
    }
}