public with sharing class HealthScoreServiceImpl {
    public Double getTotalScoreForAccountPlan(Account_Plan__c accountPlan, List<PQ_AP_Score__mdt> allMetadata) {
        if (accountPlan == null || allMetadata == null) {
            return 0;
        }
        Double updatedScore = 0;
        for (PQ_AP_Score__mdt metadata : allMetadata) {
            Double points = getScoreFromPlanForMetadata(accountPlan, metadata);
            if (points != -1) {
                updatedScore += points;
            }
        }
        return updatedScore;
    }

    public Double getTotalScoreForAccountPlanPercent(Account_Plan__c accountPlan, List<PQ_AP_Score__mdt> allMetadata) {
        if (accountPlan == null || allMetadata == null) {
            return 0;
        }
        Double updatedScore = 0;
        for (PQ_AP_Score__mdt metadata : allMetadata) {
            Double points = getScoreFromPlanForMetadataPercent(accountPlan, metadata);

            Decimal thresholdLimit = (metadata.Threshold_Limit__c != null)
                ? metadata.Threshold_Limit__c
                : metadata.Score_BP_High__c;

            Decimal categoryPointTotal = (metadata.Category_Point_Total__c != null)
                ? metadata.Category_Point_Total__c
                : (metadata.Threshold_Limit__c != null) ? metadata.Threshold_Limit__c : metadata.Score_BP_High__c;

            points = points < thresholdLimit ? points : thresholdLimit;

            Double percentage = (points / thresholdLimit) * 100;

            Double pointsAwarded = (percentage / 100) * categoryPointTotal;

            if (points != -1) {
                updatedScore += pointsAwarded;
            }
        }

        return updatedScore;
    }

    public Double getMaxTotalScore() {
        List<PQ_AP_Score__mdt> allMetadata = HealthScoreMetadataSelector.newInstance().selectEnabled();
        Decimal maxPoints = 0;
        for (PQ_AP_Score__mdt metadata : allMetadata) {
            maxPoints += metadata.Score_BP_High__c;
        }
        return maxPoints;
    }

    public Double getMaxTotalScorePercent() {
        List<PQ_AP_Score__mdt> allMetadata = HealthScoreMetadataSelector.newInstance().selectEnabled();
        Decimal maxPoints = 0;
        for (PQ_AP_Score__mdt metadata : allMetadata) {
            maxPoints += (metadata.Category_Point_Total__c != null)
                ? metadata.Category_Point_Total__c
                : (metadata.Threshold_Limit__c != null) ? metadata.Threshold_Limit__c : metadata.Score_BP_High__c;
        }
        return maxPoints;
    }

    public Set<String> getAccountPlanFieldNamesForScoreMetadata(List<PQ_AP_Score__mdt> scoreMetadata) {
        if (scoreMetadata == null || scoreMetadata.size() == 0) {
            return new Set<String>();
        }
        Set<String> fieldNames = new Set<String>();
        for (PQ_AP_Score__mdt metadata : scoreMetadata) {
            if (
                UTIL_Describe.isValidField(
                    Schema.SObjectType.pqcrush__Account_Plan__c.getName(),
                    metadata.Score_Field_API_Name__c.toLowerCase()
                )
            ) {
                fieldNames.add(metadata.Score_Field_API_Name__c);
                if (
                    metadata.Date_Field_API_Name__c != null &&
                    UTIL_Describe.isValidField(
                        Schema.SObjectType.pqcrush__Account_Plan__c.getName(),
                        metadata.Date_Field_API_Name__c.toLowerCase()
                    )
                ) {
                    fieldNames.add(metadata.Date_Field_API_Name__c);
                }
            }
        }
        return fieldNames;
    }

    public List<PQ_AP_Score__mdt> getValidScoreMetadata() {
        List<PQ_AP_Score__mdt> allMetadata = HealthScoreMetadataSelector.newInstance().selectEnabled();
        List<PQ_AP_Score__mdt> validMetadata = new List<PQ_AP_Score__mdt>();
        for (PQ_AP_Score__mdt metadata : allMetadata) {
if (
                UTIL_Describe.isValidField(
                    Schema.SObjectType.pqcrush__Account_Plan__c.getName(),
                    metadata.Score_Field_API_Name__c.toLowerCase()
                )
            ) {
                validMetadata.add(metadata);
            }
        }
        return validMetadata;
    }

    public ColorBoundary getColorBoundaryFromSettings(CRUSH_Settings_Obj__c settings) {
        String lowColor = settings?.Score_Low_Color__c != null ? settings.Score_Low_Color__c : '#E1341E';
        String midColor = settings?.Score_Mid_Color__c != null ? settings.Score_Mid_Color__c : '#EB8214';
        String highColor = settings?.Score_High_Color__c != null ? settings.Score_High_Color__c : '#2DD24A';
        Decimal lowBound = settings?.Score_Low_Mid_Boundary__c != null ? settings.Score_Low_Mid_Boundary__c : .25;
        Decimal midBound = settings?.Score_Mid_High_Boundary__c != null ? settings.Score_Mid_High_Boundary__c : .75;
        return new ColorBoundary(lowColor, midColor, highColor, lowBound, midBound);
    }

    public Double getScoreFromPlanForMetadata(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        if (accountPlan == null || metadata == null) {
            return -1;
        }
        if (metadata.DeveloperName == 'Stakeholders') {
            return getMapMemberScoreFromPlanForMetadata(accountPlan, metadata);
        }
        Double count = getCountForPlanForMetadata(accountPlan, metadata);
        if (count == -1) {
            return -1;
        }
        Double points = getPointsForMetadata(metadata, count);
        Double multiplier = getMultiplierForPlanForMetadata(accountPlan, metadata);
        return points * multiplier;
    }

    public Double getScoreFromPlanForMetadataPercent(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        if (accountPlan == null || metadata == null) {
            return -1;
        }
        if (metadata.DeveloperName == 'Stakeholders') {
            return getMapMemberScoreFromPlanForMetadataPercent(accountPlan, metadata);
        }
        Double points = getCountForPlanForMetadata(accountPlan, metadata);
        if (points < 0) {
            return 0;
        }
        //return points;
        Double multiplier = 1;
        if (metadata.Use_Time_Decay__c) {
        	multiplier = getMultiplierForPlanForMetadata(accountPlan, metadata);
        }
        return points * multiplier;
    }

    public Double getMapMemberScoreFromPlanForMetadata(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        if (accountPlan == null || metadata == null || metadata.DeveloperName != 'Stakeholders') {
            return -1;
        }
        Double count = metadata.Score_Field_API_Name__c == 'pqcrush__Key_Stakeholder_Count__c'
            ? RelationshipMapService.getMapMemberCountForAccountPlan(new List<Account_Plan__c>{ accountPlan })
            : getCountForPlanForMetadata(accountPlan, metadata);
        if (count == -1) {
            return -1;
        }
        Double points = getPointsForMetadata(metadata, count);
        Double multiplier = 1;
        if (metadata.Use_Time_Decay__c) {
            multiplier = getMultiplierForPlanForScoreMetadata(accountPlan, metadata);
        }
        return points * multiplier;
    }

    public Double getMapMemberScoreFromPlanForMetadataPercent(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        if (accountPlan == null || metadata == null || metadata.DeveloperName != 'Stakeholders') {
            return -1;
        }
        Double points = metadata.Score_Field_API_Name__c == 'pqcrush__Key_Stakeholder_Count__c'
            ? RelationshipMapService.getMapMemberCountForAccountPlan(new List<Account_Plan__c>{ accountPlan })
            : getCountForPlanForMetadata(accountPlan, metadata);
        if (points < 0) {
            return 0;
        }

        Double multiplier = 1;
        if (metadata.Use_Time_Decay__c) {
             multiplier = getMultiplierForPlanForScoreMetadata(accountPlan, metadata);
         }
        return points * multiplier;
    }

    private Double getCountForPlanForMetadata(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        if (accountPlan == null || metadata == null) {
            return -1;
        }
        Double count = 0;
        try {
            Object value = accountPlan?.get(metadata.Score_Field_API_Name__c);
            count = Double.valueOf(value);
        } catch (Exception e) {
            return -1;
        }
        return count;
    }

    private Double getMultiplierForPlanForMetadata(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        if (accountPlan == null || metadata == null) {
            return 1;
        }
        Double multiplier = 1;
        Object dateObj = metadata.Date_Field_API_Name__c != null &&
            accountPlan.getPopulatedFieldsAsMap().containsKey(metadata.Date_Field_API_Name__c)
            ? accountPlan.get(metadata.Date_Field_API_Name__c)
            : null;
        if (metadata.Use_Time_Decay__c && dateObj != null) {
            try {
                Date decayDate = Date.valueOf(dateObj);
                Integer days = decayDate.daysBetween(Date.today());
                multiplier = getTimeDecayMultiplier(metadata, days);
            } catch (Exception e) {
                multiplier = 1;
            }
        }
        return multiplier;
    }

    private Double getMultiplierForPlanForScoreMetadata(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        if (accountPlan == null || metadata == null) {
            return 1;
        }
        Double multiplier = 1;
        if (metadata.Date_Field_API_Name__c == 'pqcrush__KS_Max_LMD__c') {
            Date lastModifiedDate = RelationshipMapService.getMapMemberLastUpdatedDateForAccountPlan(
                new List<Account_Plan__c>{ accountPlan }
            );
            if (lastModifiedDate != null) {
                Integer days = lastModifiedDate.daysBetween(Date.today());
                multiplier = getTimeDecayMultiplier(metadata, days);
            }
        } else {
            multiplier = getMultiplierForPlanForMetadata(accountPlan, metadata);
        }
        return multiplier;
    }

    private Double getPointsForMetadata(PQ_AP_Score__mdt metadata, Double count) {
        if (count < metadata.Count_BP_Low__c) {
            return 0;
        }
        if (count < metadata.Count_BP_Mid__c) {
            return metadata.Score_BP_Low__c;
        }
        if (count < metadata.Count_BP_High__c) {
            return metadata.Score_BP_Mid__c;
        }
        return metadata.Score_BP_High__c;
    }

    private Double getTimeDecayMultiplier(PQ_AP_Score__mdt metadata, Integer days) {
        if (days < metadata.Time_BP_Low__c) {
            return 1;
        }
        if (days < metadata.Time_BP_Mid__c) {
            return metadata.Time_BP_Mult_Low__c;
        }
        if (days < metadata.Time_BP_High__c) {
            return metadata.Time_BP_Mult_Mid__c;
        }
        return metadata.Time_BP_Mult_High__c;
    }
}