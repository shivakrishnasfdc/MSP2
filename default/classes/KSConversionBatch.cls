@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class KSConversionBatch implements Database.Batchable<SObject> {
    public Integer batchSize = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Query rmQuery = PostInstallHelperService.getQueryForKSMapConversion();
        if (rmQuery == null) {
            return null;
        }
        String queryString = rmQuery.toQueryString();
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<Account_Plan__c> plansToConvert) {
        Application.bypassTrigger = true;

        Map<Id, Id> accountPlanRMMap = createRMForAccountPlans(plansToConvert);

        insert convertKSToRMM(accountPlanRMMap);
        insert convertKSLeadsToRMMLeads(accountPlanRMMap);
        insert convertAPMatrixAssocToRMMatrixAssoc(accountPlanRMMap);
        insert convertAccountPlanSVGAssocToRM(accountPlanRMMap);
        insert convertRMTypeAccountPlansToRM(accountPlanRMMap);

        update updateRelationshipGroups(accountPlanRMMap);
        update updateRMAnchors(accountPlanRMMap);
        update updateMapMemberPlaceholders(accountPlanRMMap);
        update updateMapMemberPlaceholdersRelationships(accountPlanRMMap);
        update updateMapMemberUsers(accountPlanRMMap);
        update updateContactRelationships(accountPlanRMMap);
        update updateRMSvgNodeAssociation(accountPlanRMMap);
        update updateRMChartSettings(accountPlanRMMap);
        update updateRMNodeCoordinates(accountPlanRMMap);

        Application.bypassTrigger = false;
    }

    public void finish(Database.BatchableContext bc) {
    }

    private Map<Id, Id> createRMForAccountPlans(List<Account_Plan__c> plansToConvert) {
        // CREATE RMs For every Account Plans
        List<Relationship_Map__c> newItems = new List<Relationship_Map__c>();
        for (Account_Plan__c ap : plansToConvert) {
            newItems.add(
                new Relationship_Map__c(
                    Name = ap.Name,
                    pq_AccountPlanId__c = ap.Id,
                    Type_Setting__c = 'pqcrush__Account_Plan__c'
                )
            );
        }

        Map<Id, Id> accountPlanRMMap = new Map<Id, Id>();
        // Insert new Relationship Maps
        if (newItems.size() > 0) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Relationship_Map__c.SObjectType }
            );
            uow.registerNew(newItems);
            uow.commitWork();

            for (Relationship_Map__c rm : newItems) {
                accountPlanRMMap.put(rm.pq_AccountPlanId__c, rm.Id);
            }
        }

        return accountPlanRMMap;
    }

    // Converts Key Stakeholders to Relationship Map Members
    private List<Relationship_Map_Member__c> convertKSToRMM(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<Relationship_Map_Member__c> newItems = new List<Relationship_Map_Member__c>();
        for (Key_Stakeholder__c currentItem : [
            SELECT Id, Account_Plan__c, Contact__c, InfluenceId__c, SupportId__c
            FROM Key_Stakeholder__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            Relationship_Map_Member__c newItem = new Relationship_Map_Member__c(
                Contact__c = currentItem.Contact__c,
                Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c),
                InfluenceId__c = currentItem.InfluenceId__c,
                SupportId__c = currentItem.SupportId__c,
                Original_Key_Stakeholder__c = currentItem.Id
            );
            newItems.add(newItem);
        }

        return newItems;
    }

    // Converts Key Stakeholder Leads to Relationship Map Member Leads
    private List<Map_Member_Lead__c> convertKSLeadsToRMMLeads(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<Map_Member_Lead__c> newItems = new List<Map_Member_Lead__c>();
        for (Key_Stakeholder_Lead__c currentItem : [
            SELECT Id, Account_Plan__c, Lead__c
            FROM Key_Stakeholder_Lead__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            Map_Member_Lead__c newItem = new Map_Member_Lead__c(
                Lead__c = currentItem.Lead__c,
                Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c),
                Original_Key_Stakeholder_Lead__c = currentItem.Id
            );
            newItems.add(newItem);
        }

        // Insert new Relationship Map Members
        return newItems;
    }

    // Account Plan Matrix Association => RM Matrix Association
    private List<pq_Relationship_Map_Matrix_Association__c> convertAPMatrixAssocToRMMatrixAssoc(
        Map<Id, Id> accountPlanRMMap
    ) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<pq_Relationship_Map_Matrix_Association__c> newItems = new List<pq_Relationship_Map_Matrix_Association__c>();
        for (pq_Account_Plan_Matrix_Association__c currentItem : [
            SELECT Id, Account_Plan__c, Influence_And_Support_Matrix__c
            FROM pq_Account_Plan_Matrix_Association__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            pq_Relationship_Map_Matrix_Association__c newItem = new pq_Relationship_Map_Matrix_Association__c(
                Influence_And_Support_Matrix__c = currentItem.Influence_And_Support_Matrix__c,
                Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c)
            );
            newItems.add(newItem);
        }

        return newItems;
    }

    private List<RM_Svg_Map_Association__c> convertAccountPlanSVGAssocToRM(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<RM_Svg_Map_Association__c> newItems = new List<RM_Svg_Map_Association__c>();
        for (RM_Svg_Account_Plan_Association__c currentItem : [
            SELECT Id, Account_Plan__c, RM_Svg__c
            FROM RM_Svg_Account_Plan_Association__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            RM_Svg_Map_Association__c newItem = new RM_Svg_Map_Association__c(
                RM_Svg__c = currentItem.RM_Svg__c,
                Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c)
            );
            newItems.add(newItem);
        }

        return newItems;
    }

    // Convert Relationship Type Associations from Account Plan to Relationship Maps
    private List<Relationship_Type_Map_Association__c> convertRMTypeAccountPlansToRM(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<Relationship_Type_Map_Association__c> newItems = new List<Relationship_Type_Map_Association__c>();
        for (Relationship_Type_Account_Plan_Assoc__c rmTypeAssoc : [
            SELECT Id, Account_Plan__c, Relationship_Type__c
            FROM Relationship_Type_Account_Plan_Assoc__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            Id rmId = accountPlanRMMap.get(rmTypeAssoc.Account_Plan__c);
            if (rmId != null) {
                Relationship_Type_Map_Association__c newAssoc = new Relationship_Type_Map_Association__c(
                    Relationship_Map__c = rmId,
                    Relationship_Type__c = rmTypeAssoc.Relationship_Type__c
                );
                newItems.add(newAssoc);
            }
        }

        return newItems;
    }

    // Update Relationshp Groups
    private List<Relationship_Group__c> updateRelationshipGroups(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<Relationship_Group__c> updateItems = new List<Relationship_Group__c>();
        for (Relationship_Group__c rmGroup : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM Relationship_Group__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            rmGroup.Relationship_Map__c = accountPlanRMMap.get(rmGroup.Account_Plan__c);
            updateItems.add(rmGroup);
        }

        return updateItems;
    }

    // Update Anchors
    private List<RM_Anchor__c> updateRMAnchors(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<RM_Anchor__c> updateItems = new List<RM_Anchor__c>();
        for (RM_Anchor__c rmAnchor : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM RM_Anchor__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            rmAnchor.Relationship_Map__c = accountPlanRMMap.get(rmAnchor.Account_Plan__c);
            updateItems.add(rmAnchor);
        }

        return updateItems;
    }

    // Update Map Member Placeholders
    private List<Map_Member_Placeholder__c> updateMapMemberPlaceholders(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<Map_Member_Placeholder__c> updateItems = new List<Map_Member_Placeholder__c>();
        for (Map_Member_Placeholder__c mmph : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM Map_Member_Placeholder__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            mmph.Relationship_Map__c = accountPlanRMMap.get(mmph.Account_Plan__c);
            updateItems.add(mmph);
        }

        return updateItems;
    }

    // Update Map Member Placeholders Relationships
    private List<Map_Member_Placeholder_Relationship__c> updateMapMemberPlaceholdersRelationships(
        Map<Id, Id> accountPlanRMMap
    ) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<Map_Member_Placeholder_Relationship__c> updateItems = new List<Map_Member_Placeholder_Relationship__c>();
        for (Map_Member_Placeholder_Relationship__c currentItem : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            currentItem.Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c);
            updateItems.add(currentItem);
        }

        return updateItems;
    }

    // Update Map Member Placeholders Relationships
    private List<Map_Member_User__c> updateMapMemberUsers(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<Map_Member_User__c> updateItems = new List<Map_Member_User__c>();
        for (Map_Member_User__c currentItem : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM Map_Member_User__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            currentItem.Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c);
            updateItems.add(currentItem);
        }

        return updateItems;
    }

    // Update Contact Relationships
    private List<Contact_Relationship__c> updateContactRelationships(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<Contact_Relationship__c> updateItems = new List<Contact_Relationship__c>();
        for (Contact_Relationship__c currentItem : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM Contact_Relationship__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            currentItem.Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c);
            updateItems.add(currentItem);
        }

        return updateItems;
    }

    // Update RM SVG Node Associations
    private List<RM_Svg_Node_Association__c> updateRMSvgNodeAssociation(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<RM_Svg_Node_Association__c> updateItems = new List<RM_Svg_Node_Association__c>();
        for (RM_Svg_Node_Association__c currentItem : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM RM_Svg_Node_Association__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            currentItem.Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c);
            updateItems.add(currentItem);
        }

        return updateItems;
    }

    // Update ChartSettings
    private List<RM_Chart_Setting__c> updateRMChartSettings(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<RM_Chart_Setting__c> updateItems = new List<RM_Chart_Setting__c>();
        for (RM_Chart_Setting__c item : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM RM_Chart_Setting__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            item.Relationship_Map__c = accountPlanRMMap.get(item.Account_Plan__c);
            updateItems.add(item);
        }

        return updateItems;
    }

    // Update RM Node Coordinates
    private List<RM_Node_Coordinate__c> updateRMNodeCoordinates(Map<Id, Id> accountPlanRMMap) {
        Set<Id> accountPlanIds = accountPlanRMMap.keySet();
        List<RM_Node_Coordinate__c> updateItems = new List<RM_Node_Coordinate__c>();
        for (RM_Node_Coordinate__c currentItem : [
            SELECT Id, Account_Plan__c, Relationship_Map__c
            FROM RM_Node_Coordinate__c
            WHERE Account_Plan__c IN :accountPlanIds
        ]) {
            currentItem.Relationship_Map__c = accountPlanRMMap.get(currentItem.Account_Plan__c);
            updateItems.add(currentItem);
        }

        return updateItems;
    }
}