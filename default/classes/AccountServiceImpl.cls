@SuppressWarnings('PMD.OperationWithLimitsInLoop')
public with sharing class AccountServiceImpl {
    private static Integer maxHierarchyQueries = Limits.getLimitQueries() - 1;
    
    public static void addParentId(List<Account> newList) {
        for(Account acc : newList){
            if(acc.pqcrush__Parent_Id_Text__c != null){
                //acc.ParentId = acc.pqcrush__Parent_Id_Text__c;
                acc.ParentId = acc.pqcrush__Parent_Id_Text__c;
            }
        }
    }

    public Id getRelatedAccountIdForRecordId(Id recordId) {
        System.debug('=== AccountServiceImpl.getRelatedAccountIdForRecordId ===');
        System.debug('===recordId: ' + recordId);
        if (recordId == null) {
            return null;
        }
        Schema.SObjectType objectType = recordId.getSObjectType();
        // If we're on an Account, just return it
        if (objectType == Account.getSObjectType()) {
            return recordId;
        }

        // If we're on an Opportunity Plan it's not direct, so get from the Opportunity Plan Service
        if (objectType == PQ_Opportunity_Plan__c.getSObjectType()) {
            Id accountId = OpportunityPlanService.getAccountIdForOppPlanId(recordId);
            return accountId;
        }

        // Check if the recordId is of an object that has a relationship field to an Account
        Schema.DescribeSobjectResult objDesc = objectType.getDescribe();
        if (objDesc.getName() == 'Account_Plan__c') {
            // This is a special case for if a customer also has an object named Account_Plan__c
            return null;
        }
        Set<Schema.SObjectField> relFieldSet = SObjectService.relationshipsFromDescribeMatchingObjectType(
            objDesc,
            Account.getSObjectType()
        );
        if (!relFieldSet.isEmpty()) {
            Set<String> selectFields = new Set<String>();
            for (Schema.SObjectField field : relFieldSet) {
                selectFields.add(field.getDescribe().getName());
            }
            // passing new set to method because querySObjectWithTypeAndId modifies the selectField set internally
            SObject queriedObj = DynamicObjectQueryService.querySObjectWithTypeAndId(
                objDesc,
                recordId,
                new Set<String>(selectFields)
            );
            System.debug('==queriedObj=='+queriedObj);
            System.debug('==selectFields=='+selectFields);
            System.debug('===relatedAccountIdForRecord(queriedObj, selectFields)==='+relatedAccountIdForRecord(queriedObj, selectFields));
            return relatedAccountIdForRecord(queriedObj, selectFields);
        }
        return null;
    }

    public Map<Id, Account> getAccountAndDescendents(Id parentAccountId) {
        Map<Id, Account> fullAccountHierarchy = new Map<Id, Account>();
        Boolean endTraversing = false;
        Integer accountLevel = 0;

        List<Account> accList = new List<Account>();
        List<Id> currentParentIds = new List<Id>();

        currentParentIds.add(parentAccountId);

        string queryString = '';

        while (!endTraversing) {
            if (accountLevel == 0) {
                queryString = 'SELECT Id, Name, ParentId FROM Account WHERE Id IN :currentParentIds';
            } else {
                queryString = 'SELECT Id, Name, ParentId FROM Account WHERE ParentId IN :currentParentIds';
            }

            try {
                if (Limits.getQueries() < maxHierarchyQueries) {
                    accList = database.query(queryString);
                } else {
                    endTraversing = true;
                }
            } catch (Exception ex) {
                endTraversing = true;
            }

            if (accList.size() == 0) {
                endTraversing = true;
            } else {
                currentParentIds.clear();
                for (Integer i = 0; i < accList.size(); i++) {
                    Account account = accList[i];
                    currentParentIds.add(account.Id);
                    fullAccountHierarchy.put(account.Id, account);
                }
                accountLevel++;
            }
        }
        return fullAccountHierarchy;
    }

    public Set<Id> getIdsForRelatedObjectsToAccount(Id accountId) {
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        String savedObjects = orgSettings.Task_Objects_Related_To_Account__c;

        if (String.isBlank(savedObjects)) {
            return new Set<Id>();
        }

        List<String> saveObjectsSplit = savedObjects.split(',');

        List<Schema.sObjectType> relatedObjectTypes = new List<Schema.sObjectType>();
        for (String sobjectApiName : saveObjectsSplit) {
            if (String.isBlank(sobjectApiName)) {
                continue;
            }
            relatedObjectTypes.add(Application.getGlobalDescribe().get(sobjectApiName));
        }

        Set<Id> relatedObjectIds = SObjectService.getIdsForRelatedObjects(accountId, relatedObjectTypes);

        return relatedObjectIds;
    }

    public Map<Id, Set<Id>> getTaskWhatIdsByAccountId(Set<Id> accountIds) {
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        String savedObjects = orgSettings.Task_Objects_Related_To_Account__c;

        if (String.isBlank(savedObjects)) {
            return new Map<Id, Set<Id>>();
        }

        List<String> saveObjectsSplit = savedObjects.split(',');

        List<Schema.sObjectType> relatedObjectTypes = new List<Schema.sObjectType>();
        for (String sobjectApiName : saveObjectsSplit) {
            if (String.isBlank(sobjectApiName)) {
                continue;
            }
            relatedObjectTypes.add(Application.getGlobalDescribe().get(sobjectApiName));
        }

        Map<Id, Set<Id>> relatedObjectIds = SObjectService.getMapOfObjectIdsRelatedToIdSet(
            accountIds,
            Account.sObjectType,
            relatedObjectTypes
        );

        return relatedObjectIds;
    }

    public Set<Id> getContactIdsForAccount(Set<Id> accountIds) {
        Set<Id> result = new Set<Id>();
        if (AccountContactRelationService.areAccountContactRelationEnabled()) {
            return AccountContactRelationService.getContactIdsForAccounts(accountIds);
        }

        if (Schema.sObjectType.Contact.isQueryable()) {
            for (Contact c : [SELECT Id FROM Contact WHERE AccountId IN :accountIds]) {
                result.add(c.Id);
            }
        }

        return result;
    }

    private Id relatedAccountIdForRecord(SObject record, Set<String> inFields) {
        if (record == null) {
            return null;
        }
        for (String fieldName : inFields) {
            Id relatedId = (Id) record.get(fieldName);
            if (relatedId != null) {
                return relatedId;
            }
        }
        return null;
    }
}