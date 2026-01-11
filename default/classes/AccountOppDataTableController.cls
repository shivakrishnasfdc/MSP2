public with sharing class AccountOppDataTableController {
    public static final String NAME_FIELD = 'Name';
    public static final String ACCOUNT_NAME_FIELD = 'Account.Name';

    @AuraEnabled
    public static Map<String, Object> getDatatableData(
        Id masterAccountPlanId,
        Id accountId,
        String columnsString,
        String conditionString,
        Boolean includeDescendantData
    ) {
        Set<Id> accountIds = new Set<Id>();
        if (accountId != null) {
            Set<Id> accountIdsFromDesc = includeDescendantData
                ? AccountService.getAccountAndDescendents(accountId).keySet()
                : new Set<Id>{ accountId };

            accountIds.addAll(accountIdsFromDesc);
        }

        List<pq_Master_Account_Plan__c> masterAccountPlanList = new List<pq_Master_Account_Plan__c>();
        if (masterAccountPlanId != null) {
            Set<Id> accountIdsFromMasterPlan = MasterAccountPlanService.getRelatedAccountIdsByMasterAccountPlans(
                new Set<Id>{ masterAccountPlanId }
            );
            accountIds.addAll(accountIdsFromMasterPlan);

            masterAccountPlanList = MasterAccountPlanSelector.newInstance()
                .selectById(new Set<Id>{ masterAccountPlanId });
        }

        // Add accountId for master account plan
        if (
            masterAccountPlanList != null &&
            masterAccountPlanList.size() > 0 &&
            masterAccountPlanList[0].Account__c != null
        ) {
            accountIds.add(masterAccountPlanList[0].Account__c);
        }

        Set<String> collectedFields = new Set<String>{ NAME_FIELD };
        if (includeDescendantData) {
            collectedFields.add(ACCOUNT_NAME_FIELD);
        }

        List<String> soqlColumns = columnsString.split('[,]{1}[\\s]*'); // sanitizes the spacing between commas

        collectedFields.addAll(validatedFields(soqlColumns));

        String finalColumnsString = String.join(new List<String>(collectedFields), ', ');
        if (UserInfo.isMultiCurrencyOrganization()) {
            finalColumnsString += ', CurrencyIsoCode';
        }

        return getDatatableDataForAccountIds(finalColumnsString, collectedFields, conditionString, accountIds);
    }

    public static Map<String, Object> getDatatableDataForAccountIds(
        String finalColumnsString,
        Set<String> collectedFields,
        String conditionString,
        Set<Id> accountIds
    ) {
        Map<String, Object> bindVars = new Map<String, Object>(); // This is the datatype for a bind var
        Map<String, Object> tableServiceRequest = new Map<String, Object>();
        Map<String, Object> tableServiceResponse = new Map<String, Object>();

        bindVars.put(DataTableService.ID_SET_KEY, accountIds);

        String whereClause = 'AccountId IN :idSet';

        if (String.isNotBlank(conditionString)) {
            whereClause += ' AND (' + conditionString + ')';
        }

        String queryString = 'SELECT ' + finalColumnsString + ' FROM Opportunity WHERE ' + whereClause;

        tableServiceRequest.put(DataTableService.QUERY_STRING_KEY, queryString);
        tableServiceRequest.put(DataTableService.BIND_VAR_KEY, bindVars);

        tableServiceResponse = DataTableService.getTableCache(tableServiceRequest);

        List<Map<String, Object>> tableColumns = (List<Map<String, Object>>) tableServiceResponse.get(
            DataTableService.TABLE_COLUMNS_KEY
        );

        tableServiceResponse.put(
            DataTableService.TABLE_COLUMNS_KEY,
            filteredTableColumns(tableColumns, collectedFields)
        );

        return convertCurrencies(tableColumns, tableServiceResponse);
    }

    @AuraEnabled
    public static Map<String, Object> getFilters(Id accountPlanId, String columnsString) {
        Map<String, Object> result = new Map<String, Object>();

        Opportunity_List_User_Filter__c savedFilter = getExistingFilterForAccountPlan(accountPlanId);
        result.put('id', savedFilter.id);

        Map<String, Object> originalFilterObject = (Map<String, Object>) JSON.deserializeUntyped(
            savedFilter.Filters__c
        );

        List<String> soqlColumns = columnsString.split('[,]{1}[\\s]*');
        Schema.SObjectType oppObjType = Opportunity.SObjectType;
        Map<String, Schema.SObjectField> fieldMap = oppObjType.getDescribe().fields.getMap();

        List<Map<String, Object>> filters = new List<Map<String, Object>>();

        for (String fieldName : soqlColumns) {
            try {
                Schema.SObjectType currentSObjectType = oppObjType;
                Schema.DescribeFieldResult field;
                String flatFieldName = getFlatFieldName(fieldName);

                if (fieldName.contains('.')) {
                    String parentReference = fieldName.contains('__r')
                        ? fieldName.substringBeforeLast('__r.') + '__c' // custom objects
                        : fieldName.substringBeforeLast('.') + 'Id'; // standard objects typical schema
                    Schema.SObjectType referenceTo = fieldMap.get(parentReference)
                        .getDescribe()
                        .getReferenceTo()
                        .get(0);
                    currentSObjectType = referenceTo;
                    field = referenceTo.getDescribe()
                        .fields.getMap()
                        .get(fieldName.substringAfterLast('.'))
                        .getDescribe();
                } else {
                    field = fieldMap.get(fieldName).getDescribe();
                }

                Map<String, Object> filterMap = new Map<String, Object>();
                Map<String, Object> savedFilterMap = (Map<String, Object>) originalFilterObject.get(flatFieldName);
                filters = buildFilters(field, flatFieldName, filters, filterMap, savedFilterMap);
            } catch (Exception e) {
                continue;
            }
        }

        result.put('filters', filters);

        return result;
    }

    private static Set<String> validatedFields(List<String> fields) {
        Set<String> validatedNameFields = new Set<String>();
        for (String fieldName : fields) {
            if (String.isNotBlank(fieldName)) {
                if (fieldName.equalsIgnoreCase(NAME_FIELD) || fieldName.equalsIgnoreCase((ACCOUNT_NAME_FIELD))) {
                    continue;
                }
                validateField(fieldName);
                validatedNameFields.add(String.escapeSingleQuotes(fieldName));
            }
        }
        return validatedNameFields;
    }

    private static Map<String, Object> convertCurrencies(
        List<Map<String, Object>> tableColumns,
        Map<String, Object> tableServiceResponse
    ) {
        if (!UserInfo.IsMultiCurrencyOrganization()) {
            return tableServiceResponse;
        }

        Set<String> currencyFields = new Set<String>();

        for (Map<String, Object> item : tableColumns) {
            String field = String.valueOf(item.get('fieldName'));
            Schema.SobjectField sObjectField = Opportunity.sObjectType.getDescribe().fields.getMap().get(field);
            if (sObjectField != null && sObjectField.getDescribe().getType() == Schema.DisplayType.Currency) {
                currencyFields.add(field);
            }
        }

        List<Opportunity> opps = (List<Opportunity>) tableServiceResponse.get('tableData');
        List<Map<String, Object>> modifiedOpps = new List<Map<String, Object>>();
        for (Opportunity opp : opps) {
            Map<String, Object> oppMap = new Map<String, Object>(opp.getPopulatedFieldsAsMap());
            for (String currencyField : currencyFields) {
                Object newValue = CurrencyService.convert(
                    oppMap.get(currencyField),
                    (String) oppMap.get('CurrencyIsoCode')
                );
                oppMap.put(currencyField, newValue);
            }
            modifiedOpps.add(oppMap);
        }
        tableServiceResponse.put('tableData', modifiedOpps);
        return tableServiceResponse;
    }

    private static List<Map<String, Object>> filteredTableColumns(
        List<Map<String, Object>> unfiltered,
        Set<String> fieldNames
    ) {
        Set<String> modifiedFieldNames = new Set<String>();
        for (String fn : fieldNames) {
            modifiedFieldNames.add(fn.replace('.', '_'));
        }
        List<Map<String, Object>> filteredColumns = new List<Map<String, Object>>();
        for (Map<String, Object> col : unfiltered) {
            String fieldName = (String) col.get('fieldName');
            if (modifiedFieldNames.contains(fieldName)) {
                filteredColumns.add(col);
            }
        }
        return filteredColumns;
    }

    private static List<Map<String, Object>> buildFilters(
        Schema.DescribeFieldResult field,
        String flatFieldName,
        List<Map<String, Object>> filters,
        Map<String, Object> filterMap,
        Map<String, Object> savedFilterMap
    ) {
        Schema.DisplayType fieldType = field.getType();

        if (fieldType === Schema.DisplayType.PICKLIST || fieldType === Schema.DisplayType.MULTIPICKLIST) {
            List<Schema.PicklistEntry> picklistEntries = field.getPicklistValues();
            List<FilterObject> picklistValues = new List<FilterObject>();
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValues.add(new FilterObject(entry.getLabel(), entry.getValue(), null, false, false));
            }
            filterMap.put('name', flatFieldName);
            filterMap.put('label', field.getLabel());
            filterMap.put('values', picklistValues);
            filterMap.put(
                'selectedValues',
                savedFilterMap?.containsKey('selectedValues') != null
                    ? savedFilterMap.get('selectedValues')
                    : new List<String>()
            );
            filterMap.put('type', String.valueOf(fieldType).toLowerCase());
            filters.add(filterMap);
        }

        if (fieldType === Schema.DisplayType.Date || fieldType === Schema.DisplayType.DATETIME) {
            filterMap.put('name', flatFieldName);
            filterMap.put('label', field.getLabel());
            filterMap.put(
                'startDate',
                savedFilterMap?.containsKey('startDate') != null ? savedFilterMap.get('startDate') : ''
            );
            filterMap.put(
                'endDate',
                savedFilterMap?.containsKey('endDate') != null ? savedFilterMap.get('endDate') : ''
            );
            filterMap.put('type', String.valueOf(fieldType).toLowerCase());
            filters.add(filterMap);
        }

        return filters;
    }

    private static String getFlatFieldName(String fieldName) {
        String flatFieldName = fieldName.contains('.')
            ? fieldName.replace('.', '_') // parent fields handled by clientside flattener
            : fieldName;
        return flatFieldName;
    }

    private static Opportunity_List_User_Filter__c getExistingFilterForAccountPlan(Id accountPlanId) {
        Id userId = UserInfo.getUserId();
        List<Opportunity_List_User_Filter__c> savedFilters = OpportunityListUserFilterSelector.newInstance()
            .selectByAccountPlanAndUser(accountPlanId, userId);

        Opportunity_List_User_Filter__c savedFilter;

        if (savedFilters != null && savedFilters.size() > 0) {
            savedFilter = savedFilters[0];
        } else {
            savedFilter = (Opportunity_List_User_Filter__c) Opportunity_List_User_Filter__c.SObjectType.newSObject(
                null,
                true
            );
            savedFilter.AccountPlan__c = accountPlanId;
            savedFilter.User__c = userId;
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(savedFilter);
            uow.commitWork();
        }
        return savedFilter;
    }

    private static void validateField(String fieldName) {
        if (fieldName.contains('.')) {
            String accountFieldName = fieldName.substringAfterLast('.');
            if (!UTIL_Describe.isValidField('Account', accountFieldName)) {
                throw new AuraHandledException(
                    '\'' +
                    accountFieldName +
                    '\' is not a valid field for the Account object'
                );
            }
        } else {
            if (!UTIL_Describe.isValidField('Opportunity', fieldName)) {
                throw new AuraHandledException('\'' + fieldName + '\' is not a valid field for the Opportunity object');
            }
        }
    }
}