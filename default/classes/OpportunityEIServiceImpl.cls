@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class OpportunityEIServiceImpl {

    public void processOpportunityForDate(List<Opportunity> opps, Date d) {
        
        // Remove Opps that have already been used in calculations
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }
        List<pq_Opportunity_Effectiveness_Association__c> oppEAssocs = OpportunityEIAssociationSelector.newInstance().selectByOpportunities(oppIds);

        Set<Id> oppsUsed = new Set<Id>();
        for (pq_Opportunity_Effectiveness_Association__c oppEAssoc : oppEAssocs) {
            oppsUsed.add(oppEAssoc.Opportunity__c);
        }

        List<Opportunity> newOpps = new List<Opportunity>();
        for (Opportunity opp : opps) {
            if (!oppsUsed.contains(opp.Id)) {
                newOpps.add(opp);
            }
        }

        OpportunityEffectivenessData oppEffData =  OpportunityScoreService.calculateOpportunityEfficiencyIndex(newOpps);

        // Remove old data
        List<pq_Opportunity_Effectiveness_Index__c> oldDataList = OpportunityEffectivenessIndexSelector.newInstance().selectByDate(d);

        if (oldDataList.size() == 1) {
            OpportunityEffectivenessData oldData = OpportunityEffectivenessData.convert(oldDataList[0]);
            oppEffData = OpportunityScoreService.mergeData(oppEffData, oldData);
        }

        // Create new entry
        pq_Opportunity_Effectiveness_Index__c newItem = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d,
            Serialized_Won_Data__c = JSON.serialize(oppEffData.wonMap),
            Serialized_Lost_Data__c = JSON.serialize(oppEffData.lostMap),
            Total_Won__c = oppEffData.totalWon,
            Total_Lost__c =  oppEffData.totalLost,
            Total_Won_With_Contact__c = oppEffData.wonWithContact,
            Total_Lost_With_Contact__c = oppEffData.lostWithContact
        );

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        if (oldDataList.size() == 1) {
            newItem.Id = oldDataList[0].Id;
            uow.registerDirty(newItem);
        } else {
            uow.registerNew(newItem);
        }
        uow.commitWork();

        
        // Bind opportunities to Index
        List<pq_Opportunity_Effectiveness_Association__c> oppsAssociationList = new List<pq_Opportunity_Effectiveness_Association__c>();
        for (Opportunity opp : newOpps) {
            oppsAssociationList.add(new pq_Opportunity_Effectiveness_Association__c(Opportunity__c = opp.Id, Opportunity_Effectiveness_Index__c = newItem.Id));
        }

        fflib_ISObjectUnitOfWork uow3 = Application.UnitOfWork.newInstance();
        uow3.registerNew(oppsAssociationList);
        uow3.commitWork();
    }


    // public void processRedosForList(List<Opportunity> opps, List<OpportunityContactRole> ocrs) {

    //     Set<Id> oppIds = new Set<Id>();
    //     for (OpportunityContactRole ocr : ocrs) {
    //         oppIds.add(ocr.OpportunityId);
    //     }

    //     // Check to see if any opportunities were previously calcluated (if none, then exit)
    //     List<pq_Opportunity_Effectiveness_Association__c> associationList = OpportunityEIAssociationSelector.newInstance().selectByOpportunities(oppIds);

    //     if (associationList.size() <= 0) {
    //         return;
    //     }

    //     Set<Id> opportunityEffectivenessIndexIds = new Set<Id>();
    //     for (pq_Opportunity_Effectiveness_Association__c assoc : associationList) {
    //         opportunityEffectivenessIndexIds.add(assoc.Opportunity_Effectiveness_Index__c);
    //     }

    //     // Remove the previous assocations (since those will get recalculated with today's numbers)
    //     fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    //     uow.registerDeleted(associationList);
    //     uow.commitWork();

    //     // Redo these Opportunity Efficiency Indexes and the remainder opportunities
    //     List<pq_Opportunity_Effectiveness_Association__c> associationList2 = OpportunityEIAssociationSelector.newInstance().selectByOEI(opportunityEffectivenessIndexIds);
    //     Set<Id> oppIdsToRedo = new Set<Id>();
    //     Map<Id, Set<Id>> oppEIAndOpportunities = new Map<Id, Set<Id>>();
    //     Map<Id, Id> oppToIndexMap = new Map<Id, Id>();

    //     for (pq_Opportunity_Effectiveness_Association__c assoc : associationList2) {
    //         oppToIndexMap.put(assoc.Opportunity__c, assoc.Opportunity_Effectiveness_Index__c);
    //         oppIdsToRedo.add(assoc.Opportunity__c);
    //         if (oppEIAndOpportunities.containsKey(assoc.Opportunity_Effectiveness_Index__c)) {
    //             Set<Id> opps = oppEIAndOpportunities.get(assoc.Opportunity_Effectiveness_Index__c);
    //             opps.add(assoc.Opportunity__c);
    //             oppEIAndOpportunities.put(assoc.Opportunity_Effectiveness_Index__c, opps);
    //         } else {
    //             oppEIAndOpportunities.put(assoc.Opportunity_Effectiveness_Index__c, new Set<Id>{ assoc.Opportunity__c });
    //         }
    //     }

    //     //System.debug('*** opportunityEffectivenessIndexIds: ' + opportunityEffectivenessIndexIds);
    //     List <pq_Opportunity_Effectiveness_Index__c> oEIList = OpportunityEffectivenessIndexSelector.newInstance().selectById(opportunityEffectivenessIndexIds);
    //     Map<Id, pq_Opportunity_Effectiveness_Index__c> mapOEI = new Map<Id, pq_Opportunity_Effectiveness_Index__c>();
    //     for (pq_Opportunity_Effectiveness_Index__c oppEffIndex : oEIList) {
    //         mapOEI.put(oppEffIndex.Id, oppEffIndex);
    //     }


    //     //System.debug('*** oppIdsToRedo: ' + oppIdsToRedo);
    //     //Map<Id, List<OpportunityContactRole>> oeffindexandcontactroles = new Map<Id, List<OpportunityContactRole>>();
    //     List<OpportunityContactRole> redoOcrs = OpportunityContactRoleSelector.newInstance().selectByOpportunityIds(oppIdsToRedo);
    //     Map<Id, List<OpportunityContactRole>> oeiAndContactRoles = new Map<Id, List<OpportunityContactRole>>();
    //     for (OpportunityContactRole ocr : redoOcrs) {
    //         Id indexId = oppToIndexMap.get(ocr.OpportunityId);
    //         if (indexId != null) {
    //             if (oeiAndContactRoles.containsKey(indexId)) {
    //                 List<OpportunityContactRole> contactroles = oeiAndContactRoles.get(indexId);
    //                 contactroles.add(ocr);
    //                 oeiAndContactRoles.put(indexId, contactroles);
    //             } else {
    //                 oeiAndContactRoles.put(indexId, new List<OpportunityContactRole>{ ocr });
    //             }
    //         }
    //     }


    //     for (Id indexId : oeiAndContactRoles.keySet()) {
    //         pq_Opportunity_Effectiveness_Index__c updateIndex = mapOEI.get(indexId);
    //         //System.debug('updateIndex: ' + updateIndex);

    //         List<OpportunityContactRole> ocrList = oeiAndContactRoles.get(indexId);
    //         //System.debug('*** ocrList: ' + ocrList);
    //         OpportunityEffectivenessData indexData = OpportunityScoreService.calculateOpportunityEfficiencyIndex(ocrList);

    //         //System.debug('indexData: ' + indexData);

            
    //         updateIndex.Serialized_Won_Data__c = JSON.serialize(indexData.wonMap);
    //         updateIndex.Serialized_Lost_Data__c = JSON.serialize(indexData.lostMap);
    //     }

    //     //System.debug('*** mapOEI.values(): ' + mapOEI.values());

    //     fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();
    //     uow2.registerDirty(mapOEI.values());
    //     uow2.commitWork();
    // }

    public void processRollingData(Integer numberOfDaysToRollData) {
        Date d = Date.Today();
        Date startDate = d.AddDays(0 - numberOfDaysToRollData);
        List<pq_Opportunity_Effectiveness_Index__c> oEIDataList = OpportunityEffectivenessIndexSelector.newInstance().selectByStartDate(startDate);

        OpportunityEffectivenessData rollingTotal = new OpportunityEffectivenessData();

        for (pq_Opportunity_Effectiveness_Index__c oEIData : oEIDataList) {
            OpportunityEffectivenessData oppEffData = OpportunityEffectivenessData.convert(oEIData);
            rollingTotal = OpportunityScoreService.mergeData(rollingTotal, oppEffData);
        }

        pq_Opportunity_Effectiveness_Index__c latestOne = oEIDataList[0];
        latestOne.Rolling_Serialized_Won_Data__c = JSON.serialize(rollingTotal.wonMap);
        latestOne.Rolling_Serialized_Lost_Data__c = JSON.serialize(rollingTotal.lostMap);
        latestOne.Rolling_Total_Won__c = rollingTotal.totalWon;
        latestOne.Rolling_Total_Lost__c = rollingTotal.totalLost;
        latestOne.Rolling_Total_Won_With_Contact__c = rollingTotal.wonWithContact;
        latestOne.Rolling_Total_Lost_With_Contact__c = rollingTotal.lostWithContact;

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(latestOne);
        uow.commitWork();
    }
}