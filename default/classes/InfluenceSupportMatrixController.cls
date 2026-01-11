@SuppressWarnings('PMD.NcssMethodCount,PMD.CyclomaticComplexity')
public with sharing class InfluenceSupportMatrixController {
    @AuraEnabled
    public static List<MatrixMember> getMatrixMembers(Id mapOrAccountPlanId, List<String> additionalFields) {
        if (mapOrAccountPlanId == null) {
            return new List<MatrixMember>();
        }

        Id mapId = mapOrAccountPlanId;

        if (mapOrAccountPlanId.getSobjectType() == Account_Plan__c.getSObjectType()) {
            // TBD Refactor getMapIdForSObjectIdNoCreate to a service
            mapId = RelationshipMapMemberController.getMapIdForSObjectIdNoCreate(mapOrAccountPlanId);
        }

        List<MatrixMember> result = getMatrixMembersByMapId(mapId, additionalFields);

        return result;
    }

    private static List<MatrixMember> getMatrixMembersByMapId(Id mapId, List<String> additionalFields) {
        // Get Object info for Relationship_Map_Member__c
        Map<String, FieldMetaData> descFieldMap = SObjectService.getDescribeFieldMapsForFields(
            Relationship_Map_Member__c.SObjectType,
            additionalFields
        );

        // Retrieve data for Map Members
        List<Relationship_Map_Member__c> rmmList = RelationshipMapMemberSelector.newInstance()
            .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                new Set<Id>{ mapId },
                new Set<String>(descFieldMap.keySet()),
                new Set<String>{ 'Title' }
            );

        Set<Id> contactIds = new Set<Id>();
        Set<String> contactIdStrings = new Set<String>();
        Map<Id, Contact_Extended_Field__c> contactExtMap = new Map<Id, Contact_Extended_Field__c>();
        for (Relationship_Map_Member__c rmm : rmmList) {
            contactIds.add(rmm.Contact__c);
            contactIdStrings.add(rmm.Contact__c);
        }

        // Retrieve hierarchy links
        List<Map_Member_Placeholder_Relationship__c> hierarchyRels = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectHierarchyLinksByPlaceholderId(new Set<Id>{ mapId }, contactIdStrings);

        Set<Id> hierarchyContactIds = new Set<Id>();
        Map<Id, Id> reportsToMap = new Map<Id, Id>();
        for (Map_Member_Placeholder_Relationship__c mmpr : hierarchyRels) {
            hierarchyContactIds.add(mmpr.To__c);
            hierarchyContactIds.add(mmpr.From__c);
            reportsToMap.put(mmpr.To__c, mmpr.From__c);
        }

        hierarchyContactIds.addAll(contactIds);

        // Retrieve data for contacts (so we have contact names for the parents)
        List<Contact> contactList = ContactSelector.newInstance()
            .selectByIdAndSelectFields(hierarchyContactIds, new Set<String>{ 'ReportsToId' });
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Set<Id> parentIds = new Set<Id>();
        for (Contact con : contactList) {
            contactMap.put(con.Id, con);
            if (con.ReportsToId != null) {
                parentIds.add(con.ReportsToId);
            }
        }

        // Retrieve data for parents
        List<Contact> parentList = ContactSelector.newInstance()
            .selectByIdAndSelectFields(parentIds, new Set<String>{ 'ReportsToId' });

        for (Contact con : parentList) {
            contactMap.put(con.Id, con);
        }

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapId);
        List<MatrixMember> result = new List<MatrixMember>();
        Map<Id, Relationship_Map_Member__c> rmmMap = new Map<Id, Relationship_Map_Member__c>();

        // Loop through Map Members and populate details about it
        for (Relationship_Map_Member__c rmm : rmmList) {
            rmmMap.put(rmm.Id, rmm);
            MatrixMember mem = InfluenceSupportMatrixService.buildMatrixMemberForMapMember(
                rmm,
                descFieldMap,
                setting,
                reportsToMap,
                contactMap
            );
            result.add(mem);
        }

        if (setting.Is_Influence_Support_Global_Scope__c) {
            // Get data for global influence from extendedField
            List<Contact_Extended_Field__c> contactExtFields = ContactExtendedFieldSelector.newInstance()
                .selectByContactId(contactIds);
            for (Contact_Extended_Field__c cef : contactExtFields) {
                contactExtMap.put(cef.Contact__c, cef);
            }

            for (MatrixMember mem : result) {
                Contact_Extended_Field__c contactExtField = contactExtMap.get(mem.personId);
                mem.influence = contactExtField?.Influence__r?.Label__c;
                mem.support = contactExtField?.Support__r?.Label__c;
            }
        } else {
            for (MatrixMember mem : result) {
                mem.influence = mem.influenceOverrideValue;
                mem.support = mem.supportOverrideValue;
            }
        }


        return result;
    }

    private static List<MatrixMember> getMatrixMembersByAccountPlanId(Id accountPlanId, List<String> additionalFields) {
        Map<String, FieldMetaData> descFieldMap = SObjectService.getDescribeFieldMapsForFields(
            Key_Stakeholder__c.SObjectType,
            additionalFields
        );

        // Retrieve data for Map Members
        List<Key_Stakeholder__c> ksList = KeyStakeholderSelector.newInstance()
            .selectByAccountPlanIdForYourContactsAndSelectFields(
                new Set<Id>{ accountPlanId },
                new Set<String>(descFieldMap.keySet()),
                new Set<String>{ 'Title' }
            );

        Set<Id> contactIds = new Set<Id>();
        Set<String> contactIdStrings = new Set<String>();
        Map<Id, Contact_Extended_Field__c> contactExtMap = new Map<Id, Contact_Extended_Field__c>();
        for (Key_Stakeholder__c rmm : ksList) {
            contactIds.add(rmm.Contact__c);
            contactIdStrings.add(rmm.Contact__c);
        }

        // Retrieve hierarchy links
        List<Map_Member_Placeholder_Relationship__c> hierarchyRels = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectHierarchyLinksByPlaceholderId(new Set<Id>{ accountPlanId }, contactIdStrings);

        Set<Id> hierarchyContactIds = new Set<Id>();
        Map<Id, Id> reportsToMap = new Map<Id, Id>();
        for (Map_Member_Placeholder_Relationship__c mmpr : hierarchyRels) {
            hierarchyContactIds.add(mmpr.To__c);
            hierarchyContactIds.add(mmpr.From__c);
            reportsToMap.put(mmpr.To__c, mmpr.From__c);
        }

        hierarchyContactIds.addAll(contactIds);

        // Retrieve data for contacts (so we have contact names for the parents)
        List<Contact> contactList = ContactSelector.newInstance()
            .selectByIdAndSelectFields(hierarchyContactIds, new Set<String>{ 'ReportsToId' });
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        Set<Id> parentIds = new Set<Id>();
        for (Contact con : contactList) {
            contactMap.put(con.Id, con);
            if (con.ReportsToId != null) {
                parentIds.add(con.ReportsToId);
            }
        }

        // Retrieve data for parents
        List<Contact> parentList = ContactSelector.newInstance()
            .selectByIdAndSelectFields(parentIds, new Set<String>{ 'ReportsToId' });

        for (Contact con : parentList) {
            contactMap.put(con.Id, con);
        }

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(accountPlanId);
        List<MatrixMember> result = new List<MatrixMember>();
        Map<Id, Key_Stakeholder__c> ksMap = new Map<Id, Key_Stakeholder__c>();

        // Loop through Map Members and populate details about it
        for (Key_Stakeholder__c ks : ksList) {
            // Get additional info and add to list
            ksMap.put(ks.Id, ks);
            MatrixMember mem = InfluenceSupportMatrixService.buildMatrixMemberForKS(
                ks,
                descFieldMap,
                setting,
                reportsToMap,
                contactMap
            );
            result.add(mem);
        }

        if (setting.Is_Influence_Support_Global_Scope__c) {
            // Get data for global influence from extendedField
            List<Contact_Extended_Field__c> contactExtFields = ContactExtendedFieldSelector.newInstance()
                .selectByContactId(contactIds);
            for (Contact_Extended_Field__c cef : contactExtFields) {
                contactExtMap.put(cef.Contact__c, cef);
            }

            for (MatrixMember mem : result) {
                Contact_Extended_Field__c contactExtField = contactExtMap.get(mem.personId);
                mem.influence = contactExtField?.Influence__r?.Name;
                mem.support = contactExtField?.Support__r?.Name;
            }
        }

        return result;
    }
    @AuraEnabled
    public static String getPicklistValues(String objectName, String fieldName) {
        Map<String, String> picklistValuesMap = new Map<String, String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();

        if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
            List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValuesMap.put(entry.getLabel(),entry.getValue());
            }
        }            
        return JSON.serialize(picklistValuesMap);
    }
}