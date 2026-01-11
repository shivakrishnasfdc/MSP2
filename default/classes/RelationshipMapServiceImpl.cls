public with sharing class RelationshipMapServiceImpl {
    public pqcrush__Relationship_Map__c createRelationshipMapWithFieldValues(Map<String, Object> fieldValues) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        pqcrush__Relationship_Map__c relMap = new pqcrush__Relationship_Map__c();
        if (fieldValues != null) {
            Map<String, Schema.SObjectField> fieldMap = SObjectType.pqcrush__Relationship_Map__c.Fields.getMap();
            for (String field : fieldValues.keySet()) {
                Object value = fieldValues.get(field);
                DescribeFieldResult fdesc = fieldMap.get(field).getDescribe();
                if (fdesc.getType() == Schema.DisplayType.STRING || fdesc.getType() == Schema.DisplayType.TEXTAREA) {
                    value = UtilityForString.trimByMaxLength((String) value, fdesc.getLength());
                }
                relMap.put(field, value);
            }
        }
        uow.registerNew(relMap);
        uow.commitWork();
        return relMap;
    }

    public pqcrush__Relationship_Map__c createRelatedMap(
        List<Schema.SObjectField> objRelations,
        List<Schema.SObjectField> mapRelations,
        Schema.DescribeSObjectResult objDescribe,
        Id objRecordId
    ) {
        checkMapsEmptyError(objRelations, mapRelations, System.label.error_no_map_relationship);
        checkPermissionsForMap();
        checkReadPermissionsForObjType(objDescribe);
        UserRecordAccess recordAccess = (UserRecordAccess) UtilityForList.first(
            UserRecordAccessSelector.newInstance().selectByRecordId(new Set<Id>{ objRecordId })
        );
        checkReadPermissionsForRecordAccess(recordAccess);
        objRelations = objRelationsWithPermission(objRelations);
        mapRelations = mapRelationsWithPermission(mapRelations);
        checkMapsEmptyError(objRelations, mapRelations, System.label.error_no_map_relationship_fls);
        SObject theRecord = DynamicObjectQueryService.querySObjectWithTypeAndId(
            objDescribe,
            objRecordId,
            new Set<String>{ 'Name' }
        );
        String recordName = theRecord?.get('Name') != null ? (String) theRecord.get('Name') : 'Relationship Map';
        pqcrush__Relationship_Map__c theRM = null;

        if (mapRelations.size() > 0) {
            Map<String, Object> keyValues = new Map<String, Object>{
                'Name' => recordName,
                mapRelations[0].getDescribe().getName() => objRecordId
            };
            keyValues.put('pqcrush__Type_Setting__c', objDescribe.getName());
            theRM = RelationshipMapService.createRelationshipMapWithFieldValues(keyValues);
        }

        if (theRM == null && objRelations.size() > 0) {
            Map<String, Object> keyValues = new Map<String, Object>{ 'Name' => recordName };
            checkUpdatePermissionsForObjType(objDescribe);
            checkUpdatePermissionsForRecordAccess(recordAccess);
            keyValues.put('pqcrush__Type_Setting__c', objDescribe.getName());
            theRM = RelationshipMapService.createRelationshipMapWithFieldValues(keyValues);
            if (theRM != null) {
                updateRecordFieldWithValue(new List<SObject>{ theRecord }, objRelations[0], theRM.Id);
            }
        }
        return theRM;
    }

    public List<Relationship_Map_Member__c> addContactToRelationshipMap(Id relationshipMapId, Set<Id> contactIdSet) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Relationship_Map_Member__c> mapMembers = new List<Relationship_Map_Member__c>();

        for (Id contactId : contactIdSet) {
            Relationship_Map_Member__c member = new Relationship_Map_Member__c(
                Relationship_Map__c = relationshipMapId,
                Contact__c = contactId
            );
            System.debug('===member contact=='+member);
            mapMembers.add(member);
            uow.registerNew(member);
        }

        uow.commitWork();

        return mapMembers;
    }


    public List<Relationship_Map_Member__c> addAccountToRelationshipMap(Id relationshipMapId, Set<Id> accountIdSet) {
        System.debug('==addAccountToRelationshipMap implementataion==called');
        System.debug('==accountIdSet=='+accountIdSet);
        System.debug('==relationshipMapId=='+relationshipMapId);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Relationship_Map_Member__c> mapMembers = new List<Relationship_Map_Member__c>();

        for (Id accountId : accountIdSet) {
            Relationship_Map_Member__c member = new Relationship_Map_Member__c(
                Relationship_Map__c = relationshipMapId,
                pqcrush__Account__c = accountId
            );
            System.debug('===member account=='+member);
            mapMembers.add(member);
            uow.registerNew(member);
        }
        System.debug('===mapMembers=='+mapMembers);

        uow.commitWork();

        return mapMembers;
    }

    public Double getMapMemberCountForAccountPlan(List<Account_Plan__c> accountPlans) {
        if (accountPlans == null || accountPlans.size() <= 0) {
            return -1;
        }

        Account_Plan__c accountPlan = accountPlans[0];

        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIds(new Set<Id>{ accountPlan.Id });
        Double count = 0;
        for (Relationship_Map__c rm : maps) {
            count += rm.Map_Member_Count__c != null ? rm.Map_Member_Count__c : 0;
        }
        return count;
    }

    public Date getMapMemberLastUpdatedDateForAccountPlan(List<Account_Plan__c> accountPlans) {
        if (accountPlans == null || accountPlans.size() <= 0) {
            return null;
        }

        Account_Plan__c accountPlan = accountPlans[0];

        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIds(new Set<Id>{ accountPlan.Id });
        Date lastUpdatedDate = null;
        for (Relationship_Map__c rm : maps) {
            if (
                rm.Map_Member_Max_Modified_Date__c != null &&
                (lastUpdatedDate == null ||
                rm.Map_Member_Max_Modified_Date__c > lastUpdatedDate)
            ) {
                lastUpdatedDate = rm.Map_Member_Max_Modified_Date__c.date();
            }
        }
        return lastUpdatedDate;
    }

    public Set<Id> getMapsForObjectFromObject(Schema.SObjectType objType, Set<Id> recordIds) {
        Set<Id> result = new Set<Id>();
        if (recordIds == null || objType == null) {
            return result;
        }

        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        Set<Schema.SObjectField> objRelationshipFields = SObjectService.relationshipsFromDescribeMatchingObjectType(
            objDescribe,
            pqcrush__Relationship_Map__c.sObjectType
        );

        List<SObject> sobjresultList = DynamicObjectQueryService.querySObjectsWithTypeAndIds(
            objType,
            objRelationshipFields,
            recordIds
        );

        for (Sobject sobjresult : sobjresultList) {
            Id mapIdFound = SObjectService.getFirstIdFromSObjectMatchingFields(sobjresult, objRelationshipFields);
            if (mapIdFound != null) {
                result.add(mapIdFound);
            }
        }

        return result;
    }

    public Set<Id> getMapsForObjectFromRM(Schema.SObjectType objType, Set<Id> recordIds) {
        Set<Id> result = new Set<Id>();
        if (recordIds == null || objType == null) {
            return result;
        }

        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        Set<Schema.SObjectField> mapRelationshipFields = SObjectService.relationshipsFromDescribeMatchingObjectType(
            pqcrush__Relationship_Map__c.sObjectType.getDescribe(),
            objDescribe.getSObjectType()
        );

        List<SObject> resultList = DynamicObjectQueryService.querySObjectsWithTypeAndIdsMatchingRecords(
            pqcrush__Relationship_Map__c.sObjectType,
            mapRelationshipFields,
            recordIds
        );

        for (Sobject sobjresult : resultList) {
            Id mapIdFound = SObjectService.getFirstIdFromSObjectMatchingFields(
                sobjresult,
                new Set<Schema.SObjectField>{ pqcrush__Relationship_Map__c.Id }
            );
            result.add(mapIdFound);
        }

        return result;
    }

    public Boolean hasAccountPlanSetting(Id mapId) {
        if (mapId == null) {
            return false;
        }
        // Get map instance
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ mapId });
        if (maps == null || maps.size() == 0) {
            return false;
        }

        Relationship_Map__c rmMap = maps[0];

        return hasAccountPlanSetting(rmMap);
    }

    public Boolean hasAccountPlanSetting(Relationship_Map__c rmMap) {
        if (rmMap?.Type_Setting__c == 'pqcrush__Account_Plan__c') {
            return true;
        }

        return false;
    }

    public Id getParentIdForRelationshipMapId(Id mapId) {
        if (mapId == null || mapId.getSObjectType() != Relationship_Map__c.getSObjectType()) {
            return null;
        }
        // Get map instance
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ mapId });
        if (maps == null || maps.size() == 0) {
            return null;
        }

        Relationship_Map__c rmMap = maps[0];

        return getParentIdForRelationshipMap(rmMap);
    }

    public Id getParentIdForRelationshipMap(Relationship_Map__c rmMap) {
        if (rmMap?.Type_Setting__c == 'pqcrush__Account_Plan__c') {
            return rmMap.pq_AccountPlanId__c;
        }

        return null;
    }

    //------------------------//
    // -- PRIVATE METHODS  -- //
    //------------------------//
    private void updateRecordFieldWithValue(List<SObject> theRecords, Schema.SObjectField field, Object value) {
        if (theRecords == null || theRecords.size() <= 0) {
            return;
        }

        List<SObject> recordsToUpdate = new List<SObject>();

        for (SObject theRecord : theRecords) {
            SObject toUpdate = theRecord.getSObjectType().newSObject(theRecord.Id);
            toUpdate.put(field, value);
            recordsToUpdate.add(toUpdate);
        }

        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ theRecords[0].getSObjectType() }
        );
        uow.registerDirty(recordsToUpdate);
        uow.commitWork();
    }

    private void checkMapsEmptyError(List<Object> list1, List<Object> list2, String errorMessage) {
        if ((list1 == null || list1.size() == 0) && (list2 == null || list2.size() == 0)) {
            throw Application.createAuraHandledException(errorMessage);
        }
    }

    private Boolean checkReadPermissionsForObjType(Schema.DescribeSObjectResult objDescribe) {
        if (objDescribe == null || !objDescribe.isAccessible()) {
            String objName = objDescribe == null ? System.label.Unknown_Object : objDescribe.getName();
            throw Application.createAuraHandledException(
                String.format(System.label.error_insufficient_access, new List<String>{ objName })
            );
        }
        return true;
    }

    private Boolean checkUpdatePermissionsForObjType(Schema.DescribeSObjectResult objDescribe) {
        if (objDescribe == null || !objDescribe.isAccessible()) {
            String objName = objDescribe == null ? System.label.Unknown_Object : objDescribe.getName();
            throw Application.createAuraHandledException(
                String.format(System.label.error_insufficient_access, new List<String>{ objName })
            );
        }
        return true;
    }

    private Boolean checkReadPermissionsForRecordAccess(UserRecordAccess recordAccess) {
        if (recordAccess == null) {
            throw Application.createAuraHandledException(System.label.error_insufficient_access_this_record);
        }
        if (!recordAccess.HasAllAccess && !recordAccess.HasReadAccess) {
            throw Application.createAuraHandledException(
                String.format(
                    System.label.error_insufficient_access,
                    new List<String>{ String.valueOf(recordAccess.RecordId) }
                )
            );
        }
        return true;
    }

    private Boolean checkUpdatePermissionsForRecordAccess(UserRecordAccess recordAccess) {
        if (recordAccess == null) {
            throw Application.createAuraHandledException(System.label.error_insufficient_access_this_record);
        }
        if (!recordAccess.HasAllAccess && !recordAccess.HasEditAccess) {
            throw Application.createAuraHandledException(
                String.format(
                    System.label.error_insufficient_access,
                    new List<String>{ String.valueOf(recordAccess.RecordId) }
                )
            );
        }
        return true;
    }

    private Boolean checkPermissionsForMap() {
        if (!pqcrush__Relationship_Map__c.sObjectType.getDescribe().isCreateable()) {
            throw Application.createAuraHandledException(
                String.format(
                    System.label.error_insufficient_access,
                    new List<String>{ pqcrush__Relationship_Map__c.sObjectType.getDescribe().getName() }
                )
            );
        }
        return true;
    }

    private List<Schema.SObjectField> objRelationsWithPermission(List<Schema.SObjectField> objRelations) {
        List<Schema.SObjectField> fieldsWithPermission = new List<Schema.SObjectField>();
        if (objRelations == null || objRelations.size() == 0) {
            return fieldsWithPermission;
        }
        for (Schema.SObjectField field : objRelations) {
            if (
                field != null &&
                field.getDescribe().isUpdateable() &&
                field.getDescribe().getType() == Schema.DisplayType.Reference
            ) {
                fieldsWithPermission.add(field);
            }
        }
        return fieldsWithPermission;
    }

    private List<Schema.SObjectField> mapRelationsWithPermission(List<Schema.SObjectField> objRelations) {
        List<Schema.SObjectField> fieldsWithPermission = new List<Schema.SObjectField>();
        if (objRelations == null || objRelations.size() == 0) {
            return fieldsWithPermission;
        }
        for (Schema.SObjectField field : objRelations) {
            if (
                field != null &&
                field.getDescribe().isCreateable() &&
                field.getDescribe().getType() == Schema.DisplayType.Reference
            ) {
                fieldsWithPermission.add(field);
            }
        }
        return fieldsWithPermission;
    }
}