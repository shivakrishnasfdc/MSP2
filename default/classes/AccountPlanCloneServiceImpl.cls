@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class AccountPlanCloneServiceImpl {
    public static final Integer BATCH_SIZE = 10;

    //Clone these objects along with the Key Stakeholders --> if they're passed in <--
    //Still need to handle - map specific groups, placeholder relationships, placeholder coordinates
    private List<String> keyStakeholderSimpleSubObjects = new List<String>{
        AccountPlanCloneService.MATRIX_RELATIONSHIP_NAME,
        AccountPlanCloneService.RM_BADGE_ACCOUNT_PLAN_ASSOC_NAME,
        AccountPlanCloneService.RELATIONSHIP_TYPE_ACCOUNT_PLAN_ASSOC_NAME
    };

    public List<Account_Plan__c> cloneAccountPlans(List<AccountPlanCloneWrapper> cloneWrappers) {
        Application.bypassPlanReopen = true;
        if (cloneWrappers.isEmpty()) {
            return new List<Account_Plan__c>();
        }

        Set<Id> planIds = new Set<Id>();
        for (AccountPlanCloneWrapper cloneData : cloneWrappers) {
            cloneData.validationCheck();
            planIds.add(cloneData.planId);
        }

        List<Account_Plan__c> plans = (List<Account_Plan__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            pqcrush__Account_Plan__c.getSObjectType(),
            planIds,
            new Set<String>{ 'Id' }
        );
        Map<Id, Account_Plan__c> originalPlansByPlanId = new Map<Id, Account_Plan__c>(plans);
        List<Account_Plan__c> clonedPlans = new List<Account_Plan__c>();
        for (AccountPlanCloneWrapper cloneData : cloneWrappers) {
            cloneData.relationships = relationshipsWithSubitems(cloneData.relationships);
            Account_Plan__c plan = originalPlansByPlanId.get(cloneData.planId);
            Account_Plan__c clone = plan.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
            if (!String.isBlank(cloneData.newName)) {
                //clone.Name = cloneData.newName;
                clone.Name = 'Test';
            }
            clone.pqcrush__Account__c = cloneData.newAccountId;
            if (!String.isBlank(cloneData.newOwnerId)) {
                clone.OwnerId = cloneData.newOwnerId;
            }
            clonedPlans.add(clone);
            cloneData.clonedPlan = clone;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(clonedPlans);
        new SystemContext().commitWork(uow);

        Application.bypassTrigger = true;
        // Enqueue the Queueable job
        if (Test.isRunningTest()) {
        	clonedRelationshipsForPlans(originalPlansByPlanId, cloneWrappers);
        }
        else {
        	System.enqueueJob(new AccountPlansCloneQueueable(originalPlansByPlanId,cloneWrappers));
        }
        //clonedRelationshipsForPlans(originalPlansByPlanId, cloneWrappers);
        //Application.bypassTrigger = false;
        //Application.bypassPlanReopen = false;
        return clonedPlans;
    }

    public void clonedRelationshipsForPlans(
        Map<Id, Account_Plan__c> originalPlans,
        List<AccountPlanCloneWrapper> wrappers
    ) {
        Map<String, Schema.ChildRelationship> childRelationshipsByRelationshipName = getChildRelationshipsMap();
        Map<String, Set<Id>> planIdsByRelationship = planIdsByRelationshipForWrappers(wrappers);
        List<SObject> clonedRelatedObjs = new List<SObject>();
        Set<Schema.SObjectType> relatedObjectTypes = new Set<Schema.SObjectType>();
        List<Map<Id, AccountPlanCloneWrapper>> wrapperByPlanIdNoDupeLists = dedupedWrapperByPlanIdList(wrappers);
        for (String relationshipName : planIdsByRelationship.keySet()) {
            Schema.ChildRelationship relationship = childRelationshipsByRelationshipName.get(relationshipName);
            if (relationship == null) {
                continue;
            }
            Set<Id> planIdSet = planIdsByRelationship.get(relationshipName);
            String parentRelationshipName = relationship.getField().getDescribe().getName();
            String childObjectName = relationship.getChildSObject().getDescribe().getName();
            relatedObjectTypes.add(relationship.getChildSObject());
            List<SObject> relatedObjects = CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
                Application.getGlobalDescribe().get(childObjectName),
                planIdSet,
                new Set<String>{ parentRelationshipName }
            );
            if (relationshipName == AccountPlanCloneService.TEAM_MEMBERS_RELATIONSHIP_NAME) {
                List<Team_Member__c> clonedMemers = cloneTeamMembersForPlanIdReplacingOwner(
                    relatedObjects,
                    parentRelationshipName,
                    originalPlans,
                    wrapperByPlanIdNoDupeLists
                );
                Application.bypassTrigger = false;
                fflib_ISObjectUnitOfWork teamUow = new fflib_Application.UnitOfWorkFactory(
                        new List<Schema.SObjectType>{ Team_Member__c.getSObjectType() }
                    )
                    .newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
                teamUow.registerNew(clonedMemers);
                new SystemContext().commitWork(teamUow);
                Application.bypassTrigger = true;
            } else if (relationshipName == AccountPlanCloneService.WHITE_SPACE_RELATIONSHIP_NAME) {
                List<WSRelatedObjectWrapper> relatedWSCellObjects = WhiteSpaceUtils.getWSRelatedObjectWrappers();
                for (WSRelatedObjectWrapper wrapper : relatedWSCellObjects) {
                    relatedObjectTypes.add(wrapper.objDesc.getSObjectType());
                }
                relatedObjectTypes.add(White_Space_Amount_Type_Association__c.getSObjectType());
                relatedObjectTypes.add(WS_Data_Type_Association__c.getSObjectType());
                relatedObjectTypes.add(WS_Summary_Formula__c.getSObjectType());
                clonedRelatedObjs.addAll(
                    cloneWhitespaceForPlanId(relatedObjects, parentRelationshipName, wrapperByPlanIdNoDupeLists)
                );
            } else if (relationshipName == AccountPlanCloneService.OBJECTIVES_RELATIONSHIP_NAME) {
                relatedObjectTypes.add(Objective_Opportunity__c.getSObjectType());
                relatedObjectTypes.add(Objective_Task_Association__c.getSObjectType());
                clonedRelatedObjs.addAll(
                    cloneObjectivesForPlanIdIncludingOpportunities(
                        relatedObjects,
                        parentRelationshipName,
                        wrapperByPlanIdNoDupeLists
                    )
                );
            } else if (relationshipName == AccountPlanCloneService.RELATIONSHIP_MAP_RELATIONSHIP_NAME) {
                clonePlanRelationshipMap(
                    wrapperByPlanIdNoDupeLists,
                    relatedObjects,
                    relatedObjectTypes,
                    clonedRelatedObjs
                );
            } else {
                for (Map<Id, AccountPlanCloneWrapper> wrapperList : wrapperByPlanIdNoDupeLists) {
                    Map<Id, Account_Plan__c> clonedPlans = clonedPlanMapForWrapperByRelationshipMap(
                        wrapperList,
                        relationshipName
                    );
                    if (clonedPlans.size() == 0) {
                        continue;
                    }
                    clonedRelatedObjs.addAll(
                        CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                                relatedObjects,
                                clonedPlans,
                                new Set<String>{ parentRelationshipName }
                            )
                            .values()
                    );
                }
            }
        }
        Application.bypassTrigger = true;
        BatchInsert batch = new BatchInsert();
        batch.bypassTriggers = true;
        batch.objsToInsert = clonedRelatedObjs;
        batch.relatedObjectTypes = new List<Schema.SObjectType>(relatedObjectTypes);
        if (!Test.isRunningTest()) {
        	Database.executeBatch(batch, BATCH_SIZE);
        }
        else {
            Database.executeBatch(batch, 1000);
        }
    }

    private void clonePlanRelationshipMap(
        List<Map<Id, AccountPlanCloneWrapper>> wrapperByPlanIdNoDupeLists,
        List<SObject> relatedObjects,
        Set<Schema.SObjectType> relatedObjectTypes,
        List<SObject> clonedRelatedObjs
    ) {
        List<RelationshipMapCloneWrapper> rmWrappers = new List<RelationshipMapCloneWrapper>();
        for (Map<Id, AccountPlanCloneWrapper> wrapperList : wrapperByPlanIdNoDupeLists) {
            for (SObject rel : relatedObjects) {
                Relationship_Map__c rm = (Relationship_Map__c) rel;
                AccountPlanCloneWrapper apWrapper = wrapperList.get(rm.pq_AccountPlanId__c);
                RelationshipMapCloneWrapper rmWrapper = new RelationshipMapCloneWrapper(
                    rm.Id,
                    apWrapper.newName,
                    apWrapper.newOwnerId,
                    apWrapper.clonedPlan.Id
                );
                rmWrappers.add(rmWrapper);
            }
        }
        RelationshipMapCloneService.cloneRelationshipMaps(rmWrappers, clonedRelatedObjs, relatedObjectTypes, false);
    }

    private List<SObject> cloneWhitespaceForPlanId(
        List<White_Space__c> relatedWhiteSpaces,
        String planRelationshipName,
        List<Map<Id, AccountPlanCloneWrapper>> dedupedWrappers
    ) {
        List<SObject> clonedReturnRecordsList = new List<SObject>();
        //Whitespace
        List<Map<Id, SObject>> dedupedClonedWhitespacesByOriginalId = new List<Map<Id, SObject>>();
        fflib_ISObjectUnitOfWork whitespaceUoW = new fflib_Application.UnitOfWorkFactory(
                new List<Schema.SObjectType>{ White_Space__c.getSObjectType() }
            )
            .newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        for (Map<Id, AccountPlanCloneWrapper> wrapperList : dedupedWrappers) {
            Map<Id, Account_Plan__c> clonedPlansByOriginalId = clonedPlanMapForWrapperByRelationshipMap(
                wrapperList,
                AccountPlanCloneService.WHITE_SPACE_RELATIONSHIP_NAME
            );
            if (clonedPlansByOriginalId.size() == 0) {
                continue;
            }

            //Clone Whitespace
            Map<Id, SObject> clonedWhitespacesByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedWhiteSpaces,
                clonedPlansByOriginalId,
                new Set<String>{ planRelationshipName }
            );
            dedupedClonedWhitespacesByOriginalId.add(clonedWhitespacesByOriginalId);
            whitespaceUoW.registerNew(clonedWhitespacesByOriginalId.values());
        }
        SystemContext systemContext = new systemContext();
        systemContext.commitWork(whitespaceUoW);

        //Rows & Columns
        String rowToWSRelationshipName = White_Space_Row__c.White_Space__c.getDescribe().getName();
        String colToWSRelationshipName = White_Space_Column__c.White_Space__c.getDescribe().getName();
        Set<Id> originalWhitespaceIdSet = new Map<Id, White_Space__c>(relatedWhiteSpaces).keySet();
        List<White_Space_Row__c> relatedRows = (List<White_Space_Row__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            White_Space_Row__c.getSObjectType(),
            originalWhitespaceIdSet,
            new Set<String>{ rowToWSRelationshipName }
        );
        List<White_Space_Column__c> relatedColumns = (List<White_Space_Column__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            White_Space_Column__c.getSObjectType(),
            originalWhitespaceIdSet,
            new Set<String>{ colToWSRelationshipName }
        );

        List<Map<Id, SObject>> dedupedMixedRowColWSByOriginalId = new List<Map<Id, SObject>>();
        fflib_ISObjectUnitOfWork rowColUoW = new fflib_Application.UnitOfWorkFactory(
                new List<Schema.SObjectType>{
                    White_Space_Row__c.getSObjectType(),
                    White_Space_Column__c.getSObjectType()
                }
            )
            .newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        for (Map<Id, SObject> clonedWhitespacesByOriginalId : dedupedClonedWhitespacesByOriginalId) {
            Map<Id, SObject> mixedMap = new Map<Id, SObject>();
            dedupedMixedRowColWSByOriginalId.add(mixedMap);
            if (clonedWhitespacesByOriginalId.size() == 0) {
                continue;
            }
            mixedMap.putAll(clonedWhitespacesByOriginalId);
            //Clone Rows and seperate into deduped lists for next step
            Map<Id, SObject> clonedRowsByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedRows,
                clonedWhitespacesByOriginalId,
                new Set<String>{ rowToWSRelationshipName }
            );
            mixedMap.putAll(clonedRowsByOriginalId);
            rowColUoW.registerNew(clonedRowsByOriginalId.values());

            //Clone Columns and seperate into deduped lists for next step
            Map<Id, SObject> clonedColsByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedColumns,
                clonedWhitespacesByOriginalId,
                new Set<String>{ colToWSRelationshipName }
            );
            mixedMap.putAll(clonedColsByOriginalId);
            rowColUoW.registerNew(clonedColsByOriginalId.values());
        }
        systemContext.commitWork(rowColUoW);

        //Objects depending on WS/Rows/Col (Cells, Data Types, Formulas)
        String cellToWSRelationshipName = White_Space_Cell__c.White_Space__c.getDescribe().getName();
        String cellToRowRelationshipName = White_Space_Cell__c.White_Space_Row__c.getDescribe().getName();
        String cellToColRelationshipName = White_Space_Cell__c.White_Space_Column__c.getDescribe().getName();
        String dataTypeToWSRelationshipName = WS_Data_Type__c.White_Space__c.getDescribe().getName();
        String formulaToWSRelationshipName = WS_Summary_Formula__c.White_Space__c.getDescribe().getName();
        List<White_Space_Cell__c> relatedCells = (List<White_Space_Cell__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            White_Space_Cell__c.getSObjectType(),
            originalWhitespaceIdSet,
            new Set<String>{ cellToWSRelationshipName }
        );
        List<WS_Data_Type__c> relatedDataTypes = (List<WS_Data_Type__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            WS_Data_Type__c.getSObjectType(),
            originalWhitespaceIdSet,
            new Set<String>{ dataTypeToWSRelationshipName }
        );
        List<WS_Summary_Formula__c> relatedFormulas = (List<WS_Summary_Formula__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            WS_Summary_Formula__c.getSObjectType(),
            originalWhitespaceIdSet,
            new Set<String>{ formulaToWSRelationshipName }
        );
        List<Map<Id, SObject>> dedupedClonedCellsAndDTByOriginalId = new List<Map<Id, SObject>>();
        fflib_ISObjectUnitOfWork cellAndDTUoW = new fflib_Application.UnitOfWorkFactory(
                new List<Schema.SObjectType>{ White_Space_Cell__c.getSObjectType(), WS_Data_Type__c.getSObjectType() }
            )
            .newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        for (Map<Id, SObject> clonedObjs : dedupedMixedRowColWSByOriginalId) {
            if (clonedObjs.size() == 0) {
                continue;
            }

            //Clone Cells, update relationships and seperate into deduped lists for next step
            Map<Id, SObject> clonedCellsByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedCells,
                clonedObjs,
                new Set<String>{ cellToWSRelationshipName, cellToRowRelationshipName, cellToColRelationshipName }
            );
            cellAndDTUoW.registerNew(clonedCellsByOriginalId.values());
            Map<Id, SObject> mixed = new Map<Id, SObject>(clonedCellsByOriginalId);

            //Clone Data Types and seperate into deduped lists for later step
            Map<Id, SObject> clonedDataTypesByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedDataTypes,
                clonedObjs,
                new Set<String>{ dataTypeToWSRelationshipName }
            );
            cellAndDTUoW.registerNew(clonedDataTypesByOriginalId.values());
            mixed.putAll(clonedDataTypesByOriginalId);
            dedupedClonedCellsAndDTByOriginalId.add(mixed);

            Map<Id, SObject> clonedFormulasByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedFormulas,
                clonedObjs,
                new Set<String>{ formulaToWSRelationshipName }
            );
            clonedReturnRecordsList.addAll(clonedFormulasByOriginalId.values());
        }
        systemContext.commitWork(cellAndDTUoW);

        //Objects that depend on cells (Amount Type Associations, Data Type Associations, Related Cell Objects)
        String ataToCellRelationshipName = White_Space_Amount_Type_Association__c.White_Space_Cell__c.getDescribe()
            .getName();
        String dtaToCellRelationshipName = WS_Data_Type_Association__c.White_Space_Cell__c.getDescribe().getName();
        String dtaToDTRelationshipName = WS_Data_Type_Association__c.WS_Data_Type__c.getDescribe().getName();
        Set<Id> originalWhitespaceCellIdSet = new Map<Id, White_Space_Cell__c>(relatedCells).keySet();
        Set<Id> originalDataTypeIdSet = new Map<Id, WS_Data_Type__c>(relatedDataTypes).keySet();
        Set<Id> mixedOriginalIdSet = new Set<Id>(originalWhitespaceCellIdSet);
        mixedOriginalIdSet.addAll(originalDataTypeIdSet);
        List<White_Space_Amount_Type_Association__c> relatedATAs = (List<White_Space_Amount_Type_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            White_Space_Amount_Type_Association__c.getSObjectType(),
            originalWhitespaceCellIdSet,
            new Set<String>{ ataToCellRelationshipName }
        );
        List<WS_Data_Type_Association__c> relatedDTAs = (List<WS_Data_Type_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            WS_Data_Type_Association__c.getSObjectType(),
            mixedOriginalIdSet,
            new Set<String>{ dtaToCellRelationshipName, dtaToDTRelationshipName }
        );
        List<WSRelatedObjectWrapper> relatedObjects = WhiteSpaceUtils.getWSRelatedObjectWrappers();
        List<CloneSharedService.CloneObjectsWrapper> cloneObjWraps = new List<CloneSharedService.CloneObjectsWrapper>();
        for (WSRelatedObjectWrapper wrapper : relatedObjects) {
            Set<String> relationships = new Set<String>{ wrapper.relationshipField.getName() };
            List<SObject> relatedObjs = CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
                wrapper.objDesc.getSObjectType(),
                originalWhitespaceCellIdSet,
                relationships
            );
            CloneSharedService.CloneObjectsWrapper cloneWrap = new CloneSharedService.CloneObjectsWrapper();
            cloneWrap.relatedObjects = relatedObjs;
            cloneWrap.parentRelationshipNames = relationships;
            cloneObjWraps.add(cloneWrap);
        }
        for (Map<Id, SObject> clonedCellsAndDTsByOriginalId : dedupedClonedCellsAndDTByOriginalId) {
            clonedReturnRecordsList.addAll(
                CloneSharedService.cloneWrappedObjectsReplacingParents(cloneObjWraps, clonedCellsAndDTsByOriginalId)
            );
            Map<Id, SObject> clonedATAByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedATAs,
                clonedCellsAndDTsByOriginalId,
                new Set<String>{ ataToCellRelationshipName }
            );
            clonedReturnRecordsList.addAll(clonedATAByOriginalId.values());
            Map<Id, SObject> clonedDTAsByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedDTAs,
                clonedCellsAndDTsByOriginalId,
                new Set<String>{ dtaToCellRelationshipName, dtaToDTRelationshipName }
            );
            clonedReturnRecordsList.addAll(clonedDTAsByOriginalId.values());
        }
        return clonedReturnRecordsList;
    }

    private List<SObject> cloneObjectivesForPlanIdIncludingOpportunities(
        List<Objective__c> relatedObjectives,
        String planRelationshipName,
        List<Map<Id, AccountPlanCloneWrapper>> dedupedWrappers
    ) {
        //Objectives
        List<Map<Id, SObject>> dedupedClonedObjectivesByOriginalId = new List<Map<Id, SObject>>();
        fflib_ISObjectUnitOfWork objectiveUoW = new fflib_Application.UnitOfWorkFactory(
                new List<Schema.SObjectType>{ Objective__c.getSObjectType() }
            )
            .newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        for (Map<Id, AccountPlanCloneWrapper> wrapperList : dedupedWrappers) {
           /*this one*/ Map<Id, Account_Plan__c> clonedPlansByOriginalId = clonedPlanMapForWrapperByRelationshipMap(
                wrapperList,
                AccountPlanCloneService.OBJECTIVES_RELATIONSHIP_NAME
            );
            if (clonedPlansByOriginalId.size() == 0) {
                continue;
            }

            //Clone objectives and seperate into deduped list for next step
            Map<Id, SObject> clonedObjectivesByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedObjectives,
                clonedPlansByOriginalId,
                new Set<String>{ planRelationshipName }
            );
            dedupedClonedObjectivesByOriginalId.add(clonedObjectivesByOriginalId);
            objectiveUoW.registerNew((List<Objective__c>) clonedObjectivesByOriginalId.values());
        }
        new SystemContext().commitWork(objectiveUoW);

        List<SObject> clonedRelatedObjects = new List<SObject>();
        Set<Id> originalObjectiveIdSet = new Map<Id, Objective__c>(relatedObjectives).keySet();
        //Opportunities
        String obOppToObjRelationshipName = Objective_Opportunity__c.Objective__c.getDescribe().getName();
        List<Objective_Opportunity__c> relatedOpportunities = (List<Objective_Opportunity__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Objective_Opportunity__c.getSObjectType(),
            originalObjectiveIdSet,
            new Set<String>{ obOppToObjRelationshipName }
        );
        //Objective_Task_Association__c
        String taskAssocToObjRelationshipName = Objective_Task_Association__c.Objective__c.getDescribe().getName();
        List<Objective_Task_Association__c> relatedTaskAssociations = (List<Objective_Task_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Objective_Task_Association__c.getSObjectType(),
            originalObjectiveIdSet,
            new Set<String>{ taskAssocToObjRelationshipName }
        );
        for (Map<Id, SObject> clonedObjectivesByOriginalId : dedupedClonedObjectivesByOriginalId) {
            Map<Id, SObject> clonedOpportunitiesMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedOpportunities,
                clonedObjectivesByOriginalId,
                new Set<String>{ obOppToObjRelationshipName }
            );
            clonedRelatedObjects.addAll(clonedOpportunitiesMap.values());
            Map<Id, SObject> clonedTaskAssociationsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedTaskAssociations,
                clonedObjectivesByOriginalId,
                new Set<String>{ taskAssocToObjRelationshipName }
            );
            clonedRelatedObjects.addAll(clonedTaskAssociationsMap.values());
        }
        return clonedRelatedObjects;
    }

    /*private List<SObject> cloneKeyStakeholderDependenciesWithPlaceholders(
        List<Map_Member_Placeholder__c> relatedPlaceholders,
        String planRelationshipName,
        List<Map<Id, AccountPlanCloneWrapper>> dedupedWrappers,
        Set<Id> planIdSet
    ) {
        //Placeholders Users & Groups
        String userPlanRelationshipName = Map_Member_User__c.Account_Plan__c.getDescribe().getName();
        List<Map_Member_User__c> relatedUsers = (List<Map_Member_User__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Map_Member_User__c.getSObjectType(),
            planIdset,
            new Set<String>{ userPlanRelationshipName }
        );

        String groupPlanRelationshipName = Relationship_Group__c.Account_Plan__c.getDescribe().getName();
        List<Relationship_Group__c> relatedGroups = (List<Relationship_Group__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group__c.getSObjectType(),
            planIdSet,
            new Set<String>{ groupPlanRelationshipName }
        );
        List<Map<Id, SObject>> dedupedClonedPlaceholdersByOriginalId = new List<Map<Id, SObject>>();
        List<Map<Id, SObject>> dedupedClonedUsersByOriginalId = new List<Map<Id, SObject>>();
        List<Map<Id, SObject>> dedupedClonedGroupsByOriginalId = new List<Map<Id, SObject>>();
        List<Map<Id, SObject>> dedupedClonedMixedObjectsByOriginalId = new List<Map<Id, SObject>>();
        fflib_ISObjectUnitOfWork placeholderUoW = new fflib_Application.UnitOfWorkFactory(
                new List<Schema.SObjectType>{
                    Map_Member_Placeholder__c.getSObjectType(),
                    Map_Member_User__c.getSObjectType(),
                    Relationship_Group__c.getSObjectType()
                }
            )
            .newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        for (Map<Id, AccountPlanCloneWrapper> wrapperList : dedupedWrappers) {
            Map<Id, Account_Plan__c> clonedPlansByOriginalId = clonedPlanMapForWrapperByRelationshipMap(
                wrapperList,
                AccountPlanCloneService.PLACEHOLDER_RELATIONSHIP_NAME
            );
            if (clonedPlansByOriginalId.size() == 0) {
                continue;
            }

            //Clone placeholders and seperate into deduped list for next step
            Map<Id, SObject> clonedPlaceholdersByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedPlaceholders,
                clonedPlansByOriginalId,
                new Set<String>{ planRelationshipName }
            );
            dedupedClonedPlaceholdersByOriginalId.add(clonedPlaceholdersByOriginalId);
            placeholderUoW.registerNew(clonedPlaceholdersByOriginalId.values());
            //Clone Users and seperate into deduped list for next step
            Map<Id, SObject> clonedUsersByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedUsers,
                clonedPlansByOriginalId,
                new Set<String>{ userPlanRelationshipName }
            );
            dedupedClonedUsersByOriginalId.add(clonedUsersByOriginalId);
            placeholderUoW.registerNew(clonedUsersByOriginalId.values());
            //Clone groups and seperate add to deduped list for next step
            Map<Id, SObject> clonedGroupsByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedGroups,
                clonedPlansByOriginalId,
                new Set<String>{ groupPlanRelationshipName }
            );
            dedupedClonedGroupsByOriginalId.add(clonedGroupsByOriginalId);
            Map<Id, SObject> mixed = new Map<Id, SObject>(clonedPlaceholdersByOriginalId);
            mixed.putAll(clonedGroupsByOriginalId);
            mixed.putAll(clonedUsersByOriginalId);
            mixed.putAll(clonedPlansByOriginalId);
            dedupedClonedMixedObjectsByOriginalId.add(mixed);
            placeholderUoW.registerNew(clonedGroupsByOriginalId.values());
        }
        new SystemContext().commitWork(placeholderUoW);
        Set<Id> originalPlaceholderIdSet = new Map<Id, Map_Member_Placeholder__c>(relatedPlaceholders).keySet();
        Set<Id> originalGroupIdSet = new Map<Id, Relationship_Group__c>(relatedGroups).keySet();
        Set<Id> originalMixedObjectIdSet = new Set<Id>(originalPlaceholderIdSet);
        originalMixedObjectIdSet.addAll(originalGroupIdSet);
        originalMixedObjectIdSet.addAll(planIdSet);

        //Placeholder Relationships
        List<SObject> clonedObjectsNotInserted = new List<SObject>();
        String fromPlaceholderRelName = Map_Member_Placeholder_Relationship__c.From__c.getDescribe().getName();
        String toPlaceholderRelName = Map_Member_Placeholder_Relationship__c.To__c.getDescribe().getName();
        String planPlaceholderRelName = Map_Member_Placeholder_Relationship__c.Account_Plan__c.getDescribe().getName();
        Set<String> parentFields = new Set<String>{
            fromPlaceholderRelName,
            toPlaceholderRelName,
            planPlaceholderRelName
        };
        List<Map_Member_Placeholder_Relationship__c> relatedRelationships = (List<Map_Member_Placeholder_Relationship__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Map_Member_Placeholder_Relationship__c.getSObjectType(),
            originalMixedObjectIdSet,
            parentFields
        );

        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedPlaceholderRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedRelationships,
                clonedMixedByOriginalId,
                parentFields
            );
            clonedObjectsNotInserted.addAll(clonedPlaceholderRelationshipsMap.values());
        }

        //Group Placeholder Associations
        String placeholderRelName = Relationship_Group_Placeholder_Assoc__c.Map_Member_Placeholder__c.getDescribe()
            .getName();
        String groupRelName = Relationship_Group_Placeholder_Assoc__c.Relationship_Group__c.getDescribe().getName();
        Set<String> groupPlaceholderParentFields = new Set<String>{ placeholderRelName, groupRelName };
        List<Relationship_Group_Placeholder_Assoc__c> groupPlaceholderRelationships = (List<Relationship_Group_Placeholder_Assoc__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group_Placeholder_Assoc__c.getSObjectType(),
            originalMixedObjectIdSet,
            groupPlaceholderParentFields
        );

        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedPlaceholderRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                groupPlaceholderRelationships,
                clonedMixedByOriginalId,
                groupPlaceholderParentFields
            );
            clonedObjectsNotInserted.addAll(clonedPlaceholderRelationshipsMap.values());
        }

        //Group Contact Associations
        String groupContactRelName = Relationship_Group_Contact_Association__c.Relationship_Group__c.getDescribe()
            .getName();
        Set<String> groupContactParentFields = new Set<String>{ groupContactRelName };
        List<Relationship_Group_Contact_Association__c> groupContactRelationships = (List<Relationship_Group_Contact_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group_Contact_Association__c.getSObjectType(),
            originalGroupIdSet,
            groupContactParentFields
        );

        for (Map<Id, SObject> clonedGroupsByOriginalId : dedupedClonedGroupsByOriginalId) {
            Map<Id, SObject> clonedContactRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                groupContactRelationships,
                clonedGroupsByOriginalId,
                groupContactParentFields
            );
            clonedObjectsNotInserted.addAll(clonedContactRelationshipsMap.values());
        }

        //Group User Associations
        String groupUserRelName = Relationship_Group_User_Association__c.Relationship_Group__c.getDescribe().getName();
        Set<String> groupUserParentFields = new Set<String>{ groupUserRelName };
        List<Relationship_Group_User_Association__c> groupUserRelationships = (List<Relationship_Group_User_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group_User_Association__c.getSObjectType(),
            originalGroupIdSet,
            groupUserParentFields
        );

        for (Map<Id, SObject> clonedGroupsByOriginalId : dedupedClonedGroupsByOriginalId) {
            Map<Id, SObject> clonedUserRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                groupUserRelationships,
                clonedGroupsByOriginalId,
                groupUserParentFields
            );
            clonedObjectsNotInserted.addAll(clonedUserRelationshipsMap.values());
        }

        //Group Lead Associations
        String groupLeadRelName = Relationship_Group_Lead_Association__c.Relationship_Group__c.getDescribe().getName();
        Set<String> groupLeadParentFields = new Set<String>{ groupLeadRelName };
        List<Relationship_Group_Lead_Association__c> groupLeadRelationships = (List<Relationship_Group_Lead_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group_Lead_Association__c.getSObjectType(),
            originalGroupIdSet,
            groupLeadParentFields
        );

        for (Map<Id, SObject> clonedGroupsByOriginalId : dedupedClonedGroupsByOriginalId) {
            Map<Id, SObject> clonedLeadRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                groupLeadRelationships,
                clonedGroupsByOriginalId,
                groupLeadParentFields
            );
            clonedObjectsNotInserted.addAll(clonedLeadRelationshipsMap.values());
        }

        //Anchors
        String anchorPlanRelationshipName = RM_Anchor__c.Account_Plan__c.getDescribe().getName();
        Set<String> anchorPlanParentFields = new Set<String>{ anchorPlanRelationshipName };
        List<RM_Anchor__c> anchorRelationships = (List<RM_Anchor__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            RM_Anchor__c.getSObjectType(),
            planIdSet,
            anchorPlanParentFields
        );

        String anchorFromRelationshipName = RM_Anchor__c.From__c.getDescribe().getName();
        String anchorToRelationshipName = RM_Anchor__c.To__c.getDescribe().getName();
        Set<String> anchorRelationshipFields = new Set<String>{
            anchorPlanRelationshipName,
            anchorFromRelationshipName,
            anchorToRelationshipName
        };
        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedAnchorsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                anchorRelationships,
                clonedMixedByOriginalId,
                anchorRelationshipFields
            );
            clonedObjectsNotInserted.addAll(clonedAnchorsMap.values());
        }

        //Coordinates
        String coordPlanRelationshipName = RM_Node_Coordinate__c.Account_Plan__c.getDescribe().getName();
        Set<String> coordPlanParentFields = new Set<String>{ coordPlanRelationshipName };
        List<RM_Node_Coordinate__c> coordRelationships = (List<RM_Node_Coordinate__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            RM_Node_Coordinate__c.getSObjectType(),
            planIdSet,
            coordPlanParentFields
        );

        String coordKeyRelationshipName = RM_Node_Coordinate__c.Key__c.getDescribe().getName();
        Set<String> coordRelationshipFields = new Set<String>{ coordPlanRelationshipName, coordKeyRelationshipName };
        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedAnchorsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                coordRelationships,
                clonedMixedByOriginalId,
                coordRelationshipFields
            );
            clonedObjectsNotInserted.addAll(clonedAnchorsMap.values());
        }

        //Node Badge Association
        String badgeAssocPlanRelationshipName = RM_Svg_Node_Association__c.Account_Plan__c.getDescribe().getName();
        Set<String> badgeAssocPlanParentFields = new Set<String>{ badgeAssocPlanRelationshipName };
        List<RM_Svg_Node_Association__c> badgeAssocRelationships = (List<RM_Svg_Node_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            RM_Svg_Node_Association__c.getSObjectType(),
            planIdSet,
            badgeAssocPlanParentFields
        );

        String badgeAssocKeyRelationshipName = RM_Svg_Node_Association__c.Key__c.getDescribe().getName();
        Set<String> badgeAssocRelationshipFields = new Set<String>{
            badgeAssocPlanRelationshipName,
            badgeAssocKeyRelationshipName
        };
        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedBadgeAssocMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                badgeAssocRelationships,
                clonedMixedByOriginalId,
                badgeAssocRelationshipFields
            );
            clonedObjectsNotInserted.addAll(clonedBadgeAssocMap.values());
        }

        return clonedObjectsNotInserted;
    }*/

    private List<Team_Member__c> cloneTeamMembersForPlanIdReplacingOwner(
        List<Team_Member__c> relatedObjects,
        String planRelationshipName,
        Map<Id, Account_Plan__c> originalPlansById,
        List<Map<Id, AccountPlanCloneWrapper>> dedupedWrappers
    ) {
        List<Team_Member__c> clonedRelatedObjs = new List<Team_Member__c>();
        for (Map<Id, AccountPlanCloneWrapper> wrapperList : dedupedWrappers) {
            Map<Id, Account_Plan__c> clonedPlansByOriginalId = clonedPlanMapForWrapperByRelationshipMap(
                wrapperList,
                AccountPlanCloneService.TEAM_MEMBERS_RELATIONSHIP_NAME
            );
            if (clonedPlansByOriginalId.size() == 0) {
                continue;
            }
            for (Team_Member__c relatedObj : relatedObjects) {
                Id originalPlanId = (Id) relatedObj.get(planRelationshipName);
                Account_Plan__c clonedPlan = (Account_Plan__c) clonedPlansByOriginalId.get(originalPlanId);
                if (clonedPlan == null) {
                    continue;
                }
                if (relatedObj.User__c == clonedPlan.OwnerId) {
                    continue;
                }
                Team_Member__c clonedRObj = relatedObj.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
                clonedRObj.put(planRelationshipName, clonedPlan.Id);
                clonedRelatedObjs.add(clonedRObj);
            }
        }
        return clonedRelatedObjs;
    }

    private Map<String, Set<Id>> planIdsByRelationshipForWrappers(List<AccountPlanCloneWrapper> wrappers) {
        Map<String, Set<Id>> planIdsByRelationship = new Map<String, Set<Id>>();
        for (AccountPlanCloneWrapper wrapper : wrappers) {
            if (wrapper.relationships == null) {
                wrapper.relationships = new List<String>();
            }
            for (String relationshipName : wrapper.relationships) {
                Set<Id> idSet = planIdsByRelationship.get(relationshipName);
                if (idSet == null) {
                    idSet = new Set<Id>();
                }
                idSet.add(wrapper.planId);
                planIdsByRelationship.put(relationshipName, idSet);
            }
        }
        return planIdsByRelationship;
    }

    private List<Map<Id, AccountPlanCloneWrapper>> dedupedWrapperByPlanIdList(List<AccountPlanCloneWrapper> wrappers) {
        List<Map<Id, AccountPlanCloneWrapper>> wrapperByPlanIdNoDupeLists = new List<Map<Id, AccountPlanCloneWrapper>>();
        for (AccountPlanCloneWrapper wrapper : wrappers) {
            Map<Id, AccountPlanCloneWrapper> mapWithoutPlan = null;
            for (Integer i = 0; i < wrapperByPlanIdNoDupeLists.size(); i++) {
                Map<Id, AccountPlanCloneWrapper> currentMap = wrapperByPlanIdNoDupeLists[i];
                if (currentMap.get(wrapper.planId) == null) {
                    mapWithoutPlan = currentMap;
                    break;
                }
            }
            if (mapWithoutPlan == null) {
                mapWithoutPlan = new Map<Id, AccountPlanCloneWrapper>();
                wrapperByPlanIdNoDupeLists.add(mapWithoutPlan);
            }
            mapWithoutPlan.put(wrapper.planId, wrapper);
        }
        return wrapperByPlanIdNoDupeLists;
    }

    private Map<Id, Account_Plan__c> clonedPlanMapForWrapperByRelationshipMap(
        Map<Id, AccountPlanCloneWrapper> wrapperList,
        String relationshipName
    ) {
        Map<Id, Account_Plan__c> clonedPlans = new Map<Id, Account_Plan__c>();
        for (AccountPlanCloneWrapper wrapper : wrapperList.values()) {
            if (wrapper.relationships != null && wrapper.relationships.contains(relationshipName)) {
                clonedPlans.put(wrapper.planId, wrapper.clonedPlan);
            }
        }
        return clonedPlans;
    }

    public List<String> relationshipsWithSubitems(List<String> relationships) {
        if (relationships.contains(AccountPlanCloneService.RELATIONSHIP_MAP_RELATIONSHIP_NAME)) {
            relationships.addAll(keyStakeholderSimpleSubObjects);
        }
        return relationships;
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
    private Map<String, Schema.ChildRelationship> getChildRelationshipsMap() {
        List<Schema.ChildRelationship> relationships = Schema.SObjectType.Account_Plan__c.getChildRelationships();
        Map<String, Schema.ChildRelationship> childRelationshipsByRelationshipName = new Map<String, Schema.ChildRelationship>();
        for (Schema.ChildRelationship cr : relationships) {
            childRelationshipsByRelationshipName.put(cr.getRelationshipName(), cr);
        }
        return childRelationshipsByRelationshipName;
    }
}