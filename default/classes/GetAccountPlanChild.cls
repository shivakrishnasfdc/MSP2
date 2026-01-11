public with sharing class GetAccountPlanChild {
    /*******************************
     * Get childs of Account plan *
     *******************************/
    @AuraEnabled(cacheable=true)
    public static List<GetAccountPlanChildWrapper> getRelatedChild() {
        List<GetAccountPlanChildWrapper> options = new List<GetAccountPlanChildWrapper>();
        List<GetAccountPlanChildWrapper> options1 = new List<GetAccountPlanChildWrapper>();
        try {
            Schema.DescribeSObjectResult sObjectList = pqcrush__Account_Plan__c.SObjectType.getDescribe();
            for (Schema.ChildRelationship cr : sObjectList.getChildRelationships()) {
                if (cr.getChildSObject().getDescribe().isCustom()) {
                    options.add(
                        new GetAccountPlanChildWrapper(
                            cr.getChildSObject().getDescribe().getLabel(),
                            cr.getChildSObject().getDescribe().getName()
                        )
                    );
                }
            }
            for (GetAccountPlanChildWrapper temp : options) {
                if (temp.label != 'Account Plan Template') {
                    options1.add(temp);
                }
            }
            return options1;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}