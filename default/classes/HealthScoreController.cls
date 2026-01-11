public with sharing class HealthScoreController {
    private static final Map<String, String> LABEL_MAP = new Map<String, String>{
        'CS_Cells' => String.format(System.label.Score_Label, new List<String>{ System.Label.Cross_Sell_Map }),
        'Key_Dates' => String.format(System.label.Score_Label, new List<String>{ System.Label.Key_Dates_r }),
        'Stakeholders' => String.format(System.label.Score_Label, new List<String>{ System.Label.Key_Stakeholders_r }),
        'Objective' => String.format(System.label.Score_Label, new List<String>{ System.Label.Objectives_r }),
        'AP_Opp' => String.format(
            System.label.Score_Label,
            new List<String>{ System.Label.Account_Plan_Opportunities_r }
        ),
        'SWOT' => String.format(System.label.Score_Label, new List<String>{ System.Label.SWOT_Analysis_r })
    };

    private static final Set<String> SCORE_FIELDS = new Set<String>{
        /*Account_Plan__c.Account_Plan_Score_Percent__c.getDescribe().getName(),
         Account_Plan__c.Intermediate_Score_Percent__c.getDescribe().getName(),*/
        Account_Plan__c.Account_Plan_Score__c.getDescribe().getName(),
        Account_Plan__c.Intermediate_Score__c.getDescribe().getName()
    };

    @AuraEnabled
    public static ColorBoundary getColorSettings() {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();
        return HealthScoreService.getColorBoundaryFromSettings(settings);
    }

    @AuraEnabled
    public static CRUSH_Settings_Obj__c updateColorSettings(ColorBoundary colorSettings) {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();
        if (colorSettings == null) {
            return settings;
        }
        settings.Score_Low_Color__c = colorSettings.lowColor;
        settings.Score_Mid_Color__c = colorSettings.midColor;
        settings.Score_High_Color__c = colorSettings.highColor;
        settings.Score_Low_Mid_Boundary__c = colorSettings.lowMidBoundary;
        settings.Score_Mid_High_Boundary__c = colorSettings.midHighBoundary;
        SettingService.upsertSettings(settings);
        return settings;
    }

    @AuraEnabled
    public static HealthScoreWrapper getTotalHealthScoreForAccountPlan(Id accountPlanId) {
        if (accountPlanId == null) {
            return null;
        }
        List<PQ_AP_Score__mdt> allMetadata = HealthScoreService.getValidScoreMetadata();
        Set<String> fieldNames = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(allMetadata);
        if (fieldNames.size() == 0) {
            return null;
        }
        fieldNames.addAll(SCORE_FIELDS);
        Account_Plan__c plan = (Account_Plan__c) DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account_Plan__c.getSObjectType(),
            accountPlanId,
            fieldNames
        );
        if (plan == null) {
            return null;
        }
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();
        updateScoreForAccountPlanForScore(plan, settings, allMetadata);
        ColorBoundary cb = HealthScoreService.getColorBoundaryFromSettings(settings);
        Decimal points = plan.Account_Plan_Score__c;
        Decimal maxPoints = HealthScoreService.getMaxTotalScore();
        HealthScoreWrapper score = new HealthScoreWrapper();
        score.id = 'pq_score_total_id';
        score.points = points;
        score.maxPoints = maxPoints;
        score.label = System.label.Account_Plan_Score;
        score.color = colorForScore(points, maxPoints, cb);
        return score;
    }

    @AuraEnabled
    public static HealthScoreWrapper getTotalHealthScoreForAccountPlanPercent(Id accountPlanId) {
        if (accountPlanId == null) {
            return null;
        }
        List<PQ_AP_Score__mdt> allMetadata = HealthScoreService.getValidScoreMetadata();
        Set<String> fieldNames = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(allMetadata);
        if (fieldNames.size() == 0) {
            return null;
        }
        fieldNames.addAll(SCORE_FIELDS);
        Account_Plan__c plan = (Account_Plan__c) DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account_Plan__c.getSObjectType(),
            accountPlanId,
            fieldNames
        );
        if (plan == null) {
            return null;
        }
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();
        updateScoreForAccountPlanForPercent(plan, settings, allMetadata);
        ColorBoundary cb = HealthScoreService.getColorBoundaryFromSettings(settings);
        Decimal points = plan.Account_Plan_Score__c;
        //Decimal points = (plan.Intermediate_Score__c!=null)?plan.Intermediate_Score__c:0;
        Decimal maxPoints = HealthScoreService.getMaxTotalScorePercent();
        HealthScoreWrapper score = new HealthScoreWrapper();
        score.id = 'pq_score_total_id';
        score.points = points;
        score.maxPoints = maxPoints;
        score.label = System.label.Account_Plan_Score;
        score.color = colorForScore(points, maxPoints, cb);
        return score;
    }

    @AuraEnabled
    public static List<HealthScoreWrapper> getIndividualHealthScoresForAccountPlan(Id accountPlanId) {
        if (accountPlanId == null) {
            return new List<HealthScoreWrapper>();
        }
        List<PQ_AP_Score__mdt> allMetadata = HealthScoreService.getValidScoreMetadata();
        if (allMetadata.size() == 0) {
            return new List<HealthScoreWrapper>();
        }
        Set<String> fieldNames = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(allMetadata);
        if (fieldNames.size() == 0) {
            return new List<HealthScoreWrapper>();
        }
        fieldNames.addAll(SCORE_FIELDS);
        Account_Plan__c plan = (Account_Plan__c) DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account_Plan__c.getSObjectType(),
            accountPlanId,
            fieldNames
        );
        if (plan == null) {
            return new List<HealthScoreWrapper>();
        }
        ColorBoundary settings = getColorSettings();
        List<HealthScoreWrapper> scores = new List<HealthScoreWrapper>();
        for (PQ_AP_Score__mdt metadata : allMetadata) {
            Decimal points = HealthScoreService.getScoreFromPlanForMetadata(plan, metadata);
            Decimal maxPoints = metadata.Score_BP_High__c;
            HealthScoreWrapper score = new HealthScoreWrapper();
            score.id = metadata.Id;
            score.points = points;
            score.maxPoints = maxPoints;
            score.label = getLabelForScoreMetadata(metadata);
            score.color = colorForScore(points, maxPoints, settings);
            scores.add(score);
        }
        return scores;
    }

    @AuraEnabled
    public static List<HealthScoreWrapper> getIndividualHealthScoresForAccountPlanPercent(Id accountPlanId) {
        if (accountPlanId == null) {
            return new List<HealthScoreWrapper>();
        }
        List<PQ_AP_Score__mdt> allMetadata = HealthScoreService.getValidScoreMetadata();
        if (allMetadata.size() == 0) {
            return new List<HealthScoreWrapper>();
        }
        Set<String> fieldNames = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(allMetadata);
        if (fieldNames.size() == 0) {
            return new List<HealthScoreWrapper>();
        }
        fieldNames.addAll(SCORE_FIELDS);
        Account_Plan__c plan = (Account_Plan__c) DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account_Plan__c.getSObjectType(),
            accountPlanId,
            fieldNames
        );
        if (plan == null) {
            return new List<HealthScoreWrapper>();
        }
        ColorBoundary settings = getColorSettings();
        List<HealthScoreWrapper> scores = new List<HealthScoreWrapper>();
        for (PQ_AP_Score__mdt metadata : allMetadata) {
            Decimal points = HealthScoreService.getScoreFromPlanForMetadataPercent(plan, metadata);
            Decimal thresholdLimit = (metadata.Threshold_Limit__c != null)
                ? metadata.Threshold_Limit__c
                : metadata.Score_BP_High__c;

            Decimal categoryPointTotal = (metadata.Category_Point_Total__c != null)
                ? metadata.Category_Point_Total__c
                : (metadata.Threshold_Limit__c != null) ? metadata.Threshold_Limit__c : metadata.Score_BP_High__c;

            points = points < thresholdLimit ? points : thresholdLimit;

            Double percentage = (points / thresholdLimit) * 100;

            Double pointsAwarded = (percentage / 100) * categoryPointTotal;

            HealthScoreWrapper score = new HealthScoreWrapper();
            score.id = metadata.Id;
            score.points = pointsAwarded;
            score.maxPoints = categoryPointTotal;
            score.label = getLabelForScoreMetadata(metadata);
            score.color = colorForScore(pointsAwarded, categoryPointTotal, settings);
            scores.add(score);
        }
        return scores;
    }
    private static void updateScoreForAccountPlanForScore(
        Account_Plan__c plan,
        CRUSH_Settings_Obj__c settings,
        List<PQ_AP_Score__mdt> allMetadata
    ) {
        if (settings.Use_Default_Account_Plan_Score__c != null && settings.Use_Default_Account_Plan_Score__c) {
            Double updatedScore = HealthScoreService.getTotalScoreForAccountPlan(plan, allMetadata);
            if (updatedScore != plan.Intermediate_Score__c) {
                plan.Intermediate_Score__c = updatedScore;
                plan.Default_Plan_Scoring__c = true;
                fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(
                    new fflib_SObjectUnitOfWork.SimpleDML()
                );
                uow.registerDirty(plan);
                new SystemContext().commitWork(uow);
                Formula.recalculateFormulas(new List<Account_Plan__c>{ plan });
            }
        }
    }

    private static void updateScoreForAccountPlanForPercent(
        Account_Plan__c plan,
        CRUSH_Settings_Obj__c settings,
        List<PQ_AP_Score__mdt> allMetadata
    ) {
        if (
            settings.pqcrush__Use_Percentage_Account_Plan_Score__c != null &&
            settings.pqcrush__Use_Percentage_Account_Plan_Score__c
        ) {
            Double updatedScore = HealthScoreService.getTotalScoreForAccountPlanPercent(plan, allMetadata);
            if (updatedScore != plan.Intermediate_Score__c) {
                plan.Intermediate_Score__c = updatedScore;
                plan.Default_Plan_Scoring__c = false;
                fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(
                    new fflib_SObjectUnitOfWork.SimpleDML()
                );
                uow.registerDirty(plan);
                new SystemContext().commitWork(uow);
                Formula.recalculateFormulas(new List<Account_Plan__c>{ plan });
            }
        }
    }

    private static String getLabelForScoreMetadata(PQ_AP_Score__mdt metadata) {
        if (!String.isBlank(metadata.Score_Label__c)) {
            return metadata.Score_Label__c;
        }
        if (LABEL_MAP.containsKey(metadata.DeveloperName)) {
            return LABEL_MAP.get(metadata.DeveloperName);
        }
        return metadata.Label;
    }

    private static String colorForScore(Decimal points, Decimal maxPoints, ColorBoundary bounds) {
        Decimal score = points / maxPoints;
        if (score < bounds.lowMidBoundary) {
            return bounds.lowColor;
        }
        if (score < bounds.midHighBoundary) {
            return bounds.midColor;
        }
        return bounds.highColor;
    }

    public with sharing class HealthScoreWrapper {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public Decimal points { get; set; }
        @AuraEnabled
        public Decimal maxPoints { get; set; }
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String color { get; set; }
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}