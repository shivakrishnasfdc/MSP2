public with sharing class FieldHistoryController {
    private static final String DOCUMENT_FOLDER = 'CRUSH Icons';

    private static Map<String, Document> documentsByName = new Map<String, Document>();
    private static Map<String, String> documentNameByObject = new Map<String, String>{
        'pqcrush__Account_Plan__c' => 'Account Plan Icon',
        'pqcrush__Account_Plan_Opportunity__c' => 'Opportunity Icon',
        'pqcrush__Key_Date__c' => 'Key Dates Icon',
        'Relationship_Map_Member__c' => 'Relationship Matrix Icon',
        'pqcrush__Objective__c' => 'Objective Icon',
        'pqcrush__Objective_Opportunity__c' => 'Objective Icon',
        'pqcrush__SWOT_Analysis__c' => 'SWOT Matrix Icon',
        'pqcrush__Team_Member__c' => 'Team Member Icon',
        'pqcrush__pq_CRUSH_Plan_Overview__c' => 'Plan Overview Icon'
    };

    private static Map<String, String> colorsByObject = new Map<String, String>{
        'pqcrush__Account_Plan__c' => '#e38e08',
        'pqcrush__Account_Plan_Opportunity__c' => '#03b3ab',
        'pqcrush__Key_Date__c' => '#e10a49',
        'Relationship_Map_Member__c' => '#f88103',
        'pqcrush__Objective__c' => '#0390d7',
        'pqcrush__Objective_Opportunity__c' => '#03b3ab',
        'pqcrush__SWOT_Analysis__c' => '#2b2b24',
        'pqcrush__Team_Member__c' => '#6cb539',
        'pqcrush__pq_CRUSH_Plan_Overview__c' => '#6cb539'
    };

    @AuraEnabled
    public static List<History> getHistoryByAccountPlanId(Id accountPlanId) {
        if (UtilityForSObject.isObjectReadable(Document.sObjectType)) {
            List<Document> documents = DocumentSelector.newInstance()
                .selectByFolderName(new Set<String>{ DOCUMENT_FOLDER });

            for (Document document : documents) {
                documentsByName.put(document.Name, document);
            }
        }

        List<History> result = new List<History>();
        Set<Id> accountPlanIds = new Set<Id>{ accountPlanId };

        List<SObject> accountPlans = AccountPlanSelector.newInstance().selectSObjectsByIdWithHistory(accountPlanIds);
        List<SObject> accountPlanOpportunities = AccountPlanOpportunitySelector.newInstance()
            .selectByAccountPlanIdWithHistory(accountPlanIds, AccountPlanOpportunitySelector.HISTORY_FIELDS);
        List<SObject> keyDates = KeyDateSelector.newInstance().selectByAccountPlanIdWithHistory(accountPlanIds);
        List<SObject> mapMembers = RelationshipMapMemberSelector.newInstance()
            .selectByAccountPlanIdsWithHistory(accountPlanIds, RelationshipMapMemberSelector.HISTORY_FIELDS);
        List<SObject> objectives = ObjectiveSelector.newInstance().selectByAccountPlanIdWithHistory(accountPlanIds);
        List<SObject> objectiveOpportunities = ObjectiveOpportunitySelector.newInstance()
            .selectByAccountPlanIdWithHistory(accountPlanIds, ObjectiveOpportunitySelector.HISTORY_FIELDS);
        List<SObject> planOverview = PlanOverviewSelector.newInstance()
            .selectByAccountPlanIdWithHistory(accountPlanIds);
        List<SObject> swotAnalyses = SWOTAnalysisSelector.newInstance()
            .selectByAccountPlanIdWithHistory(accountPlanIds);
        List<SObject> teamMembers = TeamMemberSelector.newInstance()
            .selectByAccountPlanIdWithHistory(accountPlanIds, TeamMemberSelector.HISTORY_FIELDS);

        result.addAll(getObjectHistories(accountPlans));
        result.addAll(getObjectHistories(accountPlanOpportunities));
        result.addAll(getObjectHistories(keyDates));
        result.addAll(getObjectHistories(mapMembers));
        result.addAll(getObjectHistories(objectives));
        result.addAll(getObjectHistories(objectiveOpportunities));
        result.addAll(getObjectHistories(planOverview));
        result.addAll(getObjectHistories(swotAnalyses));
        result.addAll(getObjectHistories(teamMembers));

        result.sort();
        return result;
    }

    private static List<History> getObjectHistories(List<SObject> objects) {
        List<SObject> histories = new List<SObject>();
        for (SObject iterationObject : objects) {
            if (iterationObject.getSObjects('Histories') != null) {
                histories.addAll((List<SObject>) iterationObject.getSObjects('Histories'));
            }
        }

        List<History> result = new List<History>();
        History tempHistory;
        for (SObject historyObject : histories) {
            tempHistory = new History(historyObject);
            tempHistory.color = colorsByObject.get(tempHistory.parentObjectName);

            Document iconDocument = documentsByName.get(documentNameByObject.get(tempHistory.parentObjectName));

            if (iconDocument != null) {
                tempHistory.iconUrl = '/servlet/servlet.FileDownload?file=' + iconDocument.Id;
            }

            if (!(tempHistory.newValue instanceof Id)) {
                result.add(tempHistory);
            }
        }

        return result;
    }
}