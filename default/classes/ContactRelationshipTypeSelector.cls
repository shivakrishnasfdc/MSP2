public with sharing class ContactRelationshipTypeSelector extends fflib_SObjectSelector {
    private static Map<Id, Set<Id>> selectJunctionCache = new Map<Id, Set<Id>>();

    public static ContactRelationshipTypeSelector newInstance() {
        return (ContactRelationshipTypeSelector) Application.Selector.newInstance(
            Contact_Relationship_Type__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Contact_Relationship_Type__c.Id,
            Contact_Relationship_Type__c.Name,
            Contact_Relationship_Type__c.IsActive__c,
            Contact_Relationship_Type__c.Label__c,
            Contact_Relationship_Type__c.Label_Editable__c,
            Contact_Relationship_Type__c.Color__c,
            Contact_Relationship_Type__c.Used_in_all_account_plans__c,
            Contact_Relationship_Type__c.Used_in_all_relationship_maps__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Contact_Relationship_Type__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Contact_Relationship_Type__c> selectAll() {
        return Database.query(newQueryFactory().setCondition('IsActive__c = true').toSOQL());
    }

    public List<Contact_Relationship_Type__c> selectByRelationshipMaps(
        Set<Id> relationshipMapIdSet,
        Boolean hasAccountPlanSetting,
        Id accountPlanId
    ) {
        List<Relationship_Type_Map_Association__c> relTypeAssociations = Database.query(
            'select Relationship_Type__c from Relationship_Type_Map_Association__c where Relationship_Map__c in :relationshipMapIdSet'
        );
        Set<Id> idSet = new Set<Id>();
        for (Relationship_Type_Map_Association__c relTypeAssociation : relTypeAssociations) {
            idSet.add(relTypeAssociation.Relationship_Type__c);
        }

        if (accountPlanId != null) {
            List<Relationship_Type_Account_Plan_Assoc__c> relTypeAPAssociations = Database.query(
                'select Relationship_Type__c from Relationship_Type_Account_Plan_Assoc__c where Account_Plan__c = :accountPlanId'
            );

            for (Relationship_Type_Account_Plan_Assoc__c relTypeAPAssociation : relTypeAPAssociations) {
                idSet.add(relTypeAPAssociation.Relationship_Type__c);
            }
        }

        String condition1 = 'IsActive__c = true AND (Used_in_all_relationship_maps__c = true OR id in :idSet)';
        if (hasAccountPlanSetting) {
            condition1 = 'IsActive__c = true AND (Used_in_all_account_plans__c = true OR id in :idSet)';
        }

        return Database.query(newQueryFactory().setCondition(condition1).toSOQL());
    }

    public List<Contact_Relationship_Type__c> selectByAccountPlans(Set<Id> accountPlanIdSet) {
        List<Relationship_Type_Account_Plan_Assoc__c> relTypeAssociations = Database.query(
            'select Relationship_Type__c from Relationship_Type_Account_Plan_Assoc__c where Account_Plan__c in :accountPlanIdSet'
        );
        Set<Id> idSet = new Set<Id>();
        for (Relationship_Type_Account_Plan_Assoc__c relTypeAssociation : relTypeAssociations) {
            idSet.add(relTypeAssociation.Relationship_Type__c);
        }

        return Database.query(
            newQueryFactory()
                .setCondition('IsActive__c = true AND (Used_in_all_account_plans__c = true OR id in :idSet)')
                .toSOQL()
        );
    }

    public Set<Id> getRelationshipTypesFromJunction(Id maporAccountPlanId) {
        if (selectJunctionCache.containsKey(maporAccountPlanId)) {
            return selectJunctionCache.get(maporAccountPlanId);
        }
        Set<Id> relTypeIds = new Set<Id>();

        if (mapOrAccountPlanId.getSobjectType() == Relationship_Map__c.getSObjectType()) {
            List<Relationship_Map__c> maps = Database.query(
                'select Id, pq_AccountPlanId__c from Relationship_Map__c where Id = :maporAccountPlanId'
            );

            if (maps != null && maps.size() > 0 && maps[0].pq_AccountPlanId__c != null) {
                Id accountPlanId = maps[0].pq_AccountPlanId__c; // NOPMD
                // GET RELATIONSHIP TYPES RELATED TO THE ACCOUNT PLAN
                List<Relationship_Type_Account_Plan_Assoc__c> acctPlanAssociations = Database.query(
                    'SELECT Relationship_Type__c FROM pqcrush__Relationship_Type_Account_Plan_Assoc__c where Account_Plan__c = :accountPlanId'
                );
                for (Relationship_Type_Account_Plan_Assoc__c acctPlanAssociation : acctPlanAssociations) {
                    relTypeIds.add(acctPlanAssociation.Relationship_Type__c);
                }
            }

            // GET RELATIONSHIP TYPES RELATED TO THE RELATIONSHIP MAP
            List<Relationship_Type_Map_Association__c> mapAssociations = Database.query(
                'SELECT Relationship_Type__c FROM pqcrush__Relationship_Type_Map_Association__c where Relationship_Map__c = :mapOrAccountPlanId'
            );
            for (Relationship_Type_Map_Association__c mapAssociation : mapAssociations) {
                relTypeIds.add(mapAssociation.Relationship_Type__c);
            }
            selectJunctionCache.put(maporAccountPlanId, relTypeIds);
            return relTypeIds;
        } else if (mapOrAccountPlanId.getSobjectType() == Account_Plan__c.getSObjectType()) {
            // GET RELATIONSHIP TYPES RELATED TO THE ACCOUNT PLAN
            List<Relationship_Type_Account_Plan_Assoc__c> accountPlanAssociations = Database.query(
                'SELECT Relationship_Type__c FROM pqcrush__Relationship_Type_Account_Plan_Assoc__c where Account_Plan__c = :mapOrAccountPlanId'
            );
            for (Relationship_Type_Account_Plan_Assoc__c accountPlanAssociation : accountPlanAssociations) {
                relTypeIds.add(accountPlanAssociation.Relationship_Type__c);
            }
            selectJunctionCache.put(maporAccountPlanId, relTypeIds);
            return relTypeIds;
        }

        selectJunctionCache.put(maporAccountPlanId, relTypeIds);
        return relTypeIds;
    }
}