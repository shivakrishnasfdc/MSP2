public with sharing class RelationshipMapSelector extends fflib_SObjectSelector {
    private static Map<Set<Id>, List<Relationship_Map__c>> selectByIdcache = new Map<Set<Id>, List<Relationship_Map__c>>();
    public RelationshipMapSelector() {
        super(false, true, false);
    }

    public static RelationshipMapSelector newInstance() {
        return (RelationshipMapSelector) Application.Selector.newInstance(Relationship_Map__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Relationship_Map__c.Id,
            Relationship_Map__c.Name,
            Relationship_Map__c.pq_AccountPlanId__c,
            Relationship_Map__c.pq_Opportunity_Plan__c,
            Relationship_Map__c.Map_Member_Count__c,
            Relationship_Map__c.Map_Member_Max_Modified_Date__c,
            Relationship_Map__c.Type_Setting__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Relationship_Map__c.sObjectType;
    }

    public override String getOrderBy() {
        String userSetting = 'CreatedDate DESC';
        Schema.DescribeFieldResult fieldResult = pqcrush__pq_CRUSH_User_Setting__c.pqcrush__Account_Plan_Sort__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList) {
            if (p.isDefaultValue()) {
                userSetting = p.getValue();
            }
        }
        List<pqcrush__pq_Crush_User_Setting__c> userSettings = CrushUserSettingSelector.newInstance()
            .selectForCurrentUser();
        if (userSettings != null && userSettings.size() > 0) {
            if (userSettings[0].pqcrush__Account_Plan_Sort__c != null) {
                userSetting = userSettings[0].pqcrush__Account_Plan_Sort__c;
            }
        }
        return userSetting;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Relationship_Map__c> selectByIds(Set<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            return new List<Relationship_Map__c>();
        }
        if (selectByIdcache.containsKey(ids)) {
            return selectByIdcache.get(ids);
        }
        List<Relationship_Map__c> result = (List<Relationship_Map__c>) selectSObjectsById(ids);
        selectByIdcache.put(ids, result);
        System.debug('==selectByIds result==='+result);
        return result;
    }

    public List<Relationship_Map__c> selectAll() {
        return Database.query(newQueryFactory().toSOQL());
    }

    public List<Relationship_Map__c> selectByAccountPlanIds(Set<Id> accountPlanIds) {
        if (accountPlanIds == null || accountPlanIds.isEmpty()) {
            return new List<Relationship_Map__c>();
        }
        return Database.query(newQueryFactory().setCondition('pq_AccountPlanId__c IN :accountPlanIds').toSOQL());
    }

    public List<Relationship_Map__c> selectByAccountPlanIdsData(Set<Id> accountPlanIds) {
        String sortOrd = 'CreatedDate ASC';
        if (accountPlanIds == null || accountPlanIds.isEmpty()) {
            return new List<Relationship_Map__c>();
        } else {
            List<pq_CRUSH_Account_Plan_User_Setting__c> settings = AccountPlanUserSettingSelector.newInstance()
                .selectByAccPlanID(accountPlanIds);

            if (settings.size() > 0) {
                sortOrd = settings[0].pqcrush__Account_Plan_RM_Sort__c;
            }
        }
        List<String> orderByParts = sortOrd.trim().split(' ');
        String fieldNamePart = orderByParts[0];
        String fieldSortOrderPart = orderByParts.size() > 1 ? orderByParts[1] : null;
        fflib_QueryFactory.SortOrder sortOrder = fieldSortOrderPart == 'ASC'
            ? fflib_QueryFactory.SortOrder.ASCENDING
            : fflib_QueryFactory.SortOrder.DESCENDING;

        return Database.query(
            newQueryFactory()
                .setCondition('pq_AccountPlanId__c IN :accountPlanIds')
                .setOrdering(fieldNamePart, sortOrder)
                .toSOQL()
        );
    }

    public List<Relationship_Map__c> selectByOppPlanIds(Set<Id> oppPlanIds) {
        if (oppPlanIds == null || oppPlanIds.isEmpty()) {
            return new List<Relationship_Map__c>();
        }
        return Database.query(newQueryFactory().setCondition('pq_Opportunity_Plan__c IN :oppPlanIds').toSOQL());
    }
}