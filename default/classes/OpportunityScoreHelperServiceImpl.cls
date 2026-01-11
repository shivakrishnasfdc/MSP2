public with sharing class OpportunityScoreHelperServiceImpl {

    public Map<Id, List<OpportunityContactRole>> getMapOppsContactRole(Set<Id> oppIds) {
        List<OpportunityContactRole> ocrs = OpportunityContactRoleSelector.newInstance().selectByOpportunityIds(oppIds);

        Map<Id, List<OpportunityContactRole>> mapOpps = new Map<Id, List<OpportunityContactRole>>();

        for (OpportunityContactRole ocr : ocrs) {
            if (!mapOpps.containsKey(ocr.OpportunityId)) {
                mapOpps.put(ocr.OpportunityId, new List<OpportunityContactRole>{ ocr });
            } else {
                List<OpportunityContactRole> ocrList = mapOpps.get(ocr.OpportunityId);
                ocrList.add(ocr);
                mapOpps.put(ocr.OpportunityId, ocrList);
            }
        }

        return mapOpps;
    }

    public OpportunityScoreData calculateOpportunityScoreData(List<OpportunityContactRole> ocrs, OpportunityEffectivenessData oeData) {
        OpportunityScoreData result = new OpportunityScoreData();

        Map<String, Decimal> lostData = oeData.lostMap;
        Map<String, Decimal> wonData = oeData.wonMap;

        Decimal totalWon = oeData.totalWon;
        Decimal totalLost = oeData.totalLost;
        Decimal totalWonWithContact = oeData.wonWithContact;
        Decimal totalLostWithContact = oeData.lostWithContact;

        Boolean hasContact = false;

        Set<String> roles = new Set<String>();
        if (ocrs != null && ocrs.size() > 0) {
            for (OpportunityContactRole ocr : ocrs) {
                roles.add(ocr.Role);
            }
            hasContact = true;
        }

        List<NameDecimalPair> positiveDifference = new List<NameDecimalPair>();
        Decimal totalPossibleScore = 0;
        Decimal totalScore = 0;
        for (String k : wonData.keySet()) {
            Decimal lost = 0;
            if (lostData.containsKey(k)) {
                lost = lostData.get(k);
            }
            Decimal won = wonData.get(k);
            Decimal wonDiff = this.calcDiffInPercent(won, lost, totalWon, totalLost);
            totalPossibleScore += wonDiff;
            if (wonDiff > 0 && !roles.contains(k)) {
                positiveDifference.add(new NameDecimalPair(k, wonDiff));
            } else if (wonDiff > 0) {
                totalScore += wonDiff;
            }
        }

        result.dataList = positiveDifference;

        result.withOpportunityContact = 0;
        Decimal oppWithContactPercent = this.calcDiffInPercent(totalWonWithContact, totalLostWithContact, totalWon, totalLost);
        if (oppWithContactPercent > 0 && roles.size() <= 0) {
            result.withOpportunityContact = oppWithContactPercent;
        }

        result.normalizedScore = this.calculateOpportunityScore(totalScore, totalPossibleScore);

        return result;
    }

    private Decimal calculateOpportunityScore(Decimal totalScore, Decimal totalPossible) {
        return ((totalScore / totalPossible) * 100).round(System.RoundingMode.FLOOR);
    }

    private Decimal calcDiffInPercent(Decimal won, Decimal lost, Decimal totalWon, Decimal totalLost) {
        
        Decimal percentWon = 0;
        if (totalWon > 0) {
            percentWon = won / totalWon;
        }

        Decimal percentLost = 0;
        if (totalLost > 0) {
            percentLost = lost / totalLost;
        }

        return percentWon - percentLost;
    }
}