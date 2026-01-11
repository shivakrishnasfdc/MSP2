public with sharing class RelationshipLineWrapperServiceImpl {
    /******************************
     *      PUBLIC METHODS
     ******************************/

    public Map<Id, String> getNodeNames(
        List<Contact_Relationship__c> contactRelList,
        List<Map_Member_Placeholder_Relationship__c> mapMemberList
    ) {
        Set<Id> idSet = new Set<Id>();

        for (Map_Member_Placeholder_Relationship__c mmpr : mapMemberList) {
            idSet.add((Id) mmpr.To__c);
            idSet.add((Id) mmpr.From__c);
        }

        List<User> users = UsersSelector.newInstance().selectById(idSet);
        List<Lead> leads = LeadSelector.newInstance().selectById(idSet);
        List<Map_Member_Placeholder__c> placeholders = MapMemberPlaceHolderSelector.newInstance().selectById(idSet);
        List<Relationship_Group__c> relGroups = RelationshipGroupSelector.newInstance().selectById(idSet);

        Map<Id, String> mapNodeNames = new Map<Id, String>();
        for (User user : users) {
            mapNodeNames.put(user.Id, user.FirstName + ' ' + user.LastName);
        }
        for (Lead lead : leads) {
            mapNodeNames.put(lead.Id, lead.FirstName + ' ' + lead.LastName);
        }
        for (Map_Member_Placeholder__c placeholder : placeholders) {
            mapNodeNames.put(placeholder.Id, placeholder.Label__c);
        }
        for (Relationship_Group__c relGroup : relGroups) {
            mapNodeNames.put(relGroup.Id, relGroup.Label__c);
        }

        Set<Id> contactIdSet = new Set<Id>();

        for (Contact_Relationship__c cr : contactRelList) {
            contactIdSet.add((Id) cr.To_Contact__c);
            contactIdSet.add((Id) cr.From_Contact__c);
        }

        List<Contact> allContacts = ContactSelector.newInstance().selectById(contactIdSet);
        for (Contact c : allContacts) {
            mapNodeNames.put(c.Id, c.Name);
        }

        return mapNodeNames;
    }

    public Map<String, List<CommonRelationshipLineObject>> organizeMemberList(
        Id contactId,
        List<Map_Member_Placeholder_Relationship__c> mapMemberList,
        List<Contact_Relationship__c> contactRelList
    ) {
        Map<String, List<CommonRelationshipLineObject>> mapByContainerId = new Map<String, List<CommonRelationshipLineObject>>();

        mapByContainerId = processMapMembers(contactId, mapMemberList, mapByContainerId);
        mapByContainerId = processContactRelationships(contactId, contactRelList, mapByContainerId);

        return mapByContainerId;
    }

    private Map<String, List<CommonRelationshipLineObject>> processMapMembers(
        Id contactId,
        List<Map_Member_Placeholder_Relationship__c> mapMemberList,
        Map<String, List<CommonRelationshipLineObject>> mapByContainerId
    ) {
        for (Map_Member_Placeholder_Relationship__c mmpr : mapMemberList) {
            String key;
            String containerName;
            Boolean isGlobal = false;
            if (mmpr.Relationship_Map__c != null) {
                containerName = mmpr.Relationship_Map__r.Name;
                key = mmpr.Relationship_Map__c;
            } else if (mmpr.Account_Plan__c != null) {
                containerName = mmpr.Account_Plan__r.Name;
                key = mmpr.Account_Plan__c;
            } else {
                // Global Relationships
                key = '__global';
                containerName = System.Label.Global_Relationships;
                isGlobal = true;
            }

            Id nodeKey;
            if (mmpr.To__c == contactId && mmpr.From__c != contactId) {
                nodeKey = (Id) mmpr.From__c;
            } else if (mmpr.To__c != contactId && mmpr.From__c == contactId) {
                nodeKey = (Id) mmpr.To__c;
            }

            CommonRelationshipLineObject newCommonRL = new CommonRelationshipLineObject(
                mmpr.Id,
                mmpr.Relationship_Map__c,
                mmpr.Account_Plan__c,
                containerName,
                nodeKey,
                HierarchyHelperService.getLabelForRelationship(mmpr),
                mmpr.Contact_Relationship_Type__r.Color__c,
                isGlobal
            );

            if (mapByContainerId.containsKey(key)) {
                List<CommonRelationshipLineObject> mList = mapByContainerId.get(key);
                mList.add(newCommonRL);
                mapByContainerId.put(key, mList);
            } else {
                mapByContainerId.put(key, new List<CommonRelationshipLineObject>{ newCommonRL });
            }
        }

        return mapByContainerId;
    }

    private Map<String, List<CommonRelationshipLineObject>> processContactRelationships(
        Id contactId,
        List<Contact_Relationship__c> contactRelList,
        Map<String, List<CommonRelationshipLineObject>> mapByContainerId
    ) {
        for (Contact_Relationship__c cr : contactRelList) {
            String key;
            String containerName;
            Boolean isGlobal = false;
            if (cr.Relationship_Map__c != null) {
                key = cr.Relationship_Map__c;
                containerName = cr.Relationship_Map__r.Name;
            } else if (cr.Account_Plan__c != null) {
                key = cr.Account_Plan__c;
                containerName = cr.Account_Plan__r.Name;
            } else {
                key = '__global';
                containerName = System.Label.Global_Relationships;
                isGlobal = true;
            }

            Id nodeKey;
            if (cr.To_Contact__c == contactId && cr.From_Contact__c != contactId) {
                nodeKey = cr.From_Contact__c;
            } else if (cr.To_Contact__c != contactId && cr.From_Contact__c == contactId) {
                nodeKey = cr.To_Contact__c;
            }

            CommonRelationshipLineObject newCommonRL = new CommonRelationshipLineObject(
                cr.Id,
                cr.Relationship_Map__c,
                cr.Account_Plan__c,
                containerName,
                nodeKey,
                HierarchyHelperService.getLabelForRelationship(cr),
                cr.Contact_Relationship_Type__r.Color__c,
                isGlobal
            );

            if (mapByContainerId.containsKey(key)) {
                List<CommonRelationshipLineObject> mList = mapByContainerId.get(key);
                mList.add(newCommonRL);
                mapByContainerId.put(key, mList);
            } else {
                mapByContainerId.put(key, new List<CommonRelationshipLineObject>{ newCommonRL });
            }
        }

        return mapByContainerId;
    }
}