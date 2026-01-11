public with sharing class WhiteSpaceRows extends AccountPlanWSChildDomain {
    private WhiteSpaceRows(List<White_Space_Row__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static WhiteSpaceRows newInstance(List<White_Space_Row__c> sObjectList) {
        return (WhiteSpaceRows) Application.Domain.newInstance(sObjectList);
    }

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new WhiteSpaceRows(sObjectList);
        }
    }
}