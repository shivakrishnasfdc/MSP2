public with sharing class PostInstallHelperServiceImpl {
    /*********************************************************************/
    // Key Stakeholder and Map Member influence and support field migration
    /*********************************************************************/

    public List<Relationship_Map_Member__c> getMapMembersToUpdate() {
        Query memberQuery = new Query(Relationship_Map_Member__c.getSObjectType(), null);
        memberQuery.selectFields(
            'Id, pqcrush__Influence__c, pqcrush__Support__c, pqcrush__InfluenceId__c, pqcrush__SupportId__c'
        );
        memberQuery.addCondition(
            Query.doOr(
                Query.doAnd(
                    Query.conditionNotNull('pqcrush__Influence__c'),
                    Query.conditionNull('pqcrush__InfluenceId__c')
                ),
                Query.doAnd(Query.conditionNotNull('pqcrush__Support__c'), Query.conditionNull('pqcrush__SupportId__c'))
            )
        );
        List<Relationship_Map_Member__c> members = memberQuery.toSObjectList();
        return members;
    }

    public List<Key_Stakeholder__c> getStakeholdersToUpdate() {
        Query keystakeholderQuery = new Query(Key_Stakeholder__c.getSObjectType(), null);
        keystakeholderQuery.selectFields(
            'Id, pqcrush__Influence__c, pqcrush__Support__c, pqcrush__InfluenceId__c, pqcrush__SupportId__c'
        );
        keystakeholderQuery.addCondition(
            Query.doOr(
                Query.doAnd(
                    Query.conditionNotNull('pqcrush__Influence__c'),
                    Query.conditionNull('pqcrush__InfluenceId__c')
                ),
                Query.doAnd(Query.conditionNotNull('pqcrush__Support__c'), Query.conditionNull('pqcrush__SupportId__c'))
            )
        );
        List<Key_Stakeholder__c> keystakeholders = keystakeholderQuery.toSObjectList();
        return keystakeholders;
    }

    public Set<SObject> updateMapMembersInfleunceSupport(
        List<SObject> members,
        List<pq_Influence__c> infList,
        List<pq_Support__c> suppList
    ) {
        if (members == null || members.size() == 0) {
            return new Set<SObject>();
        }
        if (infList == null) {
            infList = new List<pq_Influence__c>();
        }
        if (suppList == null) {
            suppList = new List<pq_Support__c>();
        }
        if (infList.size() == 0 && suppList.size() == 0) {
            return new Set<SObject>();
        }
        Map<String, Id> influenceMap = new Map<String, Id>();
        for (pq_Influence__c inf : infList) {
            influenceMap.put(inf.Name, inf.Id);
        }

        Map<String, Id> supportMap = new Map<String, Id>();
        for (pq_Support__c supp : suppList) {
            supportMap.put(supp.Name, supp.Id);
        }

        Set<SObject> toUpdate = updateVerifiedMembers(members, influenceMap, supportMap);
        return toUpdate;
    }

    /****************************************/
    // Migrate to Relationship Map object
    /****************************************/

    public Integer getRecordCountForKSMapConversion() {
        Query countQuery = getKSMapConversionBaseQuery();
        countQuery.count('Id', 'totalCount');
        AggregateResult result = countQuery.aggregate()[0];
        return (Integer) result.get('totalCount');
    }

    public Query getQueryForKSMapConversion() {
        Query query = getKSMapConversionBaseQuery();
        List<String> selectFields = new List<String>();
        selectFields.add('Id');
        selectFields.add('Name');
        query.selectFields(selectFields);
        return query;
    }

    /****************************************/
    // Migrate Key Stakeholders to Map Members
    /****************************************/

    public List<Relationship_Map_Member__c> getMapMembersToUpdateCustomFields() {
        List<Relationship_Map_Member__c> mapMembersToUpdate = selectRMMWithCustomFields();
        Set<Id> ksIds = new Set<Id>();
        for (Relationship_Map_Member__c rmm : mapMembersToUpdate) {
            ksIds.add(rmm.Original_Key_Stakeholder__c);
        }

        List<Key_Stakeholder__c> keyStakeholders = selectKeystakeholdersWithCustomFields(ksIds);
        Map<Id, Key_Stakeholder__c> ksMap = new Map<Id, Key_Stakeholder__c>();

        for (Key_Stakeholder__c ks : keyStakeholders) {
            ksMap.put(ks.Id, ks);
        }

        // Populate Relationship map members with custom field data from Key stakeholder
        for (Relationship_Map_Member__c rmm : mapMembersToUpdate) {
            Key_Stakeholder__c k = ksMap.get(rmm.Original_Key_Stakeholder__c);
            this.populateRMMWithKSData(rmm, k);
        }

        return mapMembersToUpdate;
    }

    public list<String> getFieldsForKSMigration() {
        //Get a map of all pqcrush__Key_Stakeholder__c fields
        Map<String, Schema.SObjectField> keyStakeholderFields = Schema.SObjectType.pqcrush__Key_Stakeholder__c.fields.getMap();
        //Get a map of all Relationship_Map_Member__c fields
        Map<String, Schema.SObjectField> relationshipMapMemberFields = Schema.SObjectType.pqcrush__Relationship_Map_Member__c.fields.getMap();

        //Create a set of known fields to not include in the query
        Set<SObjectField> skipFields = new Set<SObjectField>{
            pqcrush__Relationship_Map_Member__c.pqcrush__contact__c,
            pqcrush__Relationship_Map_Member__c.pqcrush__influence__c,
            pqcrush__Relationship_Map_Member__c.pqcrush__support__c,
            pqcrush__Relationship_Map_Member__c.pqcrush__influenceid__c,
            pqcrush__Relationship_Map_Member__c.pqcrush__supportid__c,
            pqcrush__Relationship_Map_Member__c.pqcrush__reports_to__c
        };

        //Get a List of all fields named the same for both objects that are also custom fields and not in the skipFields set
        List<String> fieldNames = new List<String>();
        for (String keyStakeholderFieldName : keyStakeholderFields.keySet()) {
            SObjectField rmmField = relationshipMapMemberFields.get(keyStakeholderFieldName);
            SObjectField ksField = keyStakeholderFields.get(keyStakeholderFieldName);
            if (
                rmmField != null &&
                !skipFields.contains(rmmField) &&
                canUseFieldForKSMigration(rmmField) &&
                canUseFieldForKSMigration(ksField) &&
                rmmField.getDescribe().getType() == ksField.getDescribe().getType()
            ) {
                fieldNames.add(keyStakeholderFieldName);
            }
        }
        return fieldNames;
    }

    public Integer getRecordCountForKSMigration() {
        List<String> fieldNames = getFieldsForKSMigration();
        if (fieldNames == null || fieldNames.size() == 0) {
            return 0;
        }
        Query countQuery = getKSMigrationBaseQuery(fieldNames);
        countQuery.count('Id', 'totalCount');
        AggregateResult result = countQuery.aggregate()[0];
        return (Integer) result.get('totalCount');
    }

    public Query getQueryForKSMigration() {
        List<String> fieldNames = getFieldsForKSMigration();
        if (fieldNames == null || fieldNames.size() == 0) {
            return null;
        }
        Query query = getKSMigrationBaseQuery(fieldNames);
        List<String> selectFields = new List<String>(fieldNames);
        selectFields.add('Id');
        selectFields.add('pqcrush__Original_Key_Stakeholder__c');
        query.selectFields(selectFields);
        return query;
    }

    public List<Relationship_Map_Member__c> getRecordsForKSMigration() {
        Integer queryRowLimit = Limits.getLimitQueryRows();
        Query rmQuery = getQueryForKSMigration();
        rmQuery.setLimit(queryRowLimit);
        return rmQuery.toSObjectList();
    }

    /***************************************/
    // Generic Batching for Update and Insert
    /***************************************/

    public void executeBatchUpdateForRecords(List<SObject> records, List<Schema.SObjectType> objTypes) {
        executeBatchUpdateForRecords(records, objTypes, null, true);
    }

    public void executeBatchUpdateForRecords(
        List<SObject> records,
        List<Schema.SObjectType> objTypes,
        Integer batchSize,
        Boolean bypassTriggers
    ) {
        BatchUpdate batch = new BatchUpdate();
        batch.bypassTriggers = bypassTriggers;
        batch.objsToUpdate = records;
        batch.relatedObjectTypes = objTypes;
        Database.executeBatch(batch, batchSize == null ? batch.batchSize : batchSize);
    }

    public void executeBatchInsertForRecords(List<SObject> records, List<Schema.SObjectType> objTypes) {
        executeBatchInsertForRecords(records, objTypes, null, true);
    }

    public void executeBatchInsertForRecords(
        List<SObject> records,
        List<Schema.SObjectType> objTypes,
        Integer batchSize,
        Boolean bypassTriggers
    ) {
        BatchInsert batch = new BatchInsert();
        batch.bypassTriggers = bypassTriggers;
        batch.objsToInsert = records;
        batch.relatedObjectTypes = objTypes;
        Database.executeBatch(batch, batchSize == null ? batch.batchSize : batchSize);
    }

    /****************/
    // Private Methods
    /****************/

    private void populateRMMWithKSData(Relationship_Map_Member__c rmm, Key_Stakeholder__c ks) {
        if (ks == null) {
            return;
        }
        List<String> rmmCustomFields = SObjectService.getCustomFields(
            Relationship_Map_Member__c.getSObjectType(),
            true
        );
        List<String> customFields = SObjectService.getCustomFields(Key_Stakeholder__c.getSObjectType(), false);
        for (String cf : customFields) {
            if (rmmCustomFields.contains(cf) && ks.get(cf) != null) {
                rmm.put(cf, ks.get(cf));
            }
        }
    }

    private List<Relationship_Map_Member__c> selectRMMWithCustomFields() {
        Query memberQuery = new Query(Relationship_Map_Member__c.getSObjectType(), null);
        List<String> customFields = SObjectService.getCustomFields(Relationship_Map_Member__c.getSObjectType(), true);
        memberQuery.selectFields(customFields);
        memberQuery.addConditionNotNull('pqcrush__Original_Key_Stakeholder__c');
        List<Relationship_Map_Member__c> members = memberQuery.toSObjectList();
        return members;
    }

    private List<Key_Stakeholder__c> selectKeystakeholdersWithCustomFields(Set<Id> ksIds) {
        Query memberQuery = new Query(Key_Stakeholder__c.getSObjectType(), null);
        List<String> customFields = SObjectService.getCustomFields(Key_Stakeholder__c.getSObjectType(), false);
        memberQuery.selectFields(customFields);
        memberQuery.addConditionIn('Id', ksIds);
        List<Key_Stakeholder__c> ks = memberQuery.toSObjectList();
        return ks;
    }

    private Set<SObject> updateVerifiedMembers(
        List<SObject> members,
        Map<String, Id> influenceMap,
        Map<String, Id> supportMap
    ) {
        Set<SObject> toUpdate = new Set<SObject>();
        for (SObject member : members) {
            Schema.SObjectType type = member.getSobjectType();
            if (type != Relationship_Map_Member__c.SObjectType && type != Key_Stakeholder__c.SObjectType) {
                continue;
            }
            Boolean needsUpdate = false;
            String influence = (String) member.get('pqcrush__Influence__c');
            String support = (String) member.get('pqcrush__Support__c');
            if (influenceMap.containsKey(influence)) {
                member.put('pqcrush__InfluenceId__c', influenceMap.get(influence));
                needsUpdate = true;
            }
            if (supportMap.containsKey(support)) {
                member.put('pqcrush__SupportId__c', supportMap.get(support));
                needsUpdate = true;
            }
            if (needsUpdate) {
                toUpdate.add(member);
            }
        }
        return toUpdate;
    }

    private Query getKSMigrationBaseQuery(List<String> conditionFieldNames) {
        //Create a list of Query Conditions that check if a field is not null on the related pqcrush__Original_Key_Stakeholder__c relationship but is null on the Relationship_Map_Member__c record
        List<Query.Condition> conditions = new List<Query.Condition>();
        for (String fieldName : conditionFieldNames) {
            Query.Condition andCondition = Query.doAnd(
                Query.conditionNotNull('pqcrush__Original_Key_Stakeholder__r.' + fieldName),
                Query.conditionNull(fieldName)
            );
            conditions.add(andCondition);
        }

        //Use Query Class to Fetch all Relationship_Map_Member__c records with minimal data where the pqcrush__Original_Key_Stakeholder__c relationship is not null
        Query rmQuery = new Query(pqcrush__Relationship_Map_Member__c.getSObjectType(), null);
        rmQuery.addCondition(
            Query.doAnd(Query.conditionNotNull('pqcrush__Original_Key_Stakeholder__c'), Query.doOr(conditions))
        );
        return rmQuery;
    }

    private Query getKSMapConversionBaseQuery() {
        //Use Query to fetch all Account Plan records that don't have a Relationship Map record that prelates to them
        Query apQuery = new Query(pqcrush__Account_Plan__c.getSObjectType(), null);
        apQuery.addCondition(
            Query.conditionNotIn(
                'Id',
                new Query(pqcrush__Relationship_Map__c.getSObjectType(), null)
                    .selectField('pqcrush__pq_AccountPlanId__c')
            )
        );
        return apQuery;
    }

    private Boolean canUseFieldForKSMigration(Schema.SObjectField field) {
        //Check if the field is a custom field
        if (!field.getDescribe().isCustom()) {
            return false;
        }

        //check if field is updateable
        if (!field.getDescribe().isUpdateable()) {
            return false;
        }

        //check if field can be used in WHERE clause
        if (!field.getDescribe().isFilterable()) {
            return false;
        }

        return true;
    }
}