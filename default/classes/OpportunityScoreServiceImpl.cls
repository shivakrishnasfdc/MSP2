@SuppressWarnings('PMD.NcssMethodCount, PMD.CyclomaticComplexity')
public with sharing class OpportunityScoreServiceImpl {

    public OpportunityEffectivenessData calculateOpportunityEfficiencyIndex(List<Opportunity> opps) {

        OpportunityEffectivenessData result = new OpportunityEffectivenessData();
        
        if (opps == null || opps.size() <= 0) {
            return result;
        }

        Set<Id> oppIds = new Set<Id>();
        Integer totalWon = 0;
        Integer totalLost = 0;
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
            if (opp.IsClosed && opp.IsWon) {
                totalWon++;
            }
            if (opp.IsClosed && !opp.IsWon) {
                totalLost++;
            }
        }
        
        Map<Id, List<OpportunityContactRole>> mapOpps = OpportunityScoreHelperService.getMapOppsContactRole(oppIds);

        Decimal wonHasContact = 0;
        Decimal lostHasContact = 0;

        Map<String, Decimal> wonMap = new Map<String, Decimal>();
        Map<String, Decimal> lostMap = new Map<String, Decimal>();

        for (Id oppId : mapOpps.keySet()) {
            Boolean wonHasContactRole = false;
            Boolean lostHasContactRole = false;

            List<OpportunityContactRole> ocrList = mapOpps.get(oppId);

            for (OpportunityContactRole ocr : ocrList) {

                if (!ocr.Opportunity.IsClosed) {
                    continue;
                }

                if (ocr.Opportunity.IsWon) {
                    wonHasContactRole = true;
                    if (wonMap.containsKey(ocr.Role)) {
                        Decimal count = wonMap.get(ocr.Role);
                        count++;
                        wonMap.put(ocr.Role, count++);
                    } else {
                        wonMap.put(ocr.Role, 1);
                    }

                } else {
                    lostHasContactRole = true;
                    if (lostMap.containsKey(ocr.Role)) {
                        Decimal count = lostMap.get(ocr.Role);
                        count++;
                        lostMap.put(ocr.Role, count++);
                    } else {
                        lostMap.put(ocr.Role, 1);
                    }
                }
            }
            if (wonHasContactRole) {
                wonHasContact++;
            }

            if (lostHasContactRole) {
                lostHasContact++;
            }
        }

        result.wonMap = wonMap;
        result.lostMap = lostMap;
        result.lostWithContact = lostHasContact;
        result.wonWithContact = wonHasContact;
        result.totalLost = totalLost;
        result.totalWon = totalWon;

        return result;
    }

    public OpportunityEffectivenessData mergeData(OpportunityEffectivenessData newData, OpportunityEffectivenessData oldData) {

        Map<String, Decimal> newLostMap = UtilityForMap.mergeData(newData.lostMap, oldData.lostMap);
        Map<String, Decimal> newWonMap = UtilityForMap.mergeData(newData.wonMap, oldData.wonMap);

        OpportunityEffectivenessData result = new OpportunityEffectivenessData();

        result.totalLost = newData.totalLost + oldData.totalLost;
        result.totalWon = newData.totalWon + oldData.totalWon;
        result.wonWithContact = newData.wonWithContact + oldData.wonWithContact;
        result.lostWithContact = newData.lostWithContact + oldData.lostWithContact;
        result.lostMap = newLostMap;
        result.wonMap = newWonMap;
        
        return result;
    }

    public Map<Id, OpportunityScoreData> calculateOpportunityScore(Set<Id> opportunityIds) {
        Map<Id, List<OpportunityContactRole>> oppXcontactRoles = OpportunityScoreHelperService.getMapOppsContactRole(opportunityIds);
        pq_Opportunity_Effectiveness_Index__c oeiData = OpportunityEffectivenessIndexSelector.newInstance().selectOne();
        OpportunityEffectivenessData oppEffData = OpportunityEffectivenessData.convertForRollingData(oeiData);
        Map<Id, OpportunityScoreData> result = new Map<Id, OpportunityScoreData>();

        for (Id oppId : opportunityIds) {
            List<OpportunityContactRole> ocrForPlan = oppXcontactRoles.get(oppId);
            OpportunityScoreData osd = OpportunityScoreHelperService.calculateOpportunityScoreData(ocrForPlan, oppEffData);
            result.put(oppId, osd);
        }

        return result;        
    }
}