public with sharing class InputLookupController {
    /******************************
     *      PUBLIC METHODS
     ******************************/

    /**
     * Searchs (using SOSL) for a given sObject type. If no query string is provided,
     * a list of the 5 most recently viewed items of that type are returned instead.
     * @param  type         The sObject type to search.
     * @param  searchString The string to match results against.
     * @return              A list of sObjects that match the search string.
     */
    @AuraEnabled
    public static List<LookupSearchResult> searchSObject(
        String type,
        String searchString,
        String displayFieldName,
        List<String> selectedIds
    ) {
        if (
            String.isBlank(type) ||
            application.getGlobalDescribe().get(type) == null ||
            !UTIL_Describe.isValidField(type, displayFieldName)
        ) {
            return null;
        }
        String objNameField = UTIL_Describe.getNameField(type);

        if (selectedIds == null) {
            selectedIds = new List<String>();
        }

        if (String.isBlank(searchString)) {
            List<RecentlyViewed> records = DynamicObjectQueryService.queryRecentlyViewedExcludingIds(type, selectedIds);
            return processRecentlyViewedResults(records);
        } else {
            List<sObject> records = DynamicObjectQueryService.searchSObjectsWithTypeAndFieldsExcludingIds(
                type,
                searchString,
                objNameField,
                displayFieldName,
                selectedIds
            );
            return processSObjectResultsForFields(records, type, displayFieldName, objNameField);
        }
    }

    /**
     * Searchs (using SOSL) for multiple SObjectTypes represented by the InputLookupTypeObject list. If no query string is provided,
     * a list of the 5 most recently viewed items of those types are returned instead.
     * @param  types        The InputLookupTypeObject list representing the objects to search.
     * @param  searchString The string to match results against.
     * @return              A list of LookupSearchResult that match the search string.
     */
    @AuraEnabled
    public static List<LookupSearchResult> searchWithInputLookupObjects(
        List<InputLookupTypeObject> types,
        String searchString
    ) {
        if (types == null || types.size() == 0) {
            return null;
        }
        if (String.isBlank(searchString)) {
            List<RecentlyViewed> records = DynamicObjectQueryService.queryRecentlyViewedWithLookupTypes(types);
            return processRecentlyViewedResults(records);
        } else {
            List<SObject> records = DynamicObjectQueryService.searchSObjectsWithLookupTypes(types, searchString);
            return processSObjectResultsForInputLookups(records, types);
        }
    }

    /*
     * Loads the initial value of the given SObject type with Id "value"
     */
    @AuraEnabled
    public static LookupSearchResult getCurrentSelectionResultObj(Id id, String displayFieldName) {
        if (id == null || (String.valueOf(id).length() != 15 && String.valueOf(id).length() != 18)) {
            return null;
        }

        String objectName = id.getSobjectType().getDescribe().getName();
        if (objectName == 'Account_Plan__c') {
            // This is a special case for if a customer also has an object named Account_Plan__c
            return null;
        }
        if (!UTIL_Describe.isValidField(objectName, displayFieldName)) {
            return null;
        }

        List<SObject> results = Database.query(buildCurrentValueQuery(objectName, displayFieldName, id));

        return results.isEmpty()
            ? null
            : new LookupSearchResult(
                  results[0].Id,
                  objectName,
                  getObjectIconName(objectName),
                  String.valueOf(results[0].get(displayFieldName)),
                  null
              );
    }

    /**
     * Returns a lookup input map list for a given list of Ids
     */
    @AuraEnabled
    public static List<Map<String, String>> getLookupListForIds(List<Id> idList) {
        List<Map<String, String>> result = new List<Map<String, String>>();

        if (idList == null || idList.isEmpty()) {
            return result;
        }

        SObjectType objType = idList.get(0).getSObjectType();
        String objNameField = UTIL_Describe.getNameField(objType.getDescribe().getName());
        List<SObject> objs = DynamicObjectQueryService.querySObjectListWithIdsAndFields(
            idList,
            new Set<String>{ objNameField }
        );

        for (SObject obj : objs) {
            Map<String, String> listMap = new Map<String, String>();
            listMap.put('value', obj.Id);
            listMap.put('label', (String) obj.get(objNameField));
            result.add(listMap);
        }

        return result;
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private static String buildCurrentValueQuery(String objectName, String displayFieldName, Id id) {

    if(!fflib_SecurityUtils.checkObjectValidAndIsAccessable(objectName) || !fflib_SecurityUtils.checkFieldValidAndIsAccessable(objectName, displayFieldName)) {
            return null;
    }
        return 'SELECT Id, ' + displayFieldName + ' FROM ' + objectName + ' WHERE Id = :id' +' WITH SECURITY_ENFORCED';
    }

    // Static fields
    private static Map<String, String> objectIconNames; //NOPMD

    /**
     * Gets the default icon name for the specified S-Object. The default icon can be overridden
     * by the component by specifying an iconName attribute for the type. The way the default icon
     * is determined is by using the describe information for each defined tab to check for a tab
     * that is associated with an S-Object. If there is no tab (standard or custom) for a particular
     * S-Object then a default icon name cannot be determined and null will be returned
     *
     * @param name The S-Object API name
     *
     * @return The default icon name for the specified S-Object
     */
    private static String getObjectIconName(String name) {
        if (name == 'User') {
            return 'standard:user';
        }
        final String lightningIconExt = '.svg';

        if (objectIconNames == null) {
            objectIconNames = new Map<String, String>();

            for (Schema.DescribeTabSetResult tabSet : Schema.describeTabs()) {
                for (Schema.DescribeTabResult tab : tabSet.getTabs()) {
                    String typeName = tab.getSobjectName();
                    if (String.isBlank(typeName) || objectIconNames.containsKey(typeName)) {
                        continue;
                    }

                    for (Schema.DescribeIconResult icon : tab.getIcons()) {
                        String iconUrl = icon.getUrl();
                        if (iconUrl.endsWithIgnoreCase(lightningIconExt)) {
                            String iconName = iconUrl.substringAfterLast('/').substringBefore(lightningIconExt);

                            iconName = typeName.endsWithIgnoreCase('__c')
                                ? 'custom:' + iconName
                                : 'standard:' + iconName;
                            objectIconNames.put(typeName, iconName);
                            break;
                        }
                    }
                }
            }
        }
        return objectIconNames.get(name);
    }

    private static List<LookupSearchResult> processRecentlyViewedResults(List<RecentlyViewed> records) {
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        for (RecentlyViewed obj : records) {
            results.add(
                new LookupSearchResult(obj.Id, obj.Type, getObjectIconName(obj.Type), String.valueOf(obj.Name), null)
            );
        }

        return results;
    }

    private static List<LookupSearchResult> processSObjectResultsForInputLookups(
        List<SObject> records,
        List<InputLookupTypeObject> types
    ) {
        Map<String, String> typeToNameFieldMap = new Map<String, String>();
        Map<String, String> typeToDisplayFieldMap = new Map<String, String>();
        for (InputLookupTypeObject type : types) {
            typeToNameFieldMap.put(type.objType, type.objNameField);
            typeToDisplayFieldMap.put(type.objType, type.displayFieldName);
        }

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        for (SObject obj : records) {
            Map<String, Object> fieldmap = obj.getPopulatedFieldsAsMap();
            String type = obj.getSObjectType().getDescribe().getName();
            String nameField = typeToNameFieldMap.get(type);
            String label = nameField != null &&
                fieldmap.get(nameField) != null
                ? String.valueOf(fieldmap.get(nameField))
                : '[' + type + ']';
            String displayField = typeToDisplayFieldMap.get(type);
            String sublabel = displayField != null &&
                fieldmap.get(displayField) != null
                ? String.valueOf(fieldmap.get(displayField))
                : null;
            results.add(new LookupSearchResult(obj.Id, type, getObjectIconName(type), label, sublabel));
        }

        return results;
    }

    private static List<LookupSearchResult> processSObjectResultsForFields(
        List<SObject> records,
        String type,
        String displayFieldName,
        String objNameField
    ) {
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        for (sObject obj : records) {
            results.add(
                new LookupSearchResult(
                    obj.Id,
                    type,
                    getObjectIconName(type),
                    String.valueOf(obj.get(displayFieldName)),
                    displayFieldName != objNameField ? String.valueOf(obj.get(objNameField)) : null
                )
            );
        }
        return results;
    }
}