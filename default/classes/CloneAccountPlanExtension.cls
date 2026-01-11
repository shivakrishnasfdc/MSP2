@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class CloneAccountPlanExtension {
    // List of objects that will not appear on the Cloning UI, but will be included in cloning the KS Map
    private Set<String> keyStakeholderSubObjects = new Set<String>{
        pqcrush__Contact_Relationship__c.SObjectType.getDescribe().getName(),
        pqcrush__Key_Stakeholder_Lead__c.SObjectType.getDescribe().getName(),
        pqcrush__Map_Member_Placeholder__c.SObjectType.getDescribe().getName(),
        pqcrush__Map_Member_Placeholder_Relationship__c.SObjectType.getDescribe().getName(),
        pqcrush__Map_Member_User__c.SObjectType.getDescribe().getName(),
        pqcrush__pq_Account_Plan_Matrix_Association__c.SObjectType.getDescribe().getName(),
        pqcrush__Relationship_Group__c.SObjectType.getDescribe().getName(),
        pqcrush__RM_Anchor__c.SObjectType.getDescribe().getName(),
        pqcrush__RM_Chart_Setting__c.SObjectType.getDescribe().getName(),
        pqcrush__RM_Node_Coordinate__c.SObjectType.getDescribe().getName(),
        pqcrush__RM_Svg_Account_Plan_Association__c.SObjectType.getDescribe().getName(),
        pqcrush__Relationship_Type_Account_Plan_Assoc__c.SObjectType.getDescribe().getName(),
        pqcrush__RM_Svg_Node_Association__c.SObjectType.getDescribe().getName(),
        pqcrush__Key_Stakeholder__c.SObjectType.getDescribe().getName()
    };

    private ApexPages.StandardController sc;

    // Labels for selection option in the Cloning UI
    private Map<String, String> customLabelMap = new Map<String, String>{
        AccountPlanCloneService.ACCOUNT_PLAN_OPPORTUNITIES_RELATIONSHIP_NAME => Label.pqcrush.Account_Plan_Opportunities_r,
        AccountPlanCloneService.KEY_DATES_RELATIONSHIP_NAME => Label.pqcrush.Key_Dates_r,
        AccountPlanCloneService.RELATIONSHIP_MAP_RELATIONSHIP_NAME => Label.pqcrush.Key_Stakeholders_r,
        AccountPlanCloneService.OBJECTIVES_RELATIONSHIP_NAME => Label.pqcrush.Objectives_r,
        AccountPlanCloneService.SWOT_ANALYSIS_RELATIONSHIP_NAME => Label.pqcrush.SWOT_Analysis_r,
        AccountPlanCloneService.TEAM_MEMBERS_RELATIONSHIP_NAME => Label.pqcrush.Team_Members_r,
        AccountPlanCloneService.WHITE_SPACE_RELATIONSHIP_NAME => Label.pqcrush.Cross_Sell_Map
    };

    public String[] selectedFields { get; set; }

    public CloneAccountPlanExtension(ApexPages.StandardController standardController) {
        standardController.addFields(new List<String>{ 'Name', 'pqcrush__Account__c', 'OwnerId' });
        sc = standardController;
        Account_Plan__c plan = (Account_Plan__c) sc.getRecord();
        plan.OwnerId = UserInfo.getUserId();
        selectedFields = new List<String>{};
    }

    public Pagereference clonePlan() {
        Account_Plan__c plan = (Account_Plan__c) sc.getRecord();
        AccountPlanCloneWrapper wrapper = new AccountPlanCloneWrapper(
            plan.Id,
            plan.Name,
            plan.OwnerId,
            plan.Account__c,
            selectedFields
        );
        List<AccountPlanCloneWrapper> wrappers = new List<AccountPlanCloneWrapper>{ wrapper };
        List<Account_Plan__c> clonedPlans = AccountPlanCloneService.cloneAccountPlans(wrappers);
        if (clonedPlans.size() == 0) {
            return null;
        } else if (plan.OwnerId == UserInfo.getUserId()) {
            return new Pagereference('/' + clonedPlans[0].Id);
        } else {
            Schema.DescribeSObjectResult result = Account_Plan__c.SObjectType.getDescribe();
            return new Pagereference('/' + result.getKeyPrefix() + '/o');
        }
    }

    public Boolean getIsClassic() {
        return (UserInfo.getUiThemeDisplayed() == 'Theme3');
    }

    public List<SelectOption> getRelatedObjects() {
        List<Schema.ChildRelationship> relationships = Schema.SObjectType.Account_Plan__c.getChildRelationships();
        List<SelectOption> options = new List<SelectOption>();
        Map<String, SelectOption> optionMap = new Map<String, SelectOption>();
        List<String> orderList = new List<String>();
        List<String> searchRelationships = new List<String>();
        Set<String> relationshipNames = new Set<String>();
        for (Schema.ChildRelationship relationship : relationships) {
            if (!isRelationshipClonable(relationship)) {
                continue;
            }
            String relationshipName = relationship.getRelationshipName();
            if (relationshipNames.contains(relationshipName)) {
                continue;
            }
            relationshipNames.add(relationshipName);
            String displayLabel = customLabelMap.get(relationshipName);
            if (displayLabel == null) {
                displayLabel = relationship.getChildSObject().getDescribe().getLabelPlural();
            }
            searchRelationships.add('(SELECT Id FROM ' + relationshipName + ')');
            orderList.add(displayLabel);
            SelectOption option = new SelectOption(relationshipName, displayLabel);
            optionMap.put(displayLabel, option);
        }
        orderList.sort();
        Map<String, Object> queryFields = getAllRelationshipFieldsForQueries(searchRelationships);
        for (String key : orderList) {
            SelectOption option = optionMap.get(key);
            String relationship = option.getValue();
            Object obj = queryFields.get(relationship);
            if (obj != null && ((obj instanceof List<Object>) == false || !((List<Object>) obj).isEmpty())) {
                options.add(option);
            }
        }
        return options;
    }

    private Boolean isRelationshipClonable(Schema.ChildRelationship relationship) {
        if (relationship.getRelationshipName() == null) {
            return false;
        }
        Schema.DescribeSObjectResult childObjectDescribe = relationship.getChildSObject().getDescribe();
        if (!isObjectAccessClonable(childObjectDescribe)) {
            return false;
        }
        if (childObjectDescribe.getName().contains('__Share')) {
            return false;
        }
        if (isObjectSpecialCase(childObjectDescribe)) {
            return false;
        }

        return true;
    }

    private boolean isObjectAccessClonable(Schema.DescribeSObjectResult childObjectDescribe) {
        if (
            childObjectDescribe.isSearchable() == false &&
            childObjectDescribe.getName().contains('pqcrush__') == false
        ) {
            return false;
        }
        if (childObjectDescribe.isCreateable() == false) {
            return false;
        }
        if (childObjectDescribe.isQueryable() == false) {
            return false;
        }
        if (childObjectDescribe.isAccessible() == false) {
            return false;
        }
        return true;
    }

    private boolean isObjectSpecialCase(Schema.DescribeSObjectResult childObjectDescribe) {
        if (childObjectDescribe.getName() == 'EntitySubscription' && !Application.isChatterEnabled()) {
            //EntitySubscription only exists if chatter is enabled, but packages know about it even with chatter disabled
            return true;
        }
        if (childObjectDescribe.getName() == 'TaskRelation') {
            //TaskRelation is a system generated class, cannot access in object manager to set up for clone, throws an error if trying to clone it.
            return true;
        }
        if (keyStakeholderSubObjects.contains(childObjectDescribe.getName())) {
            //These sub objects are handled internally in clone logic
            return true;
        }
        return false;
    }

    private Map<String, Object> getAllRelationshipFieldsForQueries(List<String> relationshipQueries) {
        Map<String, Object> allRelationshipFields = new Map<String, Object>();
        Id recordId = sc.getId(); //NOPMD - False positive, variable used in query
        Integer chunkSize = 20;
        for (Integer i = 0; i < relationshipQueries.size(); i += chunkSize) {
            Integer min = i;
            List<String> chunk = (List<String>) UtilityForList.slice(relationshipQueries, min, chunkSize);
            String allSearch = String.join(chunk, ', ');
            String soql =
                'SELECT Id, ' +
                String.escapeSingleQuotes(allSearch) +
                ' FROM pqcrush__Account_Plan__c WHERE Id = :recordId';
            Account_Plan__c relationCheck = Database.query(soql); //NOPMD
            Map<String, Object> chunkMap = relationCheck.getPopulatedFieldsAsMap();
            allRelationshipFields.putAll(chunkMap);
        }
        return allRelationshipFields;
    }
}