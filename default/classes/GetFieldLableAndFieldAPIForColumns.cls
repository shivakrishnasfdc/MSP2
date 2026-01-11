public with sharing class GetFieldLableAndFieldAPIForColumns {
    /***********************************************************
     * Get Field Label and Field API Name of perticular object *
     ***********************************************************/
    @AuraEnabled(cacheable=true)
    public static List<GetAccountPlanChildWrapper> getFieldLableAndFieldAPI(String objectName) {
        List<Map<String, String>> listOfFieldSet = new List<Map<String, String>>();
        List<GetAccountPlanChildWrapper> options = new List<GetAccountPlanChildWrapper>();
        try {
            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Schema.FieldSet fieldSet = objectType.getDescribe().fieldSets.getMap().get(System.Label.FieldSetName);
            if (fieldSet != null) {
                for (Schema.FieldSetMember field : fieldSet.getFields()) {
                    options.add(new GetAccountPlanChildWrapper(field.getLabel(), field.getFieldPath()));
                    Map<String, String> lableAPIMap = new Map<String, String>();
                    lableAPIMap.put(field.getLabel(), field.getFieldPath());
                    listOfFieldSet.add(lableAPIMap);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        // return JSON.serialize(listOfFieldSet);
        return options;
    }
}