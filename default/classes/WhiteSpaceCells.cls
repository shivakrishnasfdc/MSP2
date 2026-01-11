public with sharing class WhiteSpaceCells extends AccountPlanWSChildDomain {
    private WhiteSpaceCells(List<White_Space_Cell__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static WhiteSpaceCells newInstance(List<White_Space_Cell__c> sObjectList) {
        return (WhiteSpaceCells) Application.Domain.newInstance(sObjectList);
    }

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new WhiteSpaceCells(sObjectList);
        }
    }
}